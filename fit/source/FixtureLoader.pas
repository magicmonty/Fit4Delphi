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
// Modified or written by Object Mentor, Inc. for inclusion with FitNesse.
// Copyright (c) 2002 Cunningham & Cunningham, Inc.
// Released under the terms of the GNU General Public License version 2 or later.
// Copyright (C) 2003,2004 by Object Mentor, Inc. All rights reserved.
// Released under the terms of the GNU General Public License version 2 or
// later.
unit FixtureLoader;

interface

uses
  StrUtils,
  SysUtils,
  Fixture,
  FixtureName,
  classes;

type
  TFixtureLoader = class
  private
    fixturePathElements : TStringList;
    procedure addPackageToFixturePath(fixture : TFixture);
    function instantiateFixture(fixtureName : string) : TFixture;
    function loadFixtureClass(fixtureName : string) : TClass;
    function instantiateFirstValidFixtureClass(fixtureName : TFixtureName) : TFixture;
  public
    class function instance() : TFixtureLoader;
    function disgraceThenLoad(tableName : string) : TFixture;
    procedure addPackageToPath(name : string);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  NoSuchFixtureException,
  CouldNotLoadComponentFitFailureException;

var
  gInstance : TFixtureLoader;

  { TFixtureLoader }

constructor TFixtureLoader.Create();
begin
  inherited Create;
  fixturePathElements := TStringList.Create;
  fixturePathElements.Add('fit');
end;

destructor TFixtureLoader.Destroy();
begin
  fixturePathElements.Free;
  inherited Destroy;
end;

class function TFixtureLoader.instance() : TFixtureLoader;
begin
  if (gInstance = nil) then
  begin
    gInstance := TFixtureLoader.Create();
  end;
  result := gInstance;
end;

//TODO

function TFixtureLoader.disgraceThenLoad(tableName : string) : TFixture;
var
  fixtureName : TFixtureName;
begin
  fixtureName := TFixtureName.Create(tableName);
  Result := instantiateFirstValidFixtureClass(fixtureName);
  addPackageToFixturePath(Result);
end;

//TODO

procedure TFixtureLoader.addPackageToFixturePath(fixture : TFixture);
//var
//  fixturePackage : Package;
begin
  //  fixturePackage := fixture.getClass().getPackage();

  //  if (fixturePackage <> nil) then
  //  begin
  //    addPackageToPath(fixturePackage.getName());
  //  end;
end;

procedure TFixtureLoader.addPackageToPath(name : string);
begin
  fixturePathElements.add(name);
end;

function TFixtureLoader.instantiateFixture(fixtureName : string) : TFixture;
var
  //  fixtureClass : TFixtureClass;
  classForFixture : TClass;
begin
  classForFixture := loadFixtureClass(fixtureName);
  // TODO  fixtureClass = new TFixtureClass(classForFixture);
  Result := TFixtureClass(classForFixture).Create;
end;

function TFixtureLoader.loadFixtureClass(fixtureName : string) : TClass;
var
  p : Integer;
begin
  try
    // TODO
    p := Pos('.', fixtureName);
    while p <> 0 do
    begin
      fixtureName := Copy(fixtureName, p + 1, MaxInt);
      p := Pos('.', fixtureName);
    end;
    result := FindClass(fixtureName);
  except
    on deadEnd : EClassNotFound do
    begin
      if (deadEnd.Message = Format('Class %s not found', [fixtureName])) then
      begin
        raise TNoSuchFixtureException.Create(fixtureName);
      end
      else
      begin
        raise TCouldNotLoadComponentFitFailureException.Create(
          deadEnd.Message, fixtureName);
      end;
    end;
  end;
end;

function TFixtureLoader.instantiateFirstValidFixtureClass(fixtureName : TFixtureName) : TFixture;
var
  i : Integer;
  each : string;
  list : TStringList;
begin
  list := fixtureName.getPotentialFixtureClassNames(fixturePathElements);
  for i := 0 to list.Count - 1 do
  begin
    each := list[i];
    try
      Result := instantiateFixture(each);
      exit;
    except
      on ignoreAndTryTheNextCandidate : TNoSuchFixtureException do
        ;
    end;
  end;
  raise TNoSuchFixtureException.Create(fixtureName.toString());
end;

end.

