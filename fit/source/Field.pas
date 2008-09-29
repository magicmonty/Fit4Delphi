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
{$H+}
unit Field;

interface

uses
  Fixture,
  TypInfo;

type
  TField = class
  private
    FFieldName : string;
    FFieldType : TTypeKind;
    function getFieldType : TTypeKind;
    function getFieldName : string;
  public
    function get(theInstance : TObject) : variant;
    procedure doSet(theInstance : TFixture; const theValue : variant);
    property FieldName : string read getFieldName;
    property FieldType : TTypeKind read getFieldType;
    constructor Create(theClass : TClass; const aFld : string); overload;
    constructor Create(const theName : string; theType : TTypeKind); overload;
  end;

implementation

{ TField }

constructor TField.Create(const theName : string; theType : TTypeKind);
begin
  FFieldName := theName;
  FFieldType := theType;
end;

constructor TField.Create(theClass : TClass; const aFld : string);
var
  thePropInfo : PPropInfo;
begin
  {$IFDEF UNICODE}
  thePropInfo := GetPropInfo( theClass.classInfo, aFld, [tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
    tkString, tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString, tkUString,
    tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray ] );
  {$ELSE}
  thePropInfo := GetPropInfo( theClass.classInfo, aFld, [tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
    tkString, tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString,
    tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray ] );
  {$ENDIF}
  self.Create(aFld, thePropInfo.PropType^.Kind);
end;

procedure TField.doSet(theInstance : TFixture; const theValue : variant);
begin
  SetPropValue(theInstance, FieldName, theValue);
end;

function TField.get(theInstance : TObject) : variant;
begin
  result := GetPropValue(theInstance, FieldName);
end;

function TField.getFieldName : string;
begin
  result := FFieldName;
end;

function TField.getFieldType : TTypeKind;
begin
  result := FFieldType;
end;

end.
