page 50102 "User Control PO"
{
    PageType = List;
    SourceTable = "User Control PO";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("PO Type"; Rec."PO Type")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        POTypeL: Record "PO Type";
                    begin
                        if POTypeL.Get(Rec."PO Type") then
                            Rec.Description := POTypeL.Description;
                    end;

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}