pageextension 50120 "Sales OrderSubform Ext" extends "Sales Order Subform"
{
    layout
    {
        addafter("Unit Price")
        {
            field("Exceed LT"; Rec."Exceed LT")
            {
                ApplicationArea = All;
            }
        }
    }
}