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
{$H+}
unit StringTokenizer;

interface

uses
  Classes;

type
  TStringTokenizer = class(TStringList)
  private
    FSeparator : string;
  protected
    procedure SetTextStr(const Value : string); override;
  public
    constructor Create(const Separator : string = ' ');
  end;

implementation

uses
  SysUtils;

{ TStringTokenizer }

constructor TStringTokenizer.Create(const Separator : string);
begin
  FSeparator := Separator;
end;

procedure TStringTokenizer.SetTextStr(const Value : string);
var
  v : string;
begin
  v := StringReplace(Value, FSeparator, #13#10, [rfReplaceAll]);
  inherited SetTextStr(v);
end;

end.

