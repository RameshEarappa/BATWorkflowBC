pageextension 50118 "Sales Price Ext" extends "Sales Prices"
{
    layout
    {
        addafter("Unit Price")
        {
            field(Status; Rec.Status)
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        modify("Sales Type")
        {
            Editable = SetEditable;
        }
        modify("Sales Code")
        {
            Editable = SetEditable;
        }
        modify("Item No.")
        {
            Editable = SetEditable;
        }
        modify("Unit of Measure Code")
        {
            Editable = SetEditable;
        }
        modify("Minimum Quantity")
        {
            Editable = SetEditable;
        }
        modify("Unit Price")
        {
            Editable = SetUnitprice;
        }
        modify("Starting Date")
        {
            Editable = SetEditable;
        }
        modify("Ending Date")
        {
            trigger OnAfterValidate()
            begin
                if Rec.Status = Rec.Status::Approved then begin
                    Rec.Status := Rec.Status::Open;
                    Rec.Modify(true);
                    SetControl();
                end;
            end;
        }
        modify(Description)
        {
            Editable = SetEditable;
        }
        modify("List Name")
        {
            Editable = SetEditable;
        }
    }

    actions
    {
        addafter(CopyPrices)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action("Send Approval Request")
                {
                    Caption = 'Send Approval Request';
                    Enabled = IsSendRequest;
                    Image = SendApprovalRequest;
                    ApplicationArea = All;
                    Promoted = true;

                    trigger OnAction()
                    var
                        WfInitCode: Codeunit "Init Workflow SalesPrice";
                        AdvanceWorkflowCUL: Codeunit "Customized Workflow SalesPrice";
                        SalesPriceL: Record "Sales Price";
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        GetCurrentlySelectedLines(SalesPriceL);
                        if WfInitCode.CheckWorkflowEnabled(SalesPriceL) then begin
                            repeat
                                WfInitCode.OnSendApproval_SP(SalesPriceL);
                            until SalesPriceL.Next() = 0
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

                    trigger OnAction()
                    var
                        InitWf: Codeunit "Init Workflow SalesPrice";
                        SalesPriceL: Record "Sales Price";
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending For Approval");
                        GetCurrentlySelectedLines(SalesPriceL);
                        repeat
                            InitWf.OnCancelApproval_SP(SalesPriceL);
                        until SalesPriceL.Next() = 0;
                        Message('The approval request for the record has been canceled.');
                    end;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Status = Rec.Status::Open then
            SetEditable := true
        else
            SetEditable := false;
    end;

    trigger OnAfterGetRecord()
    begin
        SetControl();
        if Rec.Status = Rec.Status::Open then
            SetEditable := true
        else
            SetEditable := false;
    end;

    trigger OnOpenPage()
    begin
        SetControl();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Status := Rec.Status::Open;
        SetControl();
    end;

    var
        IsSendRequest: Boolean;
        PageEditable: Boolean;
        IsCancel: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        StyleText: Text;
        SetEditable: Boolean;
        SetUnitprice: Boolean;

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
            SetUnitprice := true;
        end else
            if Rec."Status" = Rec."Status"::"Pending For Approval" then begin
                IsSendRequest := false;
                IsCancel := true;
                PageEditable := false;
                StyleText := 'Ambiguous';
                SetUnitprice := false;
            end else begin
                IsSendRequest := false;
                IsCancel := false;
                PageEditable := false;
                StyleText := 'Favorable';
                SetUnitprice := false;
            end;
        CurrPage.Update(false);
    end;

    local procedure GetCurrentlySelectedLines(var SalesPrice: Record "Sales Price"): Boolean
    begin
        CurrPage.SetSelectionFilter(SalesPrice);
        exit(SalesPrice.FindSet());
    end;
}