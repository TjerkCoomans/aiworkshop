/*------------------------------------------------------------------------
  File        : CustomerEntity
  Purpose     : Business Entity for Customer data access
  Syntax      : 
  Description : 
  Author(s)   : 
  Created     : Tue Apr 15 11:54:46 CEST 2025
  Notes       : 
----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.BusinessLogic.BusinessEntity.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS business.CustomerEntity INHERITS BusinessEntity USE-WIDGET-POOL:
    
    /* Include dataset definition */
    {business/CustomerDataset.i}
    
    /* Define data sources */
    DEFINE DATA-SOURCE srcCustomer FOR Customer.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for CustomerEntity
     Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC CustomerEntity():
        SUPER(DATASET dsCustomer:HANDLE).

        VAR HANDLE[1] hDataSourceArray = DATA-SOURCE srcCustomer:HANDLE.
        VAR CHARACTER[1] cSkipListArray = [""].
        
        /* Data Source for each table in dataset */
        THIS-OBJECT:ProDataSource = hDataSourceArray.
        /* Skip-list entry for each table in dataset */
        THIS-OBJECT:SkipList = cSkipListArray.
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Get customer by name
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL GetCustomerByName(INPUT ipcCustomerName AS CHARACTER, 
                                            OUTPUT DATASET dsCustomer):
        VAR CHARACTER cFilter.
        VAR LOGICAL lFound = FALSE.
        
        /* Build filter for customer name */
        cFilter = "WHERE Customer.Name = '" + ipcCustomerName + "'".
        
        /* Read data using filter */
        THIS-OBJECT:ReadData(cFilter).

        /* Check if customer was found */
        lFound = CAN-FIND(FIRST ttCustomer).
        
        RETURN lFound.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Get customer by customer number
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL GetCustomerByNumber(INPUT ipiCustNum AS INTEGER,
                                              OUTPUT DATASET dsCustomer):
        VAR CHARACTER cFilter.
        VAR LOGICAL lFound = FALSE.
        
        /* Build filter for customer number */
        cFilter = "WHERE Customer.CustNum = " + STRING(ipiCustNum).
        
        /* Read data using filter */
        THIS-OBJECT:ReadData(cFilter).
    
        /* Check if customer was found */
        lFound = CAN-FIND(FIRST ttCustomer).
        
        RETURN lFound.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Create customer data
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID CreateCustomer(INPUT-OUTPUT DATASET dsCustomer):
        /* Create data in database */
        THIS-OBJECT:CreateData(DATASET dsCustomer BY-REFERENCE).
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Update customer data
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID UpdateCustomer(INPUT-OUTPUT DATASET dsCustomer):
        /* Update data in database */
        THIS-OBJECT:UpdateData(DATASET dsCustomer BY-REFERENCE).
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Delete customer data
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID DeleteCustomer(INPUT-OUTPUT DATASET dsCustomer):
        /* Delete data from database */
        THIS-OBJECT:DeleteData(DATASET dsCustomer BY-REFERENCE).
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate customer data
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL ValidateCustomer(INPUT-OUTPUT DATASET dsCustomer,
                                         OUTPUT errorMessage AS CHARACTER):
        VAR LOGICAL isValid = TRUE.
        
        /* Find the first customer in the dataset */
        FIND FIRST ttCustomer NO-ERROR.
        IF AVAILABLE ttCustomer THEN DO:
            /* Validate customer name */
            IF ttCustomer.Name = "" THEN DO:
                isValid = FALSE.
                errorMessage = "Customer name cannot be empty".
            END.
        END.
        
        RETURN isValid.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Find customers with empty names
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL FindCustomersWithEmptyName(OUTPUT DATASET dsCustomer):
        VAR CHARACTER filter.
        VAR LOGICAL found = FALSE.
        
        /* Build filter for empty customer name */
        filter = "WHERE Customer.Name = ''".
        
        /* Read data using filter */
        THIS-OBJECT:ReadData(filter).
        
        /* Check if any customer was found */
        found = CAN-FIND(FIRST ttCustomer).
        
        RETURN found.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Find next customer with empty name
     Notes: Must be called after FindCustomersWithEmptyName
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL FindNextCustomerWithEmptyName(OUTPUT DATASET dsCustomer):
        DEFINE VARIABLE found AS LOGICAL NO-UNDO INIT FALSE.
        
        /* Find the next customer in the temp-table */
        FIND NEXT ttCustomer WHERE ttCustomer.Name = "" NO-ERROR.
        found = AVAILABLE ttCustomer.
        
        RETURN found.
    END METHOD.

END CLASS.
