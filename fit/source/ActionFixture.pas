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
// Derived from ActionFixture.java by Martin Chernenkoff, CHI Software Design
unit ActionFixture;

interface

uses
  Field,
  Method,
  TypeAdapter,
  Classes,
  Fixture,
  Parse,
  TypInfo,
  SysUtils;

type
  PShortString = ^ShortString;

  {$METHODINFO ON}
  TActionFixture = class(TFixture)
  protected
    cells : TParse;
    empty : array of TClass;
    procedure doCells(cells : TParse); override;
    function method(args : integer) : TMethod; overload;
    function method(test : string; args : integer) : TMethod; overload;
  published
    procedure Check;
    procedure Enter;
    procedure Press; virtual;
    procedure Start;
  end;

var
  actor : TFixture;

implementation

uses
  NoSuchMethodFitFailureException,
  FitFailureException;

{ TActionFixture }

procedure TActionFixture.doCells(cells : TParse);
var
  action : TMethod;
begin
  (*
      public void doCells(Parse cells) {
          this.cells = cells;
          try {
              Method action = getClass().getMethod(cells.text(), empty);
              action.invoke(this, empty);
          } catch (Exception e) {
              exception(cells, e);
          }
      }
  *)
  Self.cells := cells;
  try
    action := TMethod.Create(self.ClassType, cells.text());
    action.invoke(self, []);
  except
    on e : Exception do
      doException(cells, e);
  end;
end;

// TODO

procedure TActionFixture.Check;
var
  //  theMethod : TMethod;
  adapter : TTypeAdapter;
  checkValueCell : TParse;
begin
  (*
    public void check() throws Throwable
    {
      TypeAdapter adapter;
      Method theMethod = method(0);
      Class type = theMethod.getReturnType();
      try
      {
        adapter = TypeAdapter.on(actor, theMethod);
      }
      catch(Throwable e)
      {
        throw new FitFailureException("Can not parse return type: " + type.getName());
      }
      Parse checkValueCell = cells.more.more;
      if(checkValueCell == null)
        throw new FitFailureException("You must specify a value to check.");

      check(checkValueCell, adapter);
    }
  *)
  //  theMethod := method(0);
  //  Class type = theMethod.getReturnType();
  try
    // TODO I'm using properties, not methods to retrieve value for check operation
    //  adapter := TTypeAdapter.AdapterOn(actor, theMethod);
    adapter := TTypeAdapter.AdapterOn(actor, TField.Create(actor.ClassType, camel(cells.more.text))); //TODO
  except
    on e : Exception do
      raise TFitFailureException.Create('Can not parse return type: '); //TODO + type.getName());
  end;
  checkValueCell := cells.more.more;
  if (checkValueCell = nil) then
    raise TFitFailureException.Create('You must specify a value to check.');

  checkCell(checkValueCell, adapter);
end;

procedure TActionFixture.Enter;
var
  theMethod : TMethod;
  argumentCell : TParse;
  text : string;
  args : Variant;
begin
  (*
    public void enter() throws Exception
    {
      Method method = method(1);
      Class type = method.getParameterTypes()[0];
      final Parse argumentCell = cells.more.more;
      if(argumentCell == null)
        throw new FitFailureException("You must specify an argument.");
      String text = argumentCell.text();
      Object[] args;
      try
      {
        args = new Object[]{TypeAdapter.on(actor, type).parse(text)};
      }
      catch(NumberFormatException e)
      {
        throw new CouldNotParseFitFailureException(text, type.getName());
      }
      method.invoke(actor, args);
    }
  *)
  theMethod := method(1);
  //    Class type = method.getParameterTypes()[0];
  argumentCell := cells.more.more;
  if (argumentCell = nil) then
    raise TFitFailureException.Create('You must specify an argument.');
  text := argumentCell.text();
  args := TTypeAdapter.AdapterOn(actor, tkVariant).parse(text);
  theMethod.invoke(actor, [args]);
end;

procedure TActionFixture.Press;
(*
  public void press() throws Exception
  {
    method(0).invoke(actor);
  }
*)
begin
  method(0).invoke(actor, []);
end;

procedure TActionFixture.Start;
var
  fixture : TParse;
begin
  (*
    public void start() throws Throwable
    {
      Parse fixture = cells.more;
      if(fixture == null)
        throw new FitFailureException("You must specify a fixture to start.");
      actor = loadFixture(fixture.text());
    }
  *)
  fixture := cells.more;
  if (fixture = nil) then
    raise TFitFailureException.Create('You must specify a fixture to start.');
  actor := loadFixture(fixture.text());
end;

function TActionFixture.method(args : integer) : TMethod;
var
  methodCell : TParse;
begin
  (*
    protected Method method(int args) throws NoSuchMethodException
    {
      final Parse methodCell = cells.more;
      if(methodCell == null)
        throw new FitFailureException("You must specify a method.");
      return method(camel(methodCell.text()), args);
    }
  *)
  methodCell := cells.more;
  if (methodCell = nil) then
    raise TFitFailureException.Create('You must specify a method.');
  result := method(camel(methodCell.text()), args);
end;

// TODO

function TActionFixture.method(test : string; args : integer) : TMethod;
begin
  (*
    protected Method method(String test, int args) throws NoSuchMethodException
    {
      if(actor == null)
        throw new FitFailureException("You must start a fixture using the 'start' keyword.");
      Method methods[] = actor.getClass().getMethods();
      Method result = null;
      for(int i = 0; i < methods.length; i++)
      {
        Method m = methods[i];
        if(m.getName().equals(test) && m.getParameterTypes().length == args)
        {
          if(result == null)
          {
            result = m;
          }
          else
          {
            throw new FitFailureException("You can only have one " + test + "(arg) method in your fixture.");
          }
        }
      }
      if(result == null)
      {
        throw new NoSuchMethodFitFailureException(test);
      }
      return result;
    }
  *)
  if (actor = nil) then
    raise TFitFailureException.Create('You must start a fixture using the ''start'' keyword.');
  // MethodAddress doesn't support method overloading
  if not Assigned(actor.MethodAddress(test)) then
    raise TNoSuchMethodFitFailureException.Create(test);
  Result := TMethod.Create(actor.ClassType, test);
end;

initialization
  RegisterClass(TActionFixture);

finalization
  UnRegisterClass(TActionFixture);

end.
