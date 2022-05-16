pageextension 50102 PurchaseReturnOrderExt extends "Purchase Return Order"
{
    layout
    {
        addafter(Status)
        {
            field("PRO Type"; Rec."PRO Type")
            {
                ApplicationArea = All;
                Caption = 'PRO Type';
                ToolTip = 'Specifies the PRO Type that belongs login user';
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
                if Rec."PRO Type" = '' then
                    Error('PO Type cannot be blank');
            end;
        }
    }
    local procedure ShowUser()
    var
        UserControlL: Record "User Control PRO";
        UserControlPROL: Page "User Control PRO";
    begin
        UserControlL.SetRange(User, UserId);
        if UserControlL.FindSet() then begin
            UserControlPROL.SetTableView(UserControlL);
            UserControlPROL.SetRecord(UserControlL);
            UserControlPROL.Editable(false);
            UserControlPROL.LookupMode(true);
            if UserControlPROL.RunModal = Action::LookupOK then begin
                UserControlPROL.GetRecord(UserControlL);
                Rec."PO Type" := UserControlL."PRO Type";
                Rec."Assigned User ID" := UserId;
            end;
        end;
    end;

    var
        PROType: Code[50];
}