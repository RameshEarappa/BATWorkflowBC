page 50105 "Plan Shipment LT"
{
    Caption = 'Plan Shipment';
    PageType = StandardDialog;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(ShippingAgentCodeLT; ShippingAgentCodeLT)
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Code';
                    trigger OnLookup(Var Text: Text): Boolean
                    begin
                        LookupShippingAgent();
                    end;
                }
                field(ShippingAgentServiceCodeLT; ShippingAgentServiceCodeLT)
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Services';
                    trigger OnLookup(Var Text: Text): Boolean
                    begin
                        LookupShippingAgentServiceCode();
                    end;
                }
                field(NumberofServiceLT; NumberofServiceLT)
                {
                    ApplicationArea = All;
                    Caption = 'Number of Service';
                }
                field(ShipmentGroupCodeLT; ShipmentGroupCodeLT)
                {
                    ApplicationArea = All;
                    Caption = 'Shipment Group Code';
                }
                field(TotalOuterMCLT; TotalOuterMCLT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(TotalPackMCLT; TotalPackMCLT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(TotalVolumeMCLT; TotalVolumeMCLT)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    var
        NumberofServiceLT: Code[30];
        ShipmentGroupCodeLT: Code[50];
        ShippingAgentCodeLT: Code[50];
        ShippingAgentServiceCodeLT: Code[50];
        TotalOuterMCLT: Decimal;
        TotalPackMCLT: Decimal;
        TotalVolumeMCLT: Decimal;

    procedure SetupTotalValues(TotalOuterP: Decimal; TotalPackP: Decimal; TotalVolumeP: Decimal)
    begin
        TotalOuterMCLT := TotalOuterP;
        TotalPackMCLT := TotalPackP;
        TotalVolumeMCLT := TotalVolumeP;
    end;

    procedure GetPlanShipment(Var PlanShippingAgentCodeP: Text; Var PlanAgentServiceP: Text;
    Var NumberServiceP: Text; Var ShipmentGroupCodeP: Text)
    begin
        PlanShippingAgentCodeP := ShippingAgentCodeLT;
        PlanAgentServiceP := ShippingAgentServiceCodeLT;
        NumberServiceP := NumberofServiceLT;
        ShipmentGroupCodeP := ShipmentGroupCodeLT;
    end;

    local procedure LookupShippingAgent()
    var
        ShippingAgentRecL: Record "Shipping Agent";
        ShippingAgentPageL: Page "Shipping Agents";
    begin
        ShippingAgentPageL.LookupMode := true;
        if ShippingAgentPageL.RunModal() = Action::LookupOK then begin
            ShippingAgentPageL.GetRecord(ShippingAgentRecL);
            ShippingAgentCodeLT := ShippingAgentRecL.Code;
        end;
    end;

    local procedure LookupShippingAgentServiceCode()
    var
        ShippingAgentServiceRecL: Record "Shipping Agent Services";
        ShippingAgentServicePageL: Page "Shipping Agent Services";
    begin
        if ShippingAgentCodeLT <> '' then begin
            ShippingAgentServiceRecL.SetRange("Shipping Agent Code", ShippingAgentCodeLT);
            ShippingAgentServicePageL.SetTableView(ShippingAgentServiceRecL);
            ShippingAgentServicePageL.LookupMode := true;
            if ShippingAgentServicePageL.RunModal() = Action::LookupOK then begin
                ShippingAgentServicePageL.GetRecord(ShippingAgentServiceRecL);
                ShippingAgentServiceCodeLT := ShippingAgentServiceRecL.Code;
            end;
        end;
    end;
}