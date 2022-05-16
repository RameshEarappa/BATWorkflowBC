codeunit 50100 "Init Workflow ItemJnl"
{
    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendApproval_ItemJnl(var RecItemJnlLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelApproval_ItemJnl(var RecItemJnlLine: Record "Item Journal Line")
    begin
    end;
    //Event Creation End

    local procedure IsWFEnabled_ItemJnl(var RecItemJnlLine: Record "Item Journal Line"): Boolean
    var
        WFMngt: Codeunit "Workflow Management";
        WFCode: Codeunit "Customized Workflow ItemJnl";
    begin
        exit(WFMngt.CanExecuteWorkflow(RecItemJnlLine, WFCode.RunWorkflowOnSendApproval_ItemJnl))
    end;

    procedure CheckWorkflowEnabled(var RecItemJnlLine: Record "Item Journal Line"): Boolean
    var
        NoWorkflowEnb: TextConst ENU = 'No workflow Enabled for this Record type', ENG = 'No workflow Enabled for this Record type';
    begin
        if not IsWFEnabled_ItemJnl(RecItemJnlLine) then
            Error(NoWorkflowEnb);
        exit(true);
    end;


    var
        WFMngt: Codeunit "Workflow Management";
        Text001: TextConst ENU = 'No Workflows Enabled';
}