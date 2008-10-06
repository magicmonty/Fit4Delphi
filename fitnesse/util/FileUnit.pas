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
unit FileUnit;

interface

type
  TFile = class
  private
  public
    FileName : string;
    procedure delete();
    function getName() : string;
    function exists() : Boolean;
    function length : Int64;
    class function createTempFile(prefix, suffix : string) : TFile;
    constructor Create(name : string);
  end;
implementation

uses
  sysUtils,
  windows, FileOutputStream;

{ TFile }

function GetTempDir : TFileName;
var
  TmpDir : array[0..MAX_PATH - 1] of char;
begin
  try
    SetString(Result, TmpDir, GetTempPath(MAX_PATH, TmpDir));
    if not DirectoryExists(Result) then
      if not CreateDirectory(PChar(Result), nil) then
      begin
        raise Exception.Create(SysErrorMessage(GetLastError));
      end;
  except
    Result := '';
    raise;
  end;
end;

constructor TFile.Create(name : string);
var
  stream : TFileOutputStream;
begin
  inherited Create;
  FileName := name;
  stream := TFileOutputStream.Create(self);
  stream.Free;
end;

class function TFile.createTempFile(prefix, suffix : string) : TFile;
var
  TempFileName : array[0..MAX_PATH - 1] of char;
  FileName  : String;
begin
  if GetTempFileName(PChar(GetTempDir), PChar(prefix), 0, TempFileName) = 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));
  DeleteFile(PChar(FileName));
  FileName := ChangeFileExt(TempFileName, suffix);
  FileName := ExtractFilePath(FileName) + prefix + ExtractFileName(FileName);
  Result := TFile.Create(FileName);
end;

procedure TFile.delete;
begin
  DeleteFile(PChar(FileName));
end;

function TFile.exists : Boolean;
begin
  Result := FileExists(FileName);
end;

function TFile.getName : string;
begin
  Result := ExtractFileName(FileName);
end;

function TFile.length : Int64;
var
  SearchRec : TSearchRec;
begin
  if FindFirst(FileName, faAnyFile, SearchRec) = 0 then // if found
    Result := Int64(SearchRec.FindData.nFileSizeHigh) shl Int64(32) + // calculate the size
    Int64(SearchREc.FindData.nFileSizeLow)
  else
    Result := 0;
  SysUtils.FindClose(SearchRec);
end;

end.

