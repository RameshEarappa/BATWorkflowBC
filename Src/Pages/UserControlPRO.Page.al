page 50103 "User Control PRO"
{
    PageType = List;
    SourceTable = "User Control PRO";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("PRO Type"; Rec."PRO Type")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        PROTypeL: Record "PRO Type";
                    begin
                        if PROTypeL.Get(Rec."PRO Type") then
                            Rec.Description := PROTypeL.Description;
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