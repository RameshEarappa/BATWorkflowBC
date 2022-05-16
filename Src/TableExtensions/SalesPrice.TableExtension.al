tableextension 50111 "Sales Price Ext" extends "Sales Price"
{
    fields
    {
        field(50250; Status; Enum "WF Status Sales Price")
        {
            DataClassification = ToBeClassified;
        }
    }
}