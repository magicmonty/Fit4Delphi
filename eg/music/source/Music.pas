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
unit Music;

interface

uses
  Classes, SysUtils, Fixture;

type
  {$METHODINFO ON}
  TMusic = class (TPersistent)
  private
    FAlbum: string;
    FArtist: string;
    FDate: string;
    FYear: Integer;
    FGenre: string;
    FSize: LongInt;
    function GetTime: double;
    function GetTrack: string;
    function GetAlbum: Variant;
    function GetArtist: Variant;
    function GetDate: Variant;
    function GetGenre: Variant;
    function GetSize: Variant;
    function GetYear: Variant;
  public
    seconds: Integer;
    FTitle: string;
    trackCount: Integer;
    trackNumber: Integer;
    FSelected : Boolean;
    constructor Create;
    function GetTitle : Variant;
    procedure parse(sSong : string);
//    property time : double read GetTime;
    property Selected : Boolean read FSelected write FSelected;
  published
    property album : Variant read GetAlbum;
    property artist : Variant read GetArtist;
    property date : Variant read GetDate;
    property genre : Variant read GetGenre;
    property title : Variant read GetTitle;
//    property track : TStringFunc read GetFTrack;
    function track : Variant;
    property year : Variant read GetYear;
    property size : Variant read GetSize;
    function time : Variant;
//    property time : Double read GetTime;
  end;

var
  status : string;

implementation

uses
  StringTokenizer;

{ TMusic }

{
************************************ TMusic ************************************
}
constructor TMusic.Create;
begin
  Selected := False;
end;

function TMusic.GetAlbum: Variant;
begin
  Result := FAlbum;
end;

function TMusic.GetArtist: Variant;
begin
  Result := FArtist;
end;

function TMusic.GetDate: Variant;
begin
  Result := FDate;
end;

function TMusic.GetGenre: Variant;
begin
  Result := FGenre;
end;

function TMusic.GetSize: Variant;
begin
  Result := FSize;
end;

function TMusic.GetTime: double;
begin
  result := round(seconds / 0.6) / 100.0;
end;

function TMusic.GetTitle: Variant;
begin
  result := FTitle;
end;

function TMusic.GetTrack: string;
begin
  result := format('%d of %d', [trackNumber, trackCount]);
end;

function TMusic.GetYear: Variant;
begin
  Result := FYear;
end;

procedure TMusic.parse(sSong : string);
var
  iCode: Integer;
  t: TStringTokenizer;
begin
  t := TStringTokenizer.Create(#9);
  t.Text := sSong;
  FTitle := t[0];
  FArtist := t[1];
  FAlbum  := t[2];
  FGenre  := t[3];
  Val(t[4], FSize, iCode);
  Seconds := StrToInt(t[5]);
  trackNumber := StrToInt(t[6]);
  trackCount := StrToInt(t[7]);
  FYear := StrToInt(t[8]);
  FDate := t[9];
  t.Free;
end;

function TMusic.time: Variant;
begin
  Result := GetTime;
end;

function TMusic.track: Variant;
begin
  Result := GetTrack;
end;

initialization
  status := 'ready';
  RegisterClass(TMusic);

finalization
  UnRegisterClass(TMusic);

end.

