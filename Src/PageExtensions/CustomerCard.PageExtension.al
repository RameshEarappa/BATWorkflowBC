pageextension 50112 "Customer Card_Ext" extends "Customer Card"
{
    layout
    {
        addafter("Sales Promotion Group")
        {
            field("Customer Registration Number"; Rec."Customer Registration Number")
            {
                ApplicationArea = All;
            }
        }
    }
}