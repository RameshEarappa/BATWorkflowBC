pageextension 50106 "GenJournalBatch_ext" extends "General Journal Batches"
{
    layout
    {
        addafter("Copy to Posted Jnl. Lines")
        {
            field("Total Debit"; Rec."Total Debit")
            {
                ApplicationArea = All;
            }
            field("Total Credit"; Rec."Total Credit")
            {

                ApplicationArea = All;
            }
            field("Batch Name"; Rec."Batch Name")
            {
                ApplicationArea = All;
            }
        }
    }
}