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
unit RequestBuilder;

interface

uses
  classes,
  IniFiles,
  OutputStream,
  InputStream;
type
  TRequestBuilder = class
  private
    resource : string;
    method : string;
    bodyParts : TList; //= TLinkedList();
    headers : THashedStringList; //= THashMap();
    inputs : THashedStringList; //= THashMap();
    host : string;
    port : Integer;
    boundary : string;
    isMultipart : Boolean;
    bodyLength : Integer;

    function isGet() : Boolean;
    procedure buildBody();
    procedure sendHeaders(output : TOutputStream);
    procedure sendBody(output : TOutputStream);
    procedure addHostHeader();
    procedure addBodyPart(input : string);
    procedure multipart();
    class function URLEncode(const ASrc: string): string; static;
  public
    constructor Create; overload;
    constructor Create(resource : string); overload;
    destructor Destroy; override;
    procedure setMethod(method : string);
    procedure addHeader(key : string; value : string);
    function getText() : string;
    function buildRequestLine() : string;
    procedure send(output : TOutputStream);
    function inputString() : string;
    function getBoundary() : string;
    procedure addInput(key : string; value : TObject); overload;
    procedure addInput(key : string; value : string); overload;
    procedure addCredentials(username : string; password : string);
    procedure setHostAndPort(host : string; port : Integer);
    procedure addInputAsPart(name : string; content : TObject); overload;
    procedure addInputAsPart(name : string; content : string); overload;
    procedure addInputAsPart(name : string; input : TInputStream; size : Integer; contentType : string); overload;
  end;

implementation

uses
  ByteArrayInputStream,
  ByteArrayOutputStream,
  StringBuffer,
  SysUtils,
  IdCoderMIME,
  IdURI,
  StreamReader,
  StringObject,
  FitObject;

const
  ENDL = #13#10;
  //	static final byte[] ENDL := #13#10.getBytes();

type
  TInputStreamPart = class
  public
    input : TInputStream;
    size : Integer;
    contentType : string;
    constructor Create(input : TInputStream; size : Integer; contentType : string);
  end;

constructor TRequestBuilder.Create;
begin
  Create('');
end;

constructor TRequestBuilder.Create(resource : string);
begin
  method := 'GET';
  bodyParts := TList.Create();
  headers := THashedStringList.Create();
  inputs := THashedStringList.Create();
  isMultipart := false;
  bodyLength := 0;
  self.resource := resource;
end;

destructor TRequestBuilder.Destroy;
begin
  bodyParts.Free;
  headers.Free;
  inputs.Free;
end;

procedure TRequestBuilder.setMethod(method : string);
begin
  self.method := method;
end;

procedure TRequestBuilder.addHeader(key : string; value : string);
begin
  headers.Values[key] := value;
end;

function TRequestBuilder.getText() : string;
var
  output : TByteArrayOutputStream;
begin
  output := TByteArrayOutputStream.Create();
  send(output);
  Result := output.toString();
end;

function TRequestBuilder.buildRequestLine() : string;
var
  text : TStringBuffer;
  inputStr : string;
begin
  text := TStringBuffer.Create();
  text.append(method).append(' ').append(resource);
  if (isGet()) then
  begin
    inputStr := inputString();
    if (Length(inputStr) > 0) then
      text.append('?').append(inputStr);
  end;
  text.append(' HTTP/1.1');
  Result := text.toString();
end;

function TRequestBuilder.isGet() : Boolean;
begin
  Result := method = 'GET';
end;

procedure TRequestBuilder.send(output : TOutputStream);
begin
  output.write(buildRequestLine() {.getBytes('UTF-8')});
  output.write(ENDL);
  buildBody();
  sendHeaders(output);
  output.write(ENDL);
  sendBody(output);
end;

procedure TRequestBuilder.sendHeaders(output : TOutputStream);
var
  key : string;
  i : Integer;
begin
  addHostHeader();
  for i := 0 to headers.Count - 1 do
  begin
    key := headers.Names[i];
    //Trim added to resolve problem that empty value is removed from list
    output.write((key + ': ' + Trim(headers.Values[key])) {.getBytes('UTF-8')});
    output.write(ENDL);
  end;
end;

procedure TRequestBuilder.buildBody();
var
  bytes : string;
  i : Integer;
  name : string;
  value : TObject;
  partBuffer : TStringBuffer;
  part : TInputStreamPart;
  tail : TStringBuffer;
