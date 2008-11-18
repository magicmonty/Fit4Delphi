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
program DelphiTestRunner;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  IdTCPStream,
  StringBuffer in '..\fitnesse\util\StringBuffer.pas',
  ByteArrayInputStream in '..\fitnesse\streams\ByteArrayInputStream.pas',
  ByteArrayOutputStream in '..\fitnesse\streams\ByteArrayOutputStream.pas',
  FileInputStream in '..\fitnesse\streams\FileInputStream.pas',
  FileOutputStream in '..\fitnesse\streams\FileOutputStream.pas',
  FileUnit in '..\fitnesse\util\FileUnit.pas',
  FileUtil in '..\fitnesse\util\FileUtil.pas',
  InputStream in '..\fitnesse\streams\InputStream.pas',
  OutputStream in '..\fitnesse\streams\OutputStream.pas',
  PrintStream in '..\fitnesse\streams\PrintStream.pas',
  StreamReader in '..\fitnesse\util\StreamReader.pas',
  TestRunnerFixtureListener in '..\fitnesse\runner\TestRunnerFixtureListener.pas',
  CachingResultFormatter in '..\fitnesse\runner\CachingResultFormatter.pas',
  FormattingOption in '..\fitnesse\runner\FormattingOption.pas',
  PageResult in '..\fitnesse\runner\PageResult.pas',
  ResultFormatter in '..\fitnesse\runner\ResultFormatter.pas',
  ResultHandler in '..\fitnesse\runner\ResultHandler.pas',
  StandardResultHandler in '..\fitnesse\runner\StandardResultHandler.pas',
  TestRunner in '..\fitnesse\runner\TestRunner.pas',
  FitServer in '..\fit\source\FitServer.pas',
  FitProtocol in '..\fitnesse\components\FitProtocol.pas',
  CommandLine in '..\fitnesse\components\CommandLine.pas',
  ContentBuffer in '..\fitnesse\components\ContentBuffer.pas',
  ResponseParser in '..\fitnesse\http\ResponseParser.pas',
  RequestBuilder in '..\fitnesse\http\RequestBuilder.pas',
  FitObject in '..\fit\source\FitObject.pas',
  StringObject in '..\fit\source\StringObject.pas',
  TcpInputStream in '..\fitnesse\streams\TcpInputStream.pas',
  InvocationTargetException in '..\fit\source\exception\InvocationTargetException.pas';

var
  args : TStringList;
  i : Integer;
begin
  args := TStringList.Create;
  for i := 1 to ParamCount do
    args.Add(ParamStr(i));
  try
    TTestRunner.main(args);
  finally
    args.Free;
  end;
end.

