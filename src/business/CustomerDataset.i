/*------------------------------------------------------------------------
  File        : CustomerDataset.i
  Purpose     : Dataset definition for Customer entity
  Syntax      : 
  Description : 
  Author(s)   : 
  Created     : Tue Apr 15 11:54:46 CEST 2025
  Notes       : 
----------------------------------------------------------------------*/

/* Define temp-table for Customer */
DEFINE TEMP-TABLE ttCustomer BEFORE-TABLE bttCustomer
    FIELD CustNum AS INTEGER INITIAL "0" LABEL "Cust Num"
    FIELD Name AS CHARACTER LABEL "Name"
    FIELD Address AS CHARACTER LABEL "Address"
    FIELD City AS CHARACTER LABEL "City"
    FIELD State AS CHARACTER LABEL "State"
    FIELD PostalCode AS CHARACTER LABEL "Postal Code"
    FIELD Contact AS CHARACTER LABEL "Contact"
    FIELD Phone AS CHARACTER LABEL "Phone"
    FIELD SalesRep AS CHARACTER LABEL "Sales Rep"
    FIELD CreditLimit AS DECIMAL INITIAL "1500" LABEL "Credit Limit"
    FIELD Balance AS DECIMAL INITIAL "0" LABEL "Balance"
    FIELD Terms AS CHARACTER INITIAL "Net30" LABEL "Terms"
    FIELD DiscountRate AS DECIMAL INITIAL "0" LABEL "Discount"
    FIELD Comments AS CHARACTER LABEL "Comments"
    FIELD FaxNum AS CHARACTER LABEL "Fax"
    FIELD EmailAddress AS CHARACTER LABEL "Email"
    INDEX CustNum IS PRIMARY UNIQUE CustNum ASCENDING.

/* Define dataset for Customer */
DEFINE DATASET dsCustomer FOR ttCustomer.
