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
unit FitMatcher;

interface

uses
  StrUtils,
  SysUtils;

type
  TFitMatcher = class
  private
    expression : string;
    parameter : Variant;
  public
    function matches() : boolean;
    function message() : string;
    constructor Create(expression : string; parameter : Variant);
    destructor Destroy; override;
  end;

implementation

uses
  Variants,
  RegExpr,
  FitMatcherException;

{ TFitMatcher }

constructor TFitMatcher.Create(expression : string; parameter : Variant);
begin
  inherited Create;
  self.expression := expression;
  self.parameter := parameter;
end;

destructor TFitMatcher.Destroy();
begin
  inherited Destroy;
end;

function TFitMatcher.matches() : boolean;
var
  p : string; {Pattern}
  n : double;
  m : TRegExpr; {Matcher}
  nb : boolean;
  an : boolean;
  op : string;
  operand : double;
  aop : string;
  b : double;
  operandString : string;
  a : double;
  bop : string;
begin
  p := '^\s*_?\s*(<|>|<=|>=)\s*([-+]?[\d]*\.?[\d]+)';
  m := TRegExpr.Create;
  m.Expression := p;
  if m.Exec(expression) then
  begin
    op := m.Match[1];
    operandString := m.Match[2];
    operand := StrToFloat(operandString);
    n := parameter;

    if ((op = '<')) then
    begin
      result := (n < operand);
      exit;
    end;

    if ((op = '>')) then
    begin
      result := (n > operand);
      exit;
    end;

    if ((op = '<=')) then
    begin
      result := (n <= operand);
      exit;
    end;

    if ((op = '>=')) then
    begin
      result := (n >= operand);
      exit;
    end;
    result := false;
    exit;
  end;
  p := '^\s*([-+]?[\d]*\.?[\d]+)\s*(<|>|<=|>=)\s*_\s*(<|>|<=|>=)\s*([-+]?[\d]*\.?[\d]+)';
  m.Expression := p;

  if m.Exec(expression) then
  begin
    a := StrToFloat(m.Match[1]);
    aop := m.Match[2];
    bop := m.Match[3];
    b := StrToFloat(m.Match[4]);
    n := parameter;
    an := false;

    if ((aop = '<')) then
      an := a < n;

    if ((aop = '<=')) then
      an := a <= n;

    if ((aop = '>')) then
      an := a > n;

    if ((aop = '>=')) then
      an := a >= n;
    nb := false;

    if ((bop = '<')) then
      nb := n < b;

    if ((bop = '<=')) then
      nb := n <= b;

    if ((bop = '>')) then
      nb := n > b;

    if ((bop = '>=')) then
      nb := n >= b;
    Result := an and nb;
    exit;
  end;
  raise TFitMatcherException.Create('Invalid FitMatcher Expression');
end;

function TFitMatcher.message() : string;
var
  parmString : string;
begin
  Result := '';
  parmString := '<b>' + VarToStr(parameter) + '</b>';

  if (Pos('_', expression) = 0) then
  begin
    Result := parmString + expression;
  end
  else
  begin
    Result := StringReplace(expression, '_', parmString, []);
  end;
end;

end.

