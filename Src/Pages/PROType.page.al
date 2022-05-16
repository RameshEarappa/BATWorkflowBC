page 50101 "PRO Type"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PRO Type";
    Caption = 'PRO Type';


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("PRO Type"; Rec."PRO Type")
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