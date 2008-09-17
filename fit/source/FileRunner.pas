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
  TFileRunner = class( TObject )
  private
    Finput: TStringList;
    FTables: TParse;
    FFixture: TFixture;
    FOutput: TStringList;
    FInputFile, FOutputFile : TFileName;
    procedure Setinput(Value: TStringList);
    procedure setTables(const Value: TParse);
    procedure setFixture(const Value: TFixture);
    procedure SetOutput(Value: TStringList);
    procedure doArgs(args: TStringList);
    procedure process;

  public
    constructor Create;
    class procedure main( args : TStringList );
    procedure run( args : TStringList );
    property input: TStringList read Finput write Setinput;
    property Output: TStringList read FOutput write SetOutput;

    property tables : TParse read FTables write setTables;
    property theFixture : TFixture read FFixture write setFixture;

  end;

implementation

uses windows;

{ TFileRunner }

constructor TFileRunner.Create;
begin
  theFixture := TFixture.Create;
  Finput := TStringList.Create;
  FOutPut := TStringList.Create;
end;

class procedure TFileRunner.main(args: TStringList);
var theRunner : TFileRunner;
begin
  theRunner := TFileRunner.Create;
  theRunner.run( args );
  theRunner.Free;
end;

procedure TFileRunner.run( args : TStringList );
begin
  doArgs( args );
  process;
  exit;
end;

procedure TFileRunner.process;
begin
  try
    tables  := TParse.Create( input.Text );
    theFixture.doTables(tables);
  except on e: Exception do
      raise;
  end;

  tables.print(output);

  output.SaveToFile( FOutputFile );
end;


procedure TFileRunner.doArgs( args : TStringList );
begin
  if ( args.Count < 2 ) then
    raise Exception.Create( 'Usage: TFileRunner.main input-file output-file');

  FInputFile := args[ 0 ];
  FOutputFile := args[ 1 ];
  Input.loadFromFile( args[0] );
//@  theFixture.Summary.Add('input file=' + ExpandFileName( args[0] ));
//@  theFixture.Summary.Add('input update=' + dateToStr( now ) );
//@  theFixture.Summary.Add('output file=' + ExpandFileName( args[1] ) );

  input.LoadFromFile( args[0] );
  
end;

procedure TFileRunner.setFixture(const Value: TFixture);
begin
  FFixture := Value;
end;

procedure TFileRunner.Setinput(Value: TStringList);
begin
  FInput := Value;
end;

procedure TFileRunner.SetOutput(Value: TStringList);
begin
  FOutput := Value;
end;

procedure TFileRunner.setTables(const Value: TParse);
begin
  FTables := Value;
end;


end.
