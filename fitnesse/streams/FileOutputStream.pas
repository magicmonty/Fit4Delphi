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
unit FileOutputStream;

interface

uses
  classes,
  OutputStream, FileUnit;

type
  TFileOutputStream = class(TOutputStream)
  public
    constructor Create(const AFileName : String); overload;
    constructor Create(const AFile : TFile); overload;
    constructor Create(const AFile : TFile; append : Boolean); overload;
    procedure close(); override;
  end;

implementation

uses
  Windows,
  sysUtils;

{ TFileOutputStream }

constructor TFileOutputStream.Create(const AFile: TFile);
begin
  inherited Create;
  stream := TFileStream.Create(AFile.FileName, fmCreate);
end;

procedure TFileOutputStream.close;
begin
  inherited;
  FileClose((stream as TFileStream).Handle);
end;

constructor TFileOutputStream.Create(const AFile: TFile; append: Boolean);
begin
  inherited Create;
  stream := TFileStream.Create(AFile.FileName, fmCreate);
  if append then
    stream.Seek(0, soEnd);
end;

constructor TFileOutputStream.Create(const AFileName: String);
begin
  Create(TFile.Create(AFileName));
end;

end.

