pageextension 50119 "Integration Setup Ext" extends "Integration Setup"
{
    layout
    {
        addafter("Export Item Setup")
        {
            group("Balance Due")
            {
                field("Minimum Balance Due LT"; Rec."Minimum Balance Due LT")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}