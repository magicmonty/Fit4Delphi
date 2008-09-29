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
unit FitMatcherTest;

interface

uses
  StrUtils,
  SysUtils,
  TestFrameWork;

type
  Number = Double;

  TFitMatcherTest = class(TTestCase)
  private
    procedure assertMatch(expression : string; parameter : Number);
    procedure assertNoMatch(expression : string; parameter : Number);
    procedure assertException(expression : string; parameter : Variant);
  published
    procedure testSimpleMatches();
    procedure testExceptions();
    procedure testMessage();
    procedure testTrichotomy();
  end;

implementation

uses
  FitMatcher;

{ TFitMatcherTest }

procedure TFitMatcherTest.assertMatch(expression : string; parameter : Number);
var
  matcher : TFitMatcher;
begin
  matcher := TFitMatcher.Create(expression, parameter);
  checkTrue(matcher.matches());
end;

procedure TFitMatcherTest.assertNoMatch(expression : string; parameter : Number);
var
  matcher : TFitMatcher;
begin
  matcher := TFitMatcher.Create(expression, parameter);
  checkFalse(matcher.matches());
end;

procedure TFitMatcherTest.assertException(expression : string; parameter : Variant);
var
  matcher : TFitMatcher;
begin
  matcher := TFitMatcher.Create(expression, parameter);
  try
    matcher.matches();
    Fail('');
  except
  end;
end;

procedure TFitMatcherTest.testSimpleMatches();
begin
  assertMatch('_<3', 2);
  assertNoMatch('_<3', 3);
  assertMatch('_<4', 3);
  assertMatch('_ < 9', 4);
  assertMatch('<3', 2);
  assertMatch('>4', 5);
  assertMatch('>-3', -2);
  assertMatch('<3.2', 3.1);
  assertNoMatch('<3.2', 3.3);
  assertMatch('<=3', 3.0);
  assertMatch('<=3', 2.0);
  assertNoMatch('<=3', 4.0);
  assertMatch('>=2', 2.0);
  assertMatch('>=2', 3.0);
  assertNoMatch('>=2', 1.0);
end;

procedure TFitMatcherTest.testExceptions();
begin
  assertException('X', 1);
  assertException('<32', 'xxx');
end;

procedure TFitMatcherTest.testMessage();
var
  matcher : TFitMatcher;
begin
  matcher := TFitMatcher.Create('_>25', 3);
  CheckEquals('<b>3</b>>25', matcher.message());
  matcher := TFitMatcher.Create(' < 32', 5);
  CheckEquals('<b>5</b> < 32', matcher.message());
end;

procedure TFitMatcherTest.testTrichotomy();
begin
  assertMatch('5<_<32', 8);
  assertNoMatch('5<_<32', 5);
  assertNoMatch('5<_<32', 32);
  assertMatch('10>_>5', 6);
  assertNoMatch('10>_>5', 10);
  assertNoMatch('10>_>5', 5);
  assertMatch('10>=_>=5', 10);
  assertMatch('10>=_>=5', 5);
end;

initialization
  registerTest(TFitMatcherTest.Suite);

end.

