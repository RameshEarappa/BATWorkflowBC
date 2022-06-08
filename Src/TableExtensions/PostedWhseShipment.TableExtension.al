tableextension 50115 "Posted Whse Shipment Ext" extends "Posted Whse. Shipment Header"
{
    fields
    {
        field(60000; "Sell-to Customer No. LT"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Sell-to Customer No.';
        }
        field(60001; "Sell-to Customer Name LT"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Sell-to Customer Name';
        }
        field(60003; Branch; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Branch';
        }
        field(60004; "Ship-to Code LT"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Ship-to Code';
        }
        field(60005; "Bill-to Post Code LT"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Bill-to Post Code';
        }
        field(60006; "Ship-to Post Code LT"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Ship-to Post Code';
        }
        field(60007; "Total Volume MC LT"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Total Volume MCube';
        }
        field(60008; "Total Outer MC LT"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Total Outer MC';
        }
        field(60009; "Total Pack MC LT"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Total Pack MC';
        }
        field(60010; "SO Shipment LT"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'SO Shipment';
        }
        field(60011; "Number of Service LT"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Number of Service';
        }
        field(60012; "Shipment Group Code LT"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipment Group Code';
        }
        field(60013; "Last Update Time Stamp LT"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Last Update Time Stamp';
        }
        field(60014; "Ship-to Name LT"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Ship to Name';
        }
        field(60015; "Shipping Time LT"; DateFormula)
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Time';
        }
        field(60016; "Ship-to City LT"; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Ship-to City';
        }
        field(60017; "Bill-to City LT"; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Bill-to City';
        }
    }
}