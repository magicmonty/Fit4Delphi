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
{$H+}
unit FileUtil;

interface

uses
  classes, InputStream, OutputStream;

type
  TFileUtil = class
  private
    class function LoadFromStream(Stream : TStream) : string; static;
  public
    class function getFileContent(path : string) : string;
    class procedure copyBytes(inputStream : TInputStream; outputStream : TOutputStream);
  end;
implementation

uses
  sysUtils;

{ TFileUtil }

class procedure TFileUtil.copyBytes(inputStream: TInputStream;   outputStream: TOutputStream);
begin
  outputStream.stream.CopyFrom(inputStream.stream, 0);
end;

class function TFileUtil.getFileContent(path : string) : string;
var
  Stream : TStream;
begin
  Stream := TFileStream.Create(path, fmOpenRead or fmShareDenyWrite);
  try
    Result := LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

class function TFileUtil.LoadFromStream(Stream : TStream) : string;
var
  Size : Integer;
  S : string;
begin
  Size := Stream.Size - Stream.Position;
  SetString(S, nil, Size);
  Stream.Read(Pointer(S)^, Size);
  Result := S;
end;


end.

