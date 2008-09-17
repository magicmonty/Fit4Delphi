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
unit Parse;

interface

uses
  classes,
  sysUtils;

type
  TParse = class;

  TParseException = class(exception)
  private
    FErrorOffset : integer;
    function getErrorOffset : integer;
  public
    constructor Create(msg : string; offset : integer);
    property errorOffset : integer read getErrorOffset;
  end;

  TParse = class(TObject)
  private
    Fbody : string;
    Fleader : string;
    Fmore : TParse;
    Fparts : TParse;
    FTag : string;
    Ftheend : string;
    Ftrailer : string;
    class function replacement(const from : string) : string;
  public
    class function unescape(s : string) : string;
    class function unformat(s : string) : string;
    constructor Create(const text : string; tags : TStringList); overload;
    constructor Create(text : string; tags : TStringList;
      level, offset : integer); overload;
    constructor Create(text : string); overload;
    constructor Create(aTag, aBody : string; aParts, aMore : TParse); overload;
    procedure addToTag(aText : string);
    procedure addToBody(text : string);
    function at(i, j, k : integer) : TParse; overload;
    function at(i, j : integer) : TParse; overload;
    function at(i : integer) : TParse; overload;
    function leaf : TParse;
    function size : integer;
    function last : TParse;
    function text : string;
    procedure Print(theOut : TStringList);
    class function findMatchingEndTag(lc : string; matchFromHere : Integer;
      tag : string; offset : Integer) : Integer; static;

    property body : string read Fbody write Fbody;
    property leader : string read Fleader write Fleader;
    property more : TParse read Fmore write Fmore;
    property parts : TParse read Fparts write Fparts;
    property tag : string read FTag write FTag;
    property theend : string read Ftheend write Ftheend;
    property trailer : string read Ftrailer write Ftrailer;
  end;

function indexOf(const substr, theStr : string) : integer; overload;
function indexOf(const substr : string; startPos : integer; theStr : string) : integer; overload;
implementation

uses
  strUtils,
  idGlobal,
  FitParseException;

{ TParse }

function indexOf(const substr : string; startPos : integer; theStr : string) : integer;
begin
  result := indexOf(substr, copy(theStr, startPos, MAXINT));
  if (result <> 0) then
    result := result + startPos - 1;
end;

function indexOf(const substr, theStr : string) : integer;
begin
  result := pos(substr, theStr);
end;

function TParse.at(i, j : integer) : TParse;
begin
  result := at(i).parts.at(j);
end;

function TParse.at(i : integer) : TParse;
begin
  if (i = 0) or (more = nil) then
    result := self
  else
    result := more.at(i - 1);
end;

function TParse.at(i, j, k : integer) : TParse;
begin
  result := at(i, j).parts.at(k);
end;

function TParse.size : integer;
begin
  if (more = nil) then
    result := 1
  else
    result := more.size + 1;
end;

function TParse.leaf : TParse;
begin
  if (parts = nil) then
    result := self
  else
    result := parts.leaf();
end;

function TParse.last : TParse;
begin
  if (more = nil) then
    result := self
  else
    result := more.last;
end;

constructor TParse.Create(text : string; tags : TStringList;
  level, offset : integer);
var
  startMore : Integer;
  endEnd : Integer;
  startEnd : Integer;
  endTag : Integer;
  startTag : Integer;
  lc : string;
  index : Integer;
begin
  lc := LowerCase(text);
  startTag := indexOf('<' + tags[level], lc);
  endTag := indexOf('>', startTag, lc) + 1;
  //  startEnd := indexOf('</'+tags[level], endTag, lc);
  startEnd := findMatchingEndTag(lc, endTag, tags[level], offset);
  endEnd := indexOf('>', startEnd, lc) + 1;
  startMore := indexOf('<' + tags[level], endEnd, lc);
  if (startTag <= 0) or (endTag <= 0) or (startEnd <= 0) or (endEnd <= 0) then
    raise TParseException.Create('Can''t find tag: ' + tags[level], offset);

  leader := copy(text, 1, startTag - 1);
  tag := copy(text, startTag, endTag - startTag);
  body := copy(text, endTag, startEnd - endTag);
  theend := copy(text, startEnd, endEnd - startEnd);
  trailer := copy(text, endEnd, MAXINT);

  if (level + 1 < tags.count) then
  begin
    parts := TParse.Create(body, tags, level + 1, offset + endTag - 1);
    body := emptyStr;
  end
  else
  begin // Check for nested table
    index := indexOf('<' + tags[0], body);
    if (index >= 1) then
    begin
      parts := TParse.Create(body, tags, 0, offset + endTag - 1);
      body := '';
    end;
  end;

  if (startMore >= 1) then
  begin
    more := TParse.create(trailer, tags, level, offset + endEnd - 1);
    trailer := emptyStr;
  end;
