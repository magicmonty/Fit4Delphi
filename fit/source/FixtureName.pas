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
{$H+}
unit FixtureName;

interface

uses
  Classes,
  StrUtils,
  SysUtils;

type
  TFixtureName = class
  private
    nameAsString : string;
    procedure addBlahAndBlahFixture(qualifiedBy : string; candidateClassNames : TStringList);
  public
    constructor Create(tableName : string);
    function toString() : string;
    function getPotentialFixtureClassNames(fixturePathElements : TStringList) : TStringList;
    function fixtureNameHasPackageSpecified(fixtureName : string) : boolean;
    function isFullyQualified() : boolean;
  end;

implementation

uses
  GracefulNamer;

{ TFixtureName }

constructor TFixtureName.Create(tableName : string);
begin
  inherited Create;
  if (TGracefulNamer.isGracefulName(tableName)) then
  begin
    self.nameAsString := TGracefulNamer.disgrace(tableName);
  end
  else
  begin
    self.nameAsString := tableName;
  end;
end;

function TFixtureName.toString() : string;
begin
  result := nameAsString;
end;

function TFixtureName.isFullyQualified() : boolean;
begin
  result := Pos('.', nameAsString) <> 0;
end;

function TFixtureName.fixtureNameHasPackageSpecified(fixtureName : string) : boolean;
begin
  result := TFixtureName.Create(fixtureName).isFullyQualified();
end;

function TFixtureName.getPotentialFixtureClassNames(fixturePathElements : TStringList) : TStringList;
var
  packageName : string;
  i : Integer;
  candidateClassNames : TStringList;
begin
  candidateClassNames := TStringList.Create;

  if (not isFullyQualified()) then
  begin
    for i := 0 to fixturePathElements.Count - 1 do
    begin
      packageName := fixturePathElements[i];
      addBlahAndBlahFixture(packageName + '.', candidateClassNames);
    end;
  end;
  addBlahAndBlahFixture('', candidateClassNames);
  result := candidateClassNames;
end;

procedure TFixtureName.addBlahAndBlahFixture(qualifiedBy : string; candidateClassNames : TStringList);
begin
  candidateClassNames.add(qualifiedBy + nameAsString);
  candidateClassNames.add(qualifiedBy + nameAsString + 'Fixture');

  candidateClassNames.add(qualifiedBy + StringReplace(nameAsString, '.', '.T', [rfReplaceAll]));
  candidateClassNames.add(qualifiedBy + StringReplace(nameAsString, '.', '.T', [rfReplaceAll]) + 'Fixture');
end;

end.

