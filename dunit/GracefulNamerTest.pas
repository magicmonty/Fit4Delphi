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
unit GracefulNamerTest;

interface

uses
  StrUtils,
  SysUtils,
  TestFramework;

type
  TGracefulNamerTest = class(TTestCase)
  published
    procedure testIsGracefulName();
    procedure testUnGracefulName();
    procedure testEmptyString();
  end;

implementation

uses
  GracefulNamer;

{ TGracefulNamerTest }

procedure TGracefulNamerTest.testIsGracefulName();
begin
  CheckTrue(TGracefulNamer.isGracefulName('My Nice Fixture'));
  CheckTrue(TGracefulNamer.isGracefulName('My_Nice Fixture'));
  CheckTrue(TGracefulNamer.isGracefulName('My-Nice-Fixture'));
  CheckTrue(TGracefulNamer.isGracefulName('My!Really#Crazy--Name^'));
  CheckTrue(TGracefulNamer.isGracefulName('EndsWithADot.'));
  CheckFalse(TGracefulNamer.isGracefulName('MyNiceFixture'));
  CheckFalse(TGracefulNamer.isGracefulName('my.package.Fixture'));
end;

procedure TGracefulNamerTest.testUnGracefulName();
begin
  CheckEquals('BadCompany', TGracefulNamer.disgrace('Bad Company'));
  CheckEquals('BadCompany', TGracefulNamer.disgrace('bad company'));
  CheckEquals('BadCompany', TGracefulNamer.disgrace('Bad-Company'));
  CheckEquals('BadCompany', TGracefulNamer.disgrace('Bad Company.'));
  CheckEquals('BadCompany', TGracefulNamer.disgrace('(Bad Company)'));
  CheckEquals('BadCompany', TGracefulNamer.disgrace('BadCompany'));
  CheckEquals('Bad123Company', TGracefulNamer.disgrace('bad 123 company'));
  CheckEquals('Bad123Company', TGracefulNamer.disgrace('bad 123company'));
  CheckEquals('Bad123Company', TGracefulNamer.disgrace('   bad  '#9'123  company   '));
  CheckEquals('Bad123Company', TGracefulNamer.disgrace('Bad123Company'));
  CheckEquals('MyNamespaceBad123Company', TGracefulNamer.disgrace('My.Namespace.Bad123Company'));
end;

procedure TGracefulNamerTest.testEmptyString();
begin
  CheckEquals('', TGracefulNamer.disgrace(''));
end;

initialization
  registerTest(TGracefulNamerTest.Suite);

end.

