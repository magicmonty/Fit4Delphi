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
unit FormattingOptionTest;

interface

uses
  Counts,
  PageResult,
  RegexTest,
  FormattingOption,
  ByteArrayOutputStream,
  CachingResultFormatter;

type
  TFormattingOptionTest = class(TRegexTest)
  private
    output : TByteArrayOutputStream;
    option : TFormattingOption;
    formatter : TCachingResultFormatter;
    result1 : TPageResult;
    result2 : TPageResult;
    finalCounts : TCounts;
    port : Integer; //TODO= FitNesseUtil.port;
    procedure sampleFormatter();
    procedure testTheWholeDeal; // TODO
    procedure testRequest(); // TODO
  protected
    procedure SetUp(); override;
    procedure TearDown(); override;
  published
    procedure testConstruction();
    procedure testConstructionWithFile();
    procedure testRawResults();
  end;

implementation

uses
  Windows,
  FileOutputStream,
  TestFramework,
  FileUtil;

procedure TFormattingOptionTest.SetUp();
begin
  output := TByteArrayOutputStream.Create();
end;

procedure TFormattingOptionTest.TearDown();
begin
  DeleteFile('testOutput.txt');
end;

procedure TFormattingOptionTest.testConstruction();
begin
  option := TFormattingOption.Create('mock', 'stdout', output, 'localhost', 8081, 'SomePage');
  CheckEquals('mock', option.format);
  CheckSame(output, option.output);
  CheckEquals('localhost', option.host);
  CheckEquals(8081, option.port);
  CheckEquals('SomePage', option.rootPath);
end;

procedure TFormattingOptionTest.testConstructionWithFile();
begin
  option := TFormattingOption.Create('mock', 'testOutput.txt', output, 'localhost', 8081, 'SomePage');
  CheckEquals(TFileOutputStream.ClassName, option.output.ClassName);
  option.output.write('sample data');
  option.output.close();
  CheckEquals('sample data', TFileUtil.getFileContent('testOutput.txt'));
end;

procedure TFormattingOptionTest.testRawResults();
var
  content : string;
begin
  sampleFormatter();
  option := TFormattingOption.Create('raw', 'stdout', output, 'localhost', port, 'SomePage');
  option.process(formatter.getResultStream(), formatter.getByteCount());
  content := output.toString();
  assertSubString(result1.toString(), content);
  assertSubString(result2.toString(), content);
end;

procedure TFormattingOptionTest.testRequest();
var
  requestString : string;
begin
  {    TODO
    option := TFormattingOption.Create('mock', 'stdout', output, 'localhost', 8081, 'SomePage');
    requestString := option.buildRequest(new ByteArrayInputStream('test results'.getBytes()), 12).getText();

    Request request := new Request(new ByteArrayInputStream(requestString.getBytes()));
    request.parse();
    CheckEquals('POST /SomePage HTTP/1.1', request.getRequestLine());
    assertTrue(request.getHeader('Content-Type').toString().startsWith('multipart'));
    CheckEquals('localhost:8081', request.getHeader('Host'));
    CheckEquals('format', request.getInput('responder'));
    CheckEquals('mock', request.getInput('format'));
    CheckEquals('test results', request.getInput('results'));
    }
end;

procedure TFormattingOptionTest.testTheWholeDeal();
var
  result : string;
begin
  sampleFormatter();

  //TODO  FitNesseUtil.startFitnesse(InMemoryPage.makeRoot('RooT'));
  try
    begin
      option := TFormattingOption.Create('mock', 'stdout', output, 'localhost', port, '');
      option.process(formatter.getResultStream(), formatter.getByteCount());
    end;
  finally
    //TODO    FitNesseUtil.stopFitnesse();
  end;

  result := output.toString();
  assertSubString('Mock Results', result);
  assertSubString(result1.toString(), result);
  assertSubString(result2.toString(), result);
end;

procedure TFormattingOptionTest.sampleFormatter();
begin
  formatter := TCachingResultFormatter.Create();
  result1 := TPageResult.Create('ResultOne', TCounts.Create(1, 2, 3, 4), 'result one content');
  result2 := TPageResult.Create('ResultTwo', TCounts.Create(4, 3, 2, 1), 'result two content');
  finalCounts := TCounts.Create(5, 5, 5, 5);
  formatter.acceptResult(result1);
  formatter.acceptResult(result2);
  formatter.acceptFinalCount(finalCounts);
end;

initialization

  TestFramework.RegisterTest(TFormattingOptionTest.Suite);

end.

