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
unit GracefulNamer;

interface

type
  TGracefulNameState = interface
    procedure letter(c : char);
    procedure digit(c : char);
    procedure other(c : char);
  end;

  TInWordState = class(TInterfacedObject, TGracefulNameState)
    procedure letter(c : char);
    procedure digit(c : char);
    procedure other(c : char);
  end;

  TOutOfWordState = class(TInterfacedObject, TGracefulNameState)
    procedure letter(c : char);
    procedure digit(c : char);
    procedure other(c : char);
  end;

  TInNumberState = class(TInterfacedObject, TGracefulNameState)
    procedure letter(c : char);
    procedure digit(c : char);
    procedure other(c : char);
  end;

  TGracefulNamer = class
  public
    class function isGracefulName(fixtureName : string) : Boolean;
    class function disgrace(fixtureName : string) : string;
    constructor Create;
  end;

implementation

uses
  SysUtils,
  StrUtils,
  Matcher;

var
  finalName : string;
  currentState : TGracefulNameState;

const
  disgracefulNamePattern = '^\w([.]|\w)*[^.]$';
//TODO  disgracefulNamePattern = '\w(?:[.]|\w)*[^.]';

  { TGracefulNamer }

class function TGracefulNamer.disgrace(fixtureName : string) : string;
var
  i : integer;
  namer : TGracefulNamer;
  c : char;
begin
  namer := TGracefulNamer.Create;
  for i := 1 to Length(fixtureName) do
  begin
    c := fixtureName[i];

    if (c in ['a'..'z', 'A'..'Z']) then //isLetter
      currentState.letter(c)
    else
      if (c in ['0'..'9']) then //isDigit
        currentState.digit(c)
      else
        currentState.other(c);
  end;
  result := finalName;
  namer.Free;
end;

constructor TGracefulNamer.Create;
begin
  currentState := TOutOfWordState.Create();
  finalName := '';
end;

class function TGracefulNamer.isGracefulName(fixtureName : string) : Boolean;
var
  matcher : TRegExpr;
begin
  matcher := TRegExpr.Create;
  matcher.Expression := disgracefulNamePattern;
  Result := not matcher.Exec(fixtureName);
end;

{ TInWordState }

procedure TInWordState.digit(c : char);
begin
  finalName := finalName + c;
  currentState := TInNumberState.Create;
end;

procedure TInWordState.letter(c : char);
begin
  finalName := finalName + c;
end;

procedure TInWordState.other(c : char);
begin
  currentState := TOutOfWordState.Create;
end;

{ TOutOfWordState }

procedure TOutOfWordState.digit(c : char);
begin
  finalName := finalName + c;
  currentState := TInNumberState.Create;
end;

procedure TOutOfWordState.letter(c : char);
begin
  finalName := finalName + UpperCase(c);
  currentState := TInWordState.Create;
end;

procedure TOutOfWordState.other(c : char);
begin
end;

{ TInNumberState }

procedure TInNumberState.digit(c: char);
begin
  finalName := finalName + c;
end;

procedure TInNumberState.letter(c: char);
begin
  finalName := finalName + UpperCase(c);
  currentState := TInWordState.Create();
end;

procedure TInNumberState.other(c: char);
begin
  currentState := TOutOfWordState.Create();
end;

end.

