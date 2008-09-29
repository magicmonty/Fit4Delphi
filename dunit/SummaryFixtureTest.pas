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
unit SummaryFixtureTest;

interface

uses
  Variants,
  SummaryFixture,
  TestFrameWork,
  Classes,
  Contnrs,
  Binding;

type
  TSummaryFixtureTests = class(TTestCase)
  private
  published
    procedure testDoTable;
  end;

implementation

uses
  Field,
  Method,
  TypInfo,
  Parse,
  SysUtils,
  Fixture,
  TypeAdapter,
  ColumnFixture;

procedure TSummaryFixtureTests.testDoTable;
var
  theParse : TParse;
  theFixture : TFixture;
begin
  theParse := TParse.create(
    '<table><tbody>' +
    '<tr><td colspan=r"3">TActionFixture</td></tr>' +
    '<tr><td>start</td><td>TBrowser</td><td>&nbsp;</td></tr>' +
    '<tr><td>check</td><td>total songs</td><td>37</td></tr>' +
    '</tbody></table>'+
    '<table><tbody>' +
    '<tr><td colspan=r"3">TSummaryFixture</td></tr>' +
    '<tr><td>start</td><td>TBrowser</td><td>&nbsp;</td></tr>' +
    '<tr><td>check</td><td>total songs</td><td>37</td></tr>' +
    '</tbody></table>');
  theFixture := TFixture.Create;
  theFixture.doTables(theParse);

  checkEquals(0, theFixture.Counts.right, 'wrong tally for rights');
  checkEquals(1, theFixture.Counts.wrong, 'wrong tally for wrongs');
  checkEquals(0, theFixture.Counts.exceptions, 'wrong tally for exceptions');
end;

{ TRowTestFixture }

initialization

  TestFramework.RegisterTest(TSummaryFixtureTests.Suite);

end.

