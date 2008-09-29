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
// Released under the terms of the GNU General Public License version 2 or later.package fit;
{*
Copyright (c) 2002 Cunningham & Cunningham, Inc.
Derived from Fixture.java by Martin Chernenkoff, CHI Software Design
Released under the terms of the GNU General Public License version 2 or later.
*}
{$H+}
unit Fixture;

interface

uses
  Counts,
  Parse,
  Classes,
  SysUtils,
  TypInfo,
  FixtureListener, IniFiles;

type
  TFixture = class(TPersistent)
  private
    function isFriendlyException(e : Exception) : Boolean;
    procedure ClearSymbols;
    procedure interpretFollowingTables(tables : TParse);
    function getLinkedFixtureWithArgs(tables : TParse) : TFixture;
    procedure getArgsForTable(table : TParse);
    procedure interpretTables(tables : TParse);
    procedure compareCellToResult(a : TObject {TTypeAdapter}; cell : TParse);
    procedure handleErrorInCell(a : TObject {TTypeAdapter}; cell : TParse);
  protected
    FListener : IFixtureListener;
    FBPLList : TStringList;
    args : TStringList;
    function loadFixture(fixtureName : string) : TFixture;
    procedure doCell(cell : TParse; columnNumber : integer); virtual;
    procedure doCells(Cells : TParse); virtual;
    procedure doRow(Row : TParse); virtual;
    procedure doRows(Rows : TParse); virtual;
    function escape(text : string) : string; overload;
    function escape(s, sFrom, sTo : string) : string; overload;
    function camel(name : string) : string;
    //    function GetFixtureClassName(heading : TParse) : string; virtual;
    function doLabel(s : string) : string;
  public
    Counts : TCounts;
    Summary : THashedStringList;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure doTables(tables : TParse);
    procedure doTable(table : TParse); virtual;
    procedure doException(cell : TParse; e : Exception);
    procedure checkCell(cell : TParse; a : TObject {TTypeAdapter}); virtual;
    procedure addBPL(const bpl : string);
    function parse(s : string; aType : TTypeKind) : Variant;
    function getTargetClass : TClass; virtual;
    procedure setSymbol(name : string; value : string);
    function getSymbol(name : string) : string;
    class function gray(text : string) : string;
    procedure handleBlankCell(cell : TParse; a : TObject {TTypeAdapter});
    procedure ignore(cell : TParse);
    procedure right(cell : TParse);
    procedure wrong(cell : TParse); overload;
    procedure wrong(cell : TParse; actual : string); overload;
    //    class function hasParseMethod(_type: TClass): Boolean;
    //    class function callParseMethod(_type: TClass; s: String): Variant;
    property listener : IFixtureListener read FListener write FListener;
  end;

  TFixtureClass = class of TFixture;

implementation

uses
  Windows,
  NullFixtureListener,
  TypeAdapter,
  Variants,
  FixtureLoader,
  CellComparator,
  FitFailureException,
  StringTokenizer,
  Runtime;

var
  symbols : THashedStringList;

  { TFixture }

constructor TFixture.Create;
begin
  inherited;
  Counts := TCounts.Create;
  listener := TNullFixtureListener.Create;
  FBPLList := TStringList.Create;
  args := TStringList.Create;
  summary := THashedStringList.Create;
end;

// TODO

destructor TFixture.Destroy;
begin
  //  Counts.Free;
  listener := nil;
  FBPLList.Free;
  args.Free;
  //  summary.Free;
  inherited;
end;

function TFixture.getTargetClass() : TClass;
begin
  Result := self.ClassType;
end;

procedure TFixture.checkCell(cell : TParse; a : TObject {TTypeAdapter});
var
  text : string;
begin
  (*
      public void check(Parse cell, TypeAdapter a)
      {
          String text = cell.text();
          if (text.equals(""))
              handleBlankCell(cell, a);
          else if (a == null)
              ignore(cell);
          else if (text.equals("error"))
              handleErrorInCell(a, cell);
          else
              compareCellToResult(a, cell);
      }
  *)
  text := cell.text();
  if text = '' then
    handleBlankCell(cell, a)
  else
    if a = nil then
      ignore(cell)
    else
      if text = 'error' then
        handleErrorInCell(a, cell)
      else
        compareCellToResult(a, cell);
