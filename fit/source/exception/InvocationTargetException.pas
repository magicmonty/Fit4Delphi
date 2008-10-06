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
unit InvocationTargetException;

interface

uses
  SysUtils,
  ObjAuto;

type
  TInvocationTargetException = class(Exception)
  private
    targetException : Exception;
  public
    constructor Create(MethodInfo : PMethodInfoHeader; e : Exception);
    function getTargetException() : Exception;
  end;

implementation

{ TInvocationTargetException }

constructor TInvocationTargetException.Create(MethodInfo : PMethodInfoHeader; e : Exception);
begin
  inherited CreateFmt('"%s" called with invalid arguments: %s', [MethodInfo.Name, e.Message]);
  targetException := e.ClassType.Create as Exception;
  targetException.Message := e.Message;
  if (targetException is TInvocationTargetException) then
    (targetException as TInvocationTargetException).targetException := (e as
      TInvocationTargetException).targetException;

end;

function TInvocationTargetException.getTargetException : Exception;
begin
  Result := targetException;
end;

end.

