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
// Modified or written by Object Mentor, Inc. for inclusion with FitNesse.
// Copyright (c) 2002 Cunningham & Cunningham, Inc.
// Released under the terms of the GNU General Public License version 2 or later.
unit FriendlyErrorTest;

interface

uses
  StrUtils,
  SysUtils,
  TestFramework;

type
  TFriendlyErrorTest = class(TTestCase)
  published
    procedure testCantFindFixture;
    procedure testExceptionInMethod;
    procedure testNoSuchMethod;
    procedure testParseFailure;
  end;

implementation

uses
  Parse,
  Fixture,
  FixtureTests;

//Test the FitFailureException mechanism.  If this works, then all of the FitFailureException derivatives ought
//to be working too.

procedure TFriendlyErrorTest.testCantFindFixture();
var
  pageString : string;
  page : TParse;
  fixture : TFixture;
  fixtureName : string;
begin
  pageString := '<table><tr><td>NoSuchFixture</td></tr></table>';
  page := TParse.Create(pageString);
  fixture := TFixture.Create();
  fixture.doTables(page);
  fixtureName := page.at(0, 0, 0).body;
  CheckTrue(Pos('Could not find fixture: NoSuchFixture.', fixtureName) <> 0);
end;

procedure TFriendlyErrorTest.testNoSuchMethod();
var
  page : TParse;
  columnHeader : string;
  table : T2dArrayOfString;
begin
  SetLength(table, 2);
  SetLength(table[0], 1);
  SetLength(table[1], 1);
  table[0][0] := 'fitnesse.fixtures.ColumnFixtureTestFixture';
  table[1][0] := 'no such method?';

  page := TFixtureTests.executeFixture(table);
  columnHeader := page.at(0, 1, 0).body;
  CheckTrue(Pos('Could not find method: no such method?.', columnHeader) <> 0);
end;

procedure TFriendlyErrorTest.testParseFailure();
var
  page : TParse;
  table : T2dArrayOfString;
  colTwoResult : string;
begin
  SetLength(table, 3);
  SetLength(table[0], 1);
  SetLength(table[1], 2);
  SetLength(table[2], 2);
  table[0][0] := 'fitnesse.fixtures.ColumnFixtureTestFixture';
  table[1][0] := 'input';
  table[1][1] := 'output?';
  table[2][0] := '1';
  table[2][1] := 'alpha';
  page := TFixtureTests.executeFixture(table);
  colTwoResult := page.at(0, 2, 1).body;
  page.Free;
  CheckTrue(Pos('Could not parse: alpha expected type: Integer', colTwoResult) <> 0);
end;

procedure TFriendlyErrorTest.testExceptionInMethod();
var
  page : TParse;
  table : T2dArrayOfString;
  colTwoResult : string;
begin
  SetLength(table, 3);
  SetLength(table[0], 1);
  SetLength(table[1], 2);
  SetLength(table[2], 2);
  table[0][0] := 'fitnesse.fixtures.ColumnFixtureTestFixture';
  table[1][0] := 'input';
  table[1][1] := 'exception?';
  table[2][0] := '1';
  table[2][1] := 'true';
  page := TFixtureTests.executeFixture(table);
  colTwoResult := page.at(0, 2, 1).body;
  CheckTrue(Pos('I thowed up', colTwoResult) <> -1);
end;

initialization

  registerTest(TFriendlyErrorTest.Suite);

end.

