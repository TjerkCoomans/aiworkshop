# ABL Business Entity Pattern

This document describes the "Business Entity" architectural pattern found in
this codebase, as opposed to legacy direct database access. Use this as a
reference checklist when refactoring legacy ABL windows/procedures (e.g.
`ItemWin.w`-style code) into the modern pattern.

Reference implementation: `src/business/CustomerEntity.cls`,
`src/business/EntityFactory.cls`, `src/business/CustomerDataset.i`,
`src/CustomerWin.w`.

## 1. Overview

The pattern separates UI code from data access/business logic through three
collaborating pieces:

1. **Business Entity** (`*Entity.cls`) - one class per business
   object/table group. Inherits from `OpenEdge.BusinessLogic.BusinessEntity`
   and encapsulates all reads, writes, and validation for that entity.
2. **Dataset include** (`*Dataset.i`) - defines the `TEMP-TABLE`
   (with a `BEFORE-TABLE` for change tracking) and the `DATASET` that the
   entity exposes to callers.
3. **Entity Factory** (`EntityFactory.cls`) - a singleton factory that lazily
   creates and hands out singleton instances of each Business Entity, so the
   UI never calls `NEW SomeEntity()` directly.

The UI (`*.w` window/procedure) only ever talks to the Factory and the
Entity's public dataset methods. It never issues `FIND`/`FOR EACH` against
database tables directly, and never writes to the database directly.

## 2. Business Entity class

```
CLASS business.CustomerEntity INHERITS BusinessEntity USE-WIDGET-POOL:

    {business/CustomerDataset.i}

    DEFINE DATA-SOURCE srcCustomer FOR Customer.

    CONSTRUCTOR PUBLIC CustomerEntity():
        SUPER(DATASET dsCustomer:HANDLE).

        VAR HANDLE[1] hDataSourceArray = DATA-SOURCE srcCustomer:HANDLE.
        VAR CHARACTER[1] cSkipListArray = [""].

        THIS-OBJECT:ProDataSource = hDataSourceArray.
        THIS-OBJECT:SkipList = cSkipListArray.
    END CONSTRUCTOR.
    ...
END CLASS.
```

Key rules:

- Inherit `OpenEdge.BusinessLogic.BusinessEntity`; pass the dataset handle to
  `SUPER()`.
- Declare one `DEFINE DATA-SOURCE src<Entity> FOR <DbTable>.` per underlying
  database table in the dataset.
- In the constructor, build the `ProDataSource` array (one handle per
  temp-table/data-source pair) and `SkipList` array (parallel array of
  skip-list strings, `""` when none), then assign them to
  `THIS-OBJECT:ProDataSource` / `THIS-OBJECT:SkipList`. This wiring is what
  lets the inherited CRUD methods move data between the temp-table and the
  database automatically.
- All read methods build a `WHERE`-clause filter string and call the
  inherited `THIS-OBJECT:ReadData(cFilter)` - never `FIND`/`FOR EACH`
  directly against the DB table inside the entity's public API surface for
  reads driven by user input.
- All write methods delegate to the inherited base methods:
  `CreateData(DATASET ... BY-REFERENCE)`, `UpdateData(...)`,
  `DeleteData(...)`. The entity's `CreateCustomer`/`UpdateCustomer`/
  `DeleteCustomer` wrapper methods exist mainly to give callers a
  domain-named API and a seam for adding entity-specific logic later.
- Return a `LOGICAL` "found"/"success" indicator from query methods by
  checking `CAN-FIND(FIRST tt<Entity>)` (or `AVAILABLE`) after the read, so
  callers don't need to know temp-table internals.
- Validation lives in the entity (e.g. `ValidateCustomer`), taking the
  dataset `INPUT-OUTPUT BY-REFERENCE` plus an `OUTPUT errorMessage AS
  CHARACTER`, returning `LOGICAL isValid`. This keeps business rules out of
  the UI layer.
- `FIND FIRST/NEXT` on the **temp-table** (not the DB table) is fine inside
  entity methods that need to inspect already-loaded rows.

## 3. Dataset include (`*Dataset.i`)

```
DEFINE TEMP-TABLE ttCustomer BEFORE-TABLE bttCustomer
    FIELD CustNum AS INTEGER INITIAL "0" LABEL "Cust Num"
    ...
    INDEX CustNum IS PRIMARY UNIQUE CustNum ASCENDING.

DEFINE DATASET dsCustomer FOR ttCustomer.
```

- Always define a `BEFORE-TABLE` buffer alongside the temp-table - this is
  required for `TRACKING-CHANGES` to work when the UI edits rows before
  calling `UpdateCustomer`.
- Give the temp-table a primary unique index matching the DB table's key.
- The dataset (`DEFINE DATASET ds<Entity> FOR tt<Entity>.`) is the single
  contract exposed to the UI and factory; for multi-table entities it can
  span multiple temp-tables plus `DATA-RELATION`s.
- Field names/types can differ slightly from the DB table (e.g. renamed
  fields) - the `ProDataSource` mapping still transfers data as long as
  field names line up or are mapped explicitly.

## 4. Entity Factory (singleton pattern)

```
CLASS business.EntityFactory USE-WIDGET-POOL:

    VAR PRIVATE STATIC EntityFactory objInstance.
    VAR PRIVATE CustomerEntity objCustomerEntityInstance.

    CONSTRUCTOR PRIVATE EntityFactory():
    END CONSTRUCTOR.

    METHOD PUBLIC STATIC business.EntityFactory GetInstance():
        IF objInstance = ? THEN
            objInstance = NEW business.EntityFactory().
        RETURN objInstance.
    END METHOD.

    METHOD PUBLIC CustomerEntity GetCustomerEntity():
        IF objCustomerEntityInstance = ? THEN
            objCustomerEntityInstance = NEW CustomerEntity().
        RETURN objCustomerEntityInstance.
    END METHOD.

    METHOD PUBLIC VOID ResetInstances():
        IF VALID-OBJECT(objCustomerEntityInstance) THEN
            DELETE OBJECT objCustomerEntityInstance.
        objCustomerEntityInstance = ?.
    END METHOD.
END CLASS.
```

