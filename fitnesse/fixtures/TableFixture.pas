unit TableFixture;

interface

Uses
  {FIT}
  Fixture, Parse;

type
  TTableFixture = class(TFixture)
  protected
    firstRow: TParse;
    procedure doStaticTable(rows: integer); virtual; abstract;
    function getCell(row, column: integer): TParse; virtual;
    function getText(row, column: integer): String;
    function blank(row, column: integer): boolean;
    procedure wrong(row, column: integer); overload;
    procedure right(row, column: integer);
    procedure wrong(row, column: integer; actual: String); overload;
    procedure ignore(row, column: integer);
    function getInt(row, column: integer): integer;
  public
    procedure doRows(rows: TParse); override;
  end;

implementation

Uses
  {Delphi}
  SysUtils;

{ TTableFixture }

procedure TTableFixture.doRows(rows: TParse);
begin
  firstRow := rows;
  if rows = nil then
    raise Exception.Create('There are no rows in this table');
  doStaticTable(rows.size());
end;

function TTableFixture.getCell(row, column: integer): TParse;
begin
  result := firstRow.at(row, column);
end;

function TTableFixture.getText(row, column: integer): String;
begin
  result := getCell(row, column).text();
end;               

function TTableFixture.blank(row, column: integer): boolean;
begin
  result := getText(row, column) = '';
end;

procedure TTableFixture.wrong(row, column: integer);
begin
  inherited wrong(getCell(row, column));
end;          

procedure TTableFixture.right(row, column: integer);
begin
  inherited right(getCell(row, column));
end;

procedure TTableFixture.wrong(row, column: integer; actual: String);
begin
  inherited wrong(getCell(row, column), actual);
end;

procedure TTableFixture.ignore(row, column: integer);
begin
  inherited ignore(getCell(row, column));
end;

function TTableFixture.getInt(row, column: integer): integer;
var
  i: integer;
  text: String;
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
