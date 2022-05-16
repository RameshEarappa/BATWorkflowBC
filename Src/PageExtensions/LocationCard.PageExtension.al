pageextension 50114 "Location Card Ext" extends "Location Card"
{
    layout
    {
        addafter("Name-Arabic")
        {
            field(Executive; Rec.Executive)
            {
                ApplicationArea = All;
                LookupPageID = "User Lookup";
            }
            field("Approval 4 VAN Loading TO"; Rec."Approval 4 VAN Loading TO")
            {
                ApplicationArea = All;
            }
            field("Approval 4 VAN Unloading TO"; Rec."Approval 4 VAN Unloading TO")
            {
                ApplicationArea = All;
            }
        }
    }
}