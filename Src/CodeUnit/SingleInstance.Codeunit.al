codeunit 50109 "Single Instance"
{
    SingleInstance = true;

    procedure SetIsFinance(IsFinance: Boolean)
    begin
        Finance := IsFinance;
        IsFinance := false;
    end;

    procedure GetIsFinance(): Boolean
    begin
        exit(Finance);
    end;

    var
        Finance: Boolean;
}