- `CONSTRUCTOR PRIVATE` prevents direct instantiation of the factory.
- `GetInstance()` is `PUBLIC STATIC` and lazily creates the singleton
  factory (`IF objInstance = ? THEN NEW ...`).
- Each business entity gets its own `PRIVATE VAR` instance field and a
  `Get<Entity>Entity()` accessor that lazily instantiates it the same way.
  Add one pair (field + getter) per new entity type.
- Provide a `ResetInstances()` method to clean up/`DELETE OBJECT` entity
  singletons (useful for tests or explicit teardown).

## 5. UI usage pattern (`*.w`)

```
VAR EntityFactory objFactory         = EntityFactory:GetInstance().
VAR CustomerEntity objCustomerEntity = objFactory:GetCustomerEntity().
VAR LOGICAL lCustomerFound           = objCustomerEntity:GetCustomerByNumber(iCustomerNumber, OUTPUT DATASET dsCustomer).

IF lCustomerFound THEN DO:
    FIND FIRST ttCustomer.
    ...
END.
ELSE
    MESSAGE "Customer not found" VIEW-AS ALERT-BOX.
```

Reads:
1. Get the factory singleton: `EntityFactory:GetInstance()`.
2. Get the entity singleton from the factory: `objFactory:Get<Entity>Entity()`.
3. Call a domain-named query method (`GetCustomerByNumber`, `GetCustomerByName`,
   ...) passing an `OUTPUT DATASET`; check the returned `LOGICAL` found flag.
4. `FIND FIRST/NEXT` on the temp-table to read result rows into the UI.

Updates:
1. `FIND FIRST tt<Entity>` on the already-loaded dataset.
2. Turn on change tracking: `TEMP-TABLE tt<Entity>:TRACKING-CHANGES = TRUE.`
   **before** mutating any field - otherwise the base class can't compute a
   diff to send to the database.
3. Assign new field values directly on the temp-table buffer.
4. Call the entity's `Validate<Entity>(DATASET ... BY-REFERENCE, OUTPUT
   errorMessage)`.
5. If valid, call `Update<Entity>(DATASET ... BY-REFERENCE)` to persist;
   otherwise show `errorMessage` to the user.

The UI never issues `FIND`/`FOR EACH ... EXCLUSIVE-LOCK` against database
tables, never assigns DB fields directly, and never contains SQL/ABL query
building logic - all of that lives in the entity.

## 6. Anti-pattern: direct database access (legacy, avoid)

`src/ItemWin.w` shows the pattern to migrate *away from*:

```
FIND FIRST Item WHERE Item.ItemNum = INTEGER(FILL-IN_ItemNum) NO-LOCK NO-ERROR.
IF AVAILABLE Item THEN
    FILL-IN_Price = Item.Price.
...
FIND FIRST Item WHERE Item.ItemNum = INTEGER(FILL-IN_ItemNum) EXCLUSIVE-LOCK NO-ERROR.
IF AVAILABLE Item THEN DO:
    Item.Price = FILL-IN_Price.
END.
```

Problems with this style that the Business Entity pattern fixes:
- UI code queries and locks the database table directly (`FIND ...
  NO-LOCK`/`EXCLUSIVE-LOCK`), coupling the window to schema/table names.
- No shared, reusable validation layer - business rules (e.g. price > 0,
  max on-hand value) are inlined in the UI trigger.
- No change tracking / structured update path - fields are assigned
  directly on the DB buffer while it's exclusively locked.
- No factory/singleton management of query objects - every trigger
  re-queries from scratch with hand-rolled `FIND` statements.
- Not reusable from other UIs, services, or tests without duplicating the
  `FIND`/assignment logic.

## 7. Refactoring checklist

When converting a legacy window like `ItemWin.w` to this pattern:

- [ ] Create `business/<Entity>Dataset.i` with a `TEMP-TABLE tt<Entity>
  BEFORE-TABLE btt<Entity>`, matching fields/index, and a `DEFINE DATASET
  ds<Entity> FOR tt<Entity>.`
- [ ] Create `business/<Entity>Entity.cls` inheriting `BusinessEntity`,
  `{business/<Entity>Dataset.i}` include, `DEFINE DATA-SOURCE` per DB table,
  constructor wiring `ProDataSource`/`SkipList`.
- [ ] Add query methods (`Get<Entity>By...`) using `ReadData(cFilter)` and
  returning `LOGICAL` found flags.
- [ ] Add `Create<Entity>`/`Update<Entity>`/`Delete<Entity>` wrappers around
  `CreateData`/`UpdateData`/`DeleteData`.
- [ ] Add a `Validate<Entity>` method encapsulating business rules
  previously inlined in UI triggers (e.g. the price/on-hand checks in
  `ItemWin.w`).
- [ ] Register the new entity in `EntityFactory.cls`: add a private instance
  var and a `Get<Entity>Entity()` lazy accessor; include it in
  `ResetInstances()`.
- [ ] Update the `.w` triggers to: get factory -> get entity -> call query
  method with `OUTPUT DATASET` -> `FIND FIRST/NEXT` on temp-table -> for
  updates, enable `TRACKING-CHANGES`, assign temp-table fields, call
  `Validate...`, then `Update...`.
- [ ] Remove all direct `FIND ... OF <DbTable>`, `EXCLUSIVE-LOCK`, and direct
  DB field assignment from the `.w` file.
