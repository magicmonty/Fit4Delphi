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
unit RowFixture;

interface

uses
  Classes,
  SysUtils,
  Parse,
  Fixture,
  ColumnFixture;

type
  TRowFixture = class(TColumnFixture)
  protected
    procedure check(eList, cList : TList);
    function list(rows : TParse) : TList; overload;
    function list(results : TList) : TList; overload;
    function eSort(list : TList; col : integer) : TStringList;
    function cSort(list : TList; col : integer) : TStringList;
    function union(list1, list2 : TStringList) : TStringList;
    procedure bin(map : TStringList; key : Variant; row : TObject);
    procedure mark(rows : TParse; message : string); overload;
    procedure mark(rows : TList; message : string); overload;
    function buildRows(rows : TList) : TParse;
    function buildCells(row : TObject) : TParse;

    function getList(Map : TStringList; key : string) : TList;
    procedure addAll(listFrom, listTo : TList);
  public
    results : TList;
    missing : TList;
    surplus : TList;
    constructor Create; override; 
    destructor Destroy; override;
    procedure doRows(Rows : TParse); override;
    function query : TList; virtual; abstract;
    function getTargetClass() : TClass; override; // get expected type of row
    procedure match(expected, computed : TList; col : integer);
  end;

implementation

uses
  TypeAdapter,
  Binding;

{ TRowFixture }

constructor TRowFixture.Create;
begin
  inherited;
  results := TList.Create;
  surplus := TList.Create;
  missing := TList.Create;
end;

destructor TRowFixture.Destroy;
begin
  results.Free;
  surplus.Free;
  missing.Free;
  inherited;
end;

procedure TRowFixture.doRows(Rows : TParse);
var
  eList, cList : TList;
  last : TParse;
begin
  (*
      public void doRows(Parse rows) {
          try {
              bind(rows.parts);
              results = query();
              match(list(rows.more), list(results), 0);
              Parse last = rows.last();
              last.more = buildRows(surplus.toArray());
              mark(last.more, "surplus");
              mark(missing.iterator(), "missing");
          } catch (Exception e) {
              exception (rows.leaf(), e);
          }
      }
  *)
  eList := nil;
  cList := nil;
  try
    bind(rows.parts);
    results := query();
    eList := list(rows.more);
    cList := list(results);
    match(eList, cList, 0);
    last := rows.last();
    last.more := buildRows(surplus);
    mark(last.more, 'surplus');
    mark(missing, 'missing');
  except
    on e : Exception do
      doException(rows.leaf, e);
  end;
  eList.Free;
  cList.Free;
end;

function TRowFixture.list(rows : TParse) : TList;
begin
  (*
      protected List list (Parse rows) {
          List result = new LinkedList();
          while (rows != null) {
              result.add(rows);
              rows = rows.more;
          }
          return result;
      }
  *)
  result := TList.Create;
  while rows <> nil do
  begin
    result.Add(rows);
    rows := rows.more;
  end;
end;

function TRowFixture.eSort(list : TList; col : integer) : TStringList;
var
  a : TTypeAdapter;
  i : integer;
  row, cell : TParse;
  key : Variant;
  rest : TParse;
begin
  (*
   protected Map eSort(List list, int col)
   {
    TypeAdapter a = columnBindings[col].adapter;
    Map result = new HashMap(list.size());
    for(Iterator i = list.iterator(); i.hasNext();)
    {
     Parse row = (Parse) i.next();
     Parse cell = row.parts.at(col);
     try
     {
      Object key = a.parse(cell.text());
      bin(result, key, row);
     }
     catch(Exception e)
     {
      exception(cell, e);
      for(Parse rest = cell.more; rest != null; rest = rest.more)
      {
       ignore(rest);
      }
     }
    }
    return result;
   }
  *)
  a := columnBindings[col].adapter;
  result := TStringList.Create;
  for i := 0 to list.Count - 1 do
  begin
    row := TParse(list[i]);
    cell := row.parts.at(col);
    try
      key := a.parse(cell.text);
      bin(result, key, row);
    except
      on e : Exception do
      begin
        doException(cell, e);
        rest := cell.more;
        while (rest <> nil) do
        begin
          ignore(rest);
          rest := rest.more;
        end;
      end;
    end;
  end;
end;

function TRowFixture.list(results : TList) : TList;
var
  i : integer;
begin
  (*
      protected List list (Object[] rows) {
          List result = new LinkedList();
          for (int i=0; i<rows.length; i++) {
              result.add(rows[i]);
          }
          return result;
      }
  *)
  result := TList.Create;
  for i := 0 to results.Count - 1 do
    result.Add(results.Items[i]);
end;

procedure TRowFixture.match(expected, computed : TList; col : integer);
var
  i : integer;
  eMap, cMap, keys : TStringList;
  eList, cList : TList;
