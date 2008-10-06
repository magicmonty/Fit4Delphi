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
unit CachingResultFormatter;

interface

uses
  ContentBuffer,
  ResultFormatter,
  classes,
  InputStream,
  PageResult,
  Counts,
  ResultHandler;

type
  TCachingResultFormatter = class(TInterfacedObject, TResultFormatter)
  private
    buffer : TContentBuffer;
    subHandlers : TList;
  public
    constructor Create;
    destructor Destroy; override;
    function getByteCount() : Integer;
    function getResultStream() : TInputStream;
    procedure acceptResult(result : TPageResult);
    procedure acceptFinalCount(count : TCounts);
    procedure addHandler(handler : TResultHandler);
    procedure cleanUp;
  end;

implementation

uses
  ByteArrayOutputStream,
  FitProtocol;

constructor TCachingResultFormatter.Create;
begin
  subHandlers := TList.Create;
  buffer := TContentBuffer.Create('.results');
end;

destructor TCachingResultFormatter.Destroy;
begin
  buffer.Free;
  subHandlers.Free;
end;

procedure TCachingResultFormatter.acceptResult(result : TPageResult);
var
  output : TByteArrayOutputStream;
  i : Integer;
begin
  output := TByteArrayOutputStream.Create();
  TFitProtocol.writeData(result.toString() + #13#10, output);
  buffer.append(output.toByteArray());

  for i := 0 to subHandlers.Count - 1 do
    TResultHandler(subHandlers[i]).acceptResult(result);
end;

procedure TCachingResultFormatter.acceptFinalCount(count : TCounts);
var
  output : TByteArrayOutputStream;
  i : Integer;
begin
  output := TByteArrayOutputStream.Create();
  TFitProtocol.writeCounts(count, output);
  buffer.append(output.toByteArray());

  for i := 0 to subHandlers.Count - 1 do
    TResultHandler(subHandlers[i]).acceptFinalCount(count);
end;

function TCachingResultFormatter.getByteCount() : Integer;
begin
  Result := buffer.getSize();
end;

function TCachingResultFormatter.getResultStream() : TInputStream;
begin
  Result := buffer.getNonDeleteingInputStream();
end;

procedure TCachingResultFormatter.cleanUp();
begin
  buffer.delete();
end;

procedure TCachingResultFormatter.addHandler(handler : TResultHandler);
begin
  subHandlers.add(Pointer(handler));
end;

end.

