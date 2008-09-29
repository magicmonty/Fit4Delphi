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
Derived from Summary.java by Martin Chernenkoff, CHI Software Design
Released under the terms of the GNU General Public License version 2 or later.
*}
{$H+}
unit SummaryFixture;

interface

uses Classes,
  SysUtils,
  Fixture,
  Counts,
  Parse;

type
  TSummaryFixture = class(TFixture)
  protected
    function rows(count : integer) : TParse;
    function tr(parts, more : TParse) : TParse;
    function td(body : string; more : TParse) : TParse;
    procedure mark(row : TParse);
  public
    procedure doTable(table : TParse); override;
  end;

const
  countsKey = 'counts';

implementation

{ TSummary }

procedure TSummaryFixture.doTable(table : TParse);
begin
  (*
      public void doTable(Parse table) {
          summary.put(countsKey, counts());
          SortedSet keys = new TreeSet(summary.keySet());
          table.parts.more = rows(keys.iterator());
      }
  *)
//TODO  summary.AddObject(countsKey, counts);
  summary.Values[countsKey] := counts.toString;
  summary.Sort;
  table.parts.more := rows(0);
end;

function TSummaryFixture.rows(count : integer) : TParse;
begin
  (*
      protected Parse rows(Iterator keys) {
          if (keys.hasNext()) {
              Object key = keys.next();
              Parse result =
                  tr(
                      td(key.toString(),
                      td(summary.get(key).toString(),
                      null)),
                  rows(keys));
              if (key.equals(countsKey)) {
                  mark (result);
              }
              return result;
          } else {
              return null;
          }
      }
  *)
  if count < summary.Count then
  begin
    result := tr(
      td(summary.Names[count],
      td(summary.Values[summary.Names[count]], nil)),
      rows(count + 1));
    if (summary.Names[count] = countsKey) then
      mark(result);
  end
  else
    result := nil;
end;

function TSummaryFixture.tr(parts, more : TParse) : TParse;
begin
  result := TParse.Create('tr', '', parts, more);
end;

function TSummaryFixture.td(body : string; more : TParse) : TParse;
begin
  result := TParse.Create('td', gray(body), nil, more);
end;

procedure TSummaryFixture.mark(row : TParse);
var
  official : TCounts;
  cell : TParse;
begin
  (*
       protected void mark(Parse row) {
          // mark summary good/bad without counting beyond here
          Counts official = counts;
          counts = new Counts();
          Parse cell = row.parts.more;
          if (official.wrong + official.exceptions > 0) {
              wrong(cell);
          } else {
              right(cell);
          }
          counts = official;
      }
  *)
    // mark summary good/bad without counting beyond here
  official := counts;
  counts := TCounts.Create();
  cell := row.parts.more;
  if (official.wrong + official.exceptions > 0) then
    wrong(cell)
  else
    right(cell);
  counts := official;
end;

initialization
  RegisterClass(TSummaryFixture);

finalization
  UnRegisterClass(TSummaryFixture);

end.

