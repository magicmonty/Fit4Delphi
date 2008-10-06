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
// Copyright (C) 2003,2004,2005 by Object Mentor, Inc. All rights reserved.
// Released under the terms of the GNU General Public License version 2 or later.
unit StandardResultHandlerTest;

interface

uses
  TestFramework, ByteArrayOutputStream,
  StandardResultHandler, Counts, RegexTest;

type
  TStandardResultHandlerTest=class(TRegexTest)
  private
    bytes : TByteArrayOutputStream;
    handler : TStandardResultHandler;
    function getOutputForResultWithCount(counts : TCounts): String; overload;
    function getOutputForResultWithCount(title : String; counts : TCounts): String; overload;
  protected
    procedure SetUp(); override;
  published
    procedure testHandleResultPassing();
    procedure testHandleResultFailing();
    procedure testHandleResultWithErrors();
    procedure testHandleErrorWithBlankTitle();
    procedure testFinalCount();
  end;

implementation

uses
  PrintStream, PageResult;

{ TStandardResultHandlerTest }

procedure TStandardResultHandlerTest.setUp();
begin
  bytes := TByteArrayOutputStream.Create();
		handler := TStandardResultHandler.Create(TPrintStream.Create(bytes));
end;

procedure TStandardResultHandlerTest.testHandleResultPassing();
var
  output : String;
begin
  output:=getOutputForResultWithCount(TCounts.Create(5, 0, 0, 0));
  assertSubString('.....',output);
end;

procedure TStandardResultHandlerTest.testHandleResultFailing();
var
  output : String;
begin
  output:=getOutputForResultWithCount(TCounts.Create(0, 1, 0, 0));
  assertSubString('SomePage has failures',output);
end;

procedure TStandardResultHandlerTest.testHandleResultWithErrors();
var
  output : String;
begin
  output:=getOutputForResultWithCount(TCounts.Create(0, 0, 0, 1));
  assertSubString('SomePage has errors',output);
end;

procedure TStandardResultHandlerTest.testHandleErrorWithBlankTitle();
var
  output : String;
begin
  output:=getOutputForResultWithCount('',TCounts.Create(0, 0, 0, 1));
  assertSubString('The test has errors',output);
end;

procedure TStandardResultHandlerTest.testFinalCount();
var
  counts : TCounts;
begin
  counts:=TCounts.Create(5, 4, 3, 2);
  handler.acceptFinalCount(counts);
  assertSubString(counts.toString(),bytes.toString());
end;

function TStandardResultHandlerTest.getOutputForResultWithCount(counts : TCounts): String;
begin
  result := getOutputForResultWithCount('SomePage',counts);
end;

function TStandardResultHandlerTest.getOutputForResultWithCount(title : String; counts : TCounts): String;
var
  lresult : TPageResult;
  output : String;
begin
  lresult:=TPageResult.Create(title);
  lresult.setCounts(counts);
  handler.acceptResult(lresult);
  output:=bytes.toString();
  result := output;
end;

initialization

  TestFramework.RegisterTest(TStandardResultHandlerTest.Suite);

end.
