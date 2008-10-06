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
unit ContentBufferTest;

interface

uses
  TestFramework;

type
  TContentBufferTest = class(TTestCase)
  protected
    procedure TearDown(); override;
  published
    procedure testName();
    procedure testSimpleUsage();
    procedure testGettingInputStream();
    procedure testDelete();
    procedure testUnicode();
  end;

implementation

{ TContentBufferTest }

uses
  ContentBuffer,
  StrUtils,
  InputStream,
  StreamReader,
  FileUnit;

function startsWith(str, substr : string) : Boolean;
begin
  Result := LeftStr(str, Length(substr)) = substr;
end;

function endsWith(str, substr : string) : Boolean;
begin
  Result := RightStr(str, Length(substr)) = substr;
end;

procedure TContentBufferTest.tearDown();
begin
  //  System.gc();
end;

procedure TContentBufferTest.testName();
var
  name : string;
  buffer : TContentBuffer;
begin
  buffer := TContentBuffer.Create();
  try
    name := buffer.getFile().getName();
    checkTrue(startsWith(name, 'FitNesse-'));
    checkTrue(endsWith(name, '.tmp'));

    name := TContentBuffer.Create('.html').getFile().getName();
    checkTrue(startsWith(name, 'FitNesse-'));
    checkTrue(endsWith(name, '.html'));
  finally
    buffer.Free;
  end;
end;

procedure TContentBufferTest.testSimpleUsage();
var
  buffer : TContentBuffer;
begin
  buffer := TContentBuffer.Create();
  try
    buffer.append('some content');
    CheckEquals('some content', buffer.getContent());
  finally
    buffer.Free;
  end;
end;

procedure TContentBufferTest.testGettingInputStream();
var
  bytes : integer;
  buffer : TContentBuffer;
  input : TInputStream;
  content : string;
begin
  buffer := TContentBuffer.Create();
  try
    buffer.append('some content');
    bytes := buffer.getSize();
    CheckEquals(12, bytes);
    input := buffer.getInputStream();
    content := TStreamReader.Create(input).read(12);
    CheckEquals('some content', content);
  finally
    buffer.Free;
  end;
end;

procedure TContentBufferTest.testDelete();
var
  buffer : TContentBuffer;
  f : TFile;
begin
  buffer := TContentBuffer.Create();
  try
    f := buffer.getFile();
    checkTrue(f.exists());
    buffer.delete();
    CheckFalse(f.exists());
  finally
    buffer.Free;
  end;
end;

//TODO

procedure TContentBufferTest.testUnicode();
var
  buffer : TContentBuffer;
begin
  buffer := TContentBuffer.Create();
  try
    buffer.append('??¾š');
    CheckEquals('??¾š', TStreamReader.Create(buffer.getInputStream()).read(buffer.getSize()));
  finally
    buffer.Free;
  end;
end;

initialization

  TestFramework.RegisterTest(TContentBufferTest.Suite);

end.

