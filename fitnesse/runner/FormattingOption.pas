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
{$H+}
unit FormattingOption;

interface

uses
  classes,
  RequestBuilder,
  OutputStream,
  InputStream;
type
  TFormattingOption = class
  private
    status : Integer;
    resultFilename : string;
    procedure args(args : TStringList);
    procedure usage();
    function buildRequest(inputStream : TInputStream; size : Integer) : TRequestBuilder;

    procedure setOutput(stdout : TOutputStream);
  public
    format : string;
    usingStdout : boolean;
    output : TOutputStream;
    host : string;
    port : Integer;
    rootPath : string;
    filename : string;
    constructor Create(); overload;
    constructor Create(format : string; filename : string; stdout : TOutputStream; host : string; port : Integer;
      rootPath : string); overload;
    class procedure main(args : TStringList);
    procedure process(inputStream : TInputStream; size : Integer);
    function wasSuccessful : Boolean;
  end;

implementation

uses
  CommandLine,
  ResponseParser,
  FileUnit,
  FileInputStream,
  FileOutputStream,
  FileUtil,
  sysUtils;

constructor TFormattingOption.Create;
begin

end;

class procedure TFormattingOption.main(args : TStringList);
var
  option : TFormattingOption;
  inputFile : TFile;
  input : TFileInputStream;
  byteCount : Integer;
begin
  option := TFormattingOption.Create();
  option.args(args);
  inputFile := TFile.Create(option.resultFilename);
  input := TFileInputStream.Create(inputFile);
  byteCount := inputFile.length();
  option.process(input, byteCount);
  option.Free;
end;

procedure TFormattingOption.args(args : TStringList);
var
  commandLine : TCommandLine;
begin
  commandLine := TCommandLine.Create('resultFilename format outputFilename host port rootPath');
  if (not commandLine.parse(args)) then
    usage();
  resultFilename := commandLine.getArgument('resultFilename');
  format := commandLine.getArgument('format');
  filename := commandLine.getArgument('outputFilename');
  host := commandLine.getArgument('host');
  port := StrToInt(commandLine.getArgument('port'));
  rootPath := commandLine.getArgument('rootPath');
  //TODO    setOutput(System.out);
end;

procedure TFormattingOption.usage();
const
  c : Integer = -1;
begin
  WriteLn('java fitnesse.runner.FormattingOption resultFilename format outputFilename host port rootPath');
  WriteLn(#9'resultFilename:'#9'the name of the file containing test results');
  WriteLn(#9'format:        '#9'raw|html|xml|...');
  WriteLn(#9'outputfilename:'#9'stdout|a filename where the formatted results are to be stored');
  WriteLn(#9'host:          '#9'the domain name of the hosting FitNesse server');
  WriteLn(#9'port:          '#9'the port on which the hosting FitNesse server is running');
  WriteLn(#9'rootPath:      '#9'name of the test page or suite page');
  System.Halt(c);
end;

constructor TFormattingOption.Create(format : string; filename : string; stdout : TOutputStream; host : string; port :
  Integer; rootPath : string);
begin
  self.format := format;
  self.filename := filename;
  setOutput(stdout);
  self.host := host;
  self.port := port;
  self.rootPath := rootPath;
end;

procedure TFormattingOption.setOutput(stdout : TOutputStream);
begin
  if ('stdout' = filename) then
  begin
    self.output := stdout;
    self.usingStdout := true;
  end
  else
    self.output := TFileOutputStream.Create(filename);
end;

procedure TFormattingOption.process(inputStream : TInputStream; size : Integer);
var
  request : TRequestBuilder;
  response : TResponseParser;
begin
  if ('raw' = format) then
    TFileUtil.copyBytes(inputStream, output)
  else
  begin
    request := buildRequest(inputStream, size);
    response := TResponseParser.performHttpRequest(host, port, request);
    status := response.getStatus();
    output.write(response.getBody() {.getBytes('UTF-8')});
  end;
  if (not usingStdout) then
    output.close();
end;

function TFormattingOption.wasSuccessful() : Boolean;
begin
  Result := status = 200;
end;

function TFormattingOption.buildRequest(inputStream : TInputStream; size : Integer) : TRequestBuilder;
var
  request : TRequestBuilder;
begin
  request := TRequestBuilder.Create('/' + rootPath);
  request.setMethod('POST');
  request.setHostAndPort(host, port);
  request.addInput('responder', 'format');
  request.addInput('format', format);
  request.addInputAsPart('results', inputStream, size, 'text/plain');
  Result := request;
end;

end.

