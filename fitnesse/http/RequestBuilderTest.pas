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
unit RequestBuilderTest;

interface

uses
  RegexTest,
  RequestBuilder;

type
  TRequestBuilderTest = class(TRegexTest)
  private
    builder : TRequestBuilder;
    //TODO    procedure testMultipartWithRequestParser;
  protected
    procedure SetUp(); override;
    procedure TearDown(); override;
  published
    procedure testAddingCredentials;
    procedure testAddInput;
    procedure testChangingMethod;
    procedure testDeafultValues;
    procedure testGetBoundary;
    procedure testGETMethodWithInputs;
    procedure testHostHeader_RFC2616_section_14_23;
    procedure testMultipartOnePart;
    procedure testMultipartWithInputStream;
    procedure testPOSTMethodWithInputs;
  end;

implementation

uses
  sysUtils,
  TestFramework,
  ByteArrayInputStream;

procedure TRequestBuilderTest.SetUp();
begin
  builder := TRequestBuilder.Create('/');
end;

procedure TRequestBuilderTest.testDeafultValues();
var
  text : string;
begin
  builder := TRequestBuilder.Create('/someResource');
  text := builder.getText();
  assertHasRegexp('GET /someResource HTTP/1.1'#13#10, text);
end;

procedure TRequestBuilderTest.testHostHeader_RFC2616_section_14_23();
var
  text : string;
begin
  builder := TRequestBuilder.Create('/someResource');
  text := builder.getText();
  assertSubString('Host: '#13#10, text);

  builder.setHostAndPort('some.host.com', 123);
  text := builder.getText();
  assertSubString('Host: some.host.com:123'#13#10, text);
end;

procedure TRequestBuilderTest.testChangingMethod();
var
  text : string;
begin
  builder.setMethod('POST');
  text := builder.getText();
  assertHasRegexp('POST / HTTP/1.1'#13#10, text);
end;

procedure TRequestBuilderTest.testAddInput();
var
  content : string;
  inputString : string;
begin
  builder.addInput('responder', 'saveData');
  content := '!fixture fit.ColumnFixture'#10 +
    #10 +
    '!path classes'#10 +
    #10 +
    '!2 ';
  builder.addInput('pageContent', content);

  inputString := builder.inputString();
  assertSubString('responder=saveData', inputString);
  assertSubString('pageContent=%21fixture+fit.ColumnFixture%0A%0A%21path+classes%0A%0A%212+', inputString);
  assertSubString('&', inputString);
end;

procedure TRequestBuilderTest.testGETMethodWithInputs();
var
  text : string;
begin
  builder.addInput('key', 'value');
  text := builder.getText();
  assertSubString('GET /?key=value HTTP/1.1'#13#10, text);
end;

procedure TRequestBuilderTest.testPOSTMethodWithInputs();
var
  text : string;
begin
  builder.setMethod('POST');
  builder.addInput('key', 'value');
  text := builder.getText();
  assertSubString('POST / HTTP/1.1'#13#10, text);
  assertSubString('key=value', text);
end;

procedure TRequestBuilderTest.TearDown;
begin
  inherited;
  builder.Free;
end;

procedure TRequestBuilderTest.testAddingCredentials();
begin
  builder.addCredentials('Aladdin', 'open sesame');
  assertSubString('Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==', builder.getText());
end;

procedure TRequestBuilderTest.testGetBoundary();
var
  boundary : string;
begin
  boundary := builder.getBoundary();

  CheckEquals(boundary, builder.getBoundary());
  sleep(10);
  CheckFalse(boundary = TRequestBuilder.Create('blah').getBoundary());
end;

procedure TRequestBuilderTest.testMultipartOnePart();
var
  text : string;
  boundary : string;
begin
  builder.addInputAsPart('myPart', 'part data');
  text := builder.getText();

  assertSubString('POST', text);
  assertSubString('Content-Type: multipart/form-data; boundary=', text);
  boundary := builder.getBoundary();
  assertSubString('--' + boundary, text);
  assertSubString(#13#10#13#10'part data'#13#10, text);
  assertSubString('--' + boundary + '--', text);
end;

procedure TRequestBuilderTest.testMultipartWithInputStream();
var
  text : string;
  input : TByteArrayInputStream;
begin
  input := TByteArrayInputStream.Create('data from input stream' {.getBytes()});
  builder.addInputAsPart('input', input, 89, 'text/html');
  text := builder.getText();

  assertSubString('Content-Type: text/html', text);
  assertSubString(#13#10#13#10'data from input stream'#13#10, text);
end;

{
procedure TRequestBuilderTest.testMultipartWithRequestParser();
var
  text : string;
begin
  builder.addInputAsPart('part1', 'data 1');
  builder.addInput('input1', 'input1 value');
  builder.addInputAsPart('part2', 'data 2');
  text := builder.getText();

  Request request := new Request(new ByteArrayInputStream(text.getBytes()));
  request.parse();
  assertEquals('data 1', request.getInput('part1'));
  assertEquals('data 2', request.getInput('part2'));
  assertEquals('input1 value', request.getInput('input1'));
end;
}

initialization

  TestFramework.RegisterTest(TRequestBuilderTest.Suite);

end.

