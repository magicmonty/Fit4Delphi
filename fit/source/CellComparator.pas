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
unit CellComparator;

interface

uses
  StrUtils,
  SysUtils,
  Parse,
  TypeAdapter,
  Fixture;

type
  TCellComparator = class
  private
    cell : TParse;
    result : Variant;
    typeAdapter : TTypeAdapter;
    expected : Variant;
    fixture : TFixture;
    procedure compare();
    function parseCell() : Variant;
    procedure tryRelationalMatch();
    procedure compareCellToResultInt(theFixture : TFixture; a : TTypeAdapter; theCell : TParse);
  public
    class procedure compareCellToResult(theFixture : TFixture; a : TTypeAdapter; theCell : TParse);
  end;

implementation

uses
  FitMatcherException,
  FitFailureException,
  CouldNotParseFitFailureException,
  FitMatcher,
  TypInfo,
  Variants;

type
  TUnparseable = class

  end;

  { TCellComparator }

class procedure TCellComparator.compareCellToResult(theFixture : TFixture; a : TTypeAdapter; theCell : TParse);
var
  cellComparator : TCellComparator;
begin
  cellComparator := TCellComparator.Create;
  try
    cellComparator.compareCellToResultInt(theFixture, a, theCell);
  finally
    cellComparator.Free;
  end;
end;

procedure TCellComparator.compareCellToResultInt(theFixture : TFixture; a : TTypeAdapter; theCell : TParse);
begin
  typeAdapter := a;
  cell := theCell;
  fixture := theFixture;
  try
    result := typeAdapter.get();
    expected := parseCell();

    if VarIsEmpty(expected) then
    begin
      tryRelationalMatch();
    end
    else
    begin
      compare();
    end;
  except
    on e : Exception do
      fixture.doException(cell, e);
  end;
end;

procedure TCellComparator.compare();
begin
  if (typeAdapter.equals(expected, result)) then
  begin
    fixture.right(cell)
  end
  else
  begin
    fixture.wrong(cell, typeAdapter.toString(result));
  end;
end;

function TCellComparator.parseCell() : Variant;
begin
  try
    result := typeAdapter.parse(cell.text());
    exit;
    // Ignore parse exceptions, print non-parse exceptions,
    // return null so that compareCellToResult tries relational matching.
  except
    on e : EConvertError {NumberFormatException} do
      ;
    on e : TParseException do
      ;
    on e : Exception do
      ; //TODO e.printStackTrace();
  end;
  //Result := EmptyParam;
  //  Result := TUnparseable.Create;
end;

procedure TCellComparator.tryRelationalMatch();
var
  adapterType : TTypeKind;
  matcher : TFitMatcher;
  cantParseException : TFitFailureException;
begin
  (*
     Class adapterType = typeAdapter.type;
      FitFailureException cantParseException = new CouldNotParseFitFailureException(cell.text(), adapterType
              .getName());
      if (result != null)
      {
          FitMatcher matcher = new FitMatcher(cell.text(), result);
          try
          {
              if (matcher.matches())
                  right(cell);
              else
                  wrong(cell);
              cell.body = matcher.message();
          } catch (FitMatcherException fme)
          {
              exception(cell, cantParseException);
          } catch (Exception e)
          {
              exception(cell, e);
          }
      } else
      {
          // TODO-RcM Is this always accurate?
          exception(cell, cantParseException);
      }
  }
  *)
  adapterType := typeAdapter.TheType;
  cantParseException := TCouldNotParseFitFailureException.Create(cell.text(), TTypeKindNames[adapterType]);
  if (result <> null) then
  begin
    matcher := TFitMatcher.Create(cell.text(), result);
    try
      if (matcher.matches()) then
      begin
        fixture.right(cell);
      end
      else
      begin
        fixture.wrong(cell);
      end;
      cell.body := matcher.message();
    except
      on fme : TFitMatcherException do
        fixture.doException(cell, cantParseException);
      on e : Exception do
        fixture.doException(cell, e);
    end;
  end
  else
  begin
    fixture.DoException(cell, cantParseException);
  end;
end;

end.

