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
// Derived from Fixture.java by Martin Chernenkoff, CHI Software Design
// Ported to Delphi by Michal Wojcik.
//
unit Display;

interface

uses
  Classes,
  RowFixture;

type
  TDisplay = class(TRowFixture)
  public
    function query : TList; override;
    function getTargetClass() : TClass; override;
  end;

implementation

uses
  MusicLibrary,
  Music;

function TDisplay.getTargetClass : TClass;
begin
  Result := TMusic;
end;

function TDisplay.query : TList;
begin
  Result := TList.Create;
  MusicLibrary.DisplayContents(result);
end;

initialization
  RegisterClass(TDisplay);

finalization
  UnRegisterClass(TDisplay);

end.

