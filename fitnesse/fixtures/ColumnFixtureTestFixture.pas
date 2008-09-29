// Copyright (C) 2003,2004,2005 by Object Mentor, Inc. All rights reserved.
// Released under the terms of the GNU General Public License version 2 or later.
unit ColumnFixtureTestFixture;

interface

uses
  ColumnFixture;

type
{$METHODINFO ON}
  TColumnFixtureTestFixture = class(TColumnFixture)
  private
    FInput : integer;
  published
    property input : Integer read FInput write FInput;
    function output() : integer;
    function exception() : boolean;
  end;
{$METHODINFO OFF}

implementation

uses
  SysUtils,
  classes;

{ TColumnFixtureTestFixture }

function TColumnFixtureTestFixture.output() : integer;
begin
  result := input;
end;

function TColumnFixtureTestFixture.exception() : boolean;
begin
  raise SysUtils.Exception.Create('I thowed up');
end;

initialization
  RegisterClass(TColumnFixtureTestFixture);

finalization
  UnRegisterClass(TColumnFixtureTestFixture);

end.

