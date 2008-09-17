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
unit Simulator;

interface

uses
  SysUtils, ActionFixture;

type
  TSimulator = class
  public
    constructor Create;
    procedure Advance(future : TDateTime);
    procedure delay(seconds : double);
    function nextEvent(bound : TDateTime) : TDateTime;
    procedure perform;
    function sooner(soon, event : TDateTime) : TDateTime;
    procedure waitPlayComplete;
    procedure waitSearchComplete;
    procedure failLoadJam;
  end;

var
  time : TDateTime;
  nextSearchComplete : TDateTime = 0;
  nextPlayStarted : TDateTime  = 0;
  nextPlayComplete : TDateTime = 0;

function schedule(seconds : double) : TDateTime;

implementation

uses
  MusicLibrary, MusicPlayer, Dialog, Fixture;

function schedule(seconds : double) : TDateTime;
begin
(*
    static long schedule(double seconds){
        return time + (long)(1000 * seconds);
    }
*)
  result := time + (seconds/(60*60*24));
end;

{ TSimulator }

procedure TSimulator.Advance(future: TDateTime);
begin
(*
    void advance (long future) {
        while (time < future) {
            time = nextEvent(future);
            perform();
        }
    }
*)
  while time < future do begin
    time := nextEvent(future);
    perform();
  end;
end;

constructor TSimulator.Create;
begin
  time := Now();
end;

procedure TSimulator.delay(seconds: double);
begin
(*
    void delay (double seconds) {
        advance(schedule(seconds));
    }
*)
  advance(schedule(seconds));
end;

procedure TSimulator.failLoadJam;
begin
(*
    public void failLoadJam() {
        ActionFixture.actor = new Dialog("load jamed", ActionFixture.actor);
    }
*)
  ActionFixture.actor := TDialog.Create('load jamed', ActionFixture.actor);
end;

function TSimulator.nextEvent(bound: TDateTime): TDateTime;
begin
(*
    long nextEvent(long bound) {
        long result = bound;
        result = sooner(result, nextSearchComplete);
        result = sooner(result, nextPlayStarted);
        result = sooner(result, nextPlayComplete);
        return result;
    }
*)
  result := bound;
  result := sooner(result, nextSearchComplete);
  result := sooner(result, nextPlayStarted);
  result := sooner(result, nextPlayComplete);
end;

procedure TSimulator.perform;
begin
(*
    void perform() {
        if (time == nextSearchComplete)     {MusicLibrary.searchComplete();}
        if (time == nextPlayStarted)        {MusicPlayer.playStarted();}
        if (time == nextPlayComplete)       {MusicPlayer.playComplete();}
    }
*)
  if time = nextSearchComplete then
    MusicLibrary.searchComplete;
  if time = nextPlayStarted then
    MusicPlayer.playStarted;
  if time = nextPlayComplete then
    MusicPlayer.playComplete;
end;

function TSimulator.sooner(soon, event: TDateTime): TDateTime;
begin
(*
    long sooner (long soon, long event) {
        return event > time && event < soon ? event : soon;
    }
*)
  if (event > time) and (event < soon) then
    result := event
  else
    result := soon;
end;

procedure TSimulator.waitPlayComplete;
begin
(*
    public void waitPlayComplete() {
        advance(nextPlayComplete);
    }
*)
  advance(nextPlayComplete);
end;

procedure TSimulator.waitSearchComplete;
begin
(*
    public void waitSearchComplete() {
        advance(nextSearchComplete);
    }
*)
  advance(nextSearchComplete);
end;

initialization
  nextSearchComplete := 0;
  nextPlayStarted := 0;
  nextPlayComplete := 0;

end.
