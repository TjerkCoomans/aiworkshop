/*------------------------------------------------------------------------
  File        : ItemDataset.i
  Purpose     : Dataset definition for Item entity
  Syntax      : 
  Description : 
  Author(s)   : 
  Created     : Thu Aug 13 16:50:00 CEST 2026
  Notes       : 
----------------------------------------------------------------------*/

/* Define temp-table for Item */
DEFINE TEMP-TABLE ttItem BEFORE-TABLE bttItem
    FIELD Itemnum AS INTEGER INITIAL "0" LABEL "Item Num"
    FIELD ItemName AS CHARACTER LABEL "Item Name"
    FIELD CatPage AS INTEGER INITIAL "0" LABEL "Cat Page"
    FIELD Price AS DECIMAL INITIAL "0" LABEL "Price"
    FIELD CatDescription AS CHARACTER LABEL "Cat Description"
    FIELD Onhand AS INTEGER INITIAL "0" LABEL "On Hand"
    FIELD Allocated AS INTEGER INITIAL "0" LABEL "Allocated"
    FIELD ReOrder AS INTEGER INITIAL "0" LABEL "Re Order"
    FIELD OnOrder AS INTEGER INITIAL "0" LABEL "On Order"
    FIELD Category1 AS CHARACTER LABEL "Category 1"
    FIELD Category2 AS CHARACTER LABEL "Category 2"
    FIELD Special AS CHARACTER LABEL "Special"
    FIELD Weight AS DECIMAL INITIAL "0" LABEL "Weight"
    FIELD Minqty AS INTEGER INITIAL "0" LABEL "Min Qty"
    INDEX ItemNum IS PRIMARY UNIQUE Itemnum ASCENDING.

/* Define dataset for Item */
DEFINE DATASET dsItem FOR ttItem.
