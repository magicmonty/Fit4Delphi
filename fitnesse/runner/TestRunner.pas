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
unit TestRunner;

interface

uses
  FitServer,
  TestRunnerFixtureListener,
  CachingResultFormatter,
  Classes,
  Counts,
  PageResult,
  PrintStream;

type
  TTestRunner = class
  private
    host : string;
    port : Integer;
    pageName : string;
    fitServer : TFitServer;
    Foutput : TPrintStream;
    debug : boolean;
    suiteFilter : string; //= null;
    procedure usage();
    procedure processClasspathDocument();
    procedure finalCount();
  public
    fixtureListener : TTestRunnerFixtureListener;
    handler : TCachingResultFormatter;
    formatters : TList; //= new LinkedList<FormattingOption>();
    verbose : boolean;
    usingDownloadedPaths : boolean; //= true;
    constructor Create(); overload;
    constructor Create(output : TPrintStream); overload;
    class procedure main(args : TStringList);
    procedure run(args : TStringList);
    function exitCode() : Integer;
    procedure args(args : TStringList);
    function makeHttpRequest() : string;
    procedure doFormatting();
    class procedure addItemsToClasspath(classpathItems : string);
    function getCounts() : TCounts;
    procedure acceptResults(results : TPageResult);
    class procedure addUrlToClasspath(u : string {URL});

  end;

implementation

uses
  SysUtils,
  FormattingOption,
  CommandLine,
  StandardResultHandler;

constructor TTestRunner.Create();
begin
  Create(nil); //TODO  //		this(System.out);
end;

constructor TTestRunner.Create(output : TPrintStream);
begin
  Foutput := output;
  formatters := TList.Create;
  handler := TCachingResultFormatter.Create();
  usingDownloadedPaths := true;
end;

class procedure TTestRunner.main(args : TStringList);
var
  runner : TTestRunner;
begin
  runner := TTestRunner.Create();
  runner.run(args);
  Halt(runner.exitCode());
end;

procedure TTestRunner.args(args : TStringList);
var
  commandLine : TCommandLine;
begin
  commandLine :=
    TCommandLine.Create('[-debug] [-v] [-results file] [-html file] [-xml file] [-nopath] [-suiteFilter filter] host port pageName');
  if (not commandLine.parse(args)) then
    usage();

  host := commandLine.getArgument('host');
  port := StrToInt(commandLine.getArgument('port'));
  pageName := commandLine.getArgument('pageName');

  if (commandLine.hasOption('debug')) then
    debug := true;
  if (commandLine.hasOption('v')) then
  begin
    verbose := true;
    handler.addHandler(TStandardResultHandler.Create(Foutput));
  end;
  if (commandLine.hasOption('nopath')) then
    usingDownloadedPaths := false;
  if (commandLine.hasOption('results')) then
    formatters.add(TFormattingOption.Create('raw', commandLine.getOptionArgument('results', 'file'), Foutput, host,
      port,
      pageName));
  if (commandLine.hasOption('html')) then
    formatters.add(TFormattingOption.Create('html', commandLine.getOptionArgument('html', 'file'), Foutput, host,
      port,
      pageName));
  if (commandLine.hasOption('xml')) then
    formatters.add(TFormattingOption.Create('xml', commandLine.getOptionArgument('xml', 'file'), Foutput, host, port,
      pageName));

  if (commandLine.hasOption('suiteFilter')) then
    suiteFilter := commandLine.getOptionArgument('suiteFilter', 'filter');
end;

procedure TTestRunner.usage();
begin
  WriteLn('usage: java fitnesse.runner.TestRunner [options] host port page-name');
  WriteLn(#9'-v '#9'verbose: prints test progress to stdout');
  WriteLn(#9'-results <filename|''stdout''>'#9'save raw test results to a file or dump to standard output');
  WriteLn(#9'-html <filename|''stdout''>'#9'format results as HTML and save to a file or dump to standard output');
  WriteLn(#9'-debug '#9'prints FitServer protocol actions to stdout');
  WriteLn(#9'-nopath '#9'prevents downloaded path elements from being added to classpath');
  System.ExitCode := -1;
  Halt;
end;

procedure TTestRunner.run(args : TStringList);
begin
  self.args(args);
  fitServer := TFitServer.Create(host, port, debug);
  fixtureListener := TTestRunnerFixtureListener.Create(self);
  fitServer.fixtureListener := fixtureListener;
  fitServer.establishConnection(makeHttpRequest());
  fitServer.validateConnection();
  if (usingDownloadedPaths) then
    processClasspathDocument();
  fitServer.process();
  finalCount();
  fitServer.closeConnection();
  fitServer.exit();
  doFormatting();
  handler.cleanUp();
end;

procedure TTestRunner.processClasspathDocument();
var
  classpathItems : string;
begin
  classpathItems := fitServer.readDocument();
  if (verbose) then
    Foutput.println('Adding to classpath: ' + classpathItems);
  addItemsToClasspath(classpathItems);
end;

procedure TTestRunner.finalCount();
begin
  handler.acceptFinalCount(fitServer.getCounts());
end;

function TTestRunner.exitCode() : Integer;
begin
  if (fitServer = nil) then
    Result := -1
  else
    Result := fitServer.exitCode();
end;

function TTestRunner.makeHttpRequest() : string;
var
  request : string;
begin
  request := 'GET /' + pageName + '?responder=fitClient';
  if (usingDownloadedPaths) then
    request := request + '&includePaths=yes';
  if (suiteFilter <> '') then
  begin
    request := request + '&suiteFilter=' + suiteFilter;
  end;
  Result := request + ' HTTP/1.1'#13#10#13#10;
end;

function TTestRunner.getCounts() : TCounts;
begin
  Result := fitServer.getCounts();
end;

procedure TTestRunner.acceptResults(results : TPageResult);
var
  counts : TCounts;
begin
  counts := results.counts();
  fitServer.writeCounts(counts);
  handler.acceptResult(results);
end;

procedure TTestRunner.doFormatting();
var
  i : Integer;
  option : TFormattingOption;
begin
  for i := 0 to formatters.Count - 1 do
  begin
    option := TFormattingOption(formatters[i]);
    if (verbose) then
      Writeln('Formatting as ' + option.format + ' to ' + option.filename);
    option.process(handler.getResultStream(), handler.getByteCount());
  end;
end;

class procedure TTestRunner.addItemsToClasspath(classpathItems : string);
var
  items : TStringList;
  i : Integer;
  item : string;
begin
  items := TFitServer.parseAssemblyList(classpathItems); //classpathItems.split(System.getProperty('path.separator'));
  for i := 0 to items.Count - 1 do
  begin
    item := items[i];
    if item[1] = '"' then
      item := Copy(item, 2, Length(item) - 2);
    if Pos('*', item) > 0 then
      continue;
    addUrlToClasspath(item); // TODO new File(item).toURL());
  end;
end;

class procedure TTestRunner.addUrlToClasspath(u : string {URL});
begin
  LoadPackage(u);
  (*		URLClassLoader sysloader := (URLClassLoader) ClassLoader.getSystemClassLoader();
    Class sysclass := URLClassLoader.class;
    Method method := sysclass.getDeclaredMethod('addURL', new Class[]{URL.class};);
    method.setAccessible(true);
    method.invoke(sysloader, new Object[]{};);
  *)
end;

end.

