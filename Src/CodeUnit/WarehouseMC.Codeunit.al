codeunit 50102 "BAT Source LT"
{
    procedure UpdateTotalMC(var WarehouseShipmentHeaderP: Record "Warehouse Shipment Header")
    var
        WarehouseShipmentLineL: Record "Warehouse Shipment Line";
        TotalPackL: Decimal;
        TotalOuterL: Decimal;
        ItemUnitMeasureL: Record "Item Unit of Measure";
        ItemUnitMeasureL1: Record "Item Unit of Measure";
        WarehouseShipmentHeaderL: Record "Warehouse Shipment Header";
    begin
        WarehouseShipmentLineL.SetRange("No.", WarehouseShipmentHeaderP."No.");
        WarehouseShipmentLineL.SetRange("Unit of Measure Code", 'OUTER');
        WarehouseShipmentLineL.CalcSums("Qty. Outstanding");
        TotalOuterL := WarehouseShipmentLineL."Qty. Outstanding";

        WarehouseShipmentLineL.SetRange("Unit of Measure Code", 'PACK');
        WarehouseShipmentLineL.CalcSums("Qty. Outstanding");
        TotalPackL := WarehouseShipmentLineL."Qty. Outstanding";

        ItemUnitMeasureL.SetRange(Code, 'MASTERCASE');
        if ItemUnitMeasureL.FindFirst() then
            WarehouseShipmentHeaderP."Total Outer MC LT" := TotalOuterL / ItemUnitMeasureL."Qty. per Unit of Measure";

        ItemUnitMeasureL1.SetRange(Code, 'PACK');
        if ItemUnitMeasureL1.FindFirst() then begin
            WarehouseShipmentHeaderP."Total Pack MC LT" := (TotalPackL * ItemUnitMeasureL1."Qty. per Unit of Measure") / ItemUnitMeasureL."Qty. per Unit of Measure";
            WarehouseShipmentHeaderP."Total Volume MC LT" := WarehouseShipmentHeaderP."Total Outer MC LT" + WarehouseShipmentHeaderP."Total Pack MC LT";
            WarehouseShipmentHeaderP."Last Update Time Stamp LT" := CurrentDateTime;
            WarehouseShipmentHeaderP.Modify();
        end;
    end;
}