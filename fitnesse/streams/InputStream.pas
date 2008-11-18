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
unit InputStream;

interface

uses
  classes;

type
  TInputStream = class(TObject)
  public
    stream : TStream;
  public
    function isEof() : Boolean; virtual;
    destructor Destroy; override;
  end;

implementation

destructor TInputStream.Destroy;
begin
  stream.Free;
  inherited;
end;

function TInputStream.isEof: Boolean;
var
  LPos: Int64;
Begin
  LPos := stream.Seek(0,soFromCurrent);
  Result := LPos>=stream.Seek(0,soFromEnd);
  stream.Seek(LPos,soFromBeginning);

//  Result := stream.stream.Position >= stream.stream.Size;
end;

end.
