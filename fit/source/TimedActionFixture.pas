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
{*
Copyright (c) 2002 Cunningham & Cunningham, Inc.
Derived from TimedActionFixture.java by Martin Chernenkoff, CHI Software Design
Released under the terms of the GNU General Public License version 2 or later.
*}
{$H+}
unit TimedActionFixture;

interface

uses
  Classes, SysUtils, DateUtils, ActionFixture, Parse;

type
  TTimedActionFixture = class(TActionFixture)
  protected
    procedure doCells(Cells : TParse); override;
  public
    procedure doTable(table : TParse); override;
    function td (body : string) : TParse;
    function time : TDateTime; virtual;
  end;

implementation

{ TTimedActionFixture }

procedure TTimedActionFixture.doCells(Cells: TParse);
var
  start : TDateTime;
//  split : TDateTime;
  iSplit : integer;
  sCell : string;
begin
(*
    public void doCells(Parse cells) {
        Date start  = time();
        super.doCells(cells);
        long split = time().getTime() - start.getTime();
        cells.last().more = td(format.format(start));
        cells.last().more = td(split<1000 ? "&nbsp;" : Double.toString((split)/1000.0));
    }
*)
  start := time;
  inherited;
//  split := time - start;
  iSplit := MillisecondsBetween(time, start);
  cells.last.more := td(FormatDateTime('hh:mm:ss', start));
//  cells.last.more := td(FormatDateTime('hh:mm:ss', split));
  if iSplit > 1000 then
    sCell := format('%4.1f', [iSplit/1000])
  else
    sCell := '&nbsp;';
  cells.last.more := td(sCell);
(*
  cells.last.more := td(FormatDateTime('hh:mm:ss', start));

  split := MillisecondsBetween(time, start);
  if split >= 1000 then
    sCell := Format('%4.2f', [split])
  else
    sCell := '&nbsp;';
  sCell := Format('%4.2f', [split]);
  cells.last.more := td(sCell);
*)
end;

procedure TTimedActionFixture.doTable(table: TParse);
begin
(*
    public void doTable(Parse table) {
        super.doTable(table);
        table.parts.parts.last().more = td("time");
        table.parts.parts.last().more = td("split");
    }
*)
  inherited;
  table.parts.parts.last.more := td('time');
  table.parts.parts.last.more := td('split');
end;

function TTimedActionFixture.td(body: string): TParse;
begin
(*
    public Parse td (String body) {
        return new Parse("td", gray(body), null, null);
    }
*)
  result := TParse.Create('td', gray(body), nil, nil);
end;

function TTimedActionFixture.time: TDateTime;
begin
  result := Now;
end;

initialization
  RegisterClass(TTimedActionFixture);

finalization
  UnRegisterClass(TTimedActionFixture);
end.
 