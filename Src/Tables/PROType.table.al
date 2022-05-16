table 50100 "PRO Type"
{
    DataClassification = ToBeClassified;
    Caption = 'PRO Type';
    LookupPageId = "PRO Type";
    DrillDownPageId = "PRO Type";

    fields
    {
        field(1; "PRO Type"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'PRO Type';
        }
        field(2; "Description"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
    }

    keys
    {
        key("PRO Type"; "PRO Type")
        {
            Clustered = true;
        }
    }
}