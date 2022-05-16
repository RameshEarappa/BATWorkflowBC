codeunit 50106 "Customized Workflow ItemJnl"
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
    procedure RunWorkflowOnSendApproval_ItemJnl(): Code[128]
    begin
        exit('RunWorkflowOnSendApproval_ItemJnl');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Init Workflow ItemJnl", 'OnSendApproval_ItemJnl', '', true, true)]
    procedure RunWorkflowOnSendApprovalForTO(var RecItemJnlLine: Record "Item Journal Line")
    begin
        WFMngt.HandleEvent(RunWorkflowOnSendApproval_ItemJnl, RecItemJnlLine);
    end;


    //************* To set status pending approval *************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    procedure ChangeAssetStatus(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    VAR
        ItemJnline: Record "Item Journal Line";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number of
            DATABASE::"Item Journal Line":
                begin
                    RecRef.SetTable(ItemJnline);
                    ItemJnline.Validate("Status", ItemJnline."Status"::"Pending For Approval");
                    ItemJnline.Modify(true);
                    Variant := ItemJnline;
                    IsHandled := true;
                end;
        end;
    end;
    //****************************************** Send For Approval End ***********************


    //************ After approval *** Set status to Approved**************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    procedure OnReleaseDocument(RecRef: RecordRef; VAR Handled: Boolean)
    var
        ItemJnline: Record "Item Journal Line";
        Variant: Variant;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Item Journal Line":
                BEGIN
                    RecRef.SetTable(ItemJnline);
                    ItemJnline."Status" := ItemJnline."Status"::Approved;
                    //ItemJnline."Request Approved LT" := true;
                    ItemJnline.Modify(true);
                    Variant := ItemJnline;
                    RecRef.GetTable(Variant);
                    Handled := true;
                END;
        end;
    end;


    //*******************On Populate Approval Entry *********************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ItemJnline: Record "Item Journal Line";
    begin
        case RecRef.Number of
            database::"Item Journal Line":
                begin
                    RecRef.SetTable(ItemJnline);
                    ApprovalEntryArgument."Table ID" := Database::"Item Journal Line";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
                    ApprovalEntryArgument."Document No." := ItemJnline."Document No.";
                    ApprovalEntryArgument."Record ID to Approve" := ItemJnline.RecordId;
                    ApprovalEntryArgument."Due Date" := WorkDate();
                    RecRef.GetTable(ItemJnline);
                end;
        end;
    end;



    //******************To cancel approval in case of 2nd level***************** 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRec', '', false, false)]
    procedure OnBeforeHandleEventWithxRec(FunctionName: Code[128]; Variant: Variant; xVariant: Variant; VAR IsHandled: Boolean)
    Var
        ItemJnline: Record "Item Journal Line";
        RecRef: RecordRef;
        RecApprovalEntry: Record "Approval Entry";
        ActionableWorkflowStepInstance: Record "Workflow Step Instance";
        WorkFlowMgmt: Codeunit "Workflow Management";
    begin
        RecRef.GetTable(Variant);
        if (RecRef.Number = Database::"Item Journal Line") AND (FunctionName = RunWorkflowOnCancelApproval_ItemJnl()) Then begin
            IF NOT WorkFlowMgmt.FindEventWorkflowStepInstance(ActionableWorkflowStepInstance, FunctionName, Variant, xVariant) THEN BEGIN
                ItemJnline := Variant;
                Clear(RecApprovalEntry);
                RecApprovalEntry.SetRange("Table ID", Database::"Item Journal Line");
                RecApprovalEntry.SetRange("Document No.", ItemJnline."Document No.");
                RecApprovalEntry.SetRange("Record ID to Approve", ItemJnline.RecordId);
                RecApprovalEntry.SetFilter(Status, '%1|%2', RecApprovalEntry.Status::Created, RecApprovalEntry.Status::Open);
                if RecApprovalEntry.FindSet() then
                    RecApprovalEntry.ModifyAll(Status, RecApprovalEntry.Status::Canceled);
                ItemJnline.Validate("Status", ItemJnline."Status"::Open);
                ItemJnline.Modify();
                Variant := ItemJnline;
                //Message('Warehouse Item Journal approval request has been cancelled.');
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    procedure AddEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendApproval_ItemJnl(), Database::"Item Journal Line", 'Item Journal approval required', 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelApproval_ItemJnl(), Database::"Item Journal Line", 'Item journal cancel request', 0, false);
    end;

    //****************Reject***************
    procedure RunWorkflowOnReject_ItemJnl(): Code[128]
    begin
        exit('RunWorkflowOnReject_ItemJnl');
    end;
    //****************Reject End***************



    //***********************Cancel For Approval Event  Start******************
    procedure RunWorkflowOnCancelApproval_ItemJnl(): Code[128]
    begin
        exit('RunWorkflowOnCancelApproval_ItemJnl');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Init Workflow ItemJnl", 'OnCancelApproval_ItemJnl', '', true, true)]
    procedure RunWorkflow_OnCancelApproval_ItemJnl(var RecItemJnlLine: Record "Item Journal Line")
    begin
        WFMngt.HandleEvent(RunWorkflowOnCancelApproval_ItemJnl, RecItemJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeShowCommonApprovalStatus', '', true, true)]
    local procedure OnBeforeShowCommonApprovalStatus(var RecRef: RecordRef; var IsHandle: Boolean)
    var
        ItemJnline: Record "Item Journal Line";
    begin
        case RecRef.Number of
            Database::"Item Journal Line":
                begin
                    Clear(ItemJnline);
                    ItemJnline.SetRange("Document No.", Format(RecRef.Field(7)));
                    if ItemJnline.FindFirst() then
                        IsHandle := true;
                end;
        end;
    end;
    //***********************End***********************************


    //****************In case of Reject and cancel Approval request***********
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    procedure OnOpenDocument(RecRef: RecordRef; VAR Handled: Boolean)
    VAR
        ItemJnline: Record "Item Journal Line";
        Variant: Variant;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Item Journal Line":
                BEGIN
                    RecRef.SetTable(ItemJnline);
                    ItemJnline."Status" := ItemJnline."Status"::Open;
                    ItemJnline.Modify(true);
                    Variant := ItemJnline;
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
            DATABASE::"Item Journal Line":
                CardPageID := Page::"Item Journal";
        end;
    end;

    //To set document Type and No. in Notifiation email Body
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    // local procedure OnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean);
    // var
    //     FieldRef: FieldRef;
    // begin
    //     case RecRef.Number of
    //         DATABASE::"Item Journal Line":
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