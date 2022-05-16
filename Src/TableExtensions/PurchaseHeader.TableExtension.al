tableextension 50100 "PurchaseHeader_Ext" extends "Purchase Header"
{
    fields
    {
        field(50100; "PO Type"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "PO Type"."PO Type";
        }
        field(50101; "PRO Type"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "PRO Type"."PRO Type";
        }
    }
}