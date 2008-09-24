program fitrunner;

{$APPTYPE CONSOLE}

uses
  FileRunner,
  SysUtils,
  Classes;

var
  args : TStringList;
  i : Integer;
begin
  args := TStringList.Create;
  for i := 0 to ParamCount do
    args.Add(ParamStr(i));
  try
    TFileRunner.main(args);
  finally
    args.Free;
  end;
end.

