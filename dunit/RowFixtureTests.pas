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
// Moved to Delphi and updated to Fit 20070619 by Michal Wojcik, Sabre
unit RowFixtureTests;

interface

uses
  Variants,
  RowFixture,
  TestFrameWork,
  Classes,
  Contnrs,
  Binding;

type
{$METHODINFO ON}
  TSimpleRowFixture = class(TRowFixture)
  public
    function query : TList; override;
    function getTargetClass() : TClass; override;
  end;

  TTestRowFixture = class(TRowFixture)
  public
    function query : TList; override;
    function getTargetClass() : TClass; override;
    procedure SetColumnBinding(aColumnBinding : TBinding);
  end;
{$METHODINFO OFF}

  TRowFixtureTests = class(TTestCase)
  private
    // TODO Disabled as Variant ArrayOleStr cannot be easily converted to String
    procedure testMatch;
  published
    procedure testBindColumnToField;
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

type
{$METHODINFO ON}
  TSimpleBusinessObject = class
  protected
    Ffield : Integer;
  published
    property field : Integer read FField write FField;
  end;

  TStringArray = array of string;

  TBusinessObject = class
  private
    strs : TStringArray;
  public
    constructor Create(astrs : array of string);
  published
    function getStrings() : TStringArray;
    function getStringsV() : Variant;
  end;
{$METHODINFO OFF}

  { TRowFixtureTests }

procedure TRowFixtureTests.testBindColumnToField;
var
  fixture : TRowFixture;
  table : TParse;
  tableHead : TParse;
  field : TField;
begin
  fixture := TSimpleRowFixture.Create();
  table := TParse.Create('<table><tr><td>field</td></tr></table>');
  tableHead := table.parts.parts;
  fixture.bind(tableHead);
  CheckNotNull(fixture.columnBindings[0]);
  field := fixture.columnBindings[0].adapter.field;
  CheckNotNull(field);
  CheckEquals('field', field.FieldName);
  CheckEquals(Ord(tkInteger), Ord(field.FieldType));
end;

//TODO

procedure TRowFixtureTests.testMatch();
var
  fixture : TTestRowFixture;
  arrayAdapter : TTypeAdapter;
  binding : TBinding;
  computed : TList;
  expected : TList;
begin

  (*
  Now back to the bug I found: The problem stems from the fact
  that java doesn't do deep equality for arrays. Little known to
  me (I forget easily ;-), java arrays are equal only if they
  are identical. Unfortunately the 2 sort methods returns a map
  that is directly keyed on the value of the column without
  considering this little fact. Conclusion there is a missing
  and a surplus row where there should be one right row.
  -- Jacques Morel
  *)

  fixture := TTestRowFixture.Create();
  arrayAdapter := TTypeAdapter.AdapterOn(fixture, TMethod.Create(TBusinessObject, 'getStringsV')); //, new class [0])); // TODO should be getStrings
  binding := TQueryBinding.Create();
  binding.adapter := arrayAdapter;
  fixture.SetColumnBinding(binding); //    fixture.columnBindings = new Binding[]{binding};

  computed := TList.Create; //LinkedList();
  computed.add(TBusinessObject.Create(['1']));
  expected := TList.Create; //LinkedList();
  expected.add(TParse.Create('tr', '', TParse.Create('td', '1', nil, nil), nil));
  fixture.match(expected, computed, 0);
  CheckEquals(1, fixture.counts.right, 'right');
  CheckEquals(0, fixture.counts.exceptions, 'exceptions');
  CheckEquals(0, fixture.missing.Count, 'missing');
  CheckEquals(0, fixture.surplus.Count, 'surplus');
end;

procedure TRowFixtureTests.testDoTable;
var
  theParse : TParse;
  theFixture : TFixture;
begin
  theParse := TParse.create(
    '<table border="1" cellspacing="0">' +
    '<tbody><tr><td colspan="5">TSimpleRowFixture</td></tr>' +
    '<tr><td>field</td></tr>' +
    '<tr><td>2</td></tr>' +
    '<tr><td>3</td></tr>' +
    '</tbody></table>'
    );
  theFixture := TFixture.Create;
  theFixture.doTables(theParse);

  checkEquals(1, theFixture.Counts.right, 'wrong tally for rights');
  checkEquals(1, theFixture.Counts.wrong, 'wrong tally for wrongs');

end;

{ TRowTestFixture }

function TSimpleRowFixture.getTargetClass : TClass;
begin
  Result := TSimpleBusinessObject;
end;

function TSimpleRowFixture.query : TList;
var
  obj : TSimpleBusinessObject;
begin
  Result := TList.Create;
  obj := TSimpleBusinessObject.Create;
  obj.field := 2;
  Result.Add(obj);
end;

{ TTestRowFixture }

function TTestRowFixture.getTargetClass : TClass;
begin
  Result := TBusinessObject;
end;

function TTestRowFixture.query : TList;
begin
  Result := TList.Create;
end;

procedure TTestRowFixture.SetColumnBinding(aColumnBinding : TBinding);
begin
  FColumnBindings.Clear;
  FColumnBindings.Add(aColumnBinding);
end;

{ TBusinessObject }

constructor TBusinessObject.Create(astrs : array of string);
var
  i : Integer;
begin
  inherited Create;
  SetLength(strs, Length(astrs));
  for i := 0 to Length(astrs) - 1 do
    strs[i] := astrs[i];
end;

function TBusinessObject.getStrings : TStringArray;
begin
  Result := strs;
end;

function TBusinessObject.getStringsV: Variant;
begin
  DynArrayToVariant(Result, getStrings, TypeInfo(TStringArray));
end;

initialization

  TestFramework.RegisterTest(TRowFixtureTests.Suite);

  classes.RegisterClass(TSimpleRowFixture);

end.

