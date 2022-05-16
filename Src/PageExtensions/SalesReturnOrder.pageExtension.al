pageextension 50111 "Sales RtnOrder Ext" extends "Sales Return Order"
{
    layout
    {
        addafter(Status)
        {
            field(Branch; Rec.Branch)
            {
                ApplicationArea = All;
            }
        }
    }
}