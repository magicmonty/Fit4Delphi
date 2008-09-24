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
{$H+}
unit TypeAdapter;

interface
uses
  Fixture,
  variants,
  TypInfo,
  Field,
  Method,
  sysUtils;

type
  TTypeAdapter = class(TObject)
  public
    target : TObject;
    fixture : TFixture;
    field : TField;
    method : TMethod;
    TheType : TTypeKind;
    procedure init(fixture : TFixture; aType : TTypeKind);
    function get : variant;
    procedure doSet(const value : variant);
    class function adapterFor(aType : TTypeKind) : TTypeAdapter;
    class function AdapterOn(fixture : TFixture; aType : TTypeKind) : TTypeAdapter; overload;
    class function AdapterOn(fixture : TFixture; field : TField) : TTypeAdapter; overload;
    class function AdapterOn(fixture : TFixture; method : TMethod) : TTypeAdapter; overload;
    function parse(const s : string) : Variant; virtual;
    function invoke : Variant;
    function equals(a, b : Variant) : Boolean;
    function toString(o : Variant) : string;
  end;

  TShortAdapter = class(TTypeAdapter)
  public
    function parse(const theText : string) : variant; override;
  end;

  TIntAdapter = class(TTypeAdapter)
    function parse(const theText : string) : variant; override;
  end;

  TFloatAdapter = class(TTypeAdapter)
    function parse(const theText : string) : variant; override;
  end;

  TBooleanAdapter = class(TTypeAdapter)
    function parse(const s : string) : variant; override;
  end;

  TArrayAdapter = class(TTypeAdapter)
    function parse(const s : string) : variant; override;
  end;

const
  TTypeKindNames : array[TTypeKind] of string = (
    'Unknown', 'Integer', 'Char', 'Boolean/Enumeration', 'Float',
    'String', 'Set', 'Class', 'Method', 'WChar', 'LString', 'WString',
    'Variant', 'Array', 'Record', 'Interface', 'Int64', 'DynArray');

implementation

{ TTypeAdapter }

class function TTypeAdapter.adapterFor(aType : TTypeKind) : TTypeAdapter;
begin
  case aType of
    tkInteger : result := TIntAdapter.Create;
    tkFloat : result := TFloatAdapter.Create;
    tkEnumeration : result := TBooleanAdapter.Create;
      // for unknown reason Delphi uses this type for Boolean params/results
  else
    result := TTypeAdapter.Create;
  end;
end;

class function TTypeAdapter.AdapterOn(fixture : TFixture; aType : TTypeKind) : TTypeAdapter;
begin
  result := adapterFor(aType);
  result.init(fixture, aType);
end;

class function TTypeAdapter.AdapterOn(fixture : TFixture; field : TField) : TTypeAdapter;
begin
  result := TTypeAdapter.AdapterOn(fixture, field.FieldType);
  result.field := field;
  result.target := fixture;
end;

class function TTypeAdapter.AdapterOn(fixture : TFixture; method : TMethod) : TTypeAdapter;
begin
  result := adapterOn(fixture, method.ReturnType);
  result.method := method;
  result.target := fixture;
end;

function TTypeAdapter.parse(const s : string) : Variant;
begin
  result := fixture.parse(s, Thetype);
end;

procedure TTypeAdapter.doSet(const value : variant);
begin
  field.doSet(fixture, value);
end;

function TTypeAdapter.get : Variant;
begin
  if (field <> nil) then
    result := field.get(target)
  else
    if (method <> nil) then
      result := invoke()
    else
      result := null;
end;

function TTypeAdapter.invoke() : Variant;
begin
  Result := method.invoke(target, []);
end;

procedure TTypeAdapter.init(fixture : TFixture; aType : TTypeKind);
begin
  self.fixture := fixture;
  self.Thetype := aType;
end;

function TTypeAdapter.equals(a : Variant; b : Variant) : Boolean;
begin
  Result := a = b;
end;

function TTypeAdapter.toString(o : Variant) : string;
begin
  (*    {
          if (o == null)
          {
              return "null";
          } else if (o instanceof String && ((String) o).equals(""))
              return "blank";
          else
              return o.toString();
      }
  *)
  if VarIsNull(o) then
    Result := 'null'
  else
    if VarIsStr(o) and (o = '') then
      Result := 'blank'
    else
      Result := o;
end;

{ ShortAdapter }

function TShortAdapter.parse(const theText : string) : variant;
begin
  try
    result := StrToInt(theText);
  except
    result := 0;
  end;
end;

{ IntAdapter }

function TIntAdapter.parse(const theText : string) : variant;
begin
  result := strToInt(theText);
end;

{ FloatAdapter }

function TFloatAdapter.parse(const theText : string) : variant;
begin
  result := StrToFloat(theText);
end;

{ TBooleanAdapter }

function TBooleanAdapter.parse(const s : string) : variant;
var
  ls : string;
begin
  Result := false;
  ls := LowerCase(s);
  if (ls = 'true') or
    (ls = 'yes') or
    (ls = '1') or
    (ls = 'y') or
    (ls = '+') then
    Result := True;
end;

{ TArrayAdapter }

function TArrayAdapter.parse(const s : string) : variant;
begin
  // TODO
end;

end.

