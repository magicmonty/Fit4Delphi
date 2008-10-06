// Fit4Delphi Copyright (C) 2008. Sabre Inc.
//
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
unit StandardResultHandler;

interface

uses
  StrUtils,
  SysUtils,
  StringTokenizer,
  PrintStream,
  PageResult,
  Counts,
  InputStream,
  ResultHandler;

type
  //TODO MDM Rename to VerboseResultHandler
  TStandardResultHandler = class(TInterfacedObject, TResultHandler)
  private
    output : TPrintStream;
    pageCounts : TCounts;
    function pageDescription(Aresult : TPageResult) : string;
  public
    constructor Create(output : TPrintStream);
    destructor Destroy; override;
    procedure acceptFinalCount(count : TCounts);
    procedure acceptResult(result : TPageResult);
    function getByteCount() : Integer;
    function getResultStream() : TInputStream;
  end;

implementation

{ TStandardResultHandler }

constructor TStandardResultHandler.Create(output : TPrintStream);
begin
  inherited Create;
  pageCounts := TCounts.Create;
  self.output := output;
end;

destructor TStandardResultHandler.Destroy();
begin
  inherited Destroy;
end;

procedure TStandardResultHandler.acceptResult(result : TPageResult);
var
  i : integer;
  counts : TCounts;
begin
  counts := result.counts();
  pageCounts.tallyPageCounts(counts);
  i := 0;
  while (i < counts.right) do
  begin
    output.print('.');
    inc(i);
  end;

  if (counts.wrong > 0) or (counts.exceptions > 0) then
  begin
    output.println();

    if (counts.wrong > 0) then
    begin
      output.println(pageDescription(result) + ' has failures');
    end;

    if (counts.exceptions > 0) then
    begin
      output.println(pageDescription(result) + ' has errors');
    end;
  end;
end;

function TStandardResultHandler.pageDescription(Aresult : TPageResult) : string;
var
  description : string;
begin
  description := Aresult.title();

  if ('' = description) then
  begin
    description := 'The test';
  end;
  result := description;
end;

procedure TStandardResultHandler.acceptFinalCount(count : TCounts);
begin
  output.println();
  output.println('Test Pages: ' + pageCounts.toString);
  output.println('Assertions: ' + count.toString);
end;

function TStandardResultHandler.getByteCount() : Integer;
begin
  result := 0;
end;

function TStandardResultHandler.getResultStream() : TInputStream;
begin
  result := nil;
end;

end.