end;

//	/* Added by Rick Mugridge, Feb 2005 */

class function TParse.findMatchingEndTag(lc : string; matchFromHere : Integer; tag : string; offset : Integer) :
  Integer;
var
  fromHere : Integer;
  count : Integer;
  startEnd : Integer;
  embeddedTag : Integer;
  embeddedTagEnd : Integer;
begin
  fromHere := matchFromHere;
  count := 1;
  startEnd := 0;
  while (count > 0) do
  begin
    embeddedTag := indexOf('<' + tag, fromHere, lc);
    embeddedTagEnd := indexOf('</' + tag, fromHere, lc);
    // Which one is closer?
    if (embeddedTag <= 0) and (embeddedTagEnd <= 0) then
      raise TFitParseException.Create('Can''t find tag: ' + tag, offset);
    if (embeddedTag <= 0) then
      embeddedTag := MAXINT;
    if (embeddedTagEnd <= 0) then
      embeddedTagEnd := MAXINT;
    if (embeddedTag < embeddedTagEnd) then
    begin
      Inc(count);
      startEnd := embeddedTag;
      fromHere := indexOf('>', embeddedTag, lc) + 1;
    end
    else
      if (embeddedTagEnd < embeddedTag) then
      begin
        Dec(count);
        startEnd := embeddedTagEnd;
        fromHere := indexOf('>', embeddedTagEnd, lc) + 1;
      end;
  end;
  Result := startEnd;
end;

constructor TParse.Create(const text : string; tags : TStringList);
begin
  Create(text, tags, 0, 1);
end;

constructor TParse.Create(text : string);
var
  tags : TstringList;
begin
  tags := TStringList.Create;
  try
    tags.Add('table');
    tags.Add('tr');
    tags.Add('td');
    create(text, tags, 0, 1);
  finally
    tags.Free;
  end;
end;

function TParse.text : string;
begin
  result := Trim(unescape(unformat(body)));
end;

procedure TParse.addToTag(aText : string);
var
  last : integer;
begin
  last := length(tag) - 1;
  tag := copy(tag, 1, last) + aText + '>';
end;

class function TParse.replacement(const from : string) : string;
begin
  if (from = 'lt') then
    result := '<'
  else
    if (from = 'gt') then
      result := '>'
    else
      if (from = 'amp') then
        result := '&'
      else
        if (from = 'nbsp') then
          result := ' '
        else
          result := emptyStr;
end;

class function TParse.unescape(s : string) : string;
var
  i, j : integer;
  Strfrom, Strto : string;
begin

  i := indexOf('&', s);
  while (i > 0) do
  begin
    j := indexOf(';', i + 1, s);
    if (j > 1) then
    begin
      strFrom := LowerCase(copy(s, i + 1, j - i - 1));
      strTo := replacement(strFrom);
      if (strTo <> emptyStr) then
        s := copy(s, 1, i - 1) + strTo + copy(s, j + 1, MAXINT);
    end;
    i := indexOf('&', i + 1, s);
  end;
  result := s;
end;

class function TParse.unformat(s : string) : string;
var
  i, j : integer;
begin
  i := indexOf('<', s);
  while (i > 0) do
    //         while ((i=s.indexOf('<',i))>=0) {
  begin
    j := indexOf('>', i + 1, s);
    if (j > 1) then
      s := copy(s, 1, i - 1) + copy(s, j + 1, MAXINT)
    else
      break;

    i := indexOf('<', s);
  end;

  result := s;

end;

procedure TParse.addToBody(text : string);
begin
  body := body + text;
end;

procedure TParse.Print(theOut : TStringList);
begin
  theOut.add(leader);
  theOut.add(tag);
  if (parts <> nil) then
    parts.print(theOut)
  else
    theOut.add(body);

  theOut.add(theend);

  if (more <> nil) then
    more.print(theOut)
  else
    theOut.add(trailer);
end;

constructor TParse.Create(aTag, aBody : string; aParts, aMore : TParse);
begin
  self.leader := lf;
  self.tag := '<' + atag + '>';
  self.body := abody;
  self.theend := '</' + atag + '>';
  self.trailer := '';
  self.parts := aparts;
  self.more := amore;

end;

{ TParseException }

constructor TParseException.Create(msg : string; offset : integer);
begin
  inherited Create(msg);
  FErrorOffSet := offset;

end;

function TParseException.getErrorOffset : integer;
begin
  result := FErrorOffset;
end;

end.