begin
  if (not isMultipart) then
  begin
    bytes := inputString() {.getBytes('UTF-8')};
    bodyParts.add(TByteArrayInputStream.Create(bytes));
    Inc(bodyLength, Length(bytes));
  end
  else
  begin
    for i := 0 to inputs.Count - 1 do
    begin
      name := inputs[i];
      value := inputs.Objects[i];
      partBuffer := TStringBuffer.Create();
      partBuffer.append('--').append(getBoundary()).append(#13#10);
      partBuffer.append('Content-Disposition: form-data; name="').append(name).append('"').append(#13#10);
      if (value is TInputStreamPart) then
      begin
        part := value as TInputStreamPart;
        partBuffer.append('Content-Type: ').append(part.contentType).append(#13#10);
        partBuffer.append(#13#10);
        addBodyPart(partBuffer.toString());
        bodyParts.add(part.input);
        Inc(bodyLength, part.size);
        addBodyPart(#13#10);
      end
      else
      begin
        partBuffer.append('Content-Type: text/plain').append(#13#10);
        partBuffer.append(#13#10);
        partBuffer.append((value as TFitObject).toString);
        partBuffer.append(#13#10);
        addBodyPart(partBuffer.toString());
      end;
    end;
    tail := TStringBuffer.Create();
    tail.append('--').append(getBoundary()).append('--').append(#13#10);
    addBodyPart(tail.toString());
  end;
  addHeader('Content-Length', IntToStr(bodyLength));
end;

procedure TRequestBuilder.addBodyPart(input : string);
var
  bytes : string;
begin
  bytes := input {.toString().getBytes('UTF-8')};
  bodyParts.add(TByteArrayInputStream.Create(bytes));
  Inc(bodyLength, length(bytes));
end;

procedure TRequestBuilder.sendBody(output : TOutputStream);
var
  i : Integer;
  input : TInputStream;
  reader : TStreamReader;
  bytes : string;
begin
  for i := 0 to bodyParts.Count - 1 do
  begin
    input := TInputStream(bodyParts[i]);

    reader := TStreamReader.Create(input);
    while (not reader.isEof()) do
    begin
      bytes := reader.readBytes(1000);
      output.write(bytes);
    end;
    reader.Free;
  end;
end;

procedure TRequestBuilder.addHostHeader();
begin
  if (host <> '') then
    addHeader('Host', host + ':' + IntToStr(port))
  else
    addHeader('Host', ' '); // Needs to be a space because without that key would be removed....
end;

procedure TRequestBuilder.addInput(key : string; value : TObject);
begin
  inputs.AddObject(key, value);
end;

procedure TRequestBuilder.addInput(key : string; value : string);
var
  str : TStringObject;
begin
  str := TStringObject.Create(value);
  inputs.AddObject(key, str);
end;

class function TRequestBuilder.URLEncode(const ASrc: string): string;
var
  i: Integer;
begin
  Result := '';    {Do not Localize}
  for i := 1 to Length(ASrc) do begin
    if ASrc[i] in ['a'..'z','A'..'Z','0'..'9','.','-','*','_'] then
      Result := Result + ASrc[i]
    else if ASrc[i] = ' ' then
      Result := Result + '+'
    else
      Result := Result + '%' + IntToHex(Ord(ASrc[i]), 2);  {do not localize}
  end;
end;

function TRequestBuilder.inputString() : string;
var
  buffer : TStringBuffer;
  first : Boolean;
  i : Integer;
  key : string;
  value : TFitObject;
begin
  buffer := TStringBuffer.Create();
  first := true;
  for i := 0 to inputs.Count - 1 do
  begin
    key := inputs[i];
    value := (inputs.Objects[i] as TFitObject);
    if (not first) then
      buffer.append('&');
    buffer.append(key).append('=').append(URLEncode(value.toString() {, 'UTF-8')}));
    first := false;
  end;
  Result := buffer.toString();
end;

procedure TRequestBuilder.addCredentials(username : string; password : string);
var
  rawUserpass : string;
  userpass : string;
  Enc : TIdEncoderMime;
begin
  rawUserpass := username + ':' + password;

  Enc := TIdEncoderMIME.Create(nil);
  userpass := Enc.Encode(rawUserpass);
  Enc.Free;
  addHeader('Authorization', 'Basic ' + userpass);
end;

procedure TRequestBuilder.setHostAndPort(host : string; port : Integer);
begin
  self.host := host;
  self.port := port;
end;

function TRequestBuilder.getBoundary() : string;
begin
  if (boundary = '') then
    boundary := '----------' + IntToStr(Random(MaxInt)) + 'BoUnDaRy';
  Result := boundary;
end;

procedure TRequestBuilder.addInputAsPart(name : string; content : TObject);
begin
  multipart();
  addInput(name, content);
end;

procedure TRequestBuilder.addInputAsPart(name : string; content : string);
begin
  multipart();
  addInput(name, content);
end;

procedure TRequestBuilder.addInputAsPart(name : string; input : TInputStream; size : Integer; contentType : string);
begin
  addInputAsPart(name, TInputStreamPart.Create(input, size, contentType));
end;

procedure TRequestBuilder.multipart();
begin
  if (not isMultipart) then
  begin
    isMultipart := true;
    setMethod('POST');
    addHeader('Content-Type', 'multipart/form-data; boundary=' + getBoundary());
  end;
end;

constructor TInputStreamPart.Create(input : TInputStream; size : Integer; contentType : string);
begin
  self.input := input;
  self.size := size;
  self.contentType := contentType;
end;

initialization
  Randomize;

end.

