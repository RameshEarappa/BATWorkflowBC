pageextension 50123 "Sales Order List Ext" extends "Sales Order List"
{
    actions
    {
        addafter(SendApprovalRequest)
        {
            action(SendApprovalRequest_LT)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Send A&pproval Request';
                Enabled = Rec.Status = Rec.Status::Open;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                ToolTip = 'Request approval of the document.';

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    CheckCreditLimit: Codeunit "Event Subscriber";
                    ReleaseSalesDoc: Codeunit "Release Sales Document";
                    TotalQtyL: Integer;
                    SalesHeaderL: Record "Sales Header";
                    ShowFinanceMessageL: Text;
                begin
                    SettoSendNotification := false;
                    CurrPage.SetSelectionFilter(Rec);
                    SalesHeaderL.Copy(Rec);
                    if SalesHeaderL.FindSet() then begin
                        repeat
                            if CheckCreditLimit.CheckQuantityLimitBeforeApprovalRequest(SalesHeaderL, TotalQtyL) and CheckCreditLimit.CheckFinanceLimit(SalesHeaderL, TotalQtyL, ShowFinanceMessageL) then begin
                                SalesHeaderL.Status := SalesHeaderL.Status::Released;
                                SalesHeaderL.Modify(true);
                            end else
                                if ApprovalsMgmt.CheckSalesApprovalPossible(SalesHeaderL) then begin
                                    ApprovalsMgmt.OnSendSalesDocForApproval(SalesHeaderL);
                                    SettoSendNotification := true;
                                end;
                        until SalesHeaderL.Next() = 0;
                        Rec.Reset();
                        if SettoSendNotification then
                            Message('Approval requests have been sent.');
                    end;
                end;
            }
            action(CancelApprovalRequest_LT)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cancel Approval Re&quest';
                Enabled = Rec.Status = Rec.Status::"Pending Approval";
                Image = CancelApprovalRequest;
                ToolTip = 'Cancel the approval request.';

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
                    SalesHeaderL: Record "Sales Header";
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    SalesHeaderL.Copy(Rec);
                    if SalesHeaderL.FindSet() then
                        repeat
                            ApprovalsMgmt.OnCancelSalesApprovalRequest(SalesHeaderL);
                            WorkflowWebhookManagement.FindAndCancel(SalesHeaderL.RecordId);
                        until SalesHeaderL.Next() = 0;
                    Rec.Reset();
                    Message('Approval requests have been canceled.');
                end;
            }
        }
        modify(SendApprovalRequest)
        {
            Visible = false;
        }
        modify(CancelApprovalRequest)
        {
            Visible = false;
        }
    }
    var
        SettoSendNotification: Boolean;
}