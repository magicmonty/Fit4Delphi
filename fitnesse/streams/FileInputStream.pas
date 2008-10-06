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
unit FileInputStream;

interface

uses
  FileUnit,
  classes, InputStream;

type
  TFileInputStream = class(TInputStream)
  public
    procedure close(); virtual;
    constructor Create(const AFile : TFile);
  end;

implementation

uses
  Windows,
  sysUtils;

{ TFileInputStream }

procedure TFileInputStream.close;
begin
  FileClose((stream as TFileStream).Handle);
end;

constructor TFileInputStream.Create(const AFile: TFile);
begin
  inherited Create;
  stream := TFileStream.Create(AFile.FileName, fmOpenRead);
end;

end.

