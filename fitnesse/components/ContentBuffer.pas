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
unit ContentBuffer;

interface

uses
  FileUnit,
  OutputStream,
  InputStream;

type
  TContentBuffer = class
  private
    outputStream : TOutputStream;
    size : integer;
    tempFile : TFile;
    opened : boolean;
    procedure open();
    //    function append(const bytes) : TContentBuffer; overload;
    procedure close();
  public
    constructor Create; overload;
    constructor Create(ext : string); overload;
    destructor Destroy; override;
    function getSize() : Integer;
    function getInputStream() : TInputStream;
    function getNonDeleteingInputStream() : TInputStream;
    function getOutputStream() : TOutputStream;
    function getFile() : TFile;
    procedure delete();
    function append(value : string) : TContentBuffer; overload;
    function getContent() : string;
  end;

implementation

uses
  FileInputStream,
  FileOutputStream,
  classes,
  FileUtil;

type
  TDeleteFileInputStream = class(TFileInputStream)
  public
    tempFile : TFile;
    procedure close(); override;
  end;

procedure TDeleteFileInputStream.close();
begin
  inherited close();
  tempFile.delete();
end;

constructor TContentBuffer.Create(ext : string);
begin
  inherited Create;
  tempFile := TFile.createTempFile('FitNesse-', ext);
end;

constructor TContentBuffer.Create();
begin
  Create('.tmp');
end;

destructor TContentBuffer.Destroy();
begin
  delete();
  inherited Destroy;
end;

procedure TContentBuffer.open();
begin

  if (not opened) then
  begin
    outputStream := TFileOutputStream.Create(tempFile, true);
    opened := true;
  end;
end;

function TContentBuffer.append(value : string) : TContentBuffer;
//var
//  bytes : byte;
begin
  //  bytes:=value.getBytes('UTF-8');
  //TODO  result := append(value);

  open();
  Inc(size, Length(value));
  outputStream.write(value);
  result := self;
end;

{
function TContentBuffer.append(const bytes): TContentBuffer;
begin
  open();
  Inc(size, Length(bytes));
  outputStream.write(bytes);
  result := self;
end;
}

procedure TContentBuffer.close();
begin
  if (opened) then
  begin
    outputStream.close();
    opened := false;
  end;
end;

function TContentBuffer.getContent() : string;
begin
  close();
  result := TFileUtil.getFileContent(tempFile.FileName);
end;

function TContentBuffer.getSize() : Integer;
begin
  close();
  result := size;
end;

function TContentBuffer.getInputStream() : TInputStream;
begin
  close();
  Result := TDeleteFileInputStream.Create(tempFile);
end;

function TContentBuffer.getNonDeleteingInputStream() : TInputStream;
begin
  close();
  Result := TFileInputStream.Create(tempFile);
end;

function TContentBuffer.getOutputStream() : TOutputStream;
begin
  result := outputStream;
end;

function TContentBuffer.getFile() : TFile;
begin
  result := tempFile;
end;

procedure TContentBuffer.delete();
begin
  tempFile.delete();
end;

end.

