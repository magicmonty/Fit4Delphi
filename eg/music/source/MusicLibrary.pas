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
unit MusicLibrary;

interface

uses
  Classes, SysUtils, Music;

type
  TMusicLibrary = class (TObject)
  protected
    FLibrary: string;
    FSelectIndex: Integer;
    MusicLibrary : TList;
    function GetCount: Integer;
    function GetSelectedSong: TMusic;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadLibrary(FileName : string);
    procedure Select(index : integer);
    procedure SetSongAsSelected (index : Integer);
    function GetSong(Index : integer) : TMusic;
    procedure findAlbum(a : string);
    procedure findArtist(a : string);
    procedure findAll;
    function CountSelectedSongs : Integer;
    procedure DisplayContents(results : TList);

    property Count: Integer read GetCount;
    property Selected: Integer read FSelectIndex;
    property SelectedSong: TMusic read GetSelectedSong;
  end;

var
  looking : TMusic;

procedure searchComplete;
procedure Select(index : integer);
procedure findAlbum(a: string);
procedure findArtist(a : string);
procedure findAll;
procedure search(seconds : double);
function displayCount : integer;
function SelectedSong : TMusic;
procedure LoadLibrary(FileName : string);
function Count: Integer;
procedure DisplayContents(results: TList);

implementation

uses
  MusicPlayer, Simulator;

var
  FMusicLibrary : TMusicLibrary;

procedure DisplayContents(results: TList);
begin
//  FMusicLibrary.LoadLibrary('c:\fitnesse\source\DelphiFit\eg\music\Music.txt');
//  FMusicLibrary.select(3);
  FMusicLibrary.DisplayContents(results);
end;

function Count : Integer;
begin
  result := FMusicLibrary.Count;
end;

procedure Select(index : integer);
begin
  FMusicLibrary.Select(index);
end;

procedure LoadLibrary(FileName : string);
begin
  FMusicLibrary.LoadLibrary(FileName);
end;

function SelectedSong : TMusic;
begin
  result := FMusicLibrary.GetSelectedSong;
end;

function displayCount : integer;
begin
(*
    static int displayCount() {
        int count = 0;
        for (int i=0; i<library.length; i++) {
            count += (library[i].selected ? 1 : 0);
        }
        return count;
    }
*)
  result := FMusicLibrary.CountSelectedSongs;
end;

procedure Search(seconds : double);
begin
(*
    static void search(double seconds){
        Music.status = "searching";
        Simulator.nextSearchComplete = Simulator.schedule(seconds);
    }
*)
  Music.status := 'searching';
  Simulator.nextSearchComplete := Simulator.schedule(seconds);
end;

procedure findAlbum(a: string);
begin
(*
    static void findAlbum(String a) {
        search(1.1);
        for (int i=0; i<library.length; i++) {
            library[i].selected = library[i].album.equals(a);
        }
    }
*)
  search(1.1);
  FMusicLibrary.findAlbum(a);
end;

procedure findArtist(a : string);
begin
  search(2.3);
  FMusicLibrary.findArtist(a);
end;

procedure findAll;
begin
  search(3.2);
  FMusicLibrary.findAll;
end;

procedure searchComplete;
begin
(*
    static void searchComplete() {
        Music.status = MusicPlayer.playing == null ? "ready" : "playing";
    }
*)
  if MusicPlayer.playing = nil then
    Music.status := 'ready'
  else
    Music.status := 'playing';
end;

{ TTestMusicLibrary }

{

{ TMusicLibrary }

{
******************************** TMusicLibrary *********************************
}
function TMusicLibrary.CountSelectedSongs: Integer;
var
  i, iSelCount : integer;
begin
  iSelCount := 0;
  for i := 0 to Count - 1 do begin
    if TMusic(MusicLibrary.Items[i]).Selected then
      Inc(iSelCount);
  end;
  result := iSelCount;
end;

constructor TMusicLibrary.Create;
begin
  MusicLibrary := TList.Create;
end;

destructor TMusicLibrary.Destroy;
begin
  MusicLibrary.Free;
end;

function TMusicLibrary.GetCount: Integer;
begin
  result := MusicLibrary.Count;
end;

function TMusicLibrary.GetSelectedSong: TMusic;
begin
  result := MusicLibrary.Items[FSelectIndex - 1];
end;

function TMusicLibrary.GetSong(Index: integer): TMusic;
begin
  result := TMusic.Create;
end;

procedure TMusicLibrary.LoadLibrary(FileName : string);
var
  i : integer;
  aMusic : TMusic;
  aStringList : TStringList;
begin
  FLibrary := FileName;
  aStringList := TStringList.Create;
  aStringList.LoadFromFile(FLibrary);
  MusicLibrary.Clear;
  for i := 1 to aStringList.Count - 1 do begin
    aMusic := TMusic.Create;
    aMusic.parse(aStringList[i]);
    MusicLibrary.Add(aMusic);
  end;
  aStringList.Free;
end;

procedure TMusicLibrary.Select(index : integer);
begin
  FSelectIndex := index;
  looking := GetSelectedSong;
end;

procedure TMusicLibrary.SetSongAsSelected(index: Integer);
begin
  TMusic(MusicLibrary.Items[Index - 1]).Selected := True;
end;

procedure TMusicLibrary.findAll;
var
  i : integer;
begin
(*
    static void findAll() {
        search(3.2);
        for (int i=0; i<library.length; i++) {
            library[i].selected = true;
        }
    }
*)
  for i := 0 to Count - 1 do
    TMusic(MusicLibrary.Items[i]).Selected := True;
end;

procedure TMusicLibrary.findAlbum(a: string);
var
  i : integer;
  aMusic : TMusic;
begin
(*
    static void findAlbum(String a) {
        search(1.1);
        for (int i=0; i<library.length; i++) {
            library[i].selected = library[i].album.equals(a);
        }
    }
*)
  for i := 1 to Count do begin
    aMusic := TMusic(MusicLibrary.Items[i-1]);
    aMusic.Selected := aMusic.album = a;
  end;
end;

procedure TMusicLibrary.findArtist(a: string);
var
  i : integer;
  aMusic : TMusic;
begin
  for i := 1 to Count do begin
    aMusic := TMusic(MusicLibrary.Items[i-1]);
    aMusic.Selected := aMusic.artist = a;
  end;
end;

procedure TMusicLibrary.DisplayContents(results: TList);
var
  i : integer;
  aMusic : TMusic;
begin
  for i := 1 to Count do begin
    aMusic := TMusic(MusicLibrary.Items[i-1]);
    if aMusic.Selected then
      results.Add(aMusic);
  end;
end;

initialization
  looking := nil;
  FMusicLibrary := TMusicLibrary.Create;

finalization
  FMusicLibrary.Free;

end.
