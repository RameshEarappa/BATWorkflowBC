codeunit 50107 "Init Workflow SalesPrice"
{
    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendApproval_SP(var SalesPrice: Record "Sales Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelApproval_SP(var SalesPrice: Record "Sales Price")
    begin
    end;
    //Event Creation End

    local procedure IsWFEnabled_SP(var SalesPrice: Record "Sales Price"): Boolean
    var
        WFMngt: Codeunit "Workflow Management";
        WFCode: Codeunit "Customized Workflow SalesPrice";
    begin
        exit(WFMngt.CanExecuteWorkflow(SalesPrice, WFCode.RunWorkflowOnSendApproval_SP))
    end;

    procedure CheckWorkflowEnabled(var SalesPrice: Record "Sales Price"): Boolean
    var
        NoWorkflowEnb: TextConst ENU = 'No workflow Enabled for this Record type', ENG = 'No workflow Enabled for this Record type';
    begin
        if not IsWFEnabled_SP(SalesPrice) then
            Error(NoWorkflowEnb);
        exit(true);
    end;


    var
        WFMngt: Codeunit "Workflow Management";
        Text001: TextConst ENU = 'No Workflows Enabled';

}