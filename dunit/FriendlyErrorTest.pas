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
  private
//    procedure testExceptionInMethod;
//    procedure testNoSuchMethod;
//    procedure testParseFailure;
  published
    procedure testCantFindFixture;
  end;

implementation

uses
  Parse, Fixture;

//Test the FitFailureException mechanism.  If this works, then all of the FitFailureException derivatives ought
//to be working too.
procedure TFriendlyErrorTest.testCantFindFixture();
var
  pageString : String;
  page  : TParse;
  fixture : TFixture;
  fixtureName : String;
begin
pageString := '<table><tr><td>NoSuchFixture</td></tr></table>';
    page := TParse.Create(pageString);
    fixture := TFixture.Create();
    fixture.doTables(page);
    fixtureName := page.at(0,0,0).body;
    CheckTrue(Pos('Could not find fixture: NoSuchFixture.', fixtureName) <> 0);
end;

(* TODO
procedure TFriendlyErrorTest.testNoSuchMethod();
var
  pageString : String;
  page  : TParse;
  fixture : TFixture;
  fixtureName : String;
begin
    final String[][] table := {
          {'fitnesse.fixtures.ColumnFixtureTestFixture'},
          {'no such method?'}
        };
    page := TFixtureTest.executeFixture(table);
    String columnHeader := page.at(0,1,0).body;
    CheckTrue(columnHeader.indexOf('Could not find method: no such method?.') !:= -1);
end;

procedure TFriendlyErrorTest.testParseFailure();
var
  pageString : String;
  page  : TParse;
  fixture : TFixture;
  fixtureName : String;
begin
    final String[][] table := {
          {'fitnesse.fixtures.ColumnFixtureTestFixture'},
          {'input','output?'},
          {'1',     'alpha'}
        };
    Parse page := FixtureTest.executeFixture(table);
    String colTwoResult := page.at(0,2,1).body;
    CheckTrue(colTwoResult.indexOf('Could not parse: alpha expected type: int') !:= -1);
end;

procedure TFriendlyErrorTest.testExceptionInMethod();
var
  pageString : String;
  page  : TParse;
  fixture : TFixture;
  fixtureName : String;
begin
    final String[][] table := {
          {'fitnesse.fixtures.ColumnFixtureTestFixture'},
          {'input','exception?'},
          {'1',    'true'}
        };
    Parse page := FixtureTest.executeFixture(table);
    String colTwoResult := page.at(0,2,1).body;
    CheckTrue(colTwoResult.indexOf('I thowed up') <> -1);
end;
*)

initialization

  registerTest(TFriendlyErrorTest.Suite);

end.

