pageextension 50105 "Payment Journal_Ext" extends "Payment Journal"
{
    layout
    {
        addafter("Total Balance")
        {
            group("Total BAT Debit")
            {
                Caption = 'Total Debit';
                field("TotalDebit"; GetTotalDebitAmt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Debit';
                    Editable = false;
                    ToolTip = 'Specifies the total debit amount in the payment journal.';
                }
            }
            group("Total BAT Credit")
            {
                Caption = 'Total Credit';
                field("TotalCredit"; GetTotalCreditAmt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Credit';
                    Editable = false;
                    ToolTip = 'Specifies the total debit amount in the payment journal.';
                }
            }
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                GetTotalDebitAmt;
                GetTotalCreditAmt;
                CurrPage.Update(true);
            end;
        }
    }
    actions
    {
        modify(SendApprovalRequestJournalLine)
        {
            trigger OnBeforeAction()
            begin
                Rec."Total Debit" := GetTotalDebitAmt();
                Rec."Total Credit" := GetTotalCreditAmt();
            end;
        }
    }
    local procedure GetTotalDebitAmt(): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if GenJournalLine.FindSet() then;
        GenJournalLine.CalcSums("Debit Amount");
        exit(GenJournalLine."Debit Amount");
    end;

    local procedure GetTotalCreditAmt(): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if GenJournalLine.FindSet() then;
        GenJournalLine.CalcSums("Credit Amount");
        exit(GenJournalLine."Credit Amount");
    end;
}