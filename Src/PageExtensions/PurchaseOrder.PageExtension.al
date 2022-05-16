pageextension 50101 PurchaseOrderExt extends "Purchase Order"
{
    layout
    {
        addafter(Status)
        {
            field("PO Type"; Rec."PO Type")
            {
                ApplicationArea = All;
                Caption = 'PO Type';
                ToolTip = 'Specifies the PO Type that belongs login user';
                trigger OnLookup(Var Text: Text): Boolean
                var
                begin
                    ShowUser();
                end;
            }
        }
    }
    actions
    {
        modify(Post)
        {
            trigger OnBeforeAction()
            begin
                if Rec."PO Type" = '' then
                    Error('PO Type cannot be blank');
            end;
        }
    }
    local procedure ShowUser()
    var
        UsercontrolL: Record "User Control PO";
        UserControlPoL: Page "User Control PO";
    begin
        UsercontrolL.SetRange(User, UserId);
        if UsercontrolL.FindSet() then begin
            UserControlPoL.SetTableView(UsercontrolL);
            UserControlPoL.SetRecord(UsercontrolL);
            UserControlPoL.Editable(false);
            UserControlPoL.LookupMode(true);
            if UserControlPoL.RunModal = Action::LookupOK then begin
                UserControlPoL.GetRecord(UsercontrolL);
                Rec."PO Type" := usercontrolL."PO Type";
                Rec."Assigned User ID" := UserId;
            end;
        end;
    end;

    var
        POType: Code[50];
}