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
unit CommandLineTest;

interface

uses
  StrUtils,
  SysUtils,
  StringTokenizer,
  TestFramework,
  CommandLine;

type
  TCommandLineTest = class(TTestCase)
  private
    options : TCommandLine;
    function createOptionsAndParse(validOptions : string; enteredOptions : string) : boolean;
  published
    procedure testSimpleParsing();
    procedure testOneRequiredArgument();
    procedure testThreeRequiredArguments();
    procedure testOneSimpleOption();
    procedure testOptionWithArgument();
    procedure testInvalidOption();
    procedure testCombo();
  end;

implementation

uses
  Classes;

{ TCommandLineTest }

procedure TCommandLineTest.testSimpleParsing();
begin
  CheckTrue(createOptionsAndParse('', ''));
  CheckFalse(createOptionsAndParse('', 'blah'));
end;

procedure TCommandLineTest.testOneRequiredArgument();
begin
  CheckFalse(createOptionsAndParse('arg1', ''));
  CheckTrue(createOptionsAndParse('arg1', 'blah'));
  CheckEquals('blah', options.getArgument('arg1'));
end;

procedure TCommandLineTest.testThreeRequiredArguments();
begin
  CheckTrue(createOptionsAndParse('arg1 arg2 arg3', 'tic tac toe'));
  CheckEquals('tic', options.getArgument('arg1'));
  CheckEquals('tac', options.getArgument('arg2'));
  CheckEquals('toe', options.getArgument('arg3'));
end;

procedure TCommandLineTest.testOneSimpleOption();
begin
  CheckTrue(createOptionsAndParse('[-opt1]', ''));
  CheckFalse(options.hasOption('opt1'));
  CheckTrue(createOptionsAndParse('[-opt1]', '-opt1'));
  CheckTrue(options.hasOption('opt1'));
end;

procedure TCommandLineTest.testOptionWithArgument();
var
  argument : string;
begin
  CheckFalse(createOptionsAndParse('[-opt1 arg]', '-opt1'));
  CheckTrue(createOptionsAndParse('[-opt1 arg]', '-opt1 blah'));
  CheckTrue(options.hasOption('opt1'));
  argument := options.getOptionArgument('opt1', 'arg');
  CheckNotEquals('', argument);
  CheckEquals('blah', argument);
end;

procedure TCommandLineTest.testInvalidOption();
begin
  CheckFalse(createOptionsAndParse('', '-badArg'));
end;

procedure TCommandLineTest.testCombo();
var
  descriptor : string;
begin
  descriptor := '[-opt1 arg1 arg2] [-opt2 arg1] [-opt3] arg1 arg2';
  CheckFalse(createOptionsAndParse(descriptor, ''));
  CheckFalse(createOptionsAndParse(descriptor, 'a'));
  CheckFalse(createOptionsAndParse(descriptor, '-opt1 a b c'));
  CheckFalse(createOptionsAndParse(descriptor, '-opt2 a b'));
  CheckFalse(createOptionsAndParse(descriptor, '-opt2 -opt3 a b'));
  CheckFalse(createOptionsAndParse(descriptor, '-opt1 a -opt2 b -opt3 c d'));
  CheckFalse(createOptionsAndParse(descriptor, '-opt1 a b -opt2 c -opt3 d e f'));
  CheckTrue(createOptionsAndParse(descriptor, 'a b'));
  CheckTrue(createOptionsAndParse(descriptor, '-opt3 a b'));
  CheckTrue(createOptionsAndParse(descriptor, '-opt2 a b c'));
  CheckTrue(createOptionsAndParse(descriptor, '-opt1 a b c d'));
  CheckTrue(createOptionsAndParse(descriptor, '-opt1 a b -opt2 c d e'));
  CheckTrue(createOptionsAndParse(descriptor, '-opt1 a b -opt2 c -opt3 d e'));
  CheckTrue(options.hasOption('opt1'));
  CheckEquals('a', options.getOptionArgument('opt1', 'arg1'));
  CheckEquals('b', options.getOptionArgument('opt1', 'arg2'));
  CheckTrue(options.hasOption('opt2'));
  CheckEquals('c', options.getOptionArgument('opt2', 'arg1'));
  CheckTrue(options.hasOption('opt3'));
  CheckEquals('d', options.getArgument('arg1'));
  CheckEquals('e', options.getArgument('arg2'));
end;

function TCommandLineTest.createOptionsAndParse(validOptions : string; enteredOptions : string) : boolean;
var
  args : TStringList;
begin
  options := TCommandLine.Create(validOptions);
  args := TOption.Create().split(enteredOptions);
  result := options.parse(args);
end;

initialization

  TestFramework.RegisterTest(TCommandLineTest.Suite);

end.

