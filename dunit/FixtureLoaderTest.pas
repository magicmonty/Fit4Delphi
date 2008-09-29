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
unit FixtureLoaderTest;

interface

uses
  FixtureLoader, TestFrameWork;

type
  TFixtureLoaderTest=class(TTestCase)
  private
    fixtureLoader : TFixtureLoader;
  protected
    procedure SetUp(); override;
    procedure TearDown(); override;
  published
    procedure testLoadFixturesFromPreviouslyRememberedPackages();
    procedure testLoadFixturesWithGracefulName();
    procedure testLoadFixturesWithFixtureImplied();
    procedure testLoadFixturesWithFullPackageName;
  end;

implementation

uses
  Fixture;
  
{ TFixtureLoaderTest }

procedure TFixtureLoaderTest.setUp();
begin
  fixtureLoader := TFixtureLoader.Create();
end;

procedure TFixtureLoaderTest.TearDown;
begin
  fixtureLoader.Free;
end;

procedure TFixtureLoaderTest.testLoadFixturesFromPreviouslyRememberedPackages();
var
  f1 : TFixture;
  f2 : TFixture;
begin
  f1:=fixtureLoader.disgraceThenLoad('fit.FixtureOne');
  CheckEquals({'fit.'}'TFixtureOne',f1.ClassName); //TODO
  f2:=fixtureLoader.disgraceThenLoad('FixtureTwo');
  CheckEquals({'fit.'}'FixtureTwo',f2.ClassName); //TODO
end;

procedure TFixtureLoaderTest.testLoadFixturesWithGracefulName();
var
  f2 : TFixture;
begin
  fixtureLoader.disgraceThenLoad('fit.FixtureOne');
  f2:=fixtureLoader.disgraceThenLoad('fixture two');
  CheckEquals({'fit.'}'FixtureTwo',f2.ClassName); //TODO
end;

procedure TFixtureLoaderTest.testLoadFixturesWithFixtureImplied();
var
  fixture : TFixture;
begin
  fixtureLoader.disgraceThenLoad('fit.TheThirdFixture');
  fixture:=fixtureLoader.disgraceThenLoad('the third');
  CheckEquals({'fit.'}'TheThirdFixture',fixture.ClassName); //TODO
end;

procedure TFixtureLoaderTest.testLoadFixturesWithFullPackageName();
var
  f2 : TFixture;
begin
  fixtureLoader.disgraceThenLoad('fitnesse.fixtures.ColumnFixtureTestFixture');
  f2:=fixtureLoader.disgraceThenLoad('t column fixture test fixture'); //TODO
  CheckEquals({'fit.'}'TColumnFixtureTestFixture',f2.ClassName); //TODO
end;

initialization
  TestFramework.RegisterTest(TFixtureLoaderTest.Suite);

end.

