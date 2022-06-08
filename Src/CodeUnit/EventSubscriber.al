codeunit 50101 "Event Subscriber"
{
    Permissions = tabledata "Approval Entry" = rimd;

    var
        SalesHeaderG: Record "Sales Header";
        SetBooleanG: Boolean;
        ShowFinanceMessage: Text;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure OnAfterValidateEventNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        CustomerL: Record Customer;
    begin
        if Rec."Document Type" IN [Rec."Document Type"::Order, Rec."Document Type"::"Return Order"] then begin
            if CustomerL.Get(Rec."Sell-to Customer No.") then
                Rec.Branch := CustomerL.Branch;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeApprovalEntryInsert', '', false, false)]
    local procedure OnBeforeApprovalEntryInsert(ApprovalEntryArgument: Record "Approval Entry";
    var ApprovalEntry: Record "Approval Entry"; ApproverId: Code[50]; var IsHandled: Boolean;
    WorkflowStepArgument: Record "Workflow Step Argument")
    var
        GenJnlLineL: Record "Gen. Journal Line";
        WarehouseJournalLine: Record "Warehouse Journal Line";
        ItemJournalLine: Record "Item Journal Line";
        LocationL: Record Location;
        SalesLineL: Record "Sales Line";
        ItemL: Record Item;
        CustomerL: Record Customer;
        TotalQty: Integer;
        cust: Record "Cust. Ledger Entry";
        BinContentL: Record "Bin Content";
        ApprovalEntryL: Record "Approval Entry";
        ItemExceedL: Boolean;
        FinanceExceedL: Boolean;
    begin
        GenJnlLineL.SetRange("Document No.", ApprovalEntryArgument."Document No.");
        if GenJnlLineL.FindSet() then begin
            repeat
                ApprovalEntry."Total Debit" := GenJnlLineL."Total Debit";
                ApprovalEntry."Total Credit" := GenJnlLineL."Total Credit";
                ApprovalEntry."Posting Date" := GenJnlLineL."Posting Date";
                ApprovalEntry."Account No." := GenJnlLineL."Account No.";
                ApprovalEntry."Bal.Account No." := GenJnlLineL."Bal. Account No.";
                ApprovalEntry.Description := GenJnlLineL.Description;
            until GenJnlLineL.Next() = 0;
        end;
        WarehouseJournalLine.SetRange("Whse. Document No.", ApprovalEntryArgument."Document No.");
        if WarehouseJournalLine.FindSet() then begin
            repeat
                ApprovalEntry."Item No_LT" := WarehouseJournalLine."Item No.";
                ApprovalEntry.Description := WarehouseJournalLine.Description;
                ApprovalEntry.Quantity_LT := WarehouseJournalLine.Quantity;
            until WarehouseJournalLine.Next() = 0;
        end;
        ItemJournalLine.SetRange("Document No.", ApprovalEntryArgument."Document No.");
        if ItemJournalLine.FindSet() then begin
            repeat
                ApprovalEntry."Item No_LT" := ItemJournalLine."Item No.";
                ApprovalEntry.Description := ItemJournalLine.Description;
                ApprovalEntry.Quantity_LT := ItemJournalLine.Quantity;
                ApprovalEntry.Amount := ItemJournalLine.Amount;
            until ItemJournalLine.Next() = 0;
        end;

        //SalesOrder Approval Workflow
        //checking quantity mentioned in the sales order exceeds the available Qty.
        //If Exceeds then sending request to warehouse executive.
        Clear(SalesHeaderG);
        Clear(ShowFinanceMessage);
        if ApprovalEntry."Table ID" = DATABASE::"Sales Header" then
            if SalesHeaderG.Get(SalesHeaderG."Document Type"::Order, ApprovalEntry."Document No.") then begin
                LocationL.Get(SalesHeaderG."Location Code");
                LocationL.TestField(Executive);
                ItemExceedL := CheckQuantityLimitBeforeApprovalRequest(SalesHeaderG, TotalQty);
                FinanceExceedL := CheckFinanceLimit(SalesHeaderG, TotalQty, ShowFinanceMessage);
                if not ItemExceedL then begin
                    if FinanceExceedL then begin
                        ApprovalEntry."Approver ID" := LocationL.Executive;
                        ApprovalEntry.Description := ShowFinanceMessage;
                    end
                    else begin
                        ApprovalEntryL.Copy(ApprovalEntry);
                        ApprovalEntry."Approver ID" := LocationL.Executive;
                        ApprovalEntry.Description := 'Quantity Exceeded';
                        ApprovalEntryL.Description := ShowFinanceMessage;
                        ApprovalEntry.Insert(true);
                        ApprovalEntryL.Insert(true);
                        IsHandled := true;
                    end;
                end else
                    ApprovalEntry.Description := ShowFinanceMessage;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCreateApprovalRequests', '', false, false)]
    local procedure OnBeforeCreateApprovalRequests(RecRef: RecordRef; var IsHandled: Boolean;
    WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowUserGroupMember: Record "Workflow User Group Member";
        TransferHeaderL: Record "Transfer Header";
        LocationL: Record Location;
        workflowUser: Record "Workflow User Group";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        if TransferHeaderL.Get(RecRef.Field(1)) then begin
            if LocationL.Get(TransferHeaderL."Transfer-from Code") then
                if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then
                    if workflowUser.Get(WorkflowStepArgument."Workflow User Group Code") then begin
                        WorkflowUserGroupMember.SetRange("Workflow User Group Code", workflowUser.Code);
                        if WorkflowUserGroupMember.FindFirst() then begin
                            WorkflowUserGroupMember.Delete();
                            WorkflowUserGroupMember.Init();
                            WorkflowUserGroupMember."Workflow User Group Code" := workflowUser.Code;
                            WorkflowUserGroupMember.Validate("User Name", LocationL.Executive);
                            WorkflowUserGroupMember.Insert()
                        end;
                    end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Transfer Order", 'OnBeforeSendApprovalRequest', '', false, false)]
    local procedure OnBeforeSendApprovalRequest(var Rec: Record "Transfer Header"; var IsHandled: Boolean)
    var
        LocationL: Record Location;
    begin
        if LocationL.Get(Rec."Transfer-from Code") then begin
            LocationL.TestField(Executive);
            if Rec."Created By API" then
                if not LocationL."Approval 4 VAN Loading TO" then begin
                    Rec."Workflow Status" := Rec."Workflow Status"::Approved;
                    Rec.Status := Rec.Status::Released;
                    Rec.Modify(true);
                    IsHandled := true;
                end;
            //LocationL.TestField("Approval 4 VAN Loading TO", true);
            if Rec."VAN Unloading TO" then
                if not LocationL."Approval 4 VAN Unloading TO" then begin
                    Rec."Workflow Status" := Rec."Workflow Status"::Approved;
                    Rec.Status := Rec.Status::Released;
                    Rec.Modify(true);
                    IsHandled := true;
                end;
            //LocationL.TestField("Approval 4 VAN Unloading TO", true);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Phys. Inventory Journal EOD", 'OnBeforeSendApprovalRequest', '', false, false)]
    local procedure OnBeforeSendApprovalRequestAfterCreateTransferOrder(var IsHandled: Boolean; var Rec: Record "Item Journal Line"; Var Transferheader: Record "Transfer Header")
    var
        LocationL: Record Location;
        TransferHeaderL: Record "Transfer Header";
    begin
        if LocationL.Get(Rec."Location Code") then
            if not LocationL."Approval 4 VAN Unloading TO" then
                if TransferHeaderL.Get(Transferheader."No.") then begin
                    TransferHeaderL."Workflow Status" := TransferHeaderL."Workflow Status"::Approved;
                    TransferHeaderL.Status := TransferHeaderL.Status::Released;
                    TransferHeaderL.Modify(true);
                    IsHandled := true;
                end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'No.', false, false)]
    local procedure OnAfterValidateEvent(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalespriceL: Record "Sales Price";
    begin
        if Rec."Document Type" IN [Rec."Document Type"::Order, Rec."Document Type"::Invoice] then begin
            if Rec.Type = Rec.Type::Item then begin
                SalespriceL.SetRange("Item No.", Rec."No.");
                SalespriceL.SetFilter(Status, '%1|%2', SalespriceL.Status::Open, SalespriceL.Status::"Pending For Approval");
                if SalespriceL.FindFirst() then
                    Error('Item %1, Cannot be used. Status should be approved in sales price table', Rec."No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure OnAfterValidateEventQuantity(CurrFieldNo: Integer; var Rec: Record "Sales Line";
    var xRec: Record "Sales Line")
    var
        BinContentL: Record "Bin Content";
        SalesLineL: Record "Sales Line";
    begin
        SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
        SalesLineL.SetRange("Document No.", Rec."Document No.");
        SalesLineL.SetRange("No.", Rec."No.");
        SalesLineL.SetRange("Location Code", Rec."Location Code");
        if SalesLineL.FindSet() then
            repeat
                BinContentL.SetRange("Location Code", SalesLineL."Location Code");
                BinContentL.SetRange("Item No.", SalesLineL."No.");
                if not BinContentL.FindFirst() then
                    Rec."Exceed LT" := true;
            until SalesLineL.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeWhseShptHeaderInsert', '', false, false)]
    local procedure OnBeforeWhseShptHeaderInsert(var WarehouseRequest: Record "Warehouse Request";
    SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; TransferLine: Record "Transfer Line";
    var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        CustomerL: Record Customer;
    begin
        if CustomerL.Get(SalesHeader."Sell-to Customer No.") then;
        WarehouseShipmentHeader."Sell-to Customer No. LT" := SalesHeader."Sell-to Customer No.";
        WarehouseShipmentHeader."Sell-to Customer Name LT" := SalesHeader."Sell-to Customer Name";
        WarehouseShipmentHeader."Salesperson Code" := SalesHeader."Salesperson Code";
        WarehouseShipmentHeader.Branch := SalesHeader.Branch;
        WarehouseShipmentHeader."Bill-to City LT" := CustomerL.City;
        if SalesHeader."Ship-to Code" = '' then begin
            WarehouseShipmentHeader."Ship-to Name LT" := CustomerL.Name;
            WarehouseShipmentHeader."Ship-to City LT" := CustomerL.City;
            WarehouseShipmentHeader."Ship-to Code LT" := CustomerL."Ship-to Code";
        end else begin
            WarehouseShipmentHeader."Ship-to Name LT" := SalesHeader."Ship-to Name";
            WarehouseShipmentHeader."Ship-to City LT" := SalesHeader."Ship-to City";
            WarehouseShipmentHeader."Ship-to Code LT" := SalesHeader."Ship-to Code";
        end;
        WarehouseShipmentHeader."Bill-to Post Code LT" := SalesHeader."Bill-to Post Code";
        WarehouseShipmentHeader."Ship-to Post Code LT" := SalesHeader."Ship-to Post Code";
        WarehouseShipmentHeader."SO Shipment LT" := true;
        WarehouseShipmentHeader."Shipping Time LT" := SalesHeader."Shipping Time";
    end;

    //SalesOrder Approval Workflow
    //checking quantity mentioned in the sales order exceeds the available Qty and Credit Limit.
    //If not exceeds then updating the status in sales order and skipping the approval request. 
    procedure CheckQuantityLimitBeforeApprovalRequest(Var SalesHeaderP: Record "Sales Header"; var TotalQty: Integer): Boolean
    var
        SalesLineL: Record "Sales Line";
        ItemL: Record Item;
        ItemNoL: Text;
        LocationL: Record Location;
        BinContentL: Record "Bin Content";
    begin
        SalesHeaderP.CalcFields("Amount Including VAT");
        SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
        SalesLineL.SetRange("Document No.", SalesHeaderP."No.");
        if SalesLineL.FindSet() then begin
            SalesLineL.CalcSums(Quantity);
            TotalQty := SalesLineL.Quantity;
            repeat
                BinContentL.SetRange("Location Code", SalesLineL."Location Code");
                BinContentL.SetRange("Item No.", SalesLineL."No.");
                if not BinContentL.FindFirst() then
                    exit(false);
            until (SalesLineL.Next() = 0);
            exit(true);
        end;
    end;

    procedure CheckFinanceLimit(SalesHeaderP: Record "Sales Header"; TotalQtyP: Integer; var ShowFinanceMessageP: Text): Boolean
    var
        CustomerL: Record Customer;
        CustL: Record Customer;
        TotalBalanceL: Decimal;
        IntegrationSetupL: Record "Integration Setup";
        CurrencyExchangeRateL: Record "Currency Exchange Rate";
        AmountIncVatL: Decimal;
    begin
        IntegrationSetupL.Get();
        SalesHeaderP.CalcFields(Amount, "Amount Including VAT");
        CurrencyExchangeRateL.SetRange("Currency Code", SalesHeaderP."Currency Code");
        if CurrencyExchangeRateL.FindLast() then
            AmountIncVatL := SalesHeaderP."Amount Including VAT" * CurrencyExchangeRateL."Relational Exch. Rate Amount";
        if CustomerL.Get(SalesHeaderP."Sell-to Customer No.") then begin
            CustomerL.CalcFields("Balance (LCY)", "Balance Due (LCY)", "Outstanding Orders (LCY)");
            if CustomerL."Credit Limit (LCY)" = 0 then begin
                if CustomerL."Maximum SO Value" <= SalesHeaderP."Amount Including VAT" then
                    ShowFinanceMessageP := 'SO Value Exceeded';
                if CustomerL."Maximum SO Quantity" <= TotalQtyP then begin
                    if ShowFinanceMessageP <> '' then
                        ShowFinanceMessageP += '|' + 'SO Quantity Exceeded'
                    else
                        ShowFinanceMessageP := 'SO Quantity Exceeded';
                end;
                if CustomerL."Key Account" <> '' then begin//Checking Overdue
                    CustL.SetRange("Key Account", CustomerL."Key Account");
                    if CustL.FindSet() then begin
                        CustL.CalcFields("Balance (LCY)", "Balance Due (LCY)");
                        CustL.SetAutoCalcFields("Balance Due (LCY)");
                        repeat
                            TotalBalanceL += CustL."Balance Due (LCY)";
                        until CustL.Next() = 0;
                    end;
                    if IntegrationSetupL."Minimum Balance Due LT" <= TotalBalanceL then begin
                        if ShowFinanceMessageP <> '' then
                            ShowFinanceMessageP += '|' + 'Overdue Exceeded'
                        else
                            ShowFinanceMessageP := 'Overdue Exceeded';
                    end else
                        exit(true);
                end else begin
                    if IntegrationSetupL."Minimum Balance Due LT" <= CustomerL."Balance Due (LCY)" then begin
                        if ShowFinanceMessageP <> '' then
                            ShowFinanceMessageP += '|' + 'Overdue Exceeded'
                        else
                            ShowFinanceMessageP := 'Overdue Exceeded';
                    end else
                        exit(true);
                end;
            end else begin
                if CustomerL."Balance (LCY)" + CustomerL."Outstanding Orders (LCY)" + AmountIncVatL >= CustomerL."Credit Limit (LCY)" then  //creditlimit   
                    ShowFinanceMessageP := 'Credit Limit Exceeded';
                if CustomerL."Maximum SO Quantity" <= TotalQtyP then begin
                    if ShowFinanceMessageP <> '' then
                        ShowFinanceMessageP += '|' + 'SO Quantity Exceeded'
                    else
                        ShowFinanceMessageP := 'SO Quantity Exceeded';
                end;
                if CustomerL."Maximum SO Value" <= SalesHeaderP."Amount Including VAT" then begin
                    if ShowFinanceMessageP <> '' then
                        ShowFinanceMessageP += '|' + 'SO Value Exceeded'
                    else
                        ShowFinanceMessageP := 'SO Value Exceeded';
                end;
                if CustomerL."Key Account" <> '' then begin//Checking Overdue
                    CustL.SetRange("Key Account", CustomerL."Key Account");
                    if CustL.FindSet() then begin
                        CustL.CalcFields("Balance (LCY)", "Balance Due (LCY)");
                        CustL.SetAutoCalcFields("Balance Due (LCY)");
                        repeat
                            TotalBalanceL += CustL."Balance Due (LCY)";
                        until CustL.Next() = 0;
                    end;
                    if IntegrationSetupL."Minimum Balance Due LT" <= TotalBalanceL then begin
                        if ShowFinanceMessageP <> '' then
                            ShowFinanceMessageP += '|' + 'Overdue Exceeded'
                        else
                            ShowFinanceMessageP := 'Overdue Exceeded';
                    end else
                        exit(true)
                end else begin
                    if IntegrationSetupL."Minimum Balance Due LT" <= CustomerL."Balance Due (LCY)" then begin
                        if ShowFinanceMessageP <> '' then
                            ShowFinanceMessageP += '|' + 'Overdue Exceeded'
                        else
                            ShowFinanceMessageP := 'Overdue Exceeded';
                    end else
                        exit(true);
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeShowSalesApprovalStatus', '', false, false)]
    local procedure OnBeforeShowSalesApprovalStatus(var IsHandled: Boolean; var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            if SalesHeader.Status = SalesHeader.Status::"Pending Approval" then
                IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnAfterCreatePostedShptHeader', '', false, false)]
    local procedure OnAfterCreatePostedShptHeader(var PostedWhseShptHeader: Record "Posted Whse. Shipment Header"; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        PostedWhseShptHeader."Sell-to Customer No. LT" := WarehouseShipmentHeader."Sell-to Customer No. LT";
        PostedWhseShptHeader."Sell-to Customer Name LT" := WarehouseShipmentHeader."Sell-to Customer Name LT";
        PostedWhseShptHeader.Branch := WarehouseShipmentHeader.Branch;
        PostedWhseShptHeader."Ship-to Code LT" := WarehouseShipmentHeader."Ship-to Code LT";
        PostedWhseShptHeader."Ship-to Name LT" := WarehouseShipmentHeader."Ship-to Name LT";
        PostedWhseShptHeader."Ship-to City LT" := WarehouseShipmentHeader."Ship-to City LT";
        PostedWhseShptHeader."Bill-to City LT" := WarehouseShipmentHeader."Bill-to City LT";
        PostedWhseShptHeader."Bill-to Post Code LT" := WarehouseShipmentHeader."Bill-to Post Code LT";
        PostedWhseShptHeader."Ship-to Post Code LT" := WarehouseShipmentHeader."Ship-to Post Code LT";
        PostedWhseShptHeader."Total Outer MC LT" := WarehouseShipmentHeader."Total Outer MC LT";
        PostedWhseShptHeader."Total Pack MC LT" := WarehouseShipmentHeader."Total Pack MC LT";
        PostedWhseShptHeader."Total Volume MC LT" := WarehouseShipmentHeader."Total Volume MC LT";
        PostedWhseShptHeader."SO Shipment LT" := WarehouseShipmentHeader."SO Shipment LT";
        PostedWhseShptHeader."Last Update Time Stamp LT" := WarehouseShipmentHeader."Last Update Time Stamp LT";
        PostedWhseShptHeader."Shipment Group Code LT" := WarehouseShipmentHeader."Shipment Group Code LT";
        PostedWhseShptHeader."Number of Service LT" := WarehouseShipmentHeader."Number of Service LT";
        PostedWhseShptHeader."Shipping Time LT" := WarehouseShipmentHeader."Shipping Time LT";
        PostedWhseShptHeader.Modify(true);
    end;
}