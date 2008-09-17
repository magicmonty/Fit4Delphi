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
unit ColumnFixtureTests;

interface

uses
  ColumnFixture,
  TestFrameWork;

type

{$METHODINFO ON}
  TColumnTestFixture = class(TColumnFixture)
  public
    FField : integer;
    FstringField : String;
    constructor Create; override; 
  published
    function method : Integer;
    property field : Integer read FField write FField;
    function stringMethod : String;
    property stringField : String read FstringField write FstringField;
  end;
{$METHODINFO OFF}

  TColumnFixtureTests = class(TTestCase)
  private
    fixture : TColumnTestFixture;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure testBindColumnToMethod;
    procedure testBindColumnToField;
    procedure testBindColumnToFieldSymbol;
    procedure testBindColumnToMethodSymbol;
    procedure testGracefulColumnNames;
    procedure testDoTable;

  end;

implementation

uses
  Field,
  Method,
  TypeAdapter,
  parse,
  sysUtils,
  fixture,
  classes,
  Variants,
  Binding;

{ TestFixture }

constructor TColumnTestFixture.Create;
begin
  inherited;
  FField := 0;
end;

function TColumnTestFixture.method : Integer;
begin
  Result := 86;
end;

function TColumnTestFixture.stringMethod : String;
begin
  result := '';
end;

{ ColumnFixtureTests }

procedure TColumnFixtureTests.SetUp;
begin
  inherited;
  fixture := TColumnTestFixture.Create;
end;

procedure TColumnFixtureTests.TearDown;
begin
  inherited;
  fixture.Free;
end;

procedure TColumnFixtureTests.testBindColumnToMethod;
var
  i : integer;
  table, tableHead : TParse;
  method : TMethod;
const
  methodSpecifiers : array[0..5] of string = ('method()', 'method?', 'method!', 'string method()', 'string method?',
    'string method!');
  resultingMethodName : array[0..5] of string = ('method', 'method', 'method', 'stringMethod', 'stringMethod',
    'stringMethod');
begin
  for i := 0 to length(methodSpecifiers) - 1 do
  begin
    table := TParse.Create('<table><tr><td>' + methodSpecifiers[i] + '</td></tr></table>');
    tableHead := table.parts.parts;
    fixture.bind(tableHead);
    CheckNotNull(fixture.columnBindings[0], methodSpecifiers[i] + ' no binding found.');
    method := fixture.columnBindings[0].adapter.method;
    CheckNotNull(method, methodSpecifiers[i] + 'no method found.');
    CheckEquals(resultingMethodName[i], method.Name);
  end;
end;

procedure TColumnFixtureTests.testBindColumnToField();
var
  table, tableHead : TParse;
  field : TField;
begin
  table := TParse.Create('<table><tr><td>field</td></tr></table>');
  tableHead := table.parts.parts;
  fixture.bind(tableHead);
  CheckNotNull(fixture.columnBindings[0]);
  field := fixture.columnBindings[0].adapter.field;
  CheckNotNull(field);
  CheckEquals('field', field.FieldName);
end;

procedure TColumnFixtureTests.testGracefulColumnNames();
var
  table : TParse;
  tableHead : TParse;
  field : TField;
begin
  table := TParse.Create('<table><tr><td>string field</td></tr></table>');
  tableHead := table.parts.parts;
  fixture.bind(tableHead);
  CheckNotNull(fixture.columnBindings[0]);
  field := fixture.columnBindings[0].adapter.field;
  CheckNotNull(field);
  CheckEquals('stringField', field.FieldName);
end;

procedure TColumnFixtureTests.testBindColumnToFieldSymbol();
var
  table : TParse;
  rows : TParse;
  binding : TBinding;
  field : TField;
begin
  Fixture.setSymbol('Symbol', '42');
  table := TParse.Create('<table><tr><td>field=</td></tr><tr><td>Symbol</td></tr></table>');
  rows := table.parts;
  fixture.doRows(rows);
  binding := fixture.columnBindings[0];
  CheckNotNull(binding);
  CheckEquals(TRecallBinding, binding.ClassType);
  field := binding.adapter.field;
  CheckNotNull(field);
  CheckEquals('field', field.FieldName);
  CheckEquals(42, fixture.field);
end;

procedure TColumnFixtureTests.testBindColumnToMethodSymbol();
var
  table : TParse;
  rows : TParse;
  binding : TBinding;
  method : TMethod;
begin
  table := TParse.Create('<table><tr><td>=method?</td></tr><tr><td>MethodSymbol</td></tr></table>');
  rows := table.parts;
  fixture.doRows(rows);
  binding := fixture.columnBindings[0];
  CheckNotNull(binding);
  CheckEquals(TSaveBinding, binding.ClassType);
  method := binding.adapter.method;
  CheckEquals('method', method.Name);
  CheckEquals('86', Fixture.getSymbol('MethodSymbol'));
end;

procedure TColumnFixtureTests.testDoTable;
var
  parse   : TParse;
  fixture : TFixture;
begin
  parse :=
    TParse.create('<table><tr><td>TColumnTestFixture</td></tr>' +
      '<tr><td>field</td><td>method()</td></tr>' +
      '<tr><td>1</td><td>2</td></tr>' +
      '<tr><td>2</td><td>86</td></tr></table>');
  fixture := TFixture.Create;
  try
    fixture.doTables(parse);

    checkEquals(1, fixture.Counts.right, 'wrong tally for rights');
    checkEquals(1, fixture.Counts.wrong, 'wrong tally for wrongs');
  finally
    fixture.Free;
  end;

end;

initialization

  TestFramework.RegisterTest('uColumnFixtureTests Suite',
    TColumnFixtureTests.Suite);
  classes.RegisterClass(TColumnTestFixture);

end.

