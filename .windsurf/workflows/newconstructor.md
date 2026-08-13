---
description: Create a new constructor for an ABL class
---

# Create a New Constructor

This workflow helps you create either a default constructor or an overloaded constructor for an ABL class.

## Steps

1. **Determine Constructor Type**
   - Ask: "Do you want to create a default constructor or an overloaded constructor?"
   - Options: "default" or "overloaded"

2. **For Default Constructor**
   - If "default" is selected, create a simple constructor with no parameters:
   ```abl
   CONSTRUCTOR PUBLIC ClassName():
       SUPER().
   END CONSTRUCTOR.
   ```

3. **For Overloaded Constructor**
   - If "overloaded" is selected, ask: "What parameters do you want for the constructor?"
   - Expected format: "paramName AS dataType, paramName2 AS dataType2, ..."
   - Example: "name AS CHARACTER, age AS INTEGER, isActive AS LOGICAL"

4. **Analyze Class Properties**
   - Examine the current class file to identify existing properties
   - Look for property definitions (DEFINE PUBLIC PROPERTY, GET/SET blocks)
   - Extract property names and their data types

5. **Match Parameters to Properties**
   - Compare constructor parameters with class properties
   - For each parameter that matches a property name and type:
     - Generate assignment code: `THIS-OBJECT:PropertyName = parameterName.`
   - For parameters that don't match properties, include them as regular parameters

6. **Generate Constructor Code**
   - Create the constructor signature with all specified parameters
   - Include SUPER() call at the beginning
   - Add property assignments for matching parameters
   - Format the complete constructor block

7. **Insert Constructor**
   - Add the generated constructor code to the class file
   - Place it in an appropriate location (typically after property definitions)
   - Ensure proper indentation and formatting

## Example Output

For a class with properties `Name` (CHARACTER) and `Age` (INTEGER), and constructor parameters "name AS CHARACTER, age AS INTEGER, department AS CHARACTER":

```abl
CONSTRUCTOR PUBLIC ClassName(name AS CHARACTER, age AS INTEGER, department AS CHARACTER):
    SUPER().
    
    /* Assign matching properties */
    THIS-OBJECT:Name = name.
    THIS-OBJECT:Age = age.
    
    /* department parameter doesn't match any property, so it's available for custom logic */
    
END CONSTRUCTOR.
```

## Notes

- Always include SUPER() call at the beginning of the constructor
- Use THIS-OBJECT: prefix when assigning to properties
- Parameter names should be in camelCase, property names in PascalCase
- Add comments to distinguish between property assignments and other parameters
