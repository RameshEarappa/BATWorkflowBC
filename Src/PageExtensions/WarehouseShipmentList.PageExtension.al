pageextension 50121 "Warehouse Shipment List Ext" extends "Warehouse Shipment List"
{
    layout
    {
        addafter(Status)
        {
            field("VAN Unloading TO"; Rec."VAN Unloading TO")
            {
                ToolTip = 'Specifies the value of the VAN Unloading TO field.';
                ApplicationArea = All;
            }
            field("Created By API"; Rec."Created By API")
            {
                ToolTip = 'Specifies the value of the VAN loading TO field.';
                ApplicationArea = All;
            }
            field("Sell-to Customer No. LT"; Rec."Sell-to Customer No. LT")
            {
                ToolTip = 'Specifies the value of the Sell-to Customer No. field.';
                ApplicationArea = All;
            }
            field("Sell-to Customer Name LT"; Rec."Sell-to Customer Name LT")
            {
                ToolTip = 'Specifies the value of the Sell-to Customer Name field.';
                ApplicationArea = All;
            }
            field("Salesperson Code"; Rec."Salesperson Code")
            {
                ToolTip = 'Specifies the value of the Salesperson Code field.';
                ApplicationArea = All;
            }
            field(Branch; Rec.Branch)
            {
                ToolTip = 'Specifies the value of the Branch field.';
                ApplicationArea = All;
            }
            field("Ship-to Code LT"; Rec."Ship-to Code LT")
            {
                ToolTip = 'Specifies the value of the Ship-to Code field.';
                ApplicationArea = All;
            }
            field("Ship-to Name LT"; Rec."Ship-to Name LT")
            {
                ToolTip = 'Specifies the value of the Ship to Name field.';
                ApplicationArea = All;
            }
            field("Ship-to City LT"; Rec."Ship-to City LT")
            {
                ToolTip = 'Specifies the value of the Ship-to City field.';
                ApplicationArea = All;
            }
            field("Bill-to City LT"; Rec."Bill-to City LT")
            {
                ToolTip = 'Specifies the value of the Bill-to City field.';
                ApplicationArea = All;
            }
            field("Bill-to Post Code LT"; Rec."Bill-to Post Code LT")
            {
                ToolTip = 'Specifies the value of the Bill-to Post Code field.';
                ApplicationArea = All;
            }
            field("Ship-to Post Code LT"; Rec."Ship-to Post Code LT")
            {
                ToolTip = 'Specifies the value of the Ship-to Post Code field.';
                ApplicationArea = All;
            }
            field("Total Outer MC LT"; Rec."Total Outer MC LT")
            {
                ToolTip = 'Specifies the value of the Total Outer MC field.';
                ApplicationArea = All;
            }
            field("Total Pack MC LT"; Rec."Total Pack MC LT")
            {
                ToolTip = 'Specifies the value of the Total Pack MC field.';
                ApplicationArea = All;
            }
            field("Total Volume MC LT"; Rec."Total Volume MC LT")
            {
                ToolTip = 'Specifies the value of the Total Volume MC field.';
                ApplicationArea = All;
            }
            field("SO Shipment LT"; Rec."SO Shipment LT")
            {
                ToolTip = 'Specifies the value of the SO Shipment field.';
                ApplicationArea = All;
            }
            field("Last Update Time Stamp LT"; Rec."Last Update Time Stamp LT")
            {
                ToolTip = 'Specifies the value of the Last Update Time Stamp field.';
                ApplicationArea = All;
            }
            field("Shipment Group Code LT"; Rec."Shipment Group Code LT")
            {
                ToolTip = 'Specifies the value of the Shipment Group Code field.';
                ApplicationArea = All;
            }
            field("Number of Service LT"; Rec."Number of Service LT")
            {
                ToolTip = 'Specifies the value of the Number of Service field.';
                ApplicationArea = All;
            }
            field("Shipping Time LT"; Rec."Shipping Time LT")
            {
                ToolTip = 'Specifies the value of the Shipping Time field.';
                ApplicationArea = All;
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
                    WhsHeaderL: Record "Warehouse Shipment Header";
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    WhsHeaderL.Copy(Rec);
                    if WhsHeaderL.FindSet() then
                        repeat
                            WhseMC.UpdateTotalMC(WhsHeaderL);
                        until WhsHeaderL.Next() = 0;
                    Rec.Reset();
                    CurrPage.Update(true);
                end;
            }
            action(PlanShipment)
            {
                Caption = 'Plan Shipment';
                ApplicationArea = All;
                trigger OnAction()
                var
                    WhsHeaderL: Record "Warehouse Shipment Header";
                    PlanShipmentDialog: Page "Plan Shipment LT";
                    PlanShipmentAgent: Text;
                    PlanAgentCodeL: Text;
                    NumberServiceL: Text;
                    ShipmentGroupL: Text;
                    ShipmentGroupP: Text;
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    WhsHeaderL.Copy(Rec);
                    WhsHeaderL.CalcSums("Total Outer MC LT", "Total Pack MC LT", "Total Volume MC LT");
                    PlanShipmentDialog.Activate();
                    ShipmentGroupP := Format(Today, 0, '<Year,2><Month,2><Day,2>') + Format(Time, 0, '<Hours24,2><Minutes,2><Seconds,2>');
                    PlanShipmentDialog.SetupTotalValues(WhsHeaderL."Total Outer MC LT", WhsHeaderL."Total Pack MC LT", WhsHeaderL."Total Volume MC LT", ShipmentGroupP);
                    if PlanShipmentDialog.RunModal() = Action::OK then begin
                        PlanShipmentDialog.GetPlanShipment(PlanShipmentAgent, PlanAgentCodeL, NumberServiceL, ShipmentGroupL);
                        if (PlanShipmentAgent = '') or (PlanAgentCodeL = '') then begin
                            if Confirm('Do you want to update the lines with blank Shipping', False) then begin
                                if WhsHeaderL.FindSet() then begin
                                    WhsHeaderL.ModifyAll("Shipping Agent Code", PlanShipmentAgent);
                                    WhsHeaderL.ModifyAll("Shipping Agent Service Code", PlanAgentCodeL);
                                    WhsHeaderL.ModifyAll("Number of Service LT", NumberServiceL);
                                    WhsHeaderL.ModifyAll("Shipment Group Code LT", ShipmentGroupL);
                                end;
                            end;
                        end else
                            if WhsHeaderL.FindSet() then begin
                                WhsHeaderL.ModifyAll("Shipping Agent Code", PlanShipmentAgent);
                                WhsHeaderL.ModifyAll("Shipping Agent Service Code", PlanAgentCodeL);
                                WhsHeaderL.ModifyAll("Number of Service LT", NumberServiceL);
                                WhsHeaderL.ModifyAll("Shipment Group Code LT", ShipmentGroupL);
                            end;
                    end;
                    Rec.Reset();
                    CurrPage.Update(true);
                    PlanShipmentDialog.Close();
                end;
            }
        }
    }
}