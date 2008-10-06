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
unit RowEntryFixture;

interface

Uses
  {Delphi}
  SysUtils,
  {Fit}
  ColumnFixture, Parse;

const
  ERROR_INDICATOR = 'Unable to enter last row: ';
  RIGHT_STYLE = 'pass';
  WRONG_STYLE = 'fail';

Type
  TRowEntryFixture = class(TColumnFixture)
  protected
    function appendCell(row: TParse; text: String): TParse;
  public
    constructor Create; override;
    procedure enterRow; virtual; abstract;
    procedure doRow(row: TParse); override;            
    procedure reportError(row: TParse; e: Exception);
    function makeMessageCell(e: Exception): TParse;
    procedure insertRowAfter(currentRow: TParse; rowToAdd: TParse);
  end;

implementation

{ RowEntryFixture }

procedure TRowEntryFixture.doRow(row: TParse);
var
  index: integer;
begin
  index := AnsiPos(ERROR_INDICATOR, row.parts.body);
  if (index > 0) then
    exit;
  inherited doRow(row);
  try
    enterRow();
    right(appendCell(row, 'entered'));
  except
    on e: Exception do                                
    begin
      wrong(appendCell(row, 'skipped'));
      reportError(row, e);
    end;
  end;
end;

function TRowEntryFixture.appendCell(row: TParse; text: String): TParse;
var
  lastCell: TParse;
begin
  lastCell := TParse.Create('td', text, nil, nil);
  row.parts.last.more := lastCell;
  result := lastCell;
end;

procedure TRowEntryFixture.reportError(row: TParse; e: Exception);
var
  errorCell: TParse;
begin
  errorCell := makeMessageCell(e);
  insertRowAfter(row, TParse.Create('tr', '', errorCell, nil));
end;

function TRowEntryFixture.makeMessageCell(e: Exception): TParse;
var
  errorCell: TParse;
begin
  errorCell := TParse.Create('td', '', nil, nil);
  errorCell.addToTag(' colspan=''' + IntToStr(fColumnBindings.count + 1) + '''');
  errorCell.addToBody('<i>' + ERROR_INDICATOR + e.Message + '</i>');
  wrong(errorCell);
  result := errorCell;
end;

procedure TRowEntryFixture.insertRowAfter(currentRow, rowToAdd: TParse);
var
  nextRow: TParse;
begin
  nextRow := currentRow.more;
  currentRow.more := rowToAdd;
  rowToAdd.more := nextRow;
end;

constructor TRowEntryFixture.create;
begin
  inherited;
  
end;

end.
