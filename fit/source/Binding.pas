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
{$H+}
unit Binding;

interface

uses
  Method,
  Field,
  RegExpr,
  Fixture,
  TypeAdapter,
  Parse;

const
  //TODO  methodPattern = '(.+)(?:\(\)|\?|!)';
  methodPattern = '(.+)(\(\)|\?|!)';
  fieldPattern = '=?([^=]+)=?';

type
  TBinding = class
  private
    class function makeAdapter(fixture : TFixture; name : string) : TTypeAdapter;
    class function makeAdapterForField(name : string; fixture : TFixture) : TTypeAdapter;
    class function makeAdapterForMethod(name : string;
      fixture : TFixture; matcher : TRegExpr) : TTypeAdapter;
    class function findField(fixture : TFixture; simpleName : string) : TField;
    class function findMethod(fixture : TFixture; simpleName : string) : TMethod;
  public
    adapter : TTypeAdapter;

    procedure doCell(fixture : TFixture; cell : TParse); virtual; abstract;
    constructor Create();
    class function doCreate(fixture : TFixture; name : string) : TBinding;
  end;

  TSaveBinding = class(TBinding)
  public
    procedure doCell(fixture : TFixture; cell : TParse); override;
  end;

  TRecallBinding = class(TBinding)
  public
    procedure doCell(fixture : TFixture; cell : TParse); override;
  end;

  TSetBinding = class(TBinding)
  public
    procedure doCell(fixture : TFixture; cell : TParse); override;
  end;

  TQueryBinding = class(TBinding)
  public
    procedure doCell(fixture : TFixture; cell : TParse); override;
  end;

  TNullBinding = class(TBinding)
  public
    procedure doCell(fixture : TFixture; cell : TParse); override;
  end;

implementation

uses
  FitFailureException,
  NoSuchMethodFitFailureException,
  NoSuchFieldFitFailureException,
  ColumnFixture,
  StrUtils,
  GracefulNamer,
  SysUtils,
  TypInfo;

class function TBinding.doCreate(fixture : TFixture; name : string) : TBinding;
var
  matcher : TRegExpr;
begin
  (*
   public static Binding create(Fixture fixture, String name) throws Throwable
   {
    Binding binding = null;

    if(name.startsWith("="))
     binding = new SaveBinding();
    else if(name.endsWith("="))
     binding = new RecallBinding();
    else if(methodPattern.matcher(name).matches())
     binding = new QueryBinding();
    else if(fieldPattern.matcher(name).matches())
     binding = new SetBinding();

    if(binding == null)
     binding = new NullBinding();
    else
     binding.adapter = makeAdapter(fixture, name);

    return binding;
   }
  *)
  Result := nil;
  matcher := TRegExpr.Create;
  if AnsiStartsStr('=', name) then
    Result := TSaveBinding.Create()
  else
    if AnsiEndsStr('=', name) then
      Result := TRecallBinding.Create()
    else
    begin
      matcher.Expression := methodPattern;
      if matcher.Exec(name) then
        Result := TQueryBinding.Create()
      else
      begin
        matcher.Expression := fieldPattern;
        if (matcher.Exec(name)) then
          Result := TSetBinding.Create();
      end;
    end;
  matcher.Free;
  if (Result = nil) then
    Result := TNullBinding.Create()
  else
    Result.adapter := makeAdapter(fixture, name);
end;

class function TBinding.makeAdapter(fixture : TFixture; name : string) : TTypeAdapter;
var
  matcher : TRegExpr;
begin
  (*
   private static TypeAdapter makeAdapter(Fixture fixture, String name) throws Throwable
   {
    Matcher matcher = methodPattern.matcher(name);
    if(matcher.find())
     return makeAdapterForMethod(name, fixture, matcher);
    else
     return makeAdapterForField(name, fixture);
   }
  *)
  matcher := TRegExpr.Create;
  matcher.Expression := methodPattern;
  if matcher.Exec(name) then
    Result := makeAdapterForMethod(name, fixture, matcher)
  else
    Result := makeAdapterForField(name, fixture);
  matcher.Free;
end;

