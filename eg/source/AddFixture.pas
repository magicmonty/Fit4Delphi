unit AddFixture;

interface

uses
  ColumnFixture;

type
  {$METHODINFO ON}
  TAddFixture = class( TColumnFixture )
  private
    FSecondValue: integer;
    FFirstValue: integer;
    function getResult: Variant;
  published
    property firstValue : integer read FFirstValue write FFirstValue;
    property secondValue : integer read FSecondValue write FSecondValue;
//    property resultant : Variant read getResult;
    function resultant : Variant;
  end;

implementation

uses classes;

{ TAddFixture }

function TAddFixture.getResult: Variant;
begin
  result := FFirstValue + FSecondValue;
end;

function TAddFixture.resultant: Variant;
begin
  Result := getResult;
end;

initialization
  classes.RegisterClass( TAddFixture );

end.
 