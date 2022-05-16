pageextension 50122 "Warehouse Shipment Ext" extends "Warehouse Shipment"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Sell-to Customer No. LT"; Rec."Sell-to Customer No. LT")
            {
                ToolTip = 'Specifies the value of the Sell-to Customer No. field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("Sell-to Customer Name LT"; Rec."Sell-to Customer Name LT")
            {
                ToolTip = 'Specifies the value of the Sell-to Customer Name field.';
                ApplicationArea = All;
                Editable = false;
            }
            field(Branch; Rec.Branch)
            {
                ToolTip = 'Specifies the value of the Branch field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("Ship-to Code LT"; Rec."Ship-to Code LT")
            {
                ToolTip = 'Specifies the value of the Ship-to Code field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("Bill-to Post Code LT"; Rec."Bill-to Post Code LT")
            {
                ToolTip = 'Specifies the value of the Bill-to Post Code field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("Ship-to Post Code LT"; Rec."Ship-to Post Code LT")
            {
                ToolTip = 'Specifies the value of the Ship-to Post Code field.';
                ApplicationArea = All;
                Editable = false;
            }

            field("Total Outer MC LT"; Rec."Total Outer MC LT")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Total Pack MC LT"; Rec."Total Pack MC LT")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Total Volume MC LT"; Rec."Total Volume MC LT")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Van Loading TO LT"; Rec."Van Loading TO LT")
            {
                ToolTip = 'Specifies the value of the Van Loading TO field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("SO Shipment LT"; Rec."SO Shipment LT")
            {
                ToolTip = 'Specifies the value of the SO Shipment field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("Last Update Time Stamp LT"; Rec."Last Update Time Stamp LT")
            {
                ToolTip = 'Specifies the value of the Last Update Time Stamp field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("Shipment Group Code LT"; Rec."Shipment Group Code LT")
            {
                ToolTip = 'Specifies the value of the Shipment Group Code field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("Number of Service LT"; Rec."Number of Service LT")
            {
                ToolTip = 'Specifies the value of the Number of Service field.';
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        addafter("F&unctions")
        {
            action(UpdateMC)
            {
                Caption = 'Update MC';
                ApplicationArea = All;
                trigger OnAction()
                var
                    WhseMC: Codeunit "BAT Source LT";
                    Linesent: Integer;
                begin
                    WhseMC.UpdateTotalMC(Rec);
                    CurrPage.Update(true);
                end;
            }
        }
    }
}