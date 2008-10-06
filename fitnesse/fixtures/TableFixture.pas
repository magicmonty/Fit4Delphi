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
unit TableFixture;

interface

uses
  {FIT}
  Fixture,
  Parse;

type
  TTableFixture = class(TFixture)
  protected
    firstRow : TParse;
    procedure doStaticTable(rows : integer); virtual; abstract;
    function getCell(row, column : integer) : TParse; virtual;
    function getText(row, column : integer) : string;
    function blank(row, column : integer) : boolean;
    procedure wrong(row, column : integer); overload;
    procedure right(row, column : integer);
    procedure wrong(row, column : integer; actual : string); overload;
    procedure ignore(row, column : integer);
    function getInt(row, column : integer) : integer;
  public
    procedure doRows(rows : TParse); override;
  end;

implementation

uses
  {Delphi}
  SysUtils;

{ TTableFixture }

procedure TTableFixture.doRows(rows : TParse);
begin
  firstRow := rows;
  if rows = nil then
    raise Exception.Create('There are no rows in this table');
  doStaticTable(rows.size());
end;

function TTableFixture.getCell(row, column : integer) : TParse;
begin
  result := firstRow.at(row, column);
end;

function TTableFixture.getText(row, column : integer) : string;
begin
  result := getCell(row, column).text();
end;

function TTableFixture.blank(row, column : integer) : boolean;
begin
  result := getText(row, column) = '';
end;

procedure TTableFixture.wrong(row, column : integer);
begin
  inherited wrong(getCell(row, column));
end;

procedure TTableFixture.right(row, column : integer);
begin
  inherited right(getCell(row, column));
end;

procedure TTableFixture.wrong(row, column : integer; actual : string);
begin
  inherited wrong(getCell(row, column), actual);
end;

procedure TTableFixture.ignore(row, column : integer);
begin
  inherited ignore(getCell(row, column));
end;

function TTableFixture.getInt(row, column : integer) : integer;
var
  i : integer;
  text : string;
begin
  i := 0;
  text := getText(row, column);
  if text = '' then
  begin
    ignore(row, column);
    result := 0;
    exit;
  end;
  try
    i := StrToInt(text);
  except
    wrong(row, column);
  end;
  result := i;
end;

end.

