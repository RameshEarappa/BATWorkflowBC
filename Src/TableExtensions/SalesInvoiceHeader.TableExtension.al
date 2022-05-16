tableextension 50104 "Sales Inv Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(50100; Branch; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Branch';
            Editable = false;
        }
    }
}