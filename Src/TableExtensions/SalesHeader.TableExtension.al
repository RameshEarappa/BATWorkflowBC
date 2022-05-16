tableextension 50103 "SalesHeader Ext" extends "Sales Header"
{
    fields
    {
        field(50100; Branch; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Branch';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4));
            Editable = false;
        }
    }
}