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
unit Runtime;

interface
uses
  sysUtils,
  classes,
  Parse,
  typinfo;

type
  TRunTime = class(TObject)
  private
    Felapsed : Cardinal;
    Fstart : Cardinal;
    function d(scale : cardinal) : string;
    property elapsed : cardinal read FElapsed write Felapsed;
  public
    constructor Create;
    function toString : string;
    property start : cardinal read Fstart write Fstart;
  end;

implementation

uses
  Windows,
  Math;

{ TRuntime }

constructor TRunTime.Create;
begin
  inherited;
  start := getTickCount;
  elapsed := 0;
end;

function TRunTime.d(scale : cardinal) : string;
var
  report : cardinal;
begin
  report := elapsed div scale;
  elapsed := elapsed - report * scale;
  result := IntToStr(report);
end;

function TRunTime.toString : string;
var
  e : Cardinal;
begin
  e := GetTickCount;
  elapsed := e - start;

  if (elapsed > 600000) then
    result := d(3600000) + ':' + d(600000) + d(60000) + ':' + d(10000) + d(1000)
  else
    result := d(60000) + ':' + d(10000) + d(1000) + '.' + d(100) + d(10);
end;

end.

