tableextension 50113 "SalesLine Ext" extends "Sales Line"
{
    fields
    {
        field(60000; "Exceed LT"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Exceed';
        }
    }
}