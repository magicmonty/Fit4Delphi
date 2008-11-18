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
unit TypeAdapterTests;

interface

uses
  TestFrameWork,
  Fixture,
  classes,
  sysUtils,
  windows,
  TypeAdapter;

type
  TTypeAdapterTests = class(TTestCase)
  private
    procedure assertBooleanTypeAdapterParses(booleanString : string;
      assertedValue : boolean);
  published
    procedure testTypeAdapter;
    procedure testTypeAdapterOn;
    procedure testTypeAdapterOnWithField;
    procedure testTypeAdapterOnWithMethod;
    procedure testTypeAdapterOnWithMethodForInstance;
    procedure testTypeAdapterOnWithFieldForInstance;
    procedure testTypeAdapterGet;
    procedure testTypeAdapterSet;

    procedure testBooleanTypeAdapter;

  end;

{$METHODINFO ON}

  TTestFixture = class(TFixture)
  private
    FsampleByte : byte;
    FsampleShort : short;
    //    sampleInt     : int;
    FsampleInteger : Integer;
    FsampleFloat : double;
    Fch : char;
    Fname : string;
//    FsampleArray : array of Integer;
    FsampleDate : TDateTime;
  published
    function pi : Double;
    property sampleByte : byte read FsampleByte write FsampleByte;
    property sampleShort : short read FsampleShort write FsampleShort;
    property sampleInteger : Integer read FsampleInteger write FsampleInteger;
    property sampleFloat : double read FsampleFloat write FsampleFloat;
    property ch : char read Fch write Fch;
    property name : string read Fname write Fname;
    //    property sampleArray : array of Integer read FsampleArray write FsampleArray;
    property sampleDate : TDateTime read FsampleDate write FsampleDate;
  end;
{$METHODINFO OFF}

  TestFixtureClass = class of TTestFixture;

implementation

uses
  Field,
  Method,
  variants,
  typinfo;

{ TTypeAdapterTests }

procedure TTypeAdapterTests.assertBooleanTypeAdapterParses(booleanString : string; assertedValue : boolean);
var
  booleanAdapter : TTypeAdapter;
  result : Boolean;
begin
  booleanAdapter := TTypeAdapter.adapterFor(tkEnumeration);
  result := booleanAdapter.parse(booleanString);
  CheckTrue(VarSameValue(result, assertedValue));
end;

procedure TTypeAdapterTests.testBooleanTypeAdapter();
begin
  assertBooleanTypeAdapterParses('true', true);
  assertBooleanTypeAdapterParses('yes', true);
  assertBooleanTypeAdapterParses('y', true);
  assertBooleanTypeAdapterParses('+', true);
  assertBooleanTypeAdapterParses('1', true);
  assertBooleanTypeAdapterParses('True', true);
  assertBooleanTypeAdapterParses('YES', true);
  assertBooleanTypeAdapterParses('Y', true);

  assertBooleanTypeAdapterParses('N', false);
  assertBooleanTypeAdapterParses('No', false);
  assertBooleanTypeAdapterParses('false', false);
  assertBooleanTypeAdapterParses('0', false);
  assertBooleanTypeAdapterParses('-', false);
  assertBooleanTypeAdapterParses('whatever', false);
end;

procedure TTypeAdapterTests.testTypeAdapter;
var
  a : TTypeAdapter;
begin

  a := TTypeAdapter.adapterFor(tkInteger);
  checkEquals(a.ClassName, 'TIntAdapter');

end;

procedure TTypeAdapterTests.testTypeAdapterGet;
var
  pi: Double;
  a : TTypeAdapter;
  aFixture : TTestFixture;
  aField : TField;
  aMethod : TMethod;
begin
  aFixture := TTestFixture.Create;
  aFixture.sampleInteger := 90;
  aField := TField.Create(aFixture.ClassType, 'sampleInteger');
  a := TTypeAdapter.adapterOn(aFixture, aField);
  CheckEquals(90, integer(a.get));

  aMethod := TMethod.Create(aFixture.ClassType, 'pi');
  a := TTypeAdapter.adapterOn(aFixture, aMethod);
  pi := 3.141592653;
  checkEquals(pi, a.get);
