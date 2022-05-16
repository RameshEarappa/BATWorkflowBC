pageextension 50115 "Transfer Order Ext" extends "Transfer Order"
{
    actions
    {
        modify("Send Approval Request")
        {
            trigger OnAfterAction()
            var
                ExtendedApprovalEntryL: Codeunit "Extended Approval Entry";
            begin
                ExtendedApprovalEntryL.SwapApprovalUser(Rec);
            end;
        }
    }
}