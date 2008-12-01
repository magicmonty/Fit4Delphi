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
//TODO This is very limited port
unit StreamReader;

interface

uses
  InputStream;

type
  TStreamReader = class(TObject)
  private
    stream : TInputStream;
  public
    constructor Create(input : TInputStream);
    function read(size : Integer) : string;
    function readBytes(size : Integer) : string;
    function readLine() : string;
    function isEof() : Boolean;
  end;

implementation

uses
  IdTCPStream,
  Classes,
  IdIOHandler;

{ TStreamReader }

constructor TStreamReader.Create(input : TInputStream);
begin
  inherited Create;
  stream := input;
end;

function TStreamReader.isEof : Boolean;
begin
  Result := stream.isEof;
end;

function TStreamReader.read(size : Integer) : string;
var
  S : string;
  l : Integer;
begin
  // TODO Ugly quick fix
  if (stream.stream is TIdTCPStream) then
  begin
    Result := (stream.stream as TIdTCPStream).Connection.IOHandler.ReadString(size);
    exit;
  end;

  SetString(S, nil, Size);
  l := Stream.stream.Read(Pointer(S)^, Size);
  Result := Copy(S, 1, l);
end;

function TStreamReader.readBytes(size : Integer) : string;
begin
  Result := read(size); //TODO
end;

function TStreamReader.readLine : string;
var
  s : string;
begin
  // TODO Ugly quick fix
  if (stream.stream is TIdTCPStream) then
  begin
    Result := (stream.stream as TIdTCPStream).Connection.IOHandler.ReadLn;
    exit;
  end;

  Result := '';
  while not stream.isEof do
  begin
    s := read(1);
    if s = #13 then // TODO #13 case, slow
    begin
      s := read(1);
      if s = #10 then // TODO #10 case, slow
        break
      else
        stream.stream.Position := stream.stream.Position - 1;
    end
    else
      Result := Result + s;
  end;
end;

end.

