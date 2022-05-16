tableextension 50101 GenJournalBatch_Ext extends "Gen. Journal Batch"
{
    fields
    {
        field(50100; "Batch Name"; Code[20])
        {
            Caption = 'Batch Name';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(50101; "Total Debit"; Decimal)
        {
            Caption = 'Total Debit';
            FieldClass = FlowField;
            CalcFormula = sum("Gen. Journal Line"."Debit Amount" where("Journal Template Name" = field("Journal Template Name"), "Journal Batch Name" = field(Name)));
            Editable = false;
        }
        field(50102; "Total Credit"; Decimal)
        {
            Caption = 'Total Credit';
            FieldClass = FlowField;
            CalcFormula = sum("Gen. Journal Line"."Credit Amount" where("Journal Template Name" = field("Journal Template Name"), "Journal Batch Name" = field(Name)));
            Editable = false;
        }
        modify(Name)
        {
            trigger OnAfterValidate();
            begin
                Rec."Batch Name" := Name;
            end;
        }
    }
}