end;

procedure TFixture.compareCellToResult(a : TObject {TTypeAdapter}; cell : TParse);
begin
  (*
      private void compareCellToResult(TypeAdapter a, Parse cell)
      {
          new CellComparator().compareCellToResult(a, cell);
      }
  *)
  TCellComparator.compareCellToResult(self, a as TTypeAdapter, cell);
end;

procedure TFixture.handleBlankCell(cell : TParse; a : TObject {TTypeAdapter});
var
  ta : TTypeAdapter;
begin
  (*
      public void handleBlankCell(Parse cell, TypeAdapter a)
      {
          try
          {
              cell.addToBody(gray(a.toString(a.get())));
          } catch (Exception e)
          {
              cell.addToBody(gray("error"));
          }
      }
  *)
  ta := a as TTypeAdapter;
  try
    cell.addToBody(gray(ta.toString(ta.get())));
  except
    on e : Exception do
      cell.addToBody(gray('error'));
  end;
end;

procedure TFixture.handleErrorInCell(a : TObject {TTypeAdapter}; cell : TParse);
var
  ta : TTypeAdapter;
  result : variant;
begin
  (*
      private void handleErrorInCell(TypeAdapter a, Parse cell)
      {
          try
          {
              Object result = a.invoke();
              wrong(cell, a.toString(result));
          } catch (IllegalAccessException e)
          {
              exception(cell, e);
          } catch (Exception e)
          {
              right(cell);
          }
      }
  *)
  ta := a as TTypeAdapter;
  try
    result := ta.invoke;
    wrong(cell, ta.toString(result));
  except
    //    on e : IllegalAccessException do // TODO
    //      doException(cell, e);
    on e : Exception do
      right(cell);
  end;
end;

procedure TFixture.doCell(cell : TParse; columnNumber : integer);
begin
  (*
      public void doCell(Parse cell, int columnNumber) {
          ignore(cell);
      }
  *)
  ignore(cell);
end;

procedure TFixture.doCells(Cells : TParse);
var
  i : Integer;
begin
  (*
      public void doCells(Parse cells) {
          for (int i=0; cells != null; i++) {
              try {
                  doCell(cells, i);
              } catch (Exception e) {
                  exception(cells, e);
              }
              cells=cells.more;
          }
      }
  *)
  i := 0;
  while cells <> nil do
  begin
    try
      doCell(cells, i);
    except
      on e : Exception do
        doException(cells, e);
    end;
    cells := cells.more;
    inc(i);
  end; // while
end;

procedure TFixture.DoException(cell : TParse; e : Exception);
begin
  (*
    public void exception(Parse cell, Throwable exception)
    {
        while (exception.getClass().equals(InvocationTargetException.class))
        {
            exception = ((InvocationTargetException) exception).getTargetException();
        }
        if (isFriendlyException(exception))
        {
            cell.addToBody("<hr/>" + label(exception.getMessage()));
        } else
        {
            final StringWriter buf = new StringWriter();
            exception.printStackTrace(new PrintWriter(buf));
            cell.addToBody("<hr><pre><div class=\"fit_stacktrace\">" + (buf.toString()) + "</div></pre>");
        }
        cell.addToTag(" class=\"error\"");
        counts.exceptions++;
    }
  *)
// TODO InvocationTargetException
  if (isFriendlyException(e)) then
    cell.addToBody('<hr/>' + doLabel(e.Message))
  else
  begin
    // TODO Add dump of stack trace
    //      final StringWriter buf = new StringWriter();
    //      exception.printStackTrace(new PrintWriter(buf));
    //      cell.addToBody("<hr><pre><div class=\"fit_stacktrace\">" + (buf.toString()) + "</div></pre>");
    cell.addToBody('<hr><pre><div class="fit_stacktrace">' + e.Message + '</div></pre>');
  end;
  cell.addToTag(' class="error"');
  counts.exceptions := counts.exceptions + 1;
end;

function TFixture.isFriendlyException(e : Exception) : Boolean;
begin
  //        return exception instanceof FitFailureException;
  Result := e is TFitFailureException;
end;

