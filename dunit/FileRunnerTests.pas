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
unit fileRunnerTests;

interface

uses
  Fixture,
  TestFrameWork,
  Parse,
  FileRunner,
  classes,
  ColumnFixture;

type
  FileRunnerTest = class(TTestCase)
  published
    procedure testParseArgsInput;
  end;

{$METHODINFO ON}
  FileRunnerTestFixture = class(TColumnFixture)
  private
    function getTheField : integer;
    procedure setTheField(const Value : integer);
  public
    FField : integer;
    StringField : string;
    function stringMethod : string;
  published
    function theMethod : integer;
    property theField : integer read getTheField write setTheField;
  end;

  SumFixture = class(TColumnFixture)
  private
    FFirstValue, FSecondValue : integer;
    function getFirstValue : integer;
    function getSecondValue : integer;
    procedure setFirstValue(const Value : integer);
    procedure setSecondValue(const Value : integer);
  published
    property firstValue : integer read getFirstValue write setFirstValue;
    property secondValue : integer read getSecondValue write setSecondValue;
    function sum : integer;
  end;
{$METHODINFO OFF}

implementation

uses sysUtils;

{ FileRunnerTest }

procedure FileRunnerTest.testParseArgsInput;
var
  theRunner : TFileRunner;
  args : TStringList;
  fileContent : TStringList;
begin
  theRunner := TFileRunner.Create;
  args := TStringList.Create;
  fileCOntent := TStringList.Create;
  fileContent.LoadFromFile('runnerResults.txt');
  args.Add('fitrunner.exe');
  args.Add('runnertest.htm');
  args.Add('runnerResults.htm');
  theRunner.run(args);

  checkEquals(fileContent.text, theRunner.Output.text);
  //TODO  checkEquals( 'runnertest.txt', theRunner.theFixture.Summary.values[ 'input file' ] );
end;

{ TestFixture }

function FileRunnerTestFixture.getTheField : integer;
begin
  result := 90;
end;

function FileRunnerTestFixture.theMethod : integer;
begin
  result := FField + 1;
end;

procedure FileRunnerTestFixture.setTheField(const Value : integer);
begin
  FField := Value;
end;

function FileRunnerTestFixture.stringMethod : string;
begin
  result := emptyStr;
end;

{
function FileRunnerTestFixture.theMethod: Variant;
begin
  Result := gettheMethod;
end;
}
{ SumFixture }

function SumFixture.getFirstValue : integer;
begin
  result := FFirstValue;
end;

function SumFixture.getSecondValue : integer;
begin
  result := FSecondValue;
end;

function SumFixture.sum : integer;
begin
  result := FFirstValue + FSecondValue;
end;

procedure SumFixture.setFirstValue(const Value : integer);
begin
  FFirstValue := Value;
end;

procedure SumFixture.setSecondValue(const Value : integer);
begin
  FSecondValue := Value;
end;

initialization

  TestFramework.RegisterTest('Filerunner tests', FileRunnerTest.Suite);

  classes.RegisterClass(FileRunnerTestFixture);
  classes.RegisterClass(SumFixture);

end.

