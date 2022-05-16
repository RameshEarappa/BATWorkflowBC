tableextension 50107 "Gen Jnl Line_Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(50101; "Total Debit"; Decimal)
        {
            Caption = 'Total Debit';
            Editable = false;
        }
        field(50102; "Total Credit"; Decimal)
        {
            Caption = 'Total Credit';
            Editable = false;
        }
    }
}