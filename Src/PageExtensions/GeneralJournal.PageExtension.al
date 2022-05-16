pageextension 50103 "General Journal_Ext" extends "General Journal"
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
                    ToolTip = 'Specifies the total debit amount in the general journal.';
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
                    ToolTip = 'Specifies the total debit amount in the general journal.';
                }
            }
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
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
        GenjournalBatchL: Record "Gen. Journal Batch";
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
        GenjournalBatchL: Record "Gen. Journal Batch";
    begin
        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if GenJournalLine.FindSet() then;
        GenJournalLine.CalcSums("Credit Amount");
        exit(GenJournalLine."Credit Amount");
    end;
}