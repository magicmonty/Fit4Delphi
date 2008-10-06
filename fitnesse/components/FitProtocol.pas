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
unit FitProtocol;

interface

uses
  StrUtils,
  SysUtils,
  StringTokenizer,
  OutputStream,
  Counts,
  StreamReader;

const
  format : string = '%10.10d';

type
  TFitProtocol = class
  public
    constructor Create;
    destructor Destroy; override;
    class procedure writeData(data : string; output : TOutputStream); overload;
    //    procedure writeData(bytes : byte; output : TOutputStream); overload;
    class procedure writeSize(length : integer; output : TOutputStream);
    class procedure writeCounts(count : TCounts; output : TOutputStream);
    class function readSize(reader : TStreamReader) : integer;
    class function readDocument(reader : TStreamReader; size : integer) : string;
    class function readCounts(reader : TStreamReader) : TCounts;
  end;

implementation

{ TFitProtocol }

constructor TFitProtocol.Create();
begin
  inherited Create;
end;

destructor TFitProtocol.Destroy();
begin
  inherited Destroy;
end;

class procedure TFitProtocol.writeData(data : string; output : TOutputStream);
//var
// bytes : byte;
begin
  //  bytes:=data.getBytes('UTF-8');
  //  writeData(bytes,output);
  writeSize(length(data), output);
  output.write(data);
  output.flush();

end;
{
procedure TFitProtocol.writeData(bytes : byte; output : TOutputStream);
var
  length : integer;
begin
  length:=bytes.length;
  writeSize(length,output);
  output.write(bytes);
  output.flush();
end;
}

class procedure TFitProtocol.writeSize(length : integer; output : TOutputStream);
var
  formattedLength : string;
  //  lengthBytes : byte;
begin
  formattedLength := SysUtils.Format('%10.10d', [length]);
  //  lengthBytes:=formattedLength.getBytes();
  output.write(formattedLength {lengthBytes}); //TODO
  output.flush();
end;

class procedure TFitProtocol.writeCounts(count : TCounts; output : TOutputStream);
begin
  writeSize(0, output);
  writeSize(count.right, output);
  writeSize(count.wrong, output);
  writeSize(count.ignores, output);
  writeSize(count.exceptions, output);
end;

class function TFitProtocol.readSize(reader : TStreamReader) : Integer;
var
  sizeString : string;
begin
  sizeString := reader.read(10);

  if (length(sizeString) < 10) then
  begin
    raise Exception.Create('A size value could not be read. Fragment=|' + sizeString + '|');
  end
  else
  begin
    result := StrToInt(sizeString);
  end;
end;

class function TFitProtocol.readDocument(reader : TStreamReader; size : integer) : string;
begin
  result := reader.read(size);
end;

class function TFitProtocol.readCounts(reader : TStreamReader) : TCounts;
var
  counts : TCounts;
begin
  counts := TCounts.Create();
  counts.right := readSize(reader);
  counts.wrong := readSize(reader);
  counts.ignores := readSize(reader);
  counts.exceptions := readSize(reader);
  result := counts;
end;

end.

