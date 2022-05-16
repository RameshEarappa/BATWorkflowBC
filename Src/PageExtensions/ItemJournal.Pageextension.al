pageextension 50117 "Item Journal Ext" extends "Item Journal"
{
    layout
    {
        addafter(Description)
        {
            field(Status; Rec.Status)
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("P&osting")
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action("Send Approval Request")
                {
                    Caption = 'Send Approval Request';
                    Enabled = IsSendRequest;
                    Image = SendApprovalRequest;
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Category4;
                    // PromotedOnly = true;
                    // PromotedIsBig = true;

                    trigger OnAction()
                    var
                        WfInitCode: Codeunit "Init Workflow ItemJnl";
                        AdvanceWorkflowCUL: Codeunit "Customized Workflow ItemJnl";
                        ItemJnlLine: Record "Item Journal Line";
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        GetCurrentlySelectedLines(ItemJnlLine);
                        if WfInitCode.CheckWorkflowEnabled(ItemJnlLine) then begin
                            repeat
                                WfInitCode.OnSendApproval_ItemJnl(ItemJnlLine);
                            until ItemJnlLine.Next() = 0
                        end;
                        Message('Approval requests have been sent.');
                    end;
                }
                action("Cancel Approval Request")
                {
                    Caption = 'Cancel Approval Request';
                    Enabled = IsCancel;
                    ApplicationArea = All;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    // PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        InitWf: Codeunit "Init Workflow ItemJnl";
                        ItemJnlLine: Record "Item Journal Line";
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending For Approval");
                        GetCurrentlySelectedLines(ItemJnlLine);
                        repeat
                            InitWf.OnCancelApproval_ItemJnl(ItemJnlLine);
                        until ItemJnlLine.Next() = 0;
                        Message('The approval request for the record has been canceled.');
                    end;
                }
                // action(Approvals)
                // {
                //     AccessByPermission = TableData "Approval Entry" = R;
                //     ApplicationArea = Suite;
                //     Caption = 'Approvals';
                //     Image = Approvals;
                //     Promoted = true;
                //     PromotedCategory = Category7;
                //     ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                //     trigger OnAction()
                //     var
                //         ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                //         ItemJournalLine: Record "Item Journal Line";
                //     begin
                //         GetCurrentlySelectedLines(ItemJournalLine);
                //         ApprovalsMgmt.RunWorkflowEntriesPage(Rec.RecordId(), DATABASE::"Item Journal Line", Enum::"Approval Document Type"::" ", Rec."No.");
                //     end;
                // }
            }
        }
        modify(Post)
        {
            trigger OnBeforeAction()
            var
                ItemJnL: Record "Item Journal Line";
            begin
                GetCurrentlySelectedLines(ItemJnL);
                repeat
                    ItemJnL.TestField(Status, ItemJnL.Status::Approved);
                until ItemJnL.Next() = 0;
            end;
        }
        modify("Post and &Print")
        {
            trigger OnBeforeAction()
            var
                ItemJnL: Record "Item Journal Line";
            begin
                GetCurrentlySelectedLines(ItemJnL);
                repeat
                    ItemJnL.TestField(Status, ItemJnL.Status::Approved);
                until ItemJnL.Next() = 0;
            end;
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControl();
    end;

    trigger OnOpenPage()
    begin
        SetControl();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetControl();
    end;

    local procedure SetControl()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        if Rec."Status" = Rec."Status"::Open then begin
            IsSendRequest := true;
            IsCancel := false;
            PageEditable := true;
            StyleText := '';
        end else
            if Rec."Status" = Rec."Status"::"Pending For Approval" then begin
                IsSendRequest := false;
                IsCancel := true;
                PageEditable := false;
                StyleText := 'Ambiguous';
            end else begin
                IsSendRequest := false;
                IsCancel := false;
                PageEditable := false;
                StyleText := 'Favorable';
            end;
        CurrPage.Update(false);
    end;

    var
        IsSendRequest: Boolean;
        PageEditable: Boolean;
        IsCancel: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        StyleText: Text;

    local procedure GetCurrentlySelectedLines(var RecItemJnlLine: Record "Item Journal Line"): Boolean
    begin
        RecItemJnlLine.CopyFilters(Rec);
        exit(RecItemJnlLine.FindSet);
    end;
}