class function TBinding.makeAdapterForField(name : string; fixture : TFixture) : TTypeAdapter;
var
  field : TField;
  simpleName : string;
  fieldName : string;
  matcher : TRegExpr;
  PropInfo : PPropInfo;
begin
  (*
   private static TypeAdapter makeAdapterForField(String name, Fixture fixture)
   {
    Field field = null;
    if(GracefulNamer.isGracefulName(name))
    {
     String simpleName = GracefulNamer.disgrace(name).toLowerCase();
     field = findField(fixture, simpleName);
    }
    else
    {
     try
     {
      Matcher matcher = fieldPattern.matcher(name);
      matcher.find();
      String fieldName = matcher.group(1);
      field = fixture.getTargetClass().getField(fieldName);
     }
     catch(NoSuchFieldException e)
     {
     }
    }

    if(field == null)
     throw new NoSuchFieldFitFailureException(name);
    return TypeAdapter.on(fixture, field);
   }
  *)
  field := nil;
  if TGracefulNamer.isGracefulName(name) then
  begin
    simpleName := LowerCase(TGracefulNamer.disgrace(name));
    field := findField(fixture, simpleName);
  end
  else
  begin
    matcher := TRegExpr.Create;
    matcher.Expression := fieldPattern;
    matcher.Exec(name);
    fieldName := matcher.Match[1];
    matcher.Free;
    PropInfo := GetPropInfo(fixture.getTargetClass(), fieldName);
    if PropInfo <> nil then
      if PropInfo.Name = fieldName then // Added to pass BindingTests
        field := TField.Create(fixture.getTargetClass(), fieldName);
  end;

  if (field = nil) then
    raise TNoSuchFieldFitFailureException.Create(name);
  Result := TTypeAdapter.AdapterOn(fixture, field);
end;

class function TBinding.makeAdapterForMethod(name : string; fixture : TFixture; matcher : TRegExpr) : TTypeAdapter;
var
  method : TMethod;
  simpleName : string;
  methodName : string;
begin
  (*
   private static TypeAdapter makeAdapterForMethod(String name, Fixture fixture, Matcher matcher)
   {
    Method method = null;
    if(GracefulNamer.isGracefulName(name))
    {
     String simpleName = GracefulNamer.disgrace(name).toLowerCase();
     method = findMethod(fixture, simpleName);
    }
    else
    {
     try
     {
      String methodName = matcher.group(1);
      method = fixture.getTargetClass().getMethod(methodName, new Class[]{});
     }
     catch(NoSuchMethodException e)
     {
     }
    }

    if(method == null)
     throw new NoSuchMethodFitFailureException(name);
    return TypeAdapter.on(fixture, method);
   }
  *)
  method := nil;
  if (TGracefulNamer.isGracefulName(name)) then
  begin
    simpleName := LowerCase(TGracefulNamer.disgrace(name));
    method := findMethod(fixture, simpleName);
  end
  else
  begin
    methodName := matcher.Match[1];
    if Assigned(fixture.getTargetClass().MethodAddress(methodName)) then
    begin
      if fixture.getTargetClass().MethodName(fixture.getTargetClass().MethodAddress(methodName)) = methodName then // Added to pass BindingTests
        method := TMethod.Create(fixture.getTargetClass(), methodName);
    end;
  end;

  if (method = nil) then
    raise TNoSuchMethodFitFailureException.Create(name);
  Result := TTypeAdapter.AdapterOn(fixture, method);
end;

class function TBinding.findField(fixture : TFixture; simpleName : string) : TField;
var
  PropInfo : PPropInfo;
begin
  (*
   private static Field findField(Fixture fixture, String simpleName)
   {
    Field[] fields = fixture.getTargetClass().getFields();
    Field field = null;
    for(int i = 0; i < fields.length; i++)
    {
     Field possibleField = fields[i];
     if(simpleName.equals(possibleField.getName().toLowerCase()))
     {
      field = possibleField;
      break;
     }
    }
    return field;
   }
  *)
  Result := nil;
  PropInfo := GetPropInfo(fixture.getTargetClass(), simpleName);
  if PropInfo <> nil then
    Result := TField.Create(fixture.getTargetClass(), PropInfo.Name); // Added to pass BindingTests
end;

