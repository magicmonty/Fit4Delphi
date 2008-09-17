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
unit ParseTest;

interface

uses
  TestFrameWork,
  Parse,
  classes,
  sysUtils;

type
  TParseTest = class(TTestCase)
  published
    procedure testParsing;
    procedure testRecursing;
    procedure testIterating;
    procedure testIndexing;
    procedure testParseException;
    procedure testText;
    procedure testUnformat;
    procedure testUnescape;
    procedure testFindNestedEnd;
    procedure testNestedTables;
    procedure testNestedTables2;

    procedure testIndexOf;
    procedure testAddTag;
    procedure testAddToBody;
    procedure testParseWithTagBodyTableAndMore;
  end;

implementation

uses
  FitParseException;

{ TParseTest }

procedure TParseTest.testParsing;
var
  p : TParse;
  strList : TStringList;
begin
  strList := TStringList.Create;
  p := nil;
  try
    strList.Add('table');
    p := TParse.Create('leader<Table foo=2>body</table>trailer', strList {'table'});
    checkEquals('leader', p.leader);
    checkEquals('<Table foo=2>', p.tag);
    checkEquals('body', p.body);
    checkEquals('trailer', p.trailer);
  finally
    strList.Free;
    p.Free;
  end;

end;

procedure TParseTest.testRecursing;
var
  p : TParse;
begin
  p := TParse.Create('leader<table><TR><Td>body</tD></TR></table>trailer');
  checkEquals(emptyStr, p.body);
  checkEquals(emptyStr, p.parts.body);
  checkEquals('body', p.parts.parts.body);
end;

procedure TParseTest.testIterating;
var
  p : TParse;
begin
  p :=
    TParse.Create('leader<table><tr><td>one</td><td>two</td><td>three</td></tr><tr><td>four</td></tr></table>trailer');
  checkEquals('one', p.parts.parts.body);
  checkEquals('two', p.parts.parts.more.body);
  checkEquals('three', p.parts.parts.more.more.body);
  checkEquals('four', p.parts.more.parts.body);
end;

procedure TParseTest.testIndexing;
var
  p : TParse;
begin
  p :=
    TParse.Create('lleader<table><tr><td>one</td><td>two</td><td>three</td></tr><tr><td>four</td></tr></table>trailer');

  checkEquals('one', p.at(0, 0, 0).body);
  checkEquals('two', p.at(0, 0, 1).body);
  checkEquals('three', p.at(0, 0, 2).body);
  checkEquals('three', p.at(0, 0, 3).body);
  checkEquals('three', p.at(0, 0, 4).body);
  checkEquals('four', p.at(0, 1, 0).body);
  checkEquals('four', p.at(0, 1, 1).body);
  checkEquals('four', p.at(0, 2, 0).body);
  checkEquals(1, p.size());
  checkEquals(2, p.parts.size());
  checkEquals(3, p.parts.parts.size());
  checkEquals('one', p.leaf().body);
  checkEquals('four', p.parts.last().leaf().body);
end;

procedure TParseTest.testParseException;
begin
  try
    TParse.Create('leader<table><tr><th>one</th><th>two</th><th>three</th></tr><tr><td>four</td></tr></table>trailer');
  except
    on e : TFitParseException do
    begin
      checkEquals(18, e.ErrorOffset);
      checkEquals('Can''t find tag: td', e.Message);
      exit;
    end;
  end;
  check(false, 'expected exception not thrown');
end;

procedure TParseTest.testText;
var
  p : TParse;
  tags : TStringList;
