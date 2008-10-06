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
unit ResponseParserTest;

interface

uses
  classes,
  TestFramework,
  InputStream;

type
  TResponseParserTest = class(TTestCase)
  private
    input : TInputStream;
    response : string;
  public
    class procedure main(args : TStringList);
  published
    procedure testParsing();
    procedure testChunkedResponse();
  end;

implementation

uses
  ResponseParser,
  TestRunner,
  ByteArrayInputStream;

{ TResponseParserTest }

class procedure TResponseParserTest.main(args : TStringList);
var
  arg : TStringList;
begin
  arg := TStringList.Create;
  arg.Add('ResponseParserTest');
  TTestRunner.main(arg);
  arg.Free;
end;

procedure TResponseParserTest.testParsing();
var
  parser : TResponseParser;
begin
  response := 'HTTP/1.1 200 OK'#13#10 + 'Content-Type: text/html'#13#10 + 'Content-Length: 12'#13#10 +
    'Cache-Control: max-age=0'#13#10 + #13#10 + 'some content';
  input := TByteArrayInputStream.Create(response {.getBytes()});

  parser := TResponseParser.Create(input);
  CheckEquals(200, parser.getStatus());
  CheckEquals('text/html', parser.getHeader('Content-Type'));
  CheckEquals('some content', parser.getBody());
end;

procedure TResponseParserTest.testChunkedResponse();
var
  parser : TResponseParser;
begin
  response := 'HTTP/1.1 200 OK'#13#10 + 'Content-Type: text/html'#13#10 + 'Transfer-Encoding: chunked'#13#10 + #13#10 +
    '3'#13#10 + '123'#13#10 + '7'#13#10 + '4567890'#13#10 + '0'#13#10 + 'Tail-Header: TheEnd!'#13#10;
  input := TByteArrayInputStream.Create(response {.getBytes()});

  parser := TResponseParser.Create(input);
  CheckEquals(200, parser.getStatus());
  CheckEquals('text/html', parser.getHeader('Content-Type'));
  CheckEquals('1234567890', parser.getBody());
  CheckEquals('TheEnd!', parser.getHeader('Tail-Header'));
end;

initialization

  TestFramework.RegisterTest(TResponseParserTest.Suite);

end.

