---
description: Add a new method to an existing ABL class
package: business.logic
---

# New Method Addition Workflow

## Package: `business.logic`

This workflow is part of the `business.logic` package, which contains core business logic components for the application. Methods added using this workflow should follow the package's conventions and standards.

## Package-Level Guidelines

1. **Naming Conventions**
   - Use descriptive, action-oriented names (e.g., `CalculateTotal`, `ValidateOrder`)
   - Follow the pattern: `Verb` + `Noun` + `[Qualifier]`
   - Use PascalCase for method names

2. **Access Control**
   - Default to `PROTECTED` for internal methods
   - Use `PUBLIC` only for methods that are part of the public API
   - Mark implementation details as `PRIVATE`

3. **Documentation**
   - Include package name in method documentation
   - Reference related methods in the same package
   - Document any package-level assumptions or requirements

## Adding a New Method to the Current ABL Class

This workflow will add a new method to the currently focused ABL class in Windsurf. You'll need to provide the following information:

1. **Method Name**: Name of the new method
2. **Return Type**: Data type the method returns (use "VOID" if none)
3. **Access Modifier**: PUBLIC, PROTECTED, or PRIVATE
4. **Parameters**: Comma-separated list of parameters in format "name AS type, ..."
5. **Method Body**: The implementation code for the method

## Interactive Steps

1. **Determine Method Name**
   - Enter a descriptive name for your method (e.g., `GetCustomerName`, `CalculateTotal`)
   - Follow ABL naming conventions (PascalCase for method names)

2. **Select Return Type**
   - Choose from common ABL data types:
     - CHARACTER: For text values
     - INTEGER: For whole numbers
     - DECIMAL: For numbers with decimal places
     - LOGICAL: For true/false values
     - HANDLE: For object handles
     - DATASET-HANDLE: For dataset handles
     - VOID: For methods that don't return a value
     - Class name: For returning object instances

3. **Select Method Access Level**
   - PUBLIC: Accessible from anywhere
   - PROTECTED: Accessible only from the class and its subclasses
   - PACKAGE-PRIVATE: Accessible only from classes in the same package (default if none specified)
   - PACKAGE-PROTECTED: Accessible from the same package and subclasses
   - PRIVATE: Accessible only from within the class

4. **Define Parameters**
   - Enter parameters in the format: `parameterName AS dataType`
   - Separate multiple parameters with commas
   - Example: `piCustNum AS INTEGER, pcName AS CHARACTER`
   - Leave blank if no parameters are needed

5. **Method Implementation**
   - Provide the method body code
   - Include necessary variable declarations
   - Add proper error handling
   - Document complex logic with comments

## Steps to Add a Method

1. First, let's verify the current file is an ABL class:
   ```
   // turbo
   run_command --CommandLine "if (Test-Path -Path '${Env:Windsurf_ActiveDocumentPath}' -Include '*.cls') { exit 0 } else { exit 1 }" --Blocking true --SafeToAutoRun true
   ```

2. View the class file to determine the best location for the new method:
   ```
   view_file --AbsolutePath "${Env:Windsurf_ActiveDocumentPath}" --StartLine 0 --EndLine 200 --IncludeSummaryOfOtherLines true
   ```

3. Add the new method using the following template. The method will be added at the end of the class, before the END CLASS statement:
   ```
   // turbo
   run_command --CommandLine "$content = Get-Content -Path '${Env:Windsurf_ActiveDocumentPath}' -Raw; $newMethod = @'
   /*------------------------------------------------------------------------------
       Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   METHOD {AccessModifier} {ReturnType} {MethodName} ({Parameters}):
   
       {MethodBody}
   
       /* Example implementation */
       /* DEFINE VARIABLE hBuffer AS HANDLE NO-UNDO. */
       
       /* Add your implementation here */
       
       /* Example return for non-void methods */
       /* RETURN ''. */
   END METHOD. /* {MethodName} */
   
'@; $content -replace '(?s)(?=END CLASS\.\s*\z)', $newMethod | Set-Content -Path '${Env:Windsurf_ActiveDocumentPath}'" --Blocking true --SafeToAutoRun false
   ```

4. After adding the method, verify the class compiles:
   ```
   // turbo
   run_command --CommandLine "proenv && prolint -g ${Env:Windsurf_ActiveDocumentPath}" --Cwd (Split-Path -Parent ${Env:Windsurf_ActiveDocumentPath}) --Blocking true --SafeToAutoRun true
   ```

## Package Structure

Methods should be organized within the following package structure:

```
business/                 # Root package for all business logic
  logic/                   # Core business logic components
    customer/             # Customer-related functionality
    order/                # Order processing
    inventory/            # Inventory management
  services/               # Service layer components
  entities/               # Business entities
```

## Package-Level Guidelines

1. **Naming Conventions**
   - Use descriptive, action-oriented names (e.g., `CalculateTotal`, `ValidateOrder`)
   - Follow the pattern: `Verb` + `Noun` + `[Qualifier]`
   - Use PascalCase for method names

2. **Access Control**
   - Default to `PROTECTED` for internal methods
   - Use `PUBLIC` only for methods that are part of the public API
   - Mark implementation details as `PRIVATE`

3. **Documentation**
   - Include package name in method documentation
   - Reference related methods in the same package
   - Document any package-level assumptions or requirements

## Best Practices

- Group related methods together in the class
- Use PascalCase for method names
- Document all parameters and return values
- Include parameter validation
- Use named buffers for database access
- Implement proper error handling
- Consider thread safety for shared resources
- Keep methods focused on a single responsibility
- Use FINALLY blocks for cleanup code
- Follow the project's coding standards for variable naming and formatting

## Example Usage

To add a public method `GetCustomerName` that returns a character string and takes an integer customer ID:

1. Open the class file where you want to add the method in Windsurf
2. Run the `/newmethod` command
3. Provide the following details when prompted:
   - Method Name: `GetCustomerName`
   - Return Type: `CHARACTER`
   - Access Modifier: `PUBLIC`
   - Parameters: `piCustNum AS INTEGER`
   - Method Body:
     ```
     DEFINE VARIABLE cName AS CHARACTER NO-UNDO.
     
     FIND FIRST Customer NO-LOCK
          WHERE Customer.CustNum = piCustNum
          NO-ERROR.
          
     IF AVAILABLE Customer THEN
         cName = Customer.Name.
         
     RETURN cName.
     ```

## Example

For a method that retrieves a customer's name by ID:

```abl
/*------------------------------------------------------------------------------
    Purpose:  Returns the name of the customer with the specified ID
    Notes:    Returns an empty string if the customer is not found
    @param piCustomerId INTEGER - The ID of the customer to look up
    @return CHARACTER - The name of the customer or empty string if not found
------------------------------------------------------------------------------*/
METHOD PROTECTED CHARACTER GetCustomerName(piCustomerId AS INTEGER):
    
    DEFINE BUFFER bCustomer FOR Customer.
    DEFINE VARIABLE cName AS CHARACTER NO-UNDO.
    
    FIND FIRST bCustomer NO-LOCK
         WHERE bCustomer.CustNum = piCustomerId
         NO-ERROR.
         
    IF AVAILABLE bCustomer THEN
        cName = bCustomer.Name.
        
    RETURN cName.
    
END METHOD. /* GetCustomerName */
```
