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
unit ResponseParser;

interface

uses
  StreamReader,
  IniFiles,
  InputStream,
  RequestBuilder;

type
  TResponseParser = class
  private
    status : Integer;
    body : string;
    headers : THashedStringList; //= new HashMap<String, String>();
    input : TStreamReader;
    procedure parseStatusLine();
    procedure parseHeaders();
    function isChuncked() : Boolean;
    procedure parseChunks();
    procedure parseBody();
    function hasHeader(key : string) : Boolean;
    procedure readCRLF();
  public
    constructor Create(input : TInputStream);
    destructor Destroy; override;
    function getBody() : string;
    function getHeader(key : string) : string;
    function toString() : string;
    function readChunkSize() : Integer;
    function getStatus() : Integer;
    class function performHttpRequest(hostname : string; hostPort : Integer; builder : TRequestBuilder) :
      TResponseParser;
  end;

implementation

uses
  TcpInputStream,
  SysUtils,
  StringBuffer,
  IdTCPStream,
  Matcher,
  OutputStream,
  idTCPClient;

const
  statusLinePattern = 'HTTP/\d.\d (\d\d\d) ';
  headerPattern = '([^:]*): (.*)';

constructor TResponseParser.Create(input : TInputStream);
begin
  headers := THashedStringList.Create;
  self.input := TStreamReader.Create(input);
  parseStatusLine();
  parseHeaders();
  if (isChuncked()) then
  begin
    parseChunks();
    parseHeaders();
  end
  else
    parseBody();
end;

function TResponseParser.isChuncked() : Boolean;
var
  encoding : string;
begin
  encoding := getHeader('Transfer-Encoding');
  Result := (encoding <> '') and ('chunked' = LowerCase(encoding));
end;

procedure TResponseParser.parseStatusLine();
var
  statusLine : string;
  match : TRegExpr;
  status : string;
begin
  statusLine := input.readLine();
  match := TRegExpr.Create;
  match.Expression := statusLinePattern;
  if (match.Exec(statusLine)) then
  begin
    status := match.Match[1];
    self.status := StrToInt(status);
  end
  else
    raise Exception.Create('Could not parse Response');
end;

procedure TResponseParser.parseHeaders();
var
  line : string;
  match : TRegExpr;
  key : string;
  value : string;
begin
  line := input.readLine();
  while ('' <> line) do
  begin
    match := TRegExpr.Create;
    match.Expression := headerPattern;
    if (match.Exec(line)) then
    begin
      key := match.Match[1];
      value := match.Match[2];
      headers.Values[key] := value;
    end;
    line := input.readLine();
  end;
end;

procedure TResponseParser.parseBody();
var
  lengthHeader : string;
  bytesToRead : Integer;
begin
  lengthHeader := 'Content-Length';
  if (hasHeader(lengthHeader)) then
  begin
    bytesToRead := StrToInt(getHeader(lengthHeader));
    body := input.read(bytesToRead);
  end;
end;

procedure TResponseParser.parseChunks();
var
  bodyBuffer : TStringBuffer;
  chunkSize : Integer;
begin
  bodyBuffer := TStringBuffer.Create();
  chunkSize := readChunkSize();
  while (chunkSize <> 0) do
  begin
    bodyBuffer.append(input.read(chunkSize));
    readCRLF();
    chunkSize := readChunkSize();
  end;
  body := bodyBuffer.toString();
end;

function TResponseParser.readChunkSize() : Integer;
var
  sizeLine : string;
begin
  sizeLine := input.readLine();
  Result := StrToInt('$' + sizeLine); //TODO Verify Integer.parseInt(sizeLine, 16);
end;

procedure TResponseParser.readCRLF();
begin
  input.read(2);
end;

function TResponseParser.getStatus() : Integer;
begin
  Result := status;
end;

destructor TResponseParser.Destroy;
begin
  headers.Free;
  self.input.Free;

  inherited;
end;

function TResponseParser.getBody() : string;
begin
  Result := body;
end;

function TResponseParser.getHeader(key : string) : string;
begin
  Result := headers.Values[key];
end;

function TResponseParser.hasHeader(key : string) : Boolean;
begin
  Result := headers.IndexOfName(key) <> -1;
end;

function TResponseParser.toString() : string;
var
  buffer : TStringBuffer;
  i : Integer;
  key : string;
begin
  buffer := TStringBuffer.Create();
  buffer.append('Status: ').append(status).append(#13#10);
  buffer.append('Headers: ').append(#13#10);
  for i := 0 to headers.Count - 1 do
  begin
    key := headers[i];
    buffer.append(#9).append(key).append(': ').append(headers.ValueFromIndex[i]).append(#13#10);
  end;
  buffer.append('Body: ').append(#13#10);
  buffer.append(body);
  Result := buffer.toString();
end;

class function TResponseParser.performHttpRequest(hostname : string; hostPort : Integer; builder : TRequestBuilder) :
  TResponseParser;
var
  parser : TResponseParser;
  socketOut : TOutputStream;
  socketIn : TInputStream;
  socket : TIdTCPClient;
  inputStream : TIdTCPStream;
  outputStream : TIdTCPStream;
begin
  socket := TIdTCPClient.Create(nil);
  socket.Host := hostname;
  socket.Port := hostPort;
  socket.Connect;

  inputStream := TIdTCPStream.Create(socket);
  outputStream := TIdTCPStream.Create(socket);
  socketOut := TOutputStream.Create;
  socketIn := TTcpInputStream.Create;
  socketOut.stream := outputStream; //socket.getOutputStream();
  socketIn.stream := inputStream; // := socket.getInputStream();
  builder.send(socketOut);
  socketOut.flush();

  parser := TResponseParser.Create(socketIn);

  inputStream.Free;
  outputStream.Free;
  //  socketOut.Free;
  //  socketIn.Free;

  socket.Disconnect;
  socket.Free;
  Result := parser;
end;

end.

