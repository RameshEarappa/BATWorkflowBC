page 50100 "PO Type"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PO Type";
    Caption = 'PO Type';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("PO Type"; Rec."PO Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}