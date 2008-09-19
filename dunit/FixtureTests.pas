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
unit FixtureTests;

interface

uses
  TestFrameWork,
  Fixture,
  classes,
  sysUtils,
  windows,
  Parse;

type
  T2dArrayOfString = array of array of string;
  TStringArray = array of string;

  TFixtureTests = class(TTestCase)
  private
    class function makeFixtureTable(table : T2dArrayOfString) : string;
  public
    class function executeFixture(table : T2dArrayOfString) : TParse;
  published
    procedure TestdoTablesPass;
    procedure TestdoTablesFail;
    procedure TestdoTablesException;
    procedure TestdoTablesIgnore;
    procedure TestCheck;
    procedure testEmptyCounts;
    procedure testTally;
    procedure testRuntime;
    //    procedure testRunTimeOneSec;
    procedure testFixctureCounts;
    procedure testCreate;
  end;

{$METHODINFO ON}
  TFixtureOne = class(TFixture)
  end;

  FixtureTwo = class(TFixture)
  end;

  TheThirdFixture = class(TFixture)
  end;
{$METHODINFO OFF}

implementation

uses
  Runtime,
  Counts,
  FitFailureException;

type
  PassFixture = class(TFixture)
  public
    procedure doTable(tables : TParse); override;
  end;

  FailFixture = class(TFixture)
  public
    procedure doTable(tables : TParse); override;
  end;

  IgnoreFixture = class(TFixture)
  public
    procedure doTable(tables : TParse); override;
  end;

  ExceptionFixture = class(TFixture)
  public
    procedure doTable(tables : TParse); override;
  end;

  TTestObject = class
  public
    Field : Integer;
    constructor Create;
  end;

procedure TFixtureTests.testEmptyCounts;
var
  theCounts : TCounts;
begin
  theCounts := TCounts.Create;
  checkEquals('0 right, 0 wrong, 0 ignored, 0 exceptions', theCounts.toString);
  theCounts.Free;
end;

procedure TFixtureTests.testFixctureCounts;
var
  theFixture : TFixture;
begin
  theFixture := TFixture.create;

  checkEquals('0 right, 0 wrong, 0 ignored, 0 exceptions', theFixture.counts.toString);

end;

procedure TFixtureTests.testRuntime;
var
  theRT : TRuntime;
begin
  theRT := TRuntime.Create;
  theRT.Start := getTickCount;
  checkEquals('0:00.00', theRT.toString);
  theRT.Free;
end;

{
procedure TFixtureTests.testRunTimeOneSec;
var
  theRT : TRuntime;
begin
  theRT := TRuntime.Create;
  theRT.Start := getTickCount;
  Sleep(1000);
  check((theRT.elapsed > 500) and (theRT.Elapsed < 1500));
  theRT.Free;
end;
}

procedure TFixtureTests.testTally;
var
  theCounts, source : TCounts;
begin
  theCounts := TCounts.Create;
  source := TCounts.Create;
  source.right := 5;
  source.wrong := 5;
  source.ignores := 5;
  source.exceptions := 5;
  theCounts.tally(source);
  checkEquals(5, theCounts.right);
  checkEquals(5, theCounts.wrong);
  checkEquals(5, theCounts.ignores);
  checkEquals(5, theCounts.exceptions);
  theCounts.Free;
end;

procedure TFixtureTests.TestCheck;
begin

end;

procedure TFixtureTests.testCreate;
var
  instance : TTestObject;
  theClass : TClass;
begin
  theClass := TTestObject;
  instance := TTestObject(theClass.NewInstance);
  try
    CheckEquals(0, instance.Field);
  finally
    instance.FreeInstance;
  end;
end;

procedure TFixtureTests.TestdoTablesPass;
var
  theFixture : TFixture;
  theTable : TParse;
  passFixture : string;
begin
  passFixture := '<table><tr><td>PassFixture</td></tr></table>';
  theTable := TParse.Create(passFixture);
  theFixture := TFixture.Create;
  theFixture.doTables(theTable);

  check(pos('"pass"', theTable.Tag) > 0, 'Class pass was not found ' + theTable.tag);
  checkEquals(1, theFixture.Counts.right);

