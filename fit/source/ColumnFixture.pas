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
// Derived from ColumnFixture.java by Martin Chernenkoff, CHI Software Design
// Ported to Delphi by Salim Nair.
{$H+}
unit ColumnFixture;

interface

uses
  Field,
  Method,
  Classes,
  TypInfo,
  Parse,
  Fixture,
  SysUtils,
  TypeAdapter,
  Contnrs,
  Binding;

type
  TColumnFixture = class(TFixture)
  private
    procedure setupColumnBindings(theSize : integer);
    function getColumnBinding(idx : integer) : TBinding;
    procedure setColumnBinding(idx : integer; const Value : TBinding);
    function createBinding(column : Integer; heads : TParse) : TBinding;
  protected
    FColumnBindings : TObjectList;
    hasExecuted : Boolean;
    procedure execute; virtual;
    function bindMethod(const theName : string) : TTypeAdapter;
    function bindField(const theName : string) : TTypeAdapter;
  public
    property ColumnBindings[idx : integer] : TBinding read getColumnBinding write setColumnBinding;
    procedure bind(heads : TParse);
    procedure doCell(cell : TParse; column : integer); override;
    procedure doRows(Rows : TParse); override;
    procedure doRow(row : TParse); override;
    procedure checkCell(cell : TParse; a : TObject {TTypeAdapter}); override;
    procedure reset; virtual;
    procedure executeIfNeeded;
    constructor Create; override; 
    destructor Destroy; override;
  end;

implementation

{ TColumnFixture }

procedure TColumnFixture.setupColumnBindings(theSize : integer);
var
  i : integer;
begin

  FColumnBindings.Clear;

  for i := 0 to theSize - 1 do
    FColumnBindings.add(nil);
end;


procedure TColumnFixture.bind(heads : TParse);
(*
  protected void bind(Parse heads)
  {
   try
   {
    columnBindings = new Binding[heads.size()];
    for(int i = 0; heads != null; i++, heads = heads.more)
    {
              columnBindings[i] = createBinding(i, heads);
    }
   }
   catch(Throwable throwable)
   {
    exception(heads, throwable);
   }
  }
*)
var
  i : Integer;
begin
  try
    setupColumnBindings(heads.size);
    i := 0;
    while heads <> nil do
    begin
      columnBindings[i] := createBinding(i, heads);
      Inc(i);
      heads := heads.more;
    end;
  except
    on throwable : Exception do
      doException(heads, throwable);
  end;
end;

function TColumnFixture.createBinding(column : Integer; heads : TParse) : TBinding;
begin
  Result := TBinding.doCreate(self, heads.text());
end;
(*
  protected Binding createBinding(int column, Parse heads) throws Throwable
  {
      return Binding.create(this, heads.text());
  }
*)


procedure TColumnFixture.doCell(cell : TParse; column : integer);
(*
  public void doCell(Parse cell, int column)
  {
    try
    {
     columnBindings[column].doCell(this, cell);
    }
    catch(Throwable e)
    {
      exception(cell, e);
    }
  }
*)
begin
  try
    columnBindings[column].doCell(self, cell);
  except
    on e : Exception do
      doException(cell, e);
  end;
end;


procedure TColumnFixture.doRows(Rows : TParse);
begin
  (*
      public void doRows(Parse rows) {
          bind(rows.parts);
          super.doRows(rows.more);
      }
  *)
  bind(rows.parts);
  inherited doRows(rows.more);
end;


procedure TColumnFixture.doRow(row : TParse);
begin
  (*
    public void doRow(Parse row)
    {
      hasExecuted = false;
      try
      {
        reset();
        super.doRow(row);
        if(!hasExecuted)
        {
          execute();
        }
      }
      catch(Exception e)
      {
        exception(row.leaf(), e);
      }
    }
  *)
  hasExecuted := false;
  try
    reset();
    inherited doRow(row);
    if (not hasExecuted) then
      execute();
  except
    on e : Exception do
      doException(row.leaf(), e);
  end;
end;


procedure TColumnFixture.reset();
begin
  // about to process first cell of row
end;


procedure TColumnFixture.execute();
begin
  // about to process first method call of row
end;


procedure TColumnFixture.checkCell(cell : TParse; a : TObject {TTypeAdapter});
begin
  (*
    public void check(Parse cell, TypeAdapter a)
    {
    try
    {
       executeIfNeeded();
    }
    catch(Exception e)
    {
     exception(cell, e);
    }
     super.check(cell, a);
    }
  *)
  try
    executeIfNeeded();
  except
    on e : Exception do
      doException(cell, e);
  end;
  inherited checkCell(cell, a);
end;


procedure TColumnFixture.executeIfNeeded();
begin
  (*
   protected void executeIfNeeded() throws Exception
   {
    if(!hasExecuted)
    {
      hasExecuted = true;
      execute();
    }
   }
  *)
  if (not hasExecuted) then
  begin
    hasExecuted := true;
    execute();
  end;
end;

function TColumnFixture.getColumnBinding(idx : integer) : TBinding;
begin
  result := TBinding(FColumnBindings[idx]);
end;

procedure TColumnFixture.setColumnBinding(idx : integer;
  const Value : TBinding);
begin
  FColumnBindings[idx] := Value;
end;

function TColumnFixture.bindField(const theName : string) : TTypeAdapter;
begin
  result := TTypeAdapter.AdapterOn(self,
    TField.Create(getTargetClass, theName));
end;

function TColumnFixture.bindMethod(const theName : string) : TTypeAdapter;
begin
  result := TTypeAdapter.AdapterOn(self, TMethod.Create(getTargetClass, theName));
end;

constructor TColumnFixture.Create;
begin
  inherited Create;
  FColumnBindings := TObjectList.Create;
end;

destructor TColumnFixture.Destroy;
begin
  FColumnBindings.Free;
  inherited;
end;

end.
