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
{$H+}
unit TestRunnerFixtureListener;

interface

uses
  FixtureListener,
  Counts,
  PageResult,
  Parse {, TestRunner};

type
  TTestRunnerFixtureListener = class(TInterfacedObject, IFixtureListener)
  private
    counts : TCounts;
    atStartOfResult : boolean;
    runner : TObject {TTestRunner};
    currentPageResult : TPageResult;
  public
    constructor Create(runner : TObject {TTestRunner});
    destructor Destroy; override;
    procedure tableFinished(table : TParse);
    procedure tablesFinished(count : TCounts);
  end;

implementation

uses
  SysUtils,
  FitServer,
  TestRunner;

{ TTestRunnerFixtureListener }

constructor TTestRunnerFixtureListener.Create(runner : TObject {TTestRunner});
begin
  inherited Create;
  self.runner := runner;
  counts := TCounts.Create();
  atStartOfResult := true;
end;

destructor TTestRunnerFixtureListener.Destroy();
begin
  counts.Free;
  inherited Destroy;
end;

procedure TTestRunnerFixtureListener.tableFinished(table : TParse);
var
  pageTitle : string;
  data : string;
  indexOfFirstLineBreak : integer;
begin
  try
    data := TFitServer.readTable(table); //TODO "UTF-8";

    if (atStartOfResult) then
    begin
      indexOfFirstLineBreak := indexOf(#13#10, data);
      pageTitle := substring2(data, 0, indexOfFirstLineBreak);
      data := substring(data, indexOfFirstLineBreak + 1);
      currentPageResult := TPageResult.Create(pageTitle);
      atStartOfResult := false;
    end;
    currentPageResult.append(data);
  except
    on e : Exception do
    begin
      WriteLn(e.Message);
      //TODO e.printStackTrace();
    end;
  end;
end;

procedure TTestRunnerFixtureListener.tablesFinished(count : TCounts);
begin
  try
    currentPageResult.setCounts(count);
    (runner as TTestRunner).acceptResults(currentPageResult);
    atStartOfResult := true;
    counts.tally(count);
  except
    on e : Exception do
    begin
      WriteLn(e.Message);
      //TODO e.printStackTrace();
    end;
  end;
end;

end.

