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
unit CouldNotParseFitFailureException;

interface

uses
  FitFailureException;

type
  TCouldNotParseFitFailureException = class(TFitFailureException)
  public
    constructor Create(text : string; _type : string);
  end;

implementation

{ TCouldNotParseFitFailureException }

constructor TCouldNotParseFitFailureException.Create(text, _type : string);
begin
  inherited Create('Could not parse: ' + text + ' expected type: ' + _type + '.');
end;

end.

