pageextension 50100 UserSetupExt extends "User Setup"
{
    layout
    {
        addafter("Allow Transfer Order Posting")
        {
            field("Allow Cash Receipt Deletion"; Rec."Allow Cash Receipt Deletion")
            {
                ApplicationArea = All;
            }
            field("POST Whse Phy Inv Jnl_LT"; Rec."POST Whse Phy Inv Jnl_LT")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addfirst(Navigation)
        {
            action(POType)
            {
                Caption = 'PO Type';
                RunObject = page "User Control PO";
                RunPageLink = user = field("User ID");
                ApplicationArea = All;
            }
            action(PROType)
            {
                Caption = 'PRO Type';
                RunObject = page "User Control PRO";
                RunPageLink = user = field("User ID");
                ApplicationArea = All;
            }
        }
    }
}