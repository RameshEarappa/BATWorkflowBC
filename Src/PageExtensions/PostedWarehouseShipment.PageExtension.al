pageextension 50124 "Posted Warehouse Shipmemt Ext" extends "Posted Whse. Shipment List"
{
    layout
    {
        addafter("VAN Unloading TO")
        {

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
            // field("Van Loading TO LT"; Rec."Van Loading TO LT")
            // {
            //     ToolTip = 'Specifies the value of the Van Loading TO field.';
            //     ApplicationArea = All;
            // }
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
}