{
  print ingredient name to console
}
unit printIngredientNames;
  
  function Initialize: integer;
  begin
    Result := 0;
    AddMessage('ID;Name');  
  end;

  function Process(e: IInterface): integer;
  begin
    Result := 0;

    // process only Ingredient, skip other records
    if Signature(e) <> 'INGR' then
      Exit;
    
      AddMessage(Format('%s;%s', [
        // FixedFormID depends only on explicit masters and not affected by plugin's load order
        IntToHex(FixedFormID(e), 8),
        GetElementEditValues(e, 'FULL - Name')
      ]));
  end;

  function Finalize: integer;

  begin
    Result := 0;
  end;
end.
