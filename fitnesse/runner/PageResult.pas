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
unit PageResult;

interface

uses
  Classes,
  Counts,
  StringBuffer;

type
  TPageResult = class
  private
    Fcounts : TCounts;
    FcontentBuffer : TStringBuffer;
    Ftitle : string;
    class function parseCounts(countString : string) : TCounts;
  public
    constructor Create(title : string); overload;
    constructor Create(title : string; counts : TCounts; startingContent : string); overload;
    destructor Destroy; override;
    function content() : string;
    procedure append(data : string);
    function title() : string;
    function counts() : TCounts;
    procedure setCounts(counts : TCounts);
    function toString() : string;
    class function parse(resultString : string) : TPageResult;
  end;

implementation

uses
  Parse,
  StrUtils,
  Matcher,
  SysUtils;

const
  //  countsPattern : string = '(\\d+)[^,]*, (\\d+)[^,]*, (\\d+)[^,]*, (\\d+)[^,]*';
  countsPattern : string = '(\d+)[^,]*, (\d+)[^,]*, (\d+)[^,]*, (\d+)[^,]*';

  { TPageResult }

constructor TPageResult.Create(title : string);
begin
  inherited Create;
  Ftitle := title;
  FcontentBuffer := TStringBuffer.Create;
end;

constructor TPageResult.Create(title : string; counts : TCounts; startingContent : string);
begin
  Create(title);
  Fcounts := counts;
  append(startingContent);
end;

destructor TPageResult.Destroy();
begin
  FcontentBuffer.Free;
  inherited Destroy;
end;

function TPageResult.content() : string;
begin
  result := FcontentBuffer.toString();
end;

procedure TPageResult.append(data : string);
begin
  FcontentBuffer.append(data);
end;

function TPageResult.title() : string;
begin
  result := Ftitle;
end;

function TPageResult.counts() : TCounts;
begin
  result := Fcounts;
end;

procedure TPageResult.setCounts(counts : TCounts);
begin
  Fcounts := counts;
end;

function TPageResult.toString() : string;
var
  buffer : TStringBuffer;
begin
  buffer := TStringBuffer.Create;
  buffer.append(#13#10); //TODO Added newline
  buffer.append(counts.toString()).append(#13#10); //TODO Swapped title and counts
  buffer.append(title).append(#13#10);
  buffer.append(FcontentBuffer);
  Result := buffer.toString();
  buffer.Free;
end;

class function TPageResult.parse(resultString : string) : TPageResult;
var
  counts : TCounts;
  content : string;
  secondEndlIndex : integer;
  firstEndlIndex : integer;
  title : string;
begin
  firstEndlIndex := indexOf(#13#10, resultString);
  secondEndlIndex := indexOf(#13#10, firstEndlIndex + 1, resultString);
  title := substring2(resultString, 0, firstEndlIndex - 1);
  counts := parseCounts(substring2(resultString, firstEndlIndex + 1, secondEndlIndex - 1));
  content := substring(resultString, secondEndlIndex + 1);
  Result := TPageResult.Create(title, counts, content);
end;

class function TPageResult.parseCounts(countString : string) : TCounts;
var
  wrong : integer;
  exceptions : integer;
  right : integer;
  matcher : TRegExpr;
  ignores : integer;
begin
  matcher := TRegExpr.Create;
  matcher.Expression := countsPattern;

  if (matcher.Exec(countString)) then
  begin
    right := StrToInt(matcher.Match[1]);
    wrong := StrToInt(matcher.Match[2]);
    ignores := StrToInt(matcher.Match[3]);
    exceptions := StrToInt(matcher.Match[4]);
    Result := TCounts.Create(right, wrong, ignores, exceptions);
  end
  else
  begin
    result := nil;
  end;
  matcher.Free;
end;

end.

