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
unit MusicPlayer;

interface

uses
  Music;

type
  TMusicPlayer = class
  end;

var
  playing : TMusic;
  paused : integer;


function MinutesRemaining : double;
function SecondsRemaining : double;
procedure Pause;
procedure Play(m : TMusic);
procedure PlayComplete;
procedure PlayStarted;
procedure Stop;

implementation

uses
  MusicLibrary, Simulator;

procedure Stop;
begin
(*
    static void stop() {
        Simulator.nextPlayStarted = 0;
        Simulator.nextPlayComplete = 0;
        playComplete();
    }
*)
  Simulator.nextPlayStarted := 0;
  Simulator.nextPlayComplete := 0;
  playComplete();
end;

procedure Pause;
begin
(*
    static void pause() {
        Music.status = "pause";
        if (playing != null && paused == 0) {
            paused = (Simulator.nextPlayComplete - Simulator.time) / 1000.0;
            Simulator.nextPlayComplete = 0;
        }
    }
*)
  Music.status := 'pause';
  if (playing <> nil) and (paused = 0) then begin
    paused := Trunc((Simulator.nextPlayComplete - Simulator.time) * (60 * 60 * 24));
    Simulator.nextPlayComplete := 0;
  end;
end;

procedure play(m : TMusic);
var
  seconds : double;
begin
(*
    static void play(Music m) {
        if (paused == 0) {
            Music.status = "loading";
            double seconds = m == playing ? 0.3 : 2.5 ;
            Simulator.nextPlayStarted = Simulator.schedule(seconds);
        } else {
            Music.status = "playing";
            Simulator.nextPlayComplete = Simulator.schedule(paused);
            paused = 0;
        }
    }
*)
  if (paused = 0) then begin
    Music.status := 'loading';
    if m = playing then
      seconds := 0.3
    else
      seconds := 2.5;
    Simulator.nextPlayStarted := Simulator.schedule(seconds);
  end
  else begin
    Music.status := 'playing';
    Simulator.nextPlayComplete := Simulator.schedule(paused);
    paused := 0;
  end;
end;

procedure PlayStarted;
begin
(*
    static void playStarted() {
        Music.status = "playing";
        playing = MusicLibrary.looking;
        Simulator.nextPlayComplete = Simulator.schedule(playing.seconds);
    }
*)
  Music.status := 'playing';
  playing := MusicLibrary.looking;
  Simulator.nextPlayComplete := Simulator.schedule(playing.seconds);
end;

procedure PlayComplete;
begin
(*
    static void playComplete() {
        Music.status = "ready";
        playing = null;
    }
*)
  Music.status := 'ready';
  playing := nil;
end;

function SecondsRemaining : double;
(*
    static double secondsRemaining() {
        if (paused != 0) {
            return paused;
        } else if (playing != null) {
            return (Simulator.nextPlayComplete - Simulator.time) / 1000.0;
        } else {
            return 0;
        }
    }
*)
begin
  if (paused <> 0) then
    result := paused
  else if (playing <> nil) then
    result := (Simulator.nextPlayComplete - Simulator.time) * (60*60*24)
  else
    result := 0;
end;

function MinutesRemaining : double;
begin
  result := secondsRemaining / 60;
end;

initialization
  playing := nil;
  paused := 0;

end.
