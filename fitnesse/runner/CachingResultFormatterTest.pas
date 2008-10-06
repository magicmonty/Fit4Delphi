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
unit CachingResultFormatterTest;

interface

uses
  StrUtils, SysUtils, StringTokenizer;

type
  TCachingResultFormatterTest=class
  private
    procedure testAddResult();
    procedure testIsComposit();
  public;
    constructor Create;
    destructor Destroy; override;
  end;

function substring(str : String; offset : integer): String;
function substring2(str : String; offset : integer; count : integer): String;
function startsWith(str : String; prefix : String): boolean; 
function endsWith(str : String; suffix : String): boolean; 

implementation

function substring(str : String; offset : integer): String;
begin
  result := RightStr(str, Length(str) - offset);
end;

function substring2(str : String; offset : integer; count : integer): String;
begin
  result := MidStr(str, offset+1, count - offset);
end;

function startsWith(str : String; prefix : String): boolean;
begin
  result := (Pos(prefix, str) = 1);
end;

function endsWith(str : String; suffix : String): boolean;
begin
  result := (RightStr(str, Length(suffix)) = suffix);
end;

{ TCachingResultFormatterTest }

constructor TCachingResultFormatterTest.Create();
begin
  inherited Create;
end;

destructor TCachingResultFormatterTest.Destroy();
begin
  inherited Destroy;
end;

procedure TCachingResultFormatterTest.testAddResult();
var
  result : PageResult;
  formatter : CachingResultFormatter;
  content : String;
begin
  ~~~~~5
  formatter:=######7;
  ~~~~~5
  ~~~~~5
  result:=######7;
  formatter.acceptResult(result);
  ~~~~~5
  formatter.acceptFinalCount(######7);
  ~~~~~5
  content:=######7.read(formatter.getByteCount());
  assertSubString('0000000060',content);
  assertSubString(result.toString(),content);
  assertSubString('0000000001',content);
  assertSubString('0000000002',content);
  assertSubString('0000000003',content);
  assertSubString('0000000004',content);
end;

procedure TCachingResultFormatterTest.testIsComposit();
var
  result : PageResult;
  counts : Counts;
  formatter : CachingResultFormatter;
  mockFormatter : MockResultFormatter;
begin
  ~~~~~5
  formatter:=######7;
  ~~~~~5
  mockFormatter:=######7;
  formatter.addHandler(mockFormatter);
  ~~~~~5
  ~~~~~5
  result:=######7;
  formatter.acceptResult(result);
  ~~~~~5
  counts:=######7;
  formatter.acceptFinalCount(counts);
  assertEquals(1,mockFormatter.results.size());
  assertEquals(result.toString(),mockFormatter.results.get(0).toString());
  assertEquals(counts,mockFormatter.finalCounts);
end;


end.
