pageextension 50110 "Warehouse PhyInvJnl Ext" extends "Whse. Phys. Invt. Journal"
{
    actions
    {
        modify("&Register")
        {
            Visible = SetRegisterandRegisterPrint;
            // TRIGGER OnBeforeAction()
            // VAR
            //     WarehouseJnlLine: Record "Warehouse Journal Line";
            //     WorkflowManagement: Codeunit "Workflow Management";
            //     WorkflowEventHandling: Codeunit "Ext. Workflow Event Handling";
            //     WarehouseJnlBatch: Record "Warehouse Journal Batch";
            // BEGIN
            //     IF
            //     WorkflowManagement.CanExecuteWorkflow(WarehouseJnlBatch,
            //     WorkflowEventHandling.RunWorkflowOnSendWarehouseJournalBatchForApprovalCode) then begin
            //         WarehouseJnlLine.RESET;
            //         WarehouseJnlLine.SETRANGE("Journal Template Name", Rec."Journal Template Name");
            //         WarehouseJnlLine.SETRANGE("Journal Batch Name", Rec."Journal Batch Name");
            //         WarehouseJnlLine.SETFILTER(Status, '%1|%2', WarehouseJnlLine.Status::Open, WarehouseJnlLine.Status::"Pending For Approval");
            //         IF WarehouseJnlLine.FindFirst() THEN
            //             ERROR('Status should be Approved to Register the Warehouse Physical Inventory Journal');
            //     END;
            // END;
        }
        modify("Register and &Print")
        {
            Visible = SetRegisterandRegisterPrint;
        }
    }
    trigger OnOpenPage()
    begin
        Clear(UserSetupG);
        if UserSetupG.Get(UserId) then
            if UserSetupG."POST Whse Phy Inv Jnl_LT" then
                SetRegisterandRegisterPrint := true
            else
                SetRegisterandRegisterPrint := false;
    end;

    trigger OnAfterGetRecord()
    begin
        Clear(UserSetupG);
        if UserSetupG.Get(UserId) then
            if UserSetupG."POST Whse Phy Inv Jnl_LT" then
                SetRegisterandRegisterPrint := true
            else
                SetRegisterandRegisterPrint := false;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Clear(UserSetupG);
        if UserSetupG.Get(UserId) then
            if UserSetupG."POST Whse Phy Inv Jnl_LT" then
                SetRegisterandRegisterPrint := true
            else
                SetRegisterandRegisterPrint := false;
    end;

    var
        UserSetupG: Record "User Setup";
        SetRegisterandRegisterPrint: Boolean;
}