pageextension 50104 "Cash Recp Journal_Ext" extends "Cash Receipt Journal"
{
    layout
    {
        addafter("Total Balance")
        {
            group("Total BAT Debit")
            {
                Caption = 'Total Debit';
                field("TotalDebit"; GetTotalDebitAmt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Debit';
                    Editable = false;
                    ToolTip = 'Specifies the total debit amount in the cash journal.';
                }
            }
            group("Total BAT Credit")
            {
                Caption = 'Total Credit';
                field("TotalCredit"; GetTotalCreditAmt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Credit';
                    Editable = false;
                    ToolTip = 'Specifies the total debit amount in the cash journal.';
                }
            }
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                GetTotalDebitAmt;
                GetTotalCreditAmt;
                CurrPage.Update(true);
            end;
        }
        modify("Document No.")
        {
            Editable = SetEditable;
        }
    }
    actions
    {
        modify(SendApprovalRequestJournalLine)
        {
            Visible = false;
        }
        modify(CancelApprovalRequestJournalLine)
        {
            Visible = false;
        }
        modify(SendApprovalRequestJournalBatch)
        {
            Visible = SetVisible;
        }
        modify(CancelApprovalRequestJournalBatch)
        {
            Visible = SetVisible;
        }
        addafter(SendApprovalRequestJournalBatch)
        {
            action(ExtendedSendApprovalRequestJournalLine)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Selected Journal Lines';
                Enabled = NOT OpenApprovalEntriesOnBatchOrCurrJnlLineExist AND CanRequestFlowApprovalForBatchAndCurrentLine;
                Image = SendApprovalRequest;
                ToolTip = 'Send selected journal lines for approval.';

                trigger OnAction()
                var
                    GenJournalLine: Record "Gen. Journal Line";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    Rec.ModifyAll("Total Debit", GetTotalDebitAmt());
                    Rec.ModifyAll("Total Credit", GetTotalCreditAmt());
                    GetCurrentlySelectedLines(GenJournalLine);
                    ApprovalsMgmt.TrySendJournalLineApprovalRequests(GenJournalLine);
                end;
            }
        }
        addafter(CancelApprovalRequestJournalBatch)
        {
            action(ExtendedCancelApprovalRequestJournalLine)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Selected Journal Lines';
                Enabled = CanCancelApprovalForJnlLine OR CanCancelFlowApprovalForLine;
                Image = CancelApprovalRequest;
                ToolTip = 'Cancel sending selected journal lines for approval.';

                trigger OnAction()
                var
                    GenJournalLine: Record "Gen. Journal Line";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    GetCurrentlySelectedLines(GenJournalLine);
                    ApprovalsMgmt.TryCancelJournalLineApprovalRequests(GenJournalLine);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        IntegrationSetupL: Record "Integration Setup";
        UsersetupL: Record "User Setup";
    begin
        SetControlAppearanceFromBatch;
        SetControlAppearance;
        IntegrationSetupL.Get();
        if (IntegrationSetupL."Cash Receipt Jnl Template" = Rec."Journal Template Name")
        and (IntegrationSetupL."Cash Receipt Jnl. Batch" = Rec."Journal Batch Name") then
            SetVisible := false
        else
            SetVisible := true;
        if not SetVisible then begin
            if UsersetupL.Get(UserId) then
                if not UsersetupL."Allow Cash Receipt Deletion" then
                    SetEditable := false
                else
                    SetEditable := true;
        end else
            SetEditable := true;
    end;

    trigger OnAfterGetRecord()
    var
        IntegrationSetupL: Record "Integration Setup";
        UsersetupL: Record "User Setup";
    begin
        SetControlAppearanceFromBatch;
        SetControlAppearance;
        IntegrationSetupL.Get();
        if (IntegrationSetupL."Cash Receipt Jnl Template" = Rec."Journal Template Name")
        and (IntegrationSetupL."Cash Receipt Jnl. Batch" = Rec."Journal Batch Name") then
            SetVisible := false
        else
            SetVisible := true;
        if not SetVisible then begin
            if UsersetupL.Get(UserId) then
                if not UsersetupL."Allow Cash Receipt Deletion" then
                    SetEditable := false
                else
                    SetEditable := true;
        end else
            SetEditable := true;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        IntegrationSetupL: Record "Integration Setup";
        UsersetupL: Record "User Setup";
    begin
        IntegrationSetupL.Get();
        if UsersetupL.Get(UserId) then begin
            if not UsersetupL."Allow Cash Receipt Deletion" then begin
                if (IntegrationSetupL."Cash Receipt Jnl Template" = Rec."Journal Template Name")
                and (IntegrationSetupL."Cash Receipt Jnl. Batch" = Rec."Journal Batch Name") then
                    Error('You do not have permission to delete the records');
            end;
        end;
    end;

    trigger OnOpenPage()
    var
        IntegrationSetupL: Record "Integration Setup";
        UsersetupL: Record "User Setup";
    begin
        SetControlAppearanceFromBatch;
        SetControlAppearance;
        IntegrationSetupL.Get();
        if (IntegrationSetupL."Cash Receipt Jnl Template" = Rec."Journal Template Name")
        and (IntegrationSetupL."Cash Receipt Jnl. Batch" = Rec."Journal Batch Name") then
            SetVisible := false
        else
            SetVisible := true;
        if not SetVisible then begin
            if UsersetupL.Get(UserId) then
                if not UsersetupL."Allow Cash Receipt Deletion" then
                    SetEditable := false
                else
                    SetEditable := true;
        end else
            SetEditable := true;
    end;

    var
        OpenApprovalEntriesOnBatchOrAnyJnlLineExist: Boolean;
        CanRequestFlowApprovalForBatchAndAllLines: Boolean;
        CanCancelApprovalForJnlBatch: Boolean;
        //
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist: Boolean;
        CanRequestFlowApprovalForBatchAndCurrentLine: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExistForCurrUserBatch: Boolean;
        OpenApprovalEntriesOnJnlLineExist: Boolean;
        OpenApprovalEntriesOnJnlBatchExist: Boolean;
        CanCancelApprovalForJnlLine: Boolean;
        CanRequestFlowApprovalForBatch: Boolean;
        CanCancelFlowApprovalForLine: Boolean;
        CanCancelFlowApprovalForBatch: Boolean;
        //
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;
        JournalErrorsMgt: Codeunit "Journal Errors Mgt.";
        SetVisible: Boolean;
        SetEditable: Boolean;

    local procedure GetTotalDebitAmt(): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        GenJournalLine.CopyFilters(Rec);
        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if GenJournalLine.FindSet() then;
        GenJournalLine.CalcSums("Debit Amount");
        exit(GenJournalLine."Debit Amount");
    end;

    local procedure GetTotalCreditAmt(): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        GenJournalLine.CopyFilters(Rec);
        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if GenJournalLine.FindSet() then;
        GenJournalLine.CalcSums("Credit Amount");
        exit(GenJournalLine."Credit Amount");
    end;

    local procedure SetControlAppearanceFromBatch()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        CanRequestFlowApprovalForAllLines: Boolean;
    begin
        if not GenJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
            exit;

        CheckOpenApprovalEntries(GenJournalBatch.RecordId);

        CanCancelApprovalForJnlBatch := ApprovalsMgmt.CanCancelApprovalForRecord(GenJournalBatch.RecordId);

        WorkflowWebhookManagement.GetCanRequestAndCanCancelJournalBatch(
          GenJournalBatch, CanRequestFlowApprovalForBatch, CanCancelFlowApprovalForBatch, CanRequestFlowApprovalForAllLines);
        CanRequestFlowApprovalForBatchAndAllLines := CanRequestFlowApprovalForBatch and CanRequestFlowApprovalForAllLines;
        BackgroundErrorCheck := GenJournalBatch."Background Error Check";
        ShowAllLinesEnabled := true;
        Rec.SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
        JournalErrorsMgt.SetFullBatchCheck(true);
    end;

    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        CanRequestFlowApprovalForLine: Boolean;
    begin
        OpenApprovalEntriesExistForCurrUser :=
          OpenApprovalEntriesExistForCurrUserBatch or ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);

        OpenApprovalEntriesOnJnlLineExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist := OpenApprovalEntriesOnJnlBatchExist or OpenApprovalEntriesOnJnlLineExist;

        CanCancelApprovalForJnlLine := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);

        WorkflowWebhookManagement.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestFlowApprovalForLine, CanCancelFlowApprovalForLine);
        CanRequestFlowApprovalForBatchAndCurrentLine := CanRequestFlowApprovalForBatch and CanRequestFlowApprovalForLine;
    end;

    local procedure CheckOpenApprovalEntries(BatchRecordId: RecordID)
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        OpenApprovalEntriesExistForCurrUserBatch := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(BatchRecordId);

        OpenApprovalEntriesOnJnlBatchExist := ApprovalsMgmt.HasOpenApprovalEntries(BatchRecordId);

        OpenApprovalEntriesOnBatchOrAnyJnlLineExist :=
          OpenApprovalEntriesOnJnlBatchExist or
          ApprovalsMgmt.HasAnyOpenJournalLineApprovalEntries(Rec."Journal Template Name", Rec."Journal Batch Name");
    end;

    local procedure GetCurrentlySelectedLines(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    begin
        GenJournalLine.CopyFilters(Rec);
        exit(GenJournalLine.FindSet);
    end;
}