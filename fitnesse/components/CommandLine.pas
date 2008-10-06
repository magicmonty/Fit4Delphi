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
unit CommandLine;

interface

uses
  StrUtils,
  IniFiles,
  Classes;

type
  TOption = class
  protected
    argumentIndex : Integer;
    argumentNames : TStringList;
    argumentValues : TStringList;
    procedure parseArgumentDescriptor(arguments : string);
  public
    active : boolean;
    procedure addArgument(value : string);
    function getArgument(argName : string) : string;
    function needsMoreArguments() : boolean;
    function split(value : string) : TStringList;
  end;

  TCommandLine = class(TOption)
  private
    possibleOptions : THashedStringList;
    function GetOption(argName : string) : TOption;
  public
    constructor Create(optionDescriptor : string);
    destructor Destroy; override;
    function parse(args : TStringList) : boolean;
    function hasOption(optionName : string) : boolean;
    function getOptionArgument(optionName : string; argName : string) : string;
  end;

implementation

uses
  Parse,
  Matcher,
  SysUtils;

const
    optionPattern = '\[-(\w+)(( \w+)*)\]';
//    optionPattern = '\[-(\w+)((?: \w+)*)\]';

{ TCommandLine }

constructor TCommandLine.Create(optionDescriptor : string);
var
  optionEndIndex : integer;
  option : TOption;
  remainder : string;
  matcher : TRegExpr;
  found : Boolean;
begin
  inherited Create;
  possibleOptions := THashedStringList.Create;

  optionEndIndex := 0;
  matcher := TRegExpr.Create;
  matcher.Expression := optionPattern;
  matcher.InputString := optionDescriptor;
  found := matcher.Exec;
  while found do
  begin
    option := TOption.Create;
    option.parseArgumentDescriptor(matcher.Match[2]);
    possibleOptions.AddObject(matcher.Match[1], option);
    optionEndIndex := matcher.MatchPos[matcher.SubExprMatchCount] + matcher.MatchLen[matcher.SubExprMatchCount];
    found := matcher.ExecNext;
  end;
  remainder := substring(optionDescriptor, optionEndIndex);
  parseArgumentDescriptor(remainder);
end;

destructor TCommandLine.Destroy();
begin
  possibleOptions.Free;
  inherited Destroy;
end;

function TCommandLine.GetOption(argName : string) : TOption;
var
  index : Integer;
begin
  index := possibleOptions.IndexOf(argName);
  if index <> -1 then
    Result := possibleOptions.Objects[index] as TOption
  else
    Result := nil;
end;

function TCommandLine.parse(args : TStringList) : boolean;
var
  arg : string;
  currentOption : TOption;
  successfulParse : boolean;
  i : integer;
  argName : string;
begin
  successfulParse := true;
  currentOption := self;
  i := 0;
  while (successfulParse and (i < args.Count)) do
  begin
    arg := args[i];

    if ((currentOption <> self) and not currentOption.needsMoreArguments()) then
    begin
      currentOption := self;
    end;

    if (startsWith(arg, '-')) then
    begin
      if (currentOption.needsMoreArguments() and (currentOption <> self)) then
      begin
        successfulParse := false;
      end
      else
      begin
        argName := substring(arg, 1);
        currentOption := GetOption(argName);
        if (currentOption <> nil) then
          currentOption.active := true
        else
          successfulParse := false;
      end;
    end
    else
      if (currentOption.needsMoreArguments()) then
        currentOption.addArgument(arg)
      else
        successfulParse := false;
    inc(i);
  end;

  if (successfulParse and currentOption.needsMoreArguments()) then
    successfulParse := false;
  result := successfulParse;
end;

function TCommandLine.hasOption(optionName : string) : boolean;
var
  option : TOption;
begin
  option := GetOption(optionName);

  if (option = nil) then
    result := false
  else
    result := option.active;
end;

function TCommandLine.getOptionArgument(optionName : string; argName : string) : string;
var
  option : TOption;
begin
  option := GetOption(optionName);

  if (option = nil) then
    result := ''
  else
    result := option.getArgument(argName);
end;

//////////////////////////////////////////////////

procedure TOption.parseArgumentDescriptor(arguments : string);
var
  tokens : TStringList;
begin
  tokens := split(arguments);
  argumentNames := tokens;
  argumentValues := TStringList.Create; // = new String[argumentNames.length];
end;

function TOption.getArgument(argName : string) : string;
var
  i : Integer;
  requiredArgumentName : string;
begin
  for i := 0 to argumentNames.Count - 1 do
  begin
    requiredArgumentName := argumentNames[i];
    if (requiredArgumentName = argName) then
    begin
      Result := argumentValues[i];
      exit;
    end;
  end;
  Result := '';
end;

function TOption.needsMoreArguments() : boolean;
begin
  Result := argumentIndex < argumentNames.Count;
end;

procedure TOption.addArgument(value : string);
begin
  argumentValues.Add({[argumentIndex] := }value);
  Inc(argumentIndex);
end;

function TOption.split(value : string) : TStringList;
var
  tokens : TStringList;
  token : string;
  usableTokens : TStringList;
  i : Integer;
begin
  tokens := TStringList.Create;
  tokens.Text := StringReplace(value, ' ', #13#10, [rfReplaceAll]);
  usableTokens := TStringList.Create;
  for i := 0 to tokens.Count - 1 do
  begin
    token := tokens[i];
    if (Length(token) > 0) then
      usableTokens.add(token);
  end;
  Result := usableTokens;
  tokens.Free;
end;

end.

