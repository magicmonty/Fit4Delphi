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
// Copyright (C) 2003,2004,2005 by Object Mentor, Inc. All rights reserved.

// Released under the terms of the GNU General Public License version 2 or later.
unit PageResultTest;

interface

uses
  TestFramework;

type
  TPageResultTest = class(TTestCase)
  published
    procedure testToString();
    procedure testParse();
  end;

implementation

uses
  PageResult,
  Counts;

{ TPageResultTest }

procedure TPageResultTest.testToString();
var
  result : TPageResult;
begin
  result := TPageResult.Create('PageTitle', TCounts.Create(1, 2, 3, 4), 'content');
  CheckEquals('PageTitle'#13#10'1 right, 2 wrong, 3 ignored, 4 exceptions'#13#10'content', result.toString());
end;

procedure TPageResultTest.testParse();
var
  result : TPageResult;
  counts : TCounts;
  parsedResult : TPageResult;
begin
  counts := TCounts.Create(1, 2, 3, 4);
  result := TPageResult.Create('PageTitle', counts, 'content');
  parsedResult := TPageResult.parse(result.toString());
  CheckEquals('PageTitle', parsedResult.title());
  CheckEquals(counts.toString, parsedResult.counts().toString);
  CheckEquals('content', parsedResult.content());
end;

initialization

  TestFramework.RegisterTest(TPageResultTest.Suite);

end.

