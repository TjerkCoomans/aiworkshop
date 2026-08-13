---
description: Add a new property to an existing class
---

# New Property Addition Workflow

This workflow guides you through adding a new property to the currently open ABL class, following best practices and proper ABL syntax. All necessary code will be generated and inserted into the open class file.

## Interactive Steps

1. **Determine Property Name**
   - Enter a descriptive name for your property (e.g., customerName, orderTotal, isActive)
   - Follow ABL naming conventions (typically camelCase for properties)

2. **Select Property Type**
   - Choose from common ABL data types:
     - CHARACTER: For text values
     - INTEGER: For whole numbers
     - DECIMAL: For numbers with decimal places
     - LOGICAL: For true/false values
     - DATE: For date values
     - DATETIME: For date and time values
     - DATETIME-TZ: For date, time and timezone values
     - Class name: For object references (e.g., CustomerEntity)

3. **Select Property Access Level for GET**
   - PUBLIC: Readable from anywhere
   - PROTECTED: Readable only from the class and its subclasses
   - PACKAGE-PROTECTED: Readable from within the class, any class within its package, and from within any subclass
   - PACKAGE-PRIVATE: Readable only from within the class and any class within its package
   - PRIVATE: Readable only from within the class

4. **Select Property Access Level for SET**
   - PUBLIC: Writable from anywhere
   - PROTECTED: Writable only from the class and its subclasses
   - PACKAGE-PROTECTED: Writable from within the class, any class within its package, and from within any subclass
   - PACKAGE-PRIVATE: Writable only from within the class and any class within its package
   - PRIVATE: Writable only from within the class (recommended for encapsulation)
   - NONE: Read-only property (no setter)

5. **Is Property Static?**
   - YES: Property belongs to the class, not instances (use STATIC keyword)
   - NO: Each instance has its own copy of the property (most common)

6. **Need Custom Accessor Logic?**
   - YES: Include custom logic in getter/setter (will use METHOD-based implementation)
   - NO: Use simple property accessors (will use native property syntax)

## Code Generation

Based on your answers, one of the following code patterns will be generated and inserted into the appropriate location in your class:

### Simple Property (No Custom Logic)

```abl
/* [PropertyName] property */
DEFINE [GET-ACCESS-LEVEL] [STATIC] PROPERTY [propertyName] AS [TYPE] 
    GET.
    [SET-ACCESS-LEVEL] SET.
```

For a read-only property:

```abl
/* [PropertyName] property (read-only) */
DEFINE [GET-ACCESS-LEVEL] [STATIC] PROPERTY [propertyName] AS [TYPE] 
    GET.
```

### Property with Custom Logic

```abl
/* [PropertyName] property - private backing field */
VAR PRIVATE [STATIC] [TYPE] m_[propertyName].

/* [PropertyName] property */
DEFINE [GET-ACCESS-LEVEL] [STATIC] PROPERTY [propertyName] AS [TYPE] 
    GET():
        RETURN m_[propertyName].
    END GET.
    [SET-ACCESS-LEVEL] SET(INPUT value AS [TYPE]):
        [VALIDATION_CODE]
        m_[propertyName] = value.
    END SET.
```

## Best Practices

- Group property declarations at the top of the class
- Use ABL's native property syntax for simple properties
- Only use custom accessors when you need validation or special logic
- Consider making properties read-only when appropriate
- Use private setters for properties that should only be modified internally
- Use consistent naming conventions
- Consider using tracking-changes when updating data in a temp-table
- Make sure public methods don't need class context