end;

{ FixtureTests }

procedure TFixtureTests.TestdoTablesFail;
var
  theFixture : TFixture;
  theTable : TParse;
  passFixture : string;
begin
  passFixture := '<table><tr><td>FailFixture</td></tr></table>';
  theTable := TParse.Create(passFixture);
  theFixture := TFixture.Create;
  theFixture.doTables(theTable);

  check(pos(' class="fail"', theTable.Tag) > 0, 'Class fail was not found ' + theTable.tag);
  checkEquals(1, theFixture.Counts.wrong);
  check(pos('test failed', theTable.text) > 0, 'failure message not found');

end;

procedure TFixtureTests.TestdoTablesException;
var
  fixture : TFixture;
  table : TParse;
  passFixture : string;
begin
  passFixture := '<table><tr><td>ExceptionFixture</td></tr></table>';
  table := TParse.Create(passFixture);
  fixture := TFixture.Create;
  fixture.doTables(table);

  check(pos('Test exception from Exception Fixture', table.body) > 0, 'Exception message was not found ' + table.body);
  check(pos('class="error"', table.Tag) > 0, 'class error was not found ' + table.tag);
  checkEquals(1, fixture.Counts.exceptions);
end;

procedure TFixtureTests.TestdoTablesIgnore;
var
  theFixture : TFixture;
  theTable : TParse;
  passFixture : string;
begin
  passFixture := '<table><tr><td>IgnoreFixture</td></tr></table>';
  theTable := TParse.Create(passFixture);
  theFixture := TFixture.Create;
  theFixture.doTables(theTable);

  check(pos(' class="ignore"', theTable.Tag) > 0, 'class ignore was not found ' + theTable.tag);
  checkEquals(1, theFixture.Counts.ignores);

end;

class function TFixtureTests.executeFixture(table : T2dArrayOfString) : TParse;
var
  pageString : string;
  page : TParse;
  fixture : TFixture;
begin
  pageString := makeFixtureTable(table);
  page := TParse.Create(pageString);
  fixture := TFixture.Create();
  fixture.doTables(page);
  fixture.Free;
  result := page;
end;

class function TFixtureTests.makeFixtureTable(table : T2dArrayOfString) : string;
var
  buf : string;
  ri : Integer;
  ci : Integer;
  cell : string;
begin
  buf := '';
  buf := buf + '<table>'#10;
  for ri := Low(table) to High(table) do
  begin
    buf := buf + '  <tr>';
    for ci := Low(table[ri]) to High(table[ri]) do
    begin
      cell := table[ri][ci];
      buf := buf + '<td>' + cell + '</td>';
    end;
    buf := buf + '</tr>'#10;
  end;
  buf := buf + '</table>'#10;
  result := buf;
end;

{ PassFixture }

procedure PassFixture.doTable(tables : TParse);
begin
  right(tables);
end;

{ FailFixture }

procedure FailFixture.doTable(tables : TParse);
begin
  wrong(tables, 'test failed');
end;

{ PassFixture }

procedure IgnoreFixture.doTable(tables : TParse);
begin
  ignore(tables);
end;

{ PassFixture }

procedure ExceptionFixture.doTable(tables : TParse);
var
  e : Exception;
begin
  e := TFitFailureException.create('Test exception from Exception Fixture');
  doException(tables, e);
end;

constructor TTestObject.Create;
begin
  inherited;
  Field := 11;
end;

initialization

  registerTest(TFixtureTests.Suite);
  classes.RegisterClass(PassFixture);
  classes.RegisterClass(failFixture);
  classes.RegisterClass(IgnoreFixture);
  classes.RegisterClass(ExceptionFixture);
  classes.RegisterClass(TFixtureOne);
  classes.RegisterClass(FixtureTwo);
  classes.RegisterClass(TheThirdFixture);

end.

