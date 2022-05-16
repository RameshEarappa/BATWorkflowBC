tableextension 50109 "User Setup Ext" extends "User Setup"
{
    fields
    {
        field(50060; "Allow Cash Receipt Deletion"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allow Cash Receipt Deletion';
        }
        field(50061; "POST Whse Phy Inv Jnl_LT"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'POST Whse Phy Inv Jnl';
        }
    }
}