{
  Export MGEF (Magic Effect) records to a CSV file
}

unit ExportMagicEffects;

interface

uses xEditAPI;

implementation

var
  sl: TStringList;

function Initialize: integer;
begin
  sl := TStringList.Create;
  // Add CSV Header columns - must match Process() row exactly
  sl.Add('EditorID;FormID;Name;BaseCost;noMag;noDur;affectMag;affectDur;Hostile;Keywords;Description');
  Result := 0;
end;

function GetKeywords(e: IInterface): string;
var
  kwdaElem, entry, kywdRecord: IInterface;
  i: integer;
  kwds: TStringList;
begin
  Result := '';
  kwdaElem := ElementBySignature(e, 'KWDA');
  if not Assigned(kwdaElem) then Exit;

  kwds := TStringList.Create;
  try
    for i := 0 to Pred(ElementCount(kwdaElem)) do begin
      entry := ElementByIndex(kwdaElem, i);
      kywdRecord := LinksTo(entry);      // resolves the FormID reference to the actual KYWD record
      if Assigned(kywdRecord) then
        kwds.Add(GetElementEditValues(kywdRecord, 'EDID'));
    end;
    Result := kwds.CommaText;
  finally
    kwds.Free;
  end;
end;

function Process(e: IInterface): integer;
var
  editorID, formID, fullName, baseCost, desc, noDur, noMag, aftDur, aftMag, hostile, kwds: string;
begin
  Result := 0;
  if Signature(e) <> 'MGEF' then Exit;

  editorID := GetElementEditValues(e, 'EDID');
  formID   := IntToHex(FixedFormID(e), 8);
  fullName := GetElementEditValues(e, 'FULL');
  baseCost := GetElementEditValues(e, 'Magic Effect Data\DATA\Base Cost');
  noMag    := GetElementEditValues(e, 'Magic Effect Data\DATA\Flags\No Magnitude');
  noDur    := GetElementEditValues(e, 'Magic Effect Data\DATA\Flags\No Duration');
  aftMag   := GetElementEditValues(e, 'Magic Effect Data\DATA\Flags\Power Affects Magnitude');
  aftDur   := GetElementEditValues(e, 'Magic Effect Data\DATA\Flags\Power Affects Duration');
  hostile  := GetElementEditValues(e, 'Magic Effect Data\DATA\Flags\Hostile');
  desc     := StringReplace(GetElementEditValues(e, 'DNAM'), '"', '""', [rfReplaceAll]);
  kwds     := GetKeywords(e);

  // Add row to string list - column order/count must match header
  sl.Add(Format('%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s',
    [editorID, formID, fullName, baseCost, noMag, noDur, aftMag, aftDur, hostile, kwds, desc]));
end;

function Finalize: integer;
begin
  sl.SaveToFile(ProgramPath + 'MagicEffects.csv');
  sl.Free;
  AddMessage('Export complete: ' + ProgramPath + 'MagicEffects.csv');
  Result := 0;
end;

end.





