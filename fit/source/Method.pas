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
unit Method;

interface

uses
  TypInfo;

type
  TMethod = class
  private
    FMethodName : string;
    FReturnType : TTypeKind;
    function getMethodName : string;
    function getReturnType : TTypeKind;
  public
    function invoke(theInstance : TObject; inParams : array of Variant) : variant;
    constructor Create(theClass : TClass; const aMethod : string); overload;
    constructor Create(const theName : string; retType : TTypeKind); overload;
    property Name : string read getMethodName;
    property ReturnType : TTypeKind read getReturnType;
  end;

implementation

uses
  DetailedRTTI,
  ObjAuto,
  SysUtils;

constructor TMethod.Create(const theName : string; retType : TTypeKind);
begin
  FMethodName := theName;
  FReturnType := retType;
end;

constructor TMethod.Create(theClass : TClass; const aMethod : string);
var
  Instance : TObject;
  ReturnInfo : PReturnInfo;
begin
  Instance := theClass.NewInstance;
  try
    ReturnInfo := GetMethodReturnInfo(Instance, aMethod);
  finally
    Instance.FreeInstance;
  end;
  if (ReturnInfo = nil) or (ReturnInfo.ReturnType = nil) then
    Self.Create(aMethod, tkUnknown)
  else
    Self.Create(aMethod, ReturnInfo.ReturnType^.Kind)
end;

function TMethod.invoke(theInstance : TObject; inParams : array of Variant) : variant;
var
  ParamIndexes : array of Integer;
  Params : array of Variant;
  i, ArgCount : integer;
  MethodInfo : PMethodInfoHeader;
  ReturnInfo : PReturnInfo;
begin
  ArgCount := Length(inParams);
  SetLength(ParamIndexes, 0);
  SetLength(Params, ArgCount);

  // Params should contain arguments in reverse order!
  for i := 0 to ArgCount - 1 do
    Params[i] := inParams[ArgCount - i - 1];

  MethodInfo := GetMethodInfo(theInstance, Name);
  if not Assigned(MethodInfo) then
    raise Exception.CreateFmt('There is no method named "%s"', [Name]);
  try
    ReturnInfo := GetMethodReturnInfo(theInstance, Name);
    if (ReturnInfo = nil) or (ReturnInfo.ReturnType = nil) then
      ObjectInvoke(theInstance, MethodInfo, ParamIndexes, Params)
    else
      Result := ObjectInvoke(theInstance, MethodInfo, ParamIndexes, Params);
  except
    on E : Exception do
      raise Exception.CreateFmt('"%s" called with invalid arguments: %s', [MethodInfo.Name, E.Message]);
  end;
end;

function TMethod.getMethodName : string;
begin
  result := FMethodName;
end;

function TMethod.getReturnType : TTypeKind;
begin
  result := FReturnType;
end;

end.
