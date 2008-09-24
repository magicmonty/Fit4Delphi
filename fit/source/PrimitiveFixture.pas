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
{$H+}
unit PrimitiveFixture;

interface

uses
  Fixture,
  Parse;

type
  TPrimitiveFixture = class(TFixture)
  public
    function parseLong(cell : TParse) : longint;
    function parseDouble(cell : TParse) : double;
    procedure check(cell : TParse; value : string); overload;
    procedure check(cell : TParse; value : longint); overload;
    procedure check(cell : TParse; value : double); overload;
  end;

implementation

uses
  SysUtils,
  Classes;

{ TPrimitiveFixture }

function TPrimitiveFixture.parseLong(cell : TParse) : longint;
begin
  result := StrToInt(cell.text());
end;

function TPrimitiveFixture.parseDouble(cell : TParse) : double;
begin
  result := StrToFloat(cell.text());
end;

procedure TPrimitiveFixture.check(cell : TParse; value : string);
begin
  if ((cell.text() = value)) then
    right(cell)
  else
    wrong(cell, value)
end;

procedure TPrimitiveFixture.check(cell : TParse; value : longint);
begin
  if (parseLong(cell) = value) then
    right(cell)
  else
    wrong(cell, IntToStr(value));
end;

procedure TPrimitiveFixture.check(cell : TParse; value : double);
begin
  if (parseDouble(cell) = value) then
    right(cell)
  else
    wrong(cell, FloatToStr(value))
end;

initialization
  RegisterClass(TPrimitiveFixture);

finalization
  UnRegisterClass(TPrimitiveFixture);

end.