end;

procedure TTypeAdapterTests.testTypeAdapterOn;
var
  a : TTypeAdapter;
  aFixture : TFixture;
begin
  aFixture := TFixture.Create;
  a := TTypeAdapter.adapterOn(aFixture, tkInteger);
  checkEquals('TIntAdapter', a.ClassName);
  check(a.fixture = aFixture, 'Failed on fixture');
  check(tkInteger = a.Thetype, 'Types are different');
end;

procedure TTypeAdapterTests.testTypeAdapterOnWithField;
var
  a : TTypeAdapter;
  aFixture : TFixture;
  aField : TField;
begin
  aFixture := TFixture.Create;
  aField := TField.Create('someField', tkInteger);
  a := TTypeAdapter.adapterOn(aFixture, aField);
  checkEquals('TIntAdapter', a.ClassName);
  check(a.fixture = aFixture, 'Failed on fixture');
  check(tkInteger = a.Thetype, 'Types are not equal');
  check(a.field = aField, 'The fields are not equal');
  check(a.field.FieldType = aField.FieldType, 'Field types are not equal');
  check(a.Field.FieldName = aField.FieldName, 'Field Names are not equal');
end;

procedure TTypeAdapterTests.testTypeAdapterOnWithFieldForInstance;
var
  a : TTypeAdapter;
  aFixture : TFixture;
  aField : TField;
begin
  aFixture := TTestFixture.Create;
  aField := TField.Create(aFixture.ClassType, 'sampleInteger');
  a := TTypeAdapter.adapterOn(aFixture, aField);
  checkEquals('TIntAdapter', a.ClassName);
  check(a.fixture = aFixture, 'Failed on fixture');
  check(tkInteger = a.Thetype, 'Types are not equal');
  check(a.field = aField, 'The fields are not equal');
  check(a.field.FieldType = aField.FieldType, 'Field types are not equal');
  check(a.Field.FieldName = aField.FieldName, 'Field Names are not equal');
end;

procedure TTypeAdapterTests.testTypeAdapterOnWithMethod;
var
  a : TTypeAdapter;
  aFixture : TFixture;
  aMethod : TMethod;
begin
  aFixture := TFixture.Create;
  aMethod := TMethod.Create('pi', tkInteger);
  a := TTypeAdapter.adapterOn(aFixture, aMethod);
  checkEquals('TIntAdapter', a.ClassName);
  check(a.fixture = aFixture, 'Failed on fixture');
  check(tkInteger = a.Thetype, 'Return types are not equal');
  check(a.method = aMethod, 'The Method are not equal');
  check(a.method.ReturnType = aMethod.ReturnType, 'Method types are not equal');
  check(a.method.Name = aMethod.Name, 'Method Names are not equal');

end;

procedure TTypeAdapterTests.testTypeAdapterOnWithMethodForInstance;
var
  a : TTypeAdapter;
  aFixture : TFixture;
  aMethod : TMethod;
begin
  aFixture := TTestFixture.Create;
  aMethod := TMethod.Create(aFixture.ClassType, 'pi');
  a := TTypeAdapter.adapterOn(aFixture, aMethod);
  checkEquals('TFloatAdapter', a.ClassName);
  check(a.fixture = aFixture, 'Failed on fixture');
  check(tkFloat = a.Thetype, 'return types are not equal');
  check(a.method = aMethod, 'The Method are not equal');
  check(a.method.ReturnType = aMethod.ReturnType, 'Method types are not equal');
  check(a.method.Name = aMethod.Name, 'Method Names are not equal');

end;

procedure TTypeAdapterTests.testTypeAdapterSet;
var
  a : TTypeAdapter;
  aFixture : TFixture;
  aField : TField;
begin
  aFixture := TTestFixture.Create;
  aField := TField.Create(aFixture.ClassType, 'sampleInteger');
  a := TTypeAdapter.adapterOn(aFixture, aField);
  a.doSet(95);
  CheckEquals(95, a.get);
end;

{ TestFixture }

function TTestFixture.pi : Double;
begin
  Result := 3.141592653;
end;

initialization
  registerTest(TTypeAdapterTests.Suite);

end.
