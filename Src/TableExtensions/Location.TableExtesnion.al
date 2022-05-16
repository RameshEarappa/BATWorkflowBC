tableextension 50110 "Location Ext" extends Location
{
    fields
    {
        field(50071; "Executive"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Executive';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(50072; "Approval 4 VAN Loading TO"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Approval 4 VAN Loading TO';
        }
        field(50073; "Approval 4 VAN Unloading TO"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Approval 4 VAN Unloading TO';
        }
    }
}