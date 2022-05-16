codeunit 50103 "Extended Approval Entry"
{
    Permissions = tabledata "Approval Entry" = rimd;

    procedure SwapApprovalUser(TransferHeaderP: Record "Transfer Header")
    var
        ApprovalEntryRecL: Record "Approval Entry";
        LocationL: Record Location;
    begin
        if LocationL.Get(TransferHeaderP."Transfer-from Code") then begin
            ApprovalEntryRecL.RESET;
            ApprovalEntryRecL.SETRANGE("Record ID to Approve", TransferHeaderP.RecordId);
            ApprovalEntryRecL.SETFILTER(Status, '%1|%2', ApprovalEntryRecL.Status::Open, ApprovalEntryRecL.Status::Created);
            ApprovalEntryRecL.SETRANGE("Sequence No.", 1);
            IF ApprovalEntryRecL.FINDFIRST THEN BEGIN
                ApprovalEntryRecL."Approver ID" := LocationL.Executive;
                ApprovalEntryRecL.Modify();
            end;
        end;
    end;
}