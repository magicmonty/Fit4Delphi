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
unit RegexTest;

interface

uses
  StrUtils,
  TestFramework;

type
  TRegexTest = class(TTestCase)
  protected
    procedure assertMatches(regexp : string; str : string);
    procedure assertNotMatches(regexp : string; str : string);
    procedure assertHasRegexp(regexp : string; output : string);
    procedure assertDoesntHaveRegexp(regexp : string; output : string);
    procedure assertSubString(substring : string; str : string);
    procedure assertNotSubString(subString : string; str : string);
    function divWithIdAndContent(id : string; expectedDivContent : string) : string;
  end;

implementation

uses
  Matcher;

{ TRegexTest }

procedure TRegexTest.assertMatches(regexp : string; str : string);
begin
  assertHasRegexp(regexp, str);
end;

procedure TRegexTest.assertNotMatches(regexp : string; str : string);
begin
  assertDoesntHaveRegexp(regexp, str);
end;

procedure TRegexTest.assertHasRegexp(regexp : string; output : string);
var
  match : TRegExpr;
  found : boolean;
begin
  match := TRegExpr.Create;
  try
    match.ModifierS := true;
    match.Expression := regexp;
    //  match:=Pattern.compile(regexp,Pattern.MULTILINE|Pattern.DOTALL).matcher(output);
    found := match.Exec(output);

    if (not found) then
    begin
      fail('The regexp <' + regexp + '> was not found in: ' + output + '.');
    end;
  finally
    match.Free;
  end;
end;

procedure TRegexTest.assertDoesntHaveRegexp(regexp : string; output : string);
var
  match : TRegExpr;
  found : boolean;
begin
  match := TRegExpr.Create;
  try
    match.ModifierS := true;
    match.Expression := regexp;
//    match := Pattern.compile(regexp, Pattern.MULTILINE).matcher(output);
    found := match.Exec(output);

    if (found) then
    begin
      fail('The regexp <' + regexp + '> was found.');
    end;
  finally
    match.Free;
  end;
end;

procedure TRegexTest.assertSubString(substring : string; str : string);
begin
  if (Pos(substring, str) = 0) then
  begin
    fail('substring '+substring+' not found.');
  end;
end;

procedure TRegexTest.assertNotSubString(subString : string; str : string);
begin
  if (Pos(subString, str) > 0) then
  begin
    fail('expecting substring:'+subString+' in string:'+str+'');
  end;
end;

function TRegexTest.divWithIdAndContent(id : string; expectedDivContent : string) : string;
begin
  result := '<div.*?id=\"' + id + '\".*?>' + expectedDivContent + '</div>';
end;

end.