begin
  tags := TStringList.Create;
  p := nil;
  try
    tags.Add('td');
    p := TParse.Create('<td>a&lt;b</td>', tags);
    checkEquals('a&lt;b', p.body);
    checkEquals('a<b', p.text());
    p.Free;
    p := TParse.Create('<td>'#9'a&gt;b&nbsp;&amp;&nbsp;b>c &&&nbsp;</td>', tags);
    checkEquals('a>b & b>c &&', p.text());
    p.Free;
    p := TParse.Create('<td>'#9'a&gt;b&nbsp;&amp;&nbsp;b>c &&nbsp;</td>', tags);
    checkEquals('a>b & b>c &', p.text());
    p := TParse.Create('<TD><P><FONT FACE="Arial" SIZE=2>GroupTestFixture</FONT></TD>', tags);
    checkEquals('GroupTestFixture', p.text());
  finally
    p.Free;
    tags.Free;
  end;
end;

procedure TParseTest.testUnformat;
begin
  checkEquals('ab', TParse.unformat('<font size=+1>a</font>b'));
  checkEquals('ab', TParse.unformat('a<font size=+1>b</font>'));
  checkEquals('a<b', TParse.unformat('a<b'));
end;

procedure TParseTest.testUnescape;
begin
  checkEquals('a<b', TParse.unescape('a&lt;b'));
  checkEquals('a>b & b>c &&', TParse.unescape('a&gt;b&nbsp;&amp;&nbsp;b>c &&'));
  checkEquals('&amp;&amp;', TParse.unescape('&amp;amp;&amp;amp;'));
  checkEquals('a>b & b>c &&', TParse.unescape('a&gt;b&nbsp;&amp;&nbsp;b>c &&'));
end;

procedure TParseTest.testFindNestedEnd();
begin
  CheckEquals(1, TParse.findMatchingEndTag('</t>', 1, 't', 0));
  CheckEquals(8, TParse.findMatchingEndTag('<t></t></t>', 1, 't', 0));
  CheckEquals(15, TParse.findMatchingEndTag('<t></t><t></t></t>', 1, 't', 0));
end;

procedure TParseTest.testNestedTables();
var
  p : TParse;
  sub : TParse;
  nestedTable : string;
begin
  nestedTable := '<table><tr><td>embedded</td></tr></table>';
  p := TParse.Create('<table><tr><td>' + nestedTable + '</td></tr>' +
    '<tr><td>two</td></tr><tr><td>three</td></tr></table>trailer');
  sub := p.at(0, 0, 0).parts;
  CheckEquals(1, p.size());
  CheckEquals(3, p.parts.size());

  CheckEquals(1, sub.at(0, 0, 0).size());
  CheckEquals('embedded', sub.at(0, 0, 0).body);
  CheckEquals(1, sub.size());
  CheckEquals(1, sub.parts.size());
  CheckEquals(1, sub.parts.parts.size());

  CheckEquals('two', p.at(0, 1, 0).body);
  CheckEquals('three', p.at(0, 2, 0).body);
  CheckEquals(1, p.at(0, 1, 0).size());
  CheckEquals(1, p.at(0, 2, 0).size());
end;

procedure TParseTest.testNestedTables2();
var
  p : TParse;
  sub : TParse;
  subSub : TParse;
  nestedTable : string;
  nestedTable2 : string;
begin
  nestedTable := '<table><tr><td>embedded</td></tr></table>';
  nestedTable2 := '<table><tr><td>' + nestedTable + '</td></tr><tr><td>two</td></tr></table>';
  p := TParse.Create('<table><tr><td>one</td></tr><tr><td>' + nestedTable2 + '</td></tr>' +
    '<tr><td>three</td></tr></table>trailer');

  CheckEquals(1, p.size());
  CheckEquals(3, p.parts.size());

  CheckEquals('one', p.at(0, 0, 0).body);
  CheckEquals('three', p.at(0, 2, 0).body);
  CheckEquals(1, p.at(0, 0, 0).size());
  CheckEquals(1, p.at(0, 2, 0).size());

  sub := p.at(0, 1, 0).parts;
  CheckEquals(2, sub.parts.size());
  CheckEquals(1, sub.at(0, 0, 0).size());
  subSub := sub.at(0, 0, 0).parts;

  CheckEquals('embedded', subSub.at(0, 0, 0).body);
  CheckEquals(1, subSub.at(0, 0, 0).size());

  CheckEquals('two', sub.at(0, 1, 0).body);
  CheckEquals(1, sub.at(0, 1, 0).size());
end;

procedure TParseTest.testIndexOf;
var
  tmpStr : string;
begin
  tmpStr := '12 56';
  checkEquals(1, indexOf('1', tmpStr));
  checkEquals(2, indexOf('2', tmpStr));
  checkEquals(4, indexOf('5', 3, tmpStr));
  checkEquals(5, indexOf('6', 2, tmpStr));
  checkEquals(0, indexOf('1', 2, tmpStr));
end;

procedure TParseTest.testAddTag;
var
  theParse : TParse;
begin
  theParse := TParse.Create('<table><tr><td></td></tr></table>');
  theParse.addToTag(' test');

  checkEquals('<table test>', theParse.tag)
end;

procedure TParseTest.testAddToBody;
var
  theParse : TParse;
begin
  theParse := TParse.Create('<table><tr><td>1</td></tr></table>');
  theParse.parts.parts.addToBody('test');

  checkEquals('1test', theParse.parts.parts.text)

end;

procedure TParseTest.testParseWithTagBodyTableAndMore;
var
  theParse : TParse;
begin
  theParse := TParse.Create('table', 'bad table', nil, nil);

  checkEquals('bad table', theParse.body);
  checkEquals('<table>', theParse.tag);
  checkEquals('</table>', theParse.theend);
  check(theParse.more = nil, 'bad more');
  check(theParse.Parts = nil, 'bad parts');

end;

initialization

  RegisterTest(TParseTest.Suite);

end.

