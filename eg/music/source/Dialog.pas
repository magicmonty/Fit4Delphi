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
unit Dialog;

interface

uses
  Fixture;

type
  {$METHODINFO ON}
  TDialog = class(TFixture)
  protected
    Fmsg : String;
    caller : TFixture;
    function GetMessage: Variant;
  public
    constructor Create (msg: String; caller : TFixture); reintroduce; overload;
  published
    property Message: Variant read GetMessage;
    procedure OK;
  end;

implementation

uses
  ActionFixture, MusicPlayer;

{ TDialog }

constructor TDialog.Create(msg: String; caller: TFixture);
begin
(*
    Dialog (String message, Fixture caller) {
        this.message = message;
        this.caller = caller;
    }
*)
  self.Create;
  self.FMsg := msg;
  self.caller := caller;
end;

procedure TDialog.OK;
begin
(*
    public void ok () {
        if (message.equals("load jamed"))   {MusicPlayer.stop();}
        ActionFixture.actor = caller;
    }
*)
  if FMsg = 'load jamed' then
    MusicPlayer.stop;
  ActionFixture.actor := caller;
end;

function TDialog.GetMessage: Variant;
begin
  result := FMsg;
end;

end.
