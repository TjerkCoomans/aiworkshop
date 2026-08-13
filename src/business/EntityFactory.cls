/*------------------------------------------------------------------------
  File        : EntityFactory
  Purpose     : Factory for creating singleton instances of business entities
  Syntax      : 
  Description : Implements the Singleton pattern for business entity classes
  Author(s)   : 
  Created     : Tue Apr 15 12:01:20 CEST 2025
  Notes       : 
----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING business.CustomerEntity.
USING business.EntityFactory.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS business.EntityFactory USE-WIDGET-POOL:
    
    /* Singleton instance of this factory */
    VAR PRIVATE STATIC EntityFactory objInstance.
    
    /* Singleton instances of business entities */
    VAR PRIVATE CustomerEntity objCustomerEntityInstance.
    
    /*------------------------------------------------------------------------------
     Purpose: Private constructor to prevent direct instantiation
     Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE EntityFactory():
        /* Private constructor to enforce singleton pattern */
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Get the singleton instance of the factory
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC business.EntityFactory GetInstance():
        IF objInstance = ? THEN
            objInstance = NEW business.EntityFactory().
        
        RETURN objInstance.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Get the singleton instance of CustomerEntity
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CustomerEntity GetCustomerEntity():
        IF objCustomerEntityInstance = ? THEN
            objCustomerEntityInstance = NEW CustomerEntity().
        
        RETURN objCustomerEntityInstance.
    END METHOD.
        
    /*------------------------------------------------------------------------------
     Purpose: Reset all entity instances (for testing or cleanup)
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID ResetInstances():
        IF VALID-OBJECT(objCustomerEntityInstance) THEN
            DELETE OBJECT objCustomerEntityInstance.
        
        objCustomerEntityInstance = ?.    
    END METHOD.
    
END CLASS.
