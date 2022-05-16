pageextension 50109 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("FOC Item Exists")
        {
            field(Branch; Rec.Branch)
            {
                ApplicationArea = All;
            }
        }
    }
}