begin
  (*
      protected void match(List expected, List computed, int col) {
          if (col >= columnBindings.length) {
              check (expected, computed);
          } else if (columnBindings[col] == null) {
              match (expected, computed, col+1);
          } else {
              Map eMap = eSort(expected, col);
              Map cMap = cSort(computed, col);
              Set keys = union(eMap.keySet(),cMap.keySet());
              for (Iterator i=keys.iterator(); i.hasNext(); ) {
                  Object key = i.next();
                  List eList = (List)eMap.get(key);
                  List cList = (List)cMap.get(key);
                  if (eList == null) {
                      surplus.addAll(cList);
                  } else if (cList == null) {
                      missing.addAll(eList);
                  } else if (eList.size()==1 && cList.size()==1) {
                      check(eList, cList);
                  } else {
                      match(eList, cList, col+1);
                  }
              }
          }
      }
  *)
  if (col >= FcolumnBindings.Count) then
    check(expected, computed)
  else
    if (columnBindings[col] = nil) then
      match(expected, computed, col + 1)
    else
    begin
      eMap := eSort(expected, col);
      cMap := cSort(computed, col);
      keys := union(eMap, cMap);
      for i := 0 to keys.Count - 1 do
      begin
        eList := getList(eMap, keys[i]);
        cList := getList(cMap, keys[i]);
        if eList.Count = 0 then
          addAll(cList, surplus)
        else
          if cList.Count = 0 then
            addAll(eList, missing)
          else
            if (eList.Count = 1) and (cList.Count = 1) then
              check(eList, cList)
            else
              match(eList, cList, col + 1);
      end;
    end;
end;

procedure TRowFixture.addAll(listFrom, listTo : TList);
var
  i : integer;
begin
  for i := 0 to listFrom.Count - 1 do
    listTo.Add(listFrom.Items[i]);
end;

function TRowFixture.getList(Map : TStringList; key : string) : TList;
var
  i : integer;
begin
  result := TList.Create;
  i := Map.IndexOf(key);
  if i <> -1 then
    result := TList(Map.Objects[i]);
end;

function TRowFixture.getTargetClass : TClass;
begin
  Result := nil;
end;

function TRowFixture.cSort(list : TList; col : integer) : TStringList;
var
  a : TTypeAdapter;
  i : integer;
  row : TObject;
  key : Variant;
begin
  (*
   protected Map cSort(List list, int col)
   {
    TypeAdapter a = columnBindings[col].adapter;
    Map result = new HashMap(list.size());
    for(Iterator i = list.iterator(); i.hasNext();)
    {
     Object row = i.next();
     try
     {
      a.target = row;
      Object key = a.get();
      bin(result, key, row);
     }
     catch(Exception e)
     {
      // surplus anything with bad keys, including null
      surplus.add(row);
     }
    }
    return result;
   }
  *)
  a := columnBindings[col].adapter;
  result := TStringList.Create;
  for i := 0 to list.Count - 1 do
  begin
    row := list[i];
    try
      a.target := row;
      key := a.get();
      bin(result, key, row);
    except
      on e : Exception do
        // surplus anything with bad keys, including null
        surplus.add(row);
    end;
  end;
end;

{@}

function TRowFixture.union(list1, list2 : TStringList) : TStringList;
var
  i : integer;
begin
  result := TStringList.Create;
  for i := 0 to list1.count - 1 do
  begin
    if result.IndexOf(list1.Strings[i]) = -1 then
      result.Add(list1.Strings[i]);
  end;
  for i := 0 to list2.count - 1 do
  begin
    if result.IndexOf(list2.Strings[i]) = -1 then
      result.Add(list2.Strings[i]);
  end;
end;

//TODO

procedure TRowFixture.bin(map : TStringList; key : Variant; row : TObject);
var
  iIndex : integer;
  aList : TList;
begin
  (*
   protected void bin(Map map, Object key, Object row)
   {
    if(key.getClass().isArray())
    {
     key = Arrays.asList((Object[]) key);
    }
    if(map.containsKey(key))
    {
     ((List) map.get(key)).add(row);
    }
    else
    {
     List list = new LinkedList();
     list.add(row);
     map.put(key, list);
    }
   }
  *)
  iIndex := map.IndexOf(key);
  if iIndex <> -1 then
    TList(map.Objects[iIndex]).Add(row)
  else
  begin
    aList := TList.Create;
    aList.Add(row);
    map.AddObject(key, aList);
  end;
end;

{@}

procedure TRowFixture.check(eList, cList : TList);
var
  i : integer;
  row, cell : TParse;
  obj : TObject;
  a : TTypeAdapter;
