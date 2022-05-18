codeunit 50102 "BAT Source LT"
{
    procedure UpdateTotalMC(var WarehouseShipmentHeaderP: Record "Warehouse Shipment Header")
    var
        WarehouseShipmentLineL: Record "Warehouse Shipment Line";
        TotalPackL: Decimal;
        TotalOuterL: Decimal;
        TotalCubeL: Decimal;
        ItemUnitMeasureL: Record "Item Unit of Measure";
        IUMOuterL: Record "Item Unit of Measure";
        IUMMasterL: Record "Item Unit of Measure";
        WarehouseShipmentHeaderL: Record "Warehouse Shipment Header";
    begin
        WarehouseShipmentLineL.SetCurrentKey("No.", "Unit of Measure Code");
        WarehouseShipmentLineL.SetRange("No.", WarehouseShipmentHeaderP."No.");
        WarehouseShipmentLineL.SetRange("Unit of Measure Code", 'OUTER');
        if WarehouseShipmentLineL.FindSet() then
            repeat
                if ItemUnitMeasureL.Get(WarehouseShipmentLineL."Item No.", 'MASTERCASE') then begin
                    if ItemUnitMeasureL."Qty. per Unit of Measure" <> 0 then
                        TotalOuterL += WarehouseShipmentLineL."Qty. Outstanding" / ItemUnitMeasureL."Qty. per Unit of Measure"
                end else
                    TotalOuterL += WarehouseShipmentLineL."Qty. Outstanding" / 1;
                if IUMOuterL.Get(WarehouseShipmentLineL."Item No.", 'OUTER') then
                    TotalCubeL += WarehouseShipmentLineL."Qty. Outstanding" * IUMOuterL.Cubage;
            until WarehouseShipmentLineL.Next() = 0;

        Clear(ItemUnitMeasureL);
        WarehouseShipmentLineL.SetRange("Unit of Measure Code", 'PACK');
        if WarehouseShipmentLineL.FindSet() then
            repeat
                if ItemUnitMeasureL.Get(WarehouseShipmentLineL."Item No.", 'PACK') then
                    if IUMMasterL.Get(WarehouseShipmentLineL."Item No.", 'MASTERCASE') then begin
                        if ItemUnitMeasureL."Qty. per Unit of Measure" <> 0 then
                            TotalPackL += WarehouseShipmentLineL."Qty. Outstanding" * ItemUnitMeasureL."Qty. per Unit of Measure" / IUMMasterL."Qty. per Unit of Measure"
                    end else
                        TotalPackL += WarehouseShipmentLineL."Qty. Outstanding" * ItemUnitMeasureL."Qty. per Unit of Measure" / 1;
                TotalCubeL += WarehouseShipmentLineL."Qty. Outstanding" * ItemUnitMeasureL.Cubage;
            until WarehouseShipmentLineL.Next() = 0;
        WarehouseShipmentHeaderP."Total Outer MC LT" := TotalOuterL;
        WarehouseShipmentHeaderP."Total Pack MC LT" := TotalPackL;
        WarehouseShipmentHeaderP."Total Volume MC LT" := TotalCubeL;
        WarehouseShipmentHeaderP."Last Update Time Stamp LT" := CurrentDateTime;
        WarehouseShipmentHeaderP.Modify();
    end;
}