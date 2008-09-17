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
unit BindingTest;

interface

uses
  StrUtils,
  Parse,
  TestFramework,
  Fixture,
  RegexTest;

type
  {$METHODINFO ON}
  TTestFixture = class(TFixture)
  protected
    FintField : Integer;
  published
    property intField : Integer read FintField write FintField;
    function intMethod() : Variant;
  end;
  {$METHODINFO OFF}

  TBindingTest = class(TRegexTest)
	private
    fixture : TTestFixture;
    cell1   : TParse;
    cell2   : TParse;
    cell3   : TParse;
    cell4   : TParse;
  protected
    procedure SetUp(); override;
    procedure checkForMethodBinding(name : String; expected : boolean);
    procedure checkForFieldBinding(name : String; expected : boolean);
  published
    procedure testConstruction();
    procedure testQueryBinding();
    procedure testSetBinding();
    procedure testQueryBindingWithBlackCell();
    procedure testRecallBinding();
    procedure testSaveBinding();
    procedure testRecallBindingSymbolTableText();
    procedure testUseOfGracefulNamingForMethods();
    procedure testUseOfGracefulNamingForFields();
  end;

implementation

uses
  NoSuchFieldFitFailureException,
  NoSuchMethodFitFailureException,
  Binding;

procedure TBindingTest.setUp();
var
  table : TParse;
begin
  fixture := TTestFixture.Create();
  table := TParse.Create('<table><tr><td>123</td><td>321</td><td>abc</td><td></td></tr></table>');
  cell1 := table.parts.parts;
  cell2 := table.parts.parts.more;
  cell3 := table.parts.parts.more.more;
  cell4 := table.parts.parts.more.more.more;
end;

procedure TBindingTest.testConstruction();
begin
  CheckEquals(Binding.TQueryBinding, TBinding.doCreate(fixture, 'intMethod()').ClassType);
  CheckEquals(Binding.TQueryBinding, TBinding.doCreate(fixture, 'intMethod?').ClassType);
  CheckEquals(Binding.TQueryBinding, TBinding.doCreate(fixture, 'intMethod!').ClassType);
  CheckEquals(Binding.TSetBinding, TBinding.doCreate(fixture, 'intField').ClassType);
  CheckEquals(Binding.TRecallBinding, TBinding.doCreate(fixture, 'intField=').ClassType);
  CheckEquals(Binding.TSaveBinding, TBinding.doCreate(fixture, '=intMethod()').ClassType);
  CheckEquals(Binding.TSaveBinding, TBinding.doCreate(fixture, '=intField').ClassType);
end;

procedure TBindingTest.testQueryBinding();
var
  binding : TBinding;
begin
  binding := TBinding.doCreate(fixture, 'intMethod()');
  binding.doCell(fixture, cell1);
  CheckEquals(1, fixture.counts.wrong);

  fixture.intField := 321;
  binding.doCell(fixture, cell2);
  CheckEquals(1, fixture.counts.right);
end;

procedure TBindingTest.testSetBinding();
var
  binding : TBinding;
begin
  binding := TBinding.doCreate(fixture, 'intField');
  binding.doCell(fixture, cell1);
  CheckEquals(123, fixture.intField);

  binding.doCell(fixture, cell2);
  CheckEquals(321, fixture.intField);
end;

procedure TBindingTest.testQueryBindingWithBlackCell();
var
  binding : TBinding;
begin
  binding := TBinding.doCreate(fixture, 'intField');
  binding.doCell(fixture, cell4);
  assertSubString('0', cell4.text());
end;

procedure TBindingTest.testSaveBinding();
var
  binding : TBinding;
begin
  binding := TBinding.doCreate(fixture, '=intMethod()');
  binding.doCell(fixture, cell1);
  CheckEquals('0', Fixture.getSymbol('123'));
  assertSubString('123  = 0', cell1.text());

  fixture.intField := 999;
  binding.doCell(fixture, cell2);
  CheckEquals('999', Fixture.getSymbol('321'));
end;

procedure TBindingTest.testRecallBinding();
var
  binding : TBinding;
begin
  binding := TBinding.doCreate(fixture, 'intField=');
  Fixture.setSymbol('123', '999');
  binding.doCell(fixture, cell1);
  CheckEquals(999, fixture.intField);

  binding.doCell(fixture, cell3);
  assertSubString('No such symbol: abc', cell3.text());
end;

procedure TBindingTest.testRecallBindingSymbolTableText();
var
  binding : TBinding;
begin
  binding := TBinding.doCreate(fixture, 'intField=');
  Fixture.setSymbol('123', '999');
  binding.doCell(fixture, cell1);
  CheckEquals('123  = 999', cell1.text());
end;

procedure TBindingTest.testUseOfGracefulNamingForMethods();
begin
  checkForMethodBinding('intMethod()', true);
  checkForMethodBinding('int Method?', true);
  checkForMethodBinding('int method?', true);
  checkForMethodBinding('intmethod?', false);
  checkForMethodBinding('Intmethod?', false);
  checkForMethodBinding('IntMethod?', false);
end;

procedure TBindingTest.testUseOfGracefulNamingForFields();
begin
  checkForFieldBinding('intField', true);
  checkForFieldBinding('int Field', true);
  checkForFieldBinding('int field', true);
  checkForFieldBinding('intfield', false);
  checkForFieldBinding('Intfield', false);
  checkForFieldBinding('IntField', false);
end;

procedure TBindingTest.checkForMethodBinding(name : String; expected : boolean);
var
  binding : TBinding;
begin
//  binding := nil;
  try
    binding := TBinding.doCreate(fixture, name);
  except
    on e : TNoSuchMethodFitFailureException do
    begin
      CheckFalse(expected, 'method not found');
      exit;
    end;
  end;
  CheckTrue(expected, 'method was found');
  CheckIs(binding, TQueryBinding);
  CheckEquals('intMethod', binding.adapter.method.Name);
  binding.Free;
end;

procedure TBindingTest.checkForFieldBinding(name : String; expected : boolean);
var
  binding : TBinding;
begin
//  binding := nil;
  try
    binding := TBinding.doCreate(fixture, name);
  except
    on e : TNoSuchFieldFitFailureException do
    begin
      CheckFalse(expected, 'field not found');
      exit;
    end;
  end;
  CheckTrue(expected, 'field was found');
  CheckIs(binding, TSetBinding);
  CheckEquals('intField', binding.adapter.field.FieldName);
  binding.Free;
end;

function TTestFixture.intMethod: Variant;
begin
  Result := intField;
end;

initialization
  registerTest( TBindingTest.Suite );

end.
