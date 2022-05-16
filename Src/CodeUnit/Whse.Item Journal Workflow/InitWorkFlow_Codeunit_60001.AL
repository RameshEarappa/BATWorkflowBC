codeunit 50104 "Init Workflow LT"
{
    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendApproval_PR(var RecWarehouseJnlLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelApproval_PR(var RecWarehouseJnlLine: Record "Warehouse Journal Line")
    begin
    end;
    //Event Creation End

    local procedure IsWFEnabled_PR(var RecWarehouseJnlLine: Record "Warehouse Journal Line"): Boolean
    var
        WFMngt: Codeunit "Workflow Management";
        WFCode: Codeunit "Customized Workflow LT";
    begin
        exit(WFMngt.CanExecuteWorkflow(RecWarehouseJnlLine, WFCode.RunWorkflowOnSendApproval_PR))
    end;

    procedure CheckWorkflowEnabled(var RecWarehouseJnlLine: Record "Warehouse Journal Line"): Boolean
    var
        NoWorkflowEnb: TextConst ENU = 'No workflow Enabled for this Record type', ENG = 'No workflow Enabled for this Record type';
    begin
        if not IsWFEnabled_PR(RecWarehouseJnlLine) then
            Error(NoWorkflowEnb);
        exit(true);
    end;


    var
        WFMngt: Codeunit "Workflow Management";
        Text001: TextConst ENU = 'No Workflows Enabled';

}