begin
  (*
      protected void check (List eList, List cList) {
          if (eList.size()==0) {
              surplus.addAll(cList);
              return;
          }
          if (cList.size()==0) {
              missing.addAll(eList);
              return;
          }
          Parse row = (Parse)eList.remove(0);
          Parse cell = row.parts;
          Object obj = cList.remove(0);
          for (int i=0; i<columnBindings.length && cell!=null; i++) {
              TypeAdapter a = columnBindings[i].adapter;
              if(a != null)
              {
                a.target = obj;
              }
              check(cell, a);
              cell = cell.more;
          }
          check (eList, cList);
      }
  *)
  if (eList.Count = 0) then
  begin
    addAll(cList, surplus);
    exit;
  end;
  if (cList.Count = 0) then
  begin
    addAll(eList, missing);
    exit;
  end;
  row := TParse(eList.Items[0]);
  eList.Delete(0);
  cell := row.parts;
  obj := cList.Items[0];
  cList.Delete(0);
  i := 0;
  while (i < FcolumnBindings.Count) and (cell <> nil) do
  begin
    a := columnBindings[i].adapter;
    if a <> nil then
      a.target := obj;
    checkCell(cell, a);
    cell := cell.more;
    Inc(i);
  end;
  check(eList, cList);
end;

{@}

procedure TRowFixture.mark(rows : TParse; message : string);
var
  annotation : string;
begin
  annotation := doLabel(message);
  while (rows <> nil) do
  begin
    wrong(rows.parts);
    rows.parts.addToBody(annotation);
    rows := rows.more;
  end;
  (*
      protected void mark(Parse rows, String message) {
          String annotation = label(message);
          while (rows != null) {
              wrong(rows.parts);
              rows.parts.addToBody(annotation);
              rows = rows.more;
          }
      }
  *)
end;

{@}

procedure TRowFixture.mark(rows : TList; message : string);
var
  annotation : string;
  i : Integer;
  row : TParse;
begin
  annotation := doLabel(message);
  for i := 0 to rows.Count - 1 do
  begin
    row := TParse(rows[i]);
    wrong(row.parts);
    row.parts.addToBody(annotation);
  end;
  (*    protected void mark(Iterator rows, String message) {
          String annotation = label(message);
          while (rows.hasNext()) {;
              Parse row = (Parse)rows.next();
              wrong(row.parts);
              row.parts.addToBody(annotation);
          }
      }
  *)
end;

{@}

function TRowFixture.buildRows(rows : TList) : TParse;
var
  root : TParse;
  next : TParse;
  i : Integer;
begin
  root := TParse.Create('', '', nil, nil);
  next := root;
  for i := 0 to rows.Count - 1 do
  begin
    next.more := TParse.Create('tr', '', buildCells(rows[i]), nil);
    next := next.more;
  end;
  result := root.more;
  (*
      protected Parse buildRows(Object[] rows) {
          Parse root = new Parse(null ,null, null, null);
          Parse next = root;
          for (int i=0; i<rows.length; i++) {
              next = next.more = new Parse("tr", null, buildCells(rows[i]), null);
          }
          return root.more;
      }
  *)
end;

{@}

function TRowFixture.buildCells(row : TObject) : TParse;
var
  null : TParse;
  root : TParse;
  next : TParse;
  i : Integer;
  a : TTypeAdapter;
begin
  if (row = nil) then
  begin
    null := TParse.Create('td', 'null', nil, nil);
    null.addToTag(' colspan=' + IntToStr(FcolumnBindings.Count));
    result := null;
    exit;
  end;
  root := TParse.Create('', '', nil, nil);
  next := root;
  for i := 0 to FcolumnBindings.Count - 1 do
  begin
    next.more := TParse.Create('td', '&nbsp;', nil, nil);
    next := next.more;
    a := columnBindings[i].adapter;
    if (a = nil) then
      ignore(next)
    else
    begin
      try
        a.target := row;
        next.body := gray(escape(a.toString(a.get())));
      except
        on e : Exception do
          doException(next, e);
      end;
    end;
  end;
  result := root.more;
  (*
     protected Parse buildCells(Object row)
     {
        if(row == null)
        {
           Parse nil = new Parse("td", "null", null, null);
           nil.addToTag(" colspan=" + columnBindings.length);
           return nil;
        }
        Parse root = new Parse(null, null, null, null);
        Parse next = root;
        for(int i = 0; i < columnBindings.length; i++)
        {
           next = next.more = new Parse("td", "&nbsp;", null, null);
           TypeAdapter a = columnBindings[i].adapter;
           if(a == null)
           {
              ignore(next);
           }
           else
           {
              try
              {
                 a.target = row;
                 next.body = gray(escape(a.toString(a.get())));
              }
              catch(Exception e)
              {
                 exception(next, e);
              }
           }
        }
        return root.more;
     }
  *)
end;

end.