procedure TFixture.doRow(Row : TParse);
begin
  (*
      public void doRow(Parse row) {
          doCells(row.parts);
      }
  *)
  doCells(row.parts);
end;

procedure TFixture.doRows(Rows : TParse);
var
  more : TParse;
begin
  while rows <> nil do
  begin
    more := rows.more;
    doRow(rows);
    rows := more;
  end;
end;

procedure TFixture.doTable(table : TParse);
begin
  (*
      public void doTable(Parse table) {
          doRows(table.parts.more);
      }

  *)
  doRows(table.parts.more);
end;

procedure TFixture.doTables(tables : TParse);
var
  heading : TParse;
  fixture : TFixture;
begin
  (*
    public void doTables(Parse tables)
    {
        summary.put("run date", new Date());
        summary.put("run elapsed time", new RunTime());
        if (tables != null)
        {
            Parse heading = tables.at(0, 0, 0);
            if (heading != null)
            {
                try
                {
                    Fixture fixture = getLinkedFixtureWithArgs(tables);
                    fixture.listener = listener;
                    fixture.interpretTables(tables);
                } catch (Throwable e)
                {
                    exception(heading, e);
                    interpretFollowingTables(tables);
                }
            }
        }
        listener.tablesFinished(counts);
        ClearSymbols();
    }
  *)
  // TODO Summary support
//  summary.AddObject('run date', FormatDateTime('ddd mmm dd hh:nn:ss yyyy', Now)); // TODO Missing timezone
//  summary.AddObject('run elapsed time', TRunTime.Create());
  summary.Values['run date'] := FormatDateTime('ddd mmm dd hh:nn:ss yyyy', Now); // TODO Missing timezone
//  summary.Values['run elapsed time'] := TRunTime.Create());
  if tables <> nil then
  begin
    heading := tables.at(0, 0, 0);
    if (heading <> nil) then
    begin
      try
        fixture := getLinkedFixtureWithArgs(tables);
        fixture.listener := listener;
        fixture.interpretTables(tables);
        fixture.Free;
      except
        on e : Exception do
        begin
          doException(heading, e);
          interpretFollowingTables(tables);
        end;
      end;
    end;
  end;
  listener.tablesFinished(Counts);
  ClearSymbols();
end;

procedure TFixture.ClearSymbols();
begin
  symbols.clear();
end;

procedure TFixture.setSymbol(name : string; value : string);
begin
  symbols.Values[name] := value;
end;

function TFixture.getSymbol(name : string) : string;
begin
  Result := symbols.Values[name];
end;

function TFixture.escape(text : string) : string;
begin
  (*
      public static String escape (String string) {
          return escape(escape(string, '&', "&amp;"), '<', "&lt;");
      }
  *)
  result := escape(escape(text, '&', '&amp;'), '<', '&lt;');
end;

function TFixture.escape(s, sFrom, sTo : string) : string;
begin
  (*
      public static String escape (String string, char from, String to) {
          int i=-1;
          while ((i = string.indexOf(from, i+1)) >= 0) {
              if (i == 0) {
                  string = to + string.substring(1);
              } else if (i == string.length()) {
                  string = string.substring(0, i) + to;
              } else {
                  string = string.substring(0, i) + to + string.substring(i+1);
              }
          }
          return string;
      }
  *)
  (*i := Posn(s, sFrom, 1);
  while i >= 0 do
  begin
    if (i = 1) then
      s := sTo + s
    else
      if (i = length(s)) then
        s := s + sTo
      else
        s := Copy(s, 0, i - 1) + sTo + Copy(s, i + 1, length(s) - i);
    i := Posn(s, sFrom, i + 1);
  end;
  result := s;
  *)
  Result := StringReplace(s, sFrom, sTo, [rfReplaceAll]);
end;

class function TFixture.gray(text : string) : string;
begin
  //return " <span class=\"fit_grey\">" + string + "</span>";
  result := ' <span class="fit_grey">' + text + '</span>';
end;

procedure TFixture.ignore(cell : TParse);
begin
  (*
        cell.addToTag(" class=\"ignore\"");
        counts.ignores++;
  *)
  cell.addToTag(' class="ignore"');
  counts.ignores := counts.ignores + 1;
end;

//TODO

