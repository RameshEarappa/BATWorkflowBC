table 50101 "PO Type"
{
    DataClassification = ToBeClassified;
    Caption = 'PO Type';
    LookupPageId = "PO Type";
    DrillDownPageId = "PO Type";

    fields
    {
        field(1; "PO Type"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'PO Type';
        }
        field(2; "Description"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
    }

    keys
    {
        key("PO Type"; "PO Type")
        {
            Clustered = true;
        }
    }
}