class function TBinding.findMethod(fixture : TFixture; simpleName : string) : TMethod;
begin
  (*
   private static Method findMethod(Fixture fixture, String simpleName)
   {
    Method[] methods = fixture.getTargetClass().getMethods();
    Method method = null;
    for(int i = 0; i < methods.length; i++)
    {
     Method possibleMethod = methods[i];
     if(simpleName.equals(possibleMethod.getName().toLowerCase()))
     {
      method = possibleMethod;
      break;
     }
    }
    return method;
   }
  *)
  Result := nil;
  if Assigned(fixture.getTargetClass().MethodAddress(simpleName)) then
    Result := TMethod.Create(fixture.getTargetClass(),
      fixture.getTargetClass().MethodName(fixture.getTargetClass().MethodAddress(simpleName))); // Added to pass BindingTests
end;

constructor TBinding.Create;
begin

end;

{ TSaveBinding }

procedure TSaveBinding.doCell(fixture : TFixture; cell : TParse);
var
  symbolValue : string;
  symbolName : string;
begin
  (*		public void doCell(Fixture fixture, Parse cell)
    {
     try
     {
      //TODO-MdM hmm... somehow this needs to regulated by the fixture.
      if(fixture instanceof ColumnFixture)
       ((ColumnFixture) fixture).executeIfNeeded();
      String symbolValue = adapter.get().toString();
      String symbolName = cell.text();
      Fixture.setSymbol(symbolName, symbolValue);
      cell.addToBody(Fixture.gray(" = " + symbolValue));
     }
     catch(Exception e)
     {
      fixture.exception(cell, e);
     }
    }
  *)
  try
    //TODO-MdM hmm... somehow this needs to regulated by the fixture.
    if (fixture is TColumnFixture) then
      (fixture as TColumnFixture).executeIfNeeded();
    symbolValue := adapter.get();
    symbolName := cell.text();
    Fixture.setSymbol(symbolName, symbolValue);
    cell.addToBody(TFixture.gray(' = ' + symbolValue));
  except
    on e : Exception do
      fixture.doException(cell, e);
  end;

end;

{ TRecallBinding }

procedure TRecallBinding.doCell(fixture : TFixture; cell : TParse);
var
  value : string;
  symbolName : string;
begin
  (*
    public void doCell(Fixture fixture, Parse cell) throws Exception
    {
     String symbolName = cell.text();
     String value = (String) Fixture.getSymbol(symbolName);
     if(value == null)
      fixture.exception(cell, new FitFailureException("No such symbol: " + symbolName));
     else {
      adapter.set(adapter.parse(value));
      cell.addToBody(Fixture.gray(" = " + value));
     }
    }
  *)
  symbolName := cell.text();
  value := Fixture.getSymbol(symbolName);
  if (value = '') then
    fixture.doException(cell, TFitFailureException.Create('No such symbol: ' + symbolName))
  else
  begin
    adapter.doSet(adapter.parse(value));
    cell.addToBody(TFixture.gray(' = ' + value));
  end;
end;

{ TSetBinding }

procedure TSetBinding.doCell(fixture : TFixture; cell : TParse);
begin
  (*
   public static class SetBinding extends Binding
   {
    public void doCell(Fixture fixture, Parse cell) throws Throwable
    {
     if("".equals(cell.text()))
      fixture.handleBlankCell(cell, adapter);
     adapter.set(adapter.parse(cell.text()));
    }
   }
  *)
  if (cell.text() = '') then
    fixture.handleBlankCell(cell, adapter);
  adapter.doSet(adapter.parse(cell.text()));
end;

{ TQueryBinding }

procedure TQueryBinding.doCell(fixture : TFixture; cell : TParse);
begin
  (*
 public static class QueryBinding extends Binding
 {
  public void doCell(Fixture fixture, Parse cell)
  {
   fixture.check(cell, adapter);
  }
 }
  *)
  fixture.checkCell(cell, adapter);
end;

{ TNullBinding }

procedure TNullBinding.doCell(fixture : TFixture; cell : TParse);
begin
  (*
   public static class NullBinding extends Binding
   {
    public void doCell(Fixture fixture, Parse cell)
    {
     fixture.ignore(cell);
    }
   }
  *)
  fixture.ignore(cell);
end;

end.
