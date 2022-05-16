pageextension 50108 "Sales Order Ext" extends "Sales Order"
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
                    ShowFinanceMessageL: Text;
                begin
                    if CheckCreditLimit.CheckQuantityLimitBeforeApprovalRequest(Rec, TotalQtyL) and CheckCreditLimit.CheckFinanceLimit(Rec, TotalQtyL, ShowFinanceMessageL) then begin
                        Rec.Status := Rec.Status::Released;
                        Rec.Modify(true);
                    end else
                        if ApprovalsMgmt.CheckSalesApprovalPossible(Rec) then
                            ApprovalsMgmt.OnSendSalesDocForApproval(Rec);
                end;
            }
        }
        modify(SendApprovalRequest)
        {
            Visible = false;
        }
    }
    var
        OpenApprovalEntriesExist: Boolean;
        CanRequestApprovalForFlow: Boolean;
}