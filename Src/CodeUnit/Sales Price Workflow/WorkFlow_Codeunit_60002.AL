codeunit 50108 "Customized Workflow SalesPrice"
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
    procedure RunWorkflowOnSendApproval_SP(): Code[128]
    begin
        exit('RunWorkflowOnSendApproval_SP');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Init Workflow SalesPrice", 'OnSendApproval_SP', '', true, true)]
    procedure RunWorkflowOnSendApprovalForTO(var SalesPrice: Record "Sales Price")
    begin
        WFMngt.HandleEvent(RunWorkflowOnSendApproval_SP, SalesPrice);
    end;


    //************* To set status pending approval *************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    procedure ChangeAssetStatus(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    VAR
        SalesPriceL: Record "Sales Price";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number of
            DATABASE::"Sales Price":
                begin
                    RecRef.SetTable(SalesPriceL);
                    SalesPriceL.Validate("Status", SalesPriceL."Status"::"Pending For Approval");
                    SalesPriceL.Modify(true);
                    Variant := SalesPriceL;
                    IsHandled := true;
                end;
        end;
    end;
    //****************************************** Send For Approval End ***********************


    //************ After approval *** Set status to Approved**************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    procedure OnReleaseDocument(RecRef: RecordRef; VAR Handled: Boolean)
    var
        SalesPriceL: Record "Sales Price";
        Variant: Variant;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Sales Price":
                BEGIN
                    RecRef.SetTable(SalesPriceL);
                    SalesPriceL."Status" := SalesPriceL."Status"::Approved;
                    //SalesPriceL."Request Approved LT" := true;
                    SalesPriceL.Modify(true);
                    Variant := SalesPriceL;
                    RecRef.GetTable(Variant);
                    Handled := true;
                END;
        end;
    end;


    //*******************On Populate Approval Entry *********************
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        SalesPriceL: Record "Sales Price";
    begin
        case RecRef.Number of
            database::"Sales Price":
                begin
                    RecRef.SetTable(SalesPriceL);
                    ApprovalEntryArgument."Table ID" := Database::"Sales Price";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
                    ApprovalEntryArgument."Document No." := SalesPriceL."Item No.";
                    ApprovalEntryArgument."Record ID to Approve" := SalesPriceL.RecordId;
                    ApprovalEntryArgument."Due Date" := WorkDate();
                    RecRef.GetTable(SalesPriceL);
                end;
        end;
    end;



    //******************To cancel approval in case of 2nd level***************** 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRec', '', false, false)]
    procedure OnBeforeHandleEventWithxRec(FunctionName: Code[128]; Variant: Variant; xVariant: Variant; VAR IsHandled: Boolean)
    Var
        SalesPriceL: Record "Sales Price";
        RecRef: RecordRef;
        RecApprovalEntry: Record "Approval Entry";
        ActionableWorkflowStepInstance: Record "Workflow Step Instance";
        WorkFlowMgmt: Codeunit "Workflow Management";
    begin
        RecRef.GetTable(Variant);
        if (RecRef.Number = Database::"Sales Price") AND (FunctionName = RunWorkflowOnCancelApproval_SP()) Then begin
            IF NOT WorkFlowMgmt.FindEventWorkflowStepInstance(ActionableWorkflowStepInstance, FunctionName, Variant, xVariant) THEN BEGIN
                SalesPriceL := Variant;
                Clear(RecApprovalEntry);
                RecApprovalEntry.SetRange("Table ID", Database::"Item Journal Line");
                RecApprovalEntry.SetRange("Document No.", SalesPriceL."Item No.");
                RecApprovalEntry.SetRange("Record ID to Approve", SalesPriceL.RecordId);
                RecApprovalEntry.SetFilter(Status, '%1|%2', RecApprovalEntry.Status::Created, RecApprovalEntry.Status::Open);
                if RecApprovalEntry.FindSet() then
                    RecApprovalEntry.ModifyAll(Status, RecApprovalEntry.Status::Canceled);
                SalesPriceL.Validate("Status", SalesPriceL."Status"::Open);
                SalesPriceL.Modify();
                Variant := SalesPriceL;
                //Message('Warehouse Item Journal approval request has been cancelled.');
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    procedure AddEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendApproval_SP(), Database::"Sales Price", 'Sales price approval required', 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelApproval_SP(), Database::"Sales Price", 'Sales price cancel request', 0, false);
    end;

    //****************Reject***************
    procedure RunWorkflowOnReject_SP(): Code[128]
    begin
        exit('RunWorkflowOnReject_SP');
    end;
    //****************Reject End***************



    //***********************Cancel For Approval Event  Start******************
    procedure RunWorkflowOnCancelApproval_SP(): Code[128]
    begin
        exit('RunWorkflowOnCancelApproval_SP');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Init Workflow SalesPrice", 'OnCancelApproval_SP', '', true, true)]
    procedure RunWorkflow_OnCancelApproval_SP(var SalesPrice: Record "Sales Price")
    begin
        WFMngt.HandleEvent(RunWorkflowOnCancelApproval_SP, SalesPrice);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeShowCommonApprovalStatus', '', true, true)]
    local procedure OnBeforeShowCommonApprovalStatus(var RecRef: RecordRef; var IsHandle: Boolean)
    var
        SalesPriceL: Record "Sales Price";
    begin
        case RecRef.Number of
            DATABASE::"Sales Price":
                begin
                    Clear(SalesPriceL);
                    SalesPriceL.SetRange("Item No.", Format(RecRef.Field(1)));
                    if SalesPriceL.FindFirst() then
                        IsHandle := true;
                end;
        end;
    end;
    //***********************End***********************************


    //****************In case of Reject and cancel Approval request***********
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    procedure OnOpenDocument(RecRef: RecordRef; VAR Handled: Boolean)
    VAR
        SalesPriceL: Record "Sales Price";
        Variant: Variant;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"Sales Price":
                BEGIN
                    RecRef.SetTable(SalesPriceL);
                    SalesPriceL."Status" := SalesPriceL."Status"::Open;
                    SalesPriceL.Modify(true);
                    Variant := SalesPriceL;
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
            DATABASE::"Sales Price":
                CardPageID := Page::"Sales Prices";
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