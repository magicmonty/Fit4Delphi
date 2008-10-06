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
{$H+}
unit PrintStream;

interface

uses
  OutputStream;

type
  TPrintStream = class(TOutputStream)
  public
    procedure print(s : string);
    procedure println(s : string = '');
    constructor Create(s : String); overload;
    constructor Create(s : TOutputStream); overload;
  end;

implementation

uses
  Classes;

{ TPrintStream }

constructor TPrintStream.Create(s : String);
begin
  stream := TStringStream.Create(s);
end;

constructor TPrintStream.Create(s: TOutputStream);
begin
  stream := s.stream; //TODO???
end;

procedure TPrintStream.print(s : string);
begin
  stream.Write(s[1], Length(s));
end;

procedure TPrintStream.println(s : string = '');
begin
  print(s + #13#10);
end;

end.