function TFixture.parse(s : string; aType : TTypeKind) : Variant;
begin
  (*
      public Object parse(String s, Class type) throws Exception
      {
          if (type.equals(String.class))
          {
              if (s.toLowerCase().equals("null"))
                  return null;
              else if (s.toLowerCase().equals("blank"))
                  return "";
              else
                  return s;
          } else if (type.equals(Date.class))
          {
              return DateFormat.getDateInstance(DateFormat.SHORT).parse(s);
          } else if (hasParseMethod(type))
          {
              return callParseMethod(type, s);
          } else
          {
              throw new CouldNotParseFitFailureException(s, type.getName());
          }
      }
  *)
  case aType of
{$IFDEF UNICODE}
    tkString, tkLString, tkWString, tkUString :
{$ELSE}
    tkString, tkLString, tkWString :
{$ENDIF}
      begin
        if (AnsiSameText(s, 'null')) then
          result := null
        else
          if (AnsiSameText(s, 'blank')) then
            result := ''
          else
            result := s;
      end
  else
    result := s;
  end;
end;

//class function TFixture.hasParseMethod(_type : TClass) : Boolean;
//begin
//  (*
//    try
//    {
//        type.getMethod("parse", new Class[]
//        {String.class});
//        return true;
//    } catch (NoSuchMethodException e)
//    {
//        return false;
//    }
//  *)
//  Result := Assigned(_type.MethodAddress('parse'));
//end;
//
//class function TFixture.callParseMethod(_type : TClass; s : String) : Variant;
//var
//  parseMethod : TMethod;
//begin
//(*
//    public static Object callParseMethod(Class type, String s) throws Exception
//    {
//        Method parseMethod = type.getMethod("parse", new Class[]
//        {String.class});
//        Object o = parseMethod.invoke(null, new Object[]
//        {s});
//        return o;
//    }
//*)
//  parseMethod := TMethod.Create(_type, s);
//  Result := parseMethod.invoke(nil, s);
//end;

procedure TFixture.right(cell : TParse);
begin
  (*
        cell.addToTag(" class=\"pass\"");
        counts.right++;
  *)
  cell.addToTag(' class="pass"');
  counts.right := counts.right + 1;
end;

procedure TFixture.wrong(cell : TParse);
begin
  (*
       cell.addToTag(" class=\"fail\"");
       counts.wrong++;
  *)
  cell.addToTag(' class="fail"');
  counts.wrong := counts.wrong + 1;
end;

procedure TFixture.wrong(cell : TParse; actual : string);
begin
  (*
        wrong(cell);
        cell.addToBody(label("expected") + "<hr>" + escape(actual) + label("actual"));
  *)
  wrong(cell);
  cell.addToBody(doLabel('expected') + '<hr>' + escape(actual) + doLabel('actual'));
end;

// TODO Can be written better

function TFixture.camel(name : string) : string;
var
  b, token : string;
  t : TStringTokenizer;
  i : Integer;
begin
  (*
      public static String camel (String name) {
          StringBuffer b = new StringBuffer(name.length());
          StringTokenizer t = new StringTokenizer(name);
          b.append(t.nextToken());
          while (t.hasMoreTokens()) {
              String token = t.nextToken();
              b.append(token.substring(0, 1).toUpperCase());      // replace spaces with camelCase
              b.append(token.substring(1));
          }
          return b.toString();
      }
  *)
  b := '';
  t := TStringTokenizer.Create;
  t.Text := name;
  for i := 0 to t.Count - 1 do
  begin
    token := t[i];
    b := b + UpperCase(Copy(token, 1, 1)); // replace spaces with camelCase
    b := b + Copy(token, 2, MaxInt);
  end;
  t.Free;
  Result := b;
  (*
    StrTok(name);
    sToken := StrTok('', ' ');
    while sToken <> '' do
    begin
      b := b + sToken;
      sToken := StrTok('', ' ');
      sToken := Copy(sToken, 1, 1) + Copy(sToken, 2, length(sToken) - 1);
    end;
    result := b;
  *)
end;

function TFixture.doLabel(s : string) : string;
begin
  //" <span class=\"fit_label\">" + string + "</span>"
  result := ' <span class="fit_label">' + s + '</span>';
end;

