table 50102 "User Control PO"
{
    DataClassification = ToBeClassified;
    Caption = 'User Control';
    LookupPageId = "User Control PO";
    DrillDownPageId = "User Control PO";

    fields
    {
        field(1; "User"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'User';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(2; "PO Type"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'PO Type';
            TableRelation = "PO Type";
        }
        field(3; "Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(User; User, "PO Type")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "PO Type", Description)
        {

        }
    }
}