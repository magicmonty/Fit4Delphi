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
unit Browser;

interface

uses
  Classes, SysUtils, Fixture, MusicLibrary;

type
  {$METHODINFO ON}
  TBrowser = class (TFixture)
  protected
    FSongIndex: Integer;
    function GetTotalSongs: Variant;
    function GetTitle : Variant;
    function GetSongs : Variant;
    function GetAlbum : Variant;
    function GetArtist : Variant;
    function GetSelectedSongs : Variant;
    function GetStatus : Variant;
    function GetTrack : Variant;
    function GetYear: Variant;
    function GetTime : Variant;
    function GetRemaining : Variant;
    function GetPlaying : Variant;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    // used with enter
    procedure LoadLibrary(FileName:String);
    property Title : Variant read GetTitle;
    property Songs : Variant read GetSongs;
    property Album : Variant read GetAlbum;
    property Artist : Variant read GetArtist;
    procedure Select(Value:String);
    property SelectedSongs : Variant read GetSelectedSongs;
    property Status : Variant read GetStatus;
    property Track : Variant read GetTrack;
    property Year: Variant read GetYear;
    property Time : Variant read GetTime;
    property Remaining : Variant read GetRemaining;
    property Playing : Variant read GetPlaying;
    property TotalSongs: Variant read GetTotalSongs;
    // used with check
    // used with select
    procedure Pause;
    procedure Play;
    procedure SameAlbum;
    procedure SameArtist;
    procedure ShowAll;
  end;

implementation

uses Music, MusicPlayer;

{ TBrowser }

{
*********************************** TBrowser ***********************************
}
constructor TBrowser.Create;
begin
  inherited;
//  MusicLibrary := TMusicLibrary.Create;
end;

destructor TBrowser.Destroy;
begin
//  MusicLibrary.Free;
  inherited;
end;

function TBrowser.GetAlbum: Variant;
begin
  result := MusicLibrary.SelectedSong.album;
end;

function TBrowser.GetArtist: Variant;
begin
  result := MusicLibrary.SelectedSong.artist;
end;


function TBrowser.GetTitle: Variant;
begin
  result := MusicLibrary.SelectedSong.title;
end;

function TBrowser.GetTime: Variant;
begin
  result :=   MusicLibrary.SelectedSong.Time;
end;

procedure TBrowser.LoadLibrary(FileName : String);
begin
  if FileName = 'Source/eg/music/Music.txt' then
    FileName := '\develop\fit\Music.txt';
  MusicLibrary.LoadLibrary(FileName);
end;

procedure TBrowser.Select(Value:String);
begin
  MusicLibrary.select(StrToInt(Value));
end;

function TBrowser.GetTotalSongs: Variant;
begin
  result := MusicLibrary.Count;
end;

function TBrowser.GetYear: Variant;
begin
  result := MusicLibrary.SelectedSong.year;
end;

function TBrowser.GetTrack: Variant;
begin
  result := MusicLibrary.SelectedSong.track;
end;

procedure TBrowser.Play;
begin
(*
    public void play() {
        MusicPlayer.play(MusicLibrary.looking);
    }
*)
  MusicPlayer.Play(MusicLibrary.looking);
end;

function TBrowser.GetStatus: Variant;
begin
  result := Music.status;
end;

procedure TBrowser.Pause;
begin
  MusicPlayer.pause;
end;

function TBrowser.GetPlaying: Variant;
begin
  result := MusicPlayer.playing.title;
end;

function TBrowser.GetRemaining: Variant;
begin
  result := FloatToStr(MusicPlayer.minutesRemaining);
end;

procedure TBrowser.SameAlbum;
begin
(*
    public void sameAlbum() {
        MusicLibrary.findAlbum(MusicLibrary.looking.album);
    }
*)
  MusicLibrary.findAlbum(MusicLibrary.looking.album);
end;

function TBrowser.GetSelectedSongs: Variant;
begin
  result := MusicLibrary.displayCount;
end;

procedure TBrowser.ShowAll;
begin
  MusicLibrary.FindAll;
end;

function TBrowser.GetSongs: Variant;
begin

end;

procedure TBrowser.SameArtist;
begin
  MusicLibrary.findArtist(MusicLibrary.looking.artist);
end;

initialization
  RegisterClass(TBrowser);

finalization
  UnRegisterClass(TBrowser);

end.
