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
unit CountsTest;

interface

uses
  StrUtils, SysUtils, TestFramework;

type
  TCountsTest=class(TTestCase)
  published
    procedure testEquality();
  end;

implementation

uses
  Counts;

{ TCountsTest }

procedure TCountsTest.testEquality();
begin
		CheckFalse(TCounts.Create().equals(nil));
		CheckFalse(TCounts.Create().equals(TObject.Create){''});

//TODO CheckEquals(TCounts.Create(), TCounts.Create());
		CheckEquals(TCounts.Create().toString, TCounts.Create().toString);
		CheckEquals(TCounts.Create(0, 0, 0, 0).toString, TCounts.Create(0, 0, 0, 0).toString);
		CheckEquals(TCounts.Create(1, 1, 1, 1).toString, TCounts.Create(1, 1, 1, 1).toString);
		CheckEquals(TCounts.Create(5, 0, 1, 3).toString, TCounts.Create(5, 0, 1, 3).toString);

		CheckFalse(TCounts.Create(1, 0, 0, 0).equals(TCounts.Create(0, 0, 0, 0)));
end;

initialization
  TestFramework.RegisterTest(TCountsTest.Suite);

end.
