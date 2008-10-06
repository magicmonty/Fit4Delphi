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
{$H+}
unit StringBuffer;

interface

type
  TStringBuffer = class
  protected
    text : string;
  public
    function toString() : string;
    function append(s : string) : TStringBuffer; overload;
    function append(i : Integer) : TStringBuffer; overload;
    function append(s : TStringBuffer) : TStringBuffer; overload;
  end;
implementation

uses
  sysUtils;

{ TStringBuffer }

function TStringBuffer.append(s : string) : TStringBuffer;
begin
  text := text + s;
  Result := self;
end;

function TStringBuffer.append(s : TStringBuffer) : TStringBuffer;
begin
  Result := append(s.toString());
end;

function TStringBuffer.append(i : Integer) : TStringBuffer;
begin
  Result := append(IntToStr(i));
end;

function TStringBuffer.toString : string;
begin
  Result := text;
end;

end.

