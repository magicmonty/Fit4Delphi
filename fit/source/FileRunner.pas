// Fit4Delphi Copyright (C) 2008. Sabre Inc.
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program;
// if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
//
// Ported to Delphi by Michal Wojcik.
//
// Copyright (c) 2002 Cunningham & Cunningham, Inc.
// Released under the terms of the GNU General Public License version 2 or later.
// Ported to Delphi by Salim Nair.
unit FileRunner;

interface
uses
  classes,
  Fixture,
  Parse,
  sysutils;

type
  TFileRunner = class(TObject)
  private
    Finput : TStringList;
    FTables : TParse;
    FFixture : TFixture;
    FOutput : TStringList;
    FInputFile, FOutputFile : TFileName;
    procedure doArgs(args : TStringList);
    procedure exit;
  protected
    procedure process; virtual;
    procedure doException(e : Exception);
  public
    constructor Create;
    destructor Destroy; override;
    class procedure main(args : TStringList);
    procedure run(args : TStringList);
    property input : TStringList read Finput write Finput;
    property Output : TStringList read FOutput write FOutput;

    property tables : TParse read FTables write FTables;
    property fixture : TFixture read FFixture write FFixture;

  end;

implementation

uses
  Windows;

{ TFileRunner }

constructor TFileRunner.Create;
begin
  fixture := TFixture.Create;
  Finput := TStringList.Create;
  FOutPut := TStringList.Create;
end;

class procedure TFileRunner.main(args : TStringList);
var
  theRunner : TFileRunner;
begin
  theRunner := TFileRunner.Create;
  theRunner.run(args);
  theRunner.Free;
end;

procedure TFileRunner.run(args : TStringList);
begin
  doArgs(args);
  process;
  exit;
end;

procedure TFileRunner.process;
begin
  try
    tables := TParse.Create(input.Text);
    fixture.doTables(tables);
  except
    on e : Exception do
      doException(e);
  end;

  tables.print(output);
end;

destructor TFileRunner.Destroy;
begin
  fixture.Free;
  Finput.Free;
  FOutput.Free;
  inherited;
end;

procedure TFileRunner.doArgs(args : TStringList);
begin
  if (args.Count <> 2) then
    raise Exception.Create('Usage: TFileRunner.main input-file output-file');

  FInputFile := args[0];
  FOutputFile := args[1];
  Input.loadFromFile(args[0]);
  fixture.Summary.Add('input file=' + ExpandFileName(args[0]));
  fixture.Summary.Add('input update=' + dateToStr(now));
  fixture.Summary.Add('output file=' + ExpandFileName(args[1]));

  try
    input.LoadFromFile(FInputFile);
    output.SaveToFile(FOutputFile);
  except
    on e : Exception do
    begin
      WriteLn(e.Message);
      Halt(1); // TODO -1
    end;
  end;
end;

procedure TFileRunner.doException(e : Exception);
var
  tables : TParse;
begin
  tables := TParse.Create('body', 'Unable to parse input. Input ignored.', nil, nil);
  fixture.doException(tables, e);
end;

procedure TFileRunner.exit();
begin
  output.SaveToFile(FOutputFile);
{$IF DEF CONSOLE}
  Writeln(fixture.counts.toString);
  Halt(fixture.counts.wrong + fixture.counts.exceptions);
{$IFEND}
end;

end.