procedure TFixture.addBPL(const bpl : string);
var
  tmpStr : string;
begin

  if (FBPLList.IndexOf(bpl) = -1) then
  begin
    if (pos('bpl', ExtractFileExt(bpl)) = 0) then
      tmpStr := bpl + '.bpl'
    else
      tmpStr := bpl;
    try
      if IsConsole then
        WriteLn(tmpStr);
      FBPLList.AddObject(bpl, pointer(LoadPackage(tmpStr)));
    except
      ;
    end;
  end;
end;

//    /* Added by Rick */

function TFixture.getLinkedFixtureWithArgs(tables : TParse) : TFixture;
var
  header : TParse;
begin
  (*
      protected Fixture getLinkedFixtureWithArgs(Parse tables) throws Throwable
      {
          Parse header = tables.at(0, 0, 0);
          Fixture fixture = loadFixture(header.text());
          fixture.counts = counts;
          fixture.summary = summary;
          fixture.getArgsForTable(tables);
          return fixture;
      }
  *)
  header := tables.at(0, 0, 0);
  Result := loadFixture(header.text());
  Result.counts := counts;
  Result.summary := summary;
  Result.getArgsForTable(tables);
end;

function TFixture.loadFixture(fixtureName : string) : TFixture;
begin
  Result := TFixtureLoader.instance().disgraceThenLoad(fixtureName);
end;

procedure TFixture.getArgsForTable(table : TParse);
var
  argumentList : TStringList;
  parameters : TParse;
begin
  (*
      void getArgsForTable(Parse table)
      {
          List<String> argumentList = new ArrayList<String>();
          Parse parameters = table.parts.parts.more;
          for (; parameters != null; parameters = parameters.more)
              argumentList.add(parameters.text());

          args = (String[]) argumentList.toArray(new String[0]);
      }
  *)
  argumentList := TStringList.Create;
  parameters := table.parts.parts.more;
  while parameters <> nil do
  begin
    argumentList.add(parameters.text());
    parameters := parameters.more;
  end;
  args.Assign(argumentList);
  argumentList.Free;
end;

//    /* Added by Rick to allow a dispatch into DoFixture */

procedure TFixture.interpretTables(tables : TParse);
begin
  (*
      protected void interpretTables(Parse tables)
      {
          try
          { // Don't create the first fixture again, because creation may do something important.
              getArgsForTable(tables); // get them again for the new fixture object
              doTable(tables);
          } catch (Exception ex)
          {
              exception(tables.at(0, 0, 0), ex);
              listener.tableFinished(tables);
              return;
          }
          interpretFollowingTables(tables);
      }
  *)
  try
    // Don't create the first fixture again, because creation may do something important.
    getArgsForTable(tables); // get them again for the new fixture object
    doTable(tables);
  except
    on ex : Exception do
    begin
      doException(tables.at(0, 0, 0), ex);
      listener.tableFinished(tables);
      exit;
    end;
  end;
  interpretFollowingTables(tables);
end;

//    /* Added by Rick */

procedure TFixture.interpretFollowingTables(tables : TParse);
var
  heading : TParse;
  fixture : TFixture;
begin
  (*
      private void interpretFollowingTables(Parse tables)
      {
          listener.tableFinished(tables);
          tables = tables.more;
          while (tables != null)
          {
              Parse heading = tables.at(0, 0, 0);
              if (heading != null)
              {
                  try
                  {
                      Fixture fixture = getLinkedFixtureWithArgs(tables);
                      fixture.doTable(tables);
                  } catch (Throwable e)
                  {
                      exception(heading, e);
                  }
              }
              listener.tableFinished(tables);
              tables = tables.more;
          }
      }
  *)
  listener.tableFinished(tables);
  tables := tables.more;
  while (tables <> nil) do
  begin
    heading := tables.at(0, 0, 0);
    if (heading <> nil) then
    begin
      try
        fixture := getLinkedFixtureWithArgs(tables);
        fixture.doTable(tables);
        fixture.Free;
      except
        on E : Exception do
          doException(heading, e);
      end;
    end;
    listener.tableFinished(tables);
    tables := tables.more;
  end;
end;

initialization
  symbols := THashedStringList.Create();

finalization
  symbols.Free;

end.

