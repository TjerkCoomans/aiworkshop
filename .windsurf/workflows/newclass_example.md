---
description: Create a new ABL class
---

# New ABL Class Creation Workflow

This workflow guides you through creating a new ABL class with proper structure, including inheritance and interface implementation.

## Steps

1. **Determine Class Name**
   - Choose a descriptive name for your class
   - Follow ABL naming conventions (typically PascalCase)

2. **Select Package Location**
   - Decide which package/directory the class should be placed in
   - Options include:
     - Existing package (e.g., `business`)
     - Root project directory
     - New package

3. **Choose Inheritance**
   - Determine which class to inherit from
   - Common options:
     - `BusinessEntity` for data access classes
     - `Progress.Lang.Object` for basic classes
     - Custom abstract classes
   - No inheritance is also an option

4. **Select Interfaces to Implement**
   - Decide which interfaces the class should implement
   - Can be standard interfaces or custom interfaces
   - No interfaces is also an option

5. **Generate Class Structure**
   - Create file with appropriate header
   - Add required USING statements
   - Define class with inheritance and USE-WIDGET-POOL
   - Add placeholder for dataset definition if needed
   - Add constructor with appropriate super() call
   - Add placeholder methods for:
     - Data access (Read, Create, Update, Delete)
     - Validation
     - Business logic

6. **Implementation Details**
   - Implement required methods from parent class
   - Implement interface methods if applicable
   - Add custom methods as needed
   - Define properties with appropriate VAR statements
   - Follow ABL OO syntax patterns:
     - `VAR [access-mode] [STATIC] type variable.`

## Example Class Structure

```
/*------------------------------------------------------------------------
  File        : MyNewClass
  Purpose     : Business Entity class
  Syntax      : 
  Description : 
  Author(s)   : 
  Created     : [Current Date]
  Notes       : 
----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.BusinessLogic.BusinessEntity.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS package.MyNewClass INHERITS BusinessEntity USE-WIDGET-POOL:
    
    /* Include dataset definition if needed */
    /* {path/to/dataset.i} */
    
    /* Define data sources */
    /* DEFINE DATA-SOURCE srcExample FOR ExampleTable. */
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for MyNewClass
     Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC MyNewClass():
        /* Call the parent constructor with appropriate dataset handle */
        /* SUPER(DATASET dsExample:HANDLE). */
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Example method
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID ExampleMethod():
        /* Method implementation */
    END METHOD.
    
END CLASS.
```

## Best Practices

- Always use the USE-WIDGET-POOL option when defining a class
- Define datasets statically whenever possible
- Pass datasets by reference to methods when possible
- Make sure public methods don't need class context
- Always reference database tables using a locally defined named buffer
- Consider using tracking-changes when updating data in a temp-table
