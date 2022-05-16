tableextension 50106 "Customer Ext" extends Customer
{
    fields
    {
        field(50601; "Customer Registration Number"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
}