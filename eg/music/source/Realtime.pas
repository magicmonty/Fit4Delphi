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
unit Realtime;

interface

uses
  Classes, SysUtils, Parse, TimedActionFixture, ActionFixture, Fixture, Simulator;

type
  {$METHODINFO ON}
  TRealtime = class(TTimedActionFixture)
  private
    procedure systemMethod(prefix: string; cell: TParse);
  protected
    system : TSimulator;
  public
    constructor Create; override; 
    function time : TDateTime; override;
  published
    procedure Await;
    procedure Fail;
    procedure Pause;
    procedure Play;
    function Status : Variant;
    procedure Press; override;
  end;

implementation

uses
  Music;

{ TRealtime }

procedure TRealtime.Play;
begin
  //
end;

constructor TRealtime.Create;
begin
  inherited;
  system := TSimulator.Create;
end;

procedure TRealtime.Press;
begin
  system.delay(1.2);
  inherited;
end;

function TRealtime.Status: Variant;
begin
  result := Music.status;
end;

procedure TRealtime.Pause;
var
  seconds : double;
  iCode : integer;
begin
(*
    public void pause () {
        double seconds = Double.parseDouble(cells.more.text());
        system.delay(seconds);
    }
*)
  Val(cells.more.text, seconds, iCode);
  system.delay(seconds);
end;


function TRealtime.time: TDateTime;
begin
  result := Simulator.time;
end;

procedure TRealtime.Await;
begin
(*
    public void await () throws Exception {
        system("wait", cells.more);
    }
*)
  systemMethod('wait', cells.more);
end;

procedure TRealtime.systemMethod(prefix: string; cell: TParse);
begin
(*
    private void system(String prefix, Parse cell) throws Exception {
        String method = camel(prefix+" "+cell.text());
        Class[] empty = {};
        try {
            system.getClass().getMethod(method,empty).invoke(system,empty);
        } catch (Exception e) {
            exception (cell, e);
        }
    }
*)
  if (prefix = 'wait') then
    if (cell.text = 'play complete') then
      system.waitPlayComplete;
    if (cell.text = 'search complete') then
      system.waitSearchComplete;
  if (prefix = 'fail') and (cell.text = 'load jam') then
    system.failLoadJam;
end;

procedure TRealtime.Fail;
begin
(*
    public void fail () throws Exception {
        system("fail", cells.more);
    }
*)
  systemMethod('fail', cells.more);
end;

initialization
  RegisterClass(TRealtime);

finalization
  UnRegisterClass(TRealtime);
end.
