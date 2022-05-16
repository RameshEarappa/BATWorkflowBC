pageextension 50116 "WareHouseItemJournal Ext" extends "Whse. Item Journal"
{
    layout
    {
        addafter("C Lot No.")
        {
            field("Request Approved LT"; Rec."Request Approved LT")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        addafter("&Registering")
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Visible = true;
                Enabled = true;
                action("Send Approval Request")
                {
                    Caption = 'Send Approval Request';
                    Enabled = IsSendRequest;
                    Image = SendApprovalRequest;
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Category4;
                    //PromotedOnly = true;
                    //PromotedIsBig = true;

                    trigger OnAction()
                    var
                        WfInitCode: Codeunit "Init Workflow LT";
                        AdvanceWorkflowCUL: Codeunit "Customized Workflow LT";
                        WarehouseJnlLine: Record "Warehouse Journal Line";
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        GetCurrentlySelectedLines(WarehouseJnlLine);
                        if WfInitCode.CheckWorkflowEnabled(WarehouseJnlLine) then begin
                            repeat
                                WfInitCode.OnSendApproval_PR(WarehouseJnlLine);
                            until WarehouseJnlLine.Next() = 0
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
                    //PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        InitWf: Codeunit "Init Workflow LT";
                        WarehouseJnlLine: Record "Warehouse Journal Line";
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending For Approval");
                        GetCurrentlySelectedLines(WarehouseJnlLine);
                        repeat
                            InitWf.OnCancelApproval_PR(WarehouseJnlLine);
                        until WarehouseJnlLine.Next() = 0;
                        Message('The approval request for the record has been canceled.');
                    end;
                }
                // action(Approvals)
                // {
                //     AccessByPermission = TableData "Approval Entry" = R;
                //     ApplicationArea = Suite;
                //     Caption = 'Approvals';
                //     Image = Approvals;
                //     //Promoted = true;
                //     //PromotedCategory = Category7;
                //     ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                //     trigger OnAction()
                //     var
                //         ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                //         WarehouseJnl: Record "Warehouse Journal Line";
                //     begin
                //         GetCurrentlySelectedLines(WarehouseJnl);
                //         ApprovalsMgmt.RunWorkflowEntriesPage(WarehouseJnl.RecordId(), DATABASE::"Warehouse Journal Line", Enum::"Approval Document Type"::" ", WarehouseJnl."Whse. Document No.");
                //     end;
                // }
            }
        }
        modify("&Register")
        {
            trigger OnBeforeAction()
            var
                WhseItemJnL: Record "Warehouse Journal Line";
            begin
                GetCurrentlySelectedLines(WhseItemJnL);
                repeat
                    WhseItemJnL.TestField(Status, WhseItemJnL.Status::Approved);
                until WhseItemJnL.Next() = 0;
            end;
        }
        modify("Register and &Print")
        {
            trigger OnBeforeAction()
            var
                WhseItemJnL: Record "Warehouse Journal Line";
            begin
                GetCurrentlySelectedLines(WhseItemJnL);
                repeat
                    WhseItemJnL.TestField(Status, WhseItemJnL.Status::Approved);
                until WhseItemJnL.Next() = 0;
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
        SetEditable: Boolean;

    local procedure GetCurrentlySelectedLines(var RecWarehouseJnlLine: Record "Warehouse Journal Line"): Boolean
    begin
        RecWarehouseJnlLine.CopyFilters(Rec);
        exit(RecWarehouseJnlLine.FindSet);
    end;
}