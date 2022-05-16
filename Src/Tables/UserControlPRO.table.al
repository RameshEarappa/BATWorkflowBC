table 50103 "User Control PRO"
{
    DataClassification = ToBeClassified;
    Caption = 'User Control';
    LookupPageId = "User Control PRO";
    DrillDownPageId = "User Control PRO";

    fields
    {
        field(1; "User"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'User';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(2; "PRO Type"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'PRO Type';
            TableRelation = "PRO Type";
        }
        field(3; "Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(User; User, "PRO Type")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "PRO Type", Description)
        {

        }
    }
}