codeunit 50105 "Customized Workflow LT"
{

    trigger OnRun()
    begin

    end;

    var
        WFMngt: Codeunit "Workflow Management";
        AppMgmt: Codeunit "Approvals Mgmt.";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";



    //**************************Send For Approval Event Start***************************
    procedure RunWorkflowOnSendApproval_PR(): Code[128]
    begin
        exit('RunWorkflowOnSendApproval_PR');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Init Workflow LT", 'OnSendApproval_PR', '', true, true)]
    procedure RunWorkflowOnSendApprovalForTO(var RecWarehouseJnlLine: Record "Warehouse Journal Line")
    begin
        WFMngt.HandleEvent(RunWorkflowOnSendApproval_PR, RecWarehouseJnlLine);
    end;


    //************* To set status pending approval *************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    procedure ChangeAssetStatus(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    VAR
        RecWhseJnlLine: Record "Warehouse Journal Line";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number of
            DATABASE::"Warehouse Journal Line":
                begin
                    RecRef.SetTable(RecWhseJnlLine);
                    RecWhseJnlLine.Validate("Status", RecWhseJnlLine."Status"::"Pending For Approval");
                    RecWhseJnlLine.Modify(true);
                    Variant := RecWhseJnlLine;
                    IsHandled := true;
                end;
        end;
    end;
    //****************************************** Send For Approval End ***********************


    //************ After approval *** Set status to Approved**************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    procedure OnReleaseDocument(RecRef: RecordRef; VAR Handled: Boolean)
    var
        RecWhseJnlLine: Record "Warehouse Journal Line";
        Variant: Variant;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Warehouse Journal Line":
                BEGIN
                    RecRef.SetTable(RecWhseJnlLine);
                    RecWhseJnlLine."Status" := RecWhseJnlLine."Status"::Approved;
                    RecWhseJnlLine."Request Approved LT" := true;
                    RecWhseJnlLine.Modify(true);
                    Variant := RecWhseJnlLine;
                    RecRef.GetTable(Variant);
                    Handled := true;
                END;
        end;
    end;


    //*******************On Populate Approval Entry *********************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        RecWhseJnlLine: Record "Warehouse Journal Line";
    begin
        case RecRef.Number of
            database::"Warehouse Journal Line":
                begin
                    RecRef.SetTable(RecWhseJnlLine);
                    ApprovalEntryArgument."Table ID" := Database::"Warehouse Journal Line";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
                    ApprovalEntryArgument."Document No." := RecWhseJnlLine."Whse. Document No.";
                    ApprovalEntryArgument."Record ID to Approve" := RecWhseJnlLine.RecordId;
                    ApprovalEntryArgument."Due Date" := WorkDate();
                    RecRef.GetTable(RecWhseJnlLine);
                end;
        end;
    end;



    //******************To cancel approval in case of 2nd level***************** 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRec', '', false, false)]
    procedure OnBeforeHandleEventWithxRec(FunctionName: Code[128]; Variant: Variant; xVariant: Variant; VAR IsHandled: Boolean)
    Var
        RecWhseJnlLine: Record "Warehouse Journal Line";
        RecRef: RecordRef;
        RecApprovalEntry: Record "Approval Entry";
        ActionableWorkflowStepInstance: Record "Workflow Step Instance";
        WorkFlowMgmt: Codeunit "Workflow Management";
    begin
        RecRef.GetTable(Variant);
        if (RecRef.Number = Database::"Warehouse Journal Line") AND (FunctionName = RunWorkflowOnCancelApproval_PR()) Then begin
            IF NOT WorkFlowMgmt.FindEventWorkflowStepInstance(ActionableWorkflowStepInstance, FunctionName, Variant, xVariant) THEN BEGIN
                RecWhseJnlLine := Variant;
                Clear(RecApprovalEntry);
                RecApprovalEntry.SetRange("Table ID", Database::"Warehouse Journal Line");
                RecApprovalEntry.SetRange("Document No.", RecWhseJnlLine."Whse. Document No.");
                RecApprovalEntry.SetRange("Record ID to Approve", RecWhseJnlLine.RecordId);
                RecApprovalEntry.SetFilter(Status, '%1|%2', RecApprovalEntry.Status::Created, RecApprovalEntry.Status::Open);
                if RecApprovalEntry.FindSet() then
                    RecApprovalEntry.ModifyAll(Status, RecApprovalEntry.Status::Canceled);
                RecWhseJnlLine.Validate("Status", RecWhseJnlLine."Status"::Open);
                RecWhseJnlLine.Modify();
                Variant := RecWhseJnlLine;
                //Message('Warehouse Item Journal approval request has been cancelled.');
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    procedure AddEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendApproval_PR(), Database::"Warehouse Journal Line", 'Warehouse Item Journal approval required', 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelApproval_PR(), Database::"Warehouse Journal Line", 'Warehouse Item journal cancel request', 0, false);
    end;

    //****************Reject***************
    procedure RunWorkflowOnReject_PR(): Code[128]
    begin
        exit('RunWorkflowOnReject_PR');
    end;
    //****************Reject End***************



    //***********************Cancel For Approval Event  Start******************
    procedure RunWorkflowOnCancelApproval_PR(): Code[128]
    begin
        exit('RunWorkflowOnCancelApproval_PR');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Init Workflow LT", 'OnCancelApproval_PR', '', true, true)]
    procedure RunWorkflow_OnCancelApproval_PR(var RecWarehouseJnlLine: Record "Warehouse Journal Line")
    begin
        WFMngt.HandleEvent(RunWorkflowOnCancelApproval_PR, RecWarehouseJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeShowCommonApprovalStatus', '', true, true)]
    local procedure OnBeforeShowCommonApprovalStatus(var RecRef: RecordRef; var IsHandle: Boolean)
    var
        WarehouseJournalLine: Record "Warehouse Journal Line";
    begin
        case RecRef.Number of
            DATABASE::"Warehouse Journal Line":
                begin
                    Clear(WarehouseJournalLine);
                    WarehouseJournalLine.SetRange("Whse. Document No.", Format(RecRef.Field(50)));
                    if WarehouseJournalLine.FindFirst() then
                        IsHandle := true;
                end;
        end;
    end;
    //***********************End***********************************


    //****************In case of Reject and cancel Approval request***********
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    procedure OnOpenDocument(RecRef: RecordRef; VAR Handled: Boolean)
    VAR
        RecWhseJnlLine: Record "Warehouse Journal Line";
        Variant: Variant;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Warehouse Journal Line":
                BEGIN
                    RecRef.SetTable(RecWhseJnlLine);
                    RecWhseJnlLine."Status" := RecWhseJnlLine."Status"::Open;
                    RecWhseJnlLine.Modify(true);
                    Variant := RecWhseJnlLine;
                    RecRef.GetTable(Variant);
                    Handled := true;
                END;
        end;

    end;

    //Code to Open Record from Request to Appprove page
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnConditionalCardPageIDNotFound', '', false, false)]
    local procedure OnConditionalCardPageIDNotFound(RecordRef: RecordRef; VAR CardPageID: Integer)
    begin
        CASE RecordRef.NUMBER OF
            DATABASE::"Warehouse Journal Line":
                CardPageID := Page::"Whse. Item Journal";
        end;
    end;

    //To set document Type and No. in Notifiation email Body
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    // local procedure OnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean);
    // var
    //     FieldRef: FieldRef;
    // begin
    //     case RecRef.Number of
    //         DATABASE::"Warehouse Journal Line":
    //             begin
    //                 DocumentType := RecRef.Caption;
    //                 FieldRef := RecRef.Field(1);
    //                 DocumentNo := Format(FieldRef.Value);
    //                 IsHandled := true;
    //             end;
    //     end;
    // end;

    //to change the Email Subject
    //[EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Entry Dispatcher", 'OnBeforeCreateMailAndDispatch', '', false, false)]
    // local procedure OnBeforeCreateMailAndDispatch(var NotificationEntry: Record "Notification Entry"; var MailSubject: Text; var Email: Text; var IsHandled: Boolean);
    // var
    //     RecRef: RecordRef;
    //     ApprovalEntry: Record "Approval Entry";
    // begin

    //     if NotificationEntry.Type = NotificationEntry.Type::Approval then begin
    //         if RecRef.Get(NotificationEntry."Triggered By Record") then begin
    //             //RecRef.Open(NotificationEntry."Triggered By Record".TableNo);
    //             RecRef.SetTable(ApprovalEntry);

    //             case ApprovalEntry.Status of
    //                 ApprovalEntry.Status::Open:
    //                     MailSubject := 'Approval Required';
    //                 ApprovalEntry.Status::Approved:
    //                     MailSubject := 'Request Approved';
    //                 ApprovalEntry.Status::Rejected:
    //                     MailSubject := 'Request Rejected';
    //                 ApprovalEntry.Status::Canceled:
    //                     MailSubject := 'Request Canceled';

    //             end;
    //         end;
    //     end;
    // end;
}