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
unit WikiRunner;

interface

uses
  Fixture,
  FileRunner, Classes;

type
  TWikiRunner = class(TFileRunner)
  protected
    class procedure main(args : TStringList);
    procedure process(); override;
  end;

implementation

uses
  SysUtils,
  Parse;

{ TWikiRunner }

class procedure TWikiRunner.main(args : TStringList);
var
  theRunner : TWikiRunner;
begin
  theRunner := TWikiRunner.Create;
  theRunner.run(args);
  theRunner.Free;
end;

procedure TWikiRunner.process;
var
  tags : TStringList;
begin
  tags := TStringList.Create;
  try
    tags.Add('wiki');
    tags.Add('table');
    tags.Add('tr');
    tags.Add('td');
    try
      tables := TParse.Create(input.text, tags); // look for wiki tag enclosing tables
      fixture.doTables(tables.parts); // only do tables within that tag
    except
      on e : Exception do
        doException(e);
    end;
    tables.print(output);
  finally
    tags.Free;
  end;
end;

end.

