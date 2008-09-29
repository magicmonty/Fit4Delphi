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
Derived from Fixture.java by Martin Chernenkoff, CHI Software Design
Released under the terms of the GNU General Public License version 2 or later.
*}
{$H+}
unit Counts;

interface

uses
  Parse,
  Classes,
  SysUtils,
  TypInfo;

type
  TCount = record
    Name : string;
    Value : integer;
  end;

  TCounts = class(TInterfacedObject)
  private
    function GetItem(const Index : Integer) : TCount;
    function GetCount : integer;
  public
    exceptions : Integer;
    ignores : Integer;
    right : Integer;
    wrong : Integer;
    constructor Create; overload;
    constructor Create(right : Integer; wrong : Integer; ignores : Integer; exceptions : Integer); overload;
    property Count : integer read GetCount;
    property Items[const Index : integer] : TCount read GetItem;
    procedure tally(source : TCounts);
    function toString : string;
    procedure tallyPageCounts(counts : TCounts);
    function equals(o : TObject) : boolean;
  end;

implementation

{ TFixture }

constructor TCounts.Create;
begin
  right := 0;
  wrong := 0;
  ignores := 0;
  exceptions := 0;
end;

function TCounts.GetCount : integer;
begin
  result := 4;
end;

function TCounts.GetItem(const Index : Integer) : TCount;
begin
  case index of
    0 :
      begin
        result.Name := 'right';
        result.Value := right;
      end;
    1 :
      begin
        result.Name := 'wrong';
        result.Value := wrong;
      end;
    2 :
      begin
        result.Name := 'ignores';
        result.Value := ignores;
      end;
    3 :
      begin
        result.Name := 'exceptions';
        result.Value := exceptions;
      end;
  end;
end;

procedure TCounts.tally(source : TCounts);
begin
  (*
          public void tally(Counts source) {
              right += source.right;
              wrong += source.wrong;
              ignores += source.ignores;
              exceptions += source.exceptions;
          }
  *)
  right := right + source.right;
  wrong := wrong + source.wrong;
  ignores := ignores + source.ignores;
  exceptions := exceptions + source.exceptions;
end;

function TCounts.toString : string;
begin
  (*
          public String toString() {
              return
                  right + " right, " +
                  wrong + " wrong, " +
                  ignores + " ignored, " +
                  exceptions + " exceptions";
          }
  *)
  result := format('%d right, %d wrong, %d ignored, %d exceptions',
    [right, wrong, ignores, exceptions]);
end;

procedure TCounts.tallyPageCounts(counts : TCounts);
begin
  if (counts.wrong > 0) then
    Inc(wrong)
  else
    if (counts.exceptions > 0) then
      Inc(exceptions)
    else
      if (counts.ignores > 0) and (counts.right = 0) then
        Inc(ignores)
      else
        Inc(right);
end;

function TCounts.equals(o : TObject) : boolean;
var
  other : TCounts;
begin
  if (o = nil) or not (o is TCounts) then
  begin
    result := false;
    exit;
  end;
  other := o as TCounts;
  result := (right = other.right)
    and (wrong = other.wrong)
    and (ignores = other.ignores)
    and (exceptions = other.exceptions);
end;

constructor TCounts.Create(right : Integer; wrong : Integer; ignores : Integer; exceptions : Integer);
begin
  self.right:=right;
  self.wrong:=wrong;
  self.ignores:=ignores;
  self.exceptions:=exceptions;
end;
end.

