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
// Copyright (c) 2002 Cunningham & Cunningham, Inc.
// Released under the terms of the GNU General Public License version 2 or later.
// Ported to Delphi by Salim Nair.
{$H+}
unit uFitServer;

interface
uses
  Fixture,
  Parse,
  classes,
  Counts,
  idTCPClient,
  NullFixtureListener,
  sysUtils;

type
  TFitServer = class(TObject)
  private
    theFixture : TFixture;
    theTables : TParse;
    theCounts : TCounts;
    theTCPClient : TIdTCPClient;
    function newFixture : TFixture;
    function makeHTTPRequest : string;
    procedure Usage;
    procedure exit;
    procedure closeConnection;
    procedure loadAssemblyList(const list: TStringList);
  protected
    procedure raiseException(e : Exception);
    function readSize : integer; virtual;
    function readDocument(theSize : integer) : string; virtual;
    procedure establishConnection;
    procedure validateConnection;
    procedure print(const msg : string);
    class function parseAssemblyList(const theList : string) : TStringList;
  public
    verbose : boolean;
    theHost : string;
    thePort : integer;
    theSocketToken : integer;
    constructor Create;
    destructor Destroy; override;
    procedure run; overload;
    procedure run(arguments : TStringList); overload;
    procedure args(arguments : TStringList);
    procedure process;
    function getExitCode : Integer;
  end;

  TTablePrintingFixtureListener = class(TNullFixtureListener)
  private
    socket : TIdTCPClient;
    function MakeoutputString(theWriter : TStringList) : string;
  public
    constructor Create(aSocket : TIdTCPClient);
    procedure tableFinished(table : TParse); override;
    procedure tablesFinished(theCounts : TCounts); override;
  end;

implementation

uses
  FitParseException,
  idGlobal,
  IdTCPConnection;

const
  theFormat : string = '%.10d';

  { FitServer }

procedure TFitServer.args(arguments : TStringList);
const
  ASSEMBLYLIST : integer = 0;
  HOST : integer = 1;
  PORT : integer = 2;
  SOCKET_TOKEN : integer = 3;
  DONE : integer = 4;
var
  argumentPosition : integer;
  i : integer;
begin
  argumentPosition := 0;
  for i := 0 to arguments.Count - 1 do
  begin

    if (Pos('-', arguments[i]) = 1) then
    begin
      if (pos('-v', arguments[i]) = 1) then
        verbose := true
      else
        usage;
    end
    else
    begin
      if (argumentPosition = ASSEMBLYLIST) then
        loadAssemblyList(parseAssemblyList(arguments[i]))
      else
        if (argumentPosition = HOST) then
          theHost := arguments[i]
        else
          if (argumentPosition = PORT) then
            thePort := strToInt(arguments[i])
          else
            if (argumentPosition = SOCKET_TOKEN) then
              theSocketToken := strToInt(arguments[i]);
      inc(argumentPosition);
    end;
  end;
  if (argumentPosition <> DONE) then
    usage;
end;

procedure TFitServer.Usage;
begin
  writeLn('usage: FitServer.exe [-v] bplList host port socketTicket');
  writeLn(#9 + '-v' + #9 + 'verbose');
  ExitCode := -1;
  halt;
end;

constructor TFitServer.create;
begin
  theFixture := TFixture.Create;
  theCounts := TCounts.Create;

  theTCPClient := TIdTCPClient.Create(nil);
end;

destructor TFitServer.Destroy;
begin
  theFixture.Free;
  theCounts.Free;
  theTCPClient.Free;
  inherited;
end;

procedure TFitServer.establishConnection;
var
  theRequest : string;
begin
  theTCPClient.Host := theHost;
  theTCPClient.Port := thePort;
  theTCPClient.Connect;
  theRequest := makeHTTPRequest;
{$IFDEF VER180}
  theTCPClient.IOHandler.Write(theRequest);
{$ELSE}
  theTCPClient.Write(theRequest);
{$ENDIF}
  print('http request sent');
end;

procedure TFitServer.validateConnection;
var
  statusSize : integer;
  errorMessage : string;
begin
  print('Validating connection...');

  statusSize := readSize;
  if (statusSize = 0) then
  begin
    print(#9 + '...ok');
  end
  else
  begin
    errorMessage := readDocument(statusSize);
    print('...Failed because:' + errorMessage);
    writeLn('An error occured while connecting to client.');
    writeLn(errorMessage);
    ExitCode := -1;
    halt;
  end;
end;

function TFitServer.makeHTTPRequest : string;
begin
  result := 'GET /?responder=socketCatcher&ticket=' + intToStr(theSocketToken) +
    ' HTTP/1.1' + CR + LF + CR + LF;
end;

function TFitServer.getExitCode : Integer;
begin
  Result := theCounts.wrong + theCounts.exceptions;
end;

function TFitServer.newFixture : TFixture;
begin
  theFixture.Free;

  theFixture := TFixture.Create;
  theFixture.listener := TTablePrintingFixtureListener.Create(theTCPClient);
  result := theFixture;
end;

procedure TFitServer.process;
var
  size : integer;
  theDocument : string;
begin
  theFixture.listener := TTablePrintingFixtureListener.create(theTCPClient);
  try
    while true do
    begin
      size := readSize;
      print('processing document of size: ' + IntToStr(size));
      if (size = 0) then
        break;

      theDocument := readDocument(size);

      try
        theTables := TParse.Create(theDocument);
        newFixture.doTables(theTables);
        print(#9'results: ' + thefixture.counts.toString());
        theCounts.tally(theFixture.Counts);
      except
        on E : TFitParseException do
          raiseException(e);
      end;
    end;
    print('completion signal recieved');
  except
    on e : Exception do
      raiseException(e);
  end;
end;

function TFitServer.readDocument(theSize : integer) : string;
begin
{$IFDEF VER180}
  result := theTCPClient.IOHandler.ReadString(theSize);
{$ELSE}
  result := theTCPClient.ReadString(theSize);
{$ENDIF}
end;

function TFitServer.readSize : integer;
var
  theInput : string;
begin
{$IFDEF VER180}
  theInput := theTCPClient.IOHandler.ReadString(10);
{$ELSE}
  theInput := theTCPClient.ReadString(10);
{$ENDIF}
  try
    result := strToInt(theInput);
  except
    result := 0;
  end;

end;

procedure TFitServer.run;
var
  argList : TStringList;
  i : integer;
begin
  argList := TStringList.Create;
  try
    for i := 1 to ParamCount do
    begin
      argList.Add(ParamStr(i));
    end;
    run(argList);
  finally
    argList.Free;
  end;
end;

procedure TFitServer.run(arguments : TStringList);
begin
  args(arguments);
  establishConnection;
  validateConnection;
  process;
  closeConnection;
  exit;
end;

procedure TFitServer.closeConnection;
begin
  FreeAndNil(theTCPClient);
end;

procedure TFitServer.exit;
begin
  print('exiting');
  print(#9'tend results: ' + theCounts.toString());
end;

{ TablePrintingFixtureListener }

constructor TTablePrintingFixtureListener.Create(aSocket : TIdTCPClient);
begin
  socket := aSocket;
end;

function TTablePrintingFixtureListener.MakeoutputString(theWriter : TStringList) : string;
var
  i : integer;
begin
  for i := 0 to theWriter.count - 1 do
    result := result + theWriter[i];

end;

procedure TTablePrintingFixtureListener.tableFinished(table : TParse);
var
  more : TParse;
  writer : TStringList;
  outTxt : string;
begin
  inherited;

  writer := TStringList.create;
  try
    more := table.more;
    table.more := nil;

    table.print(writer);
    table.more := more;

    outTxt := MakeOutputString(writer);
{$IFDEF VER180}
    socket.IOHandler.Write(Format(theFormat, [length(outTxt)]));
    socket.IOHandler.Write(outTxt);
{$ELSE}
    socket.Write(Format(theFormat, [length(outTxt)]));
    socket.Write(outTxt);
{$ENDIF}
  finally
    writer.Free;
  end;

end;

procedure TTablePrintingFixtureListener.tablesFinished(theCounts : TCounts);
var
  outTxt : string;
begin
  inherited;

  try
    outTxt := Format(theFormat, [0]);
{$IFDEF VER180}
    socket.IOHandler.Write(outTxt);
    socket.IOHandler.write(Format(theFormat, [theCounts.right]));
    socket.IOHandler.write(Format(theFormat, [theCounts.wrong]));
    socket.IOHandler.write(Format(theFormat, [theCounts.ignores]));
    socket.IOHandler.write(Format(theFormat, [theCounts.exceptions]));
{$ELSE}
    socket.Write(outTxt);
    socket.write(Format(theFormat, [theCounts.right]));
    socket.write(Format(theFormat, [theCounts.wrong]));
    socket.write(Format(theFormat, [theCounts.ignores]));
    socket.write(Format(theFormat, [theCounts.exceptions]));
{$ENDIF}
  finally
  end;

end;

procedure TFitServer.raiseException(e : Exception);
begin
  print('Exception occurred!');
  print(#9 + e.Message);
  theTables := TParse.Create('span', 'Exception occurred: ', nil, nil);
  theFixture.DoException(theTables, e);
  Inc(theCounts.exceptions);
  theFixture.listener.tableFinished(theTables);
  theFixture.listener.tablesFinished(theCounts); //TODO shouldn't this be fixture.counts
end;

procedure TFitServer.print(const msg : string);
begin
  if (verbose) then
    writeLn(msg);
end;

class function TFitServer.parseAssemblyList(const theList : string) : TStringList;
begin
  Result := TStringList.Create;
  Result.Text := StringReplace(theList, ';', #13#10, [rfReplaceAll]);
end;

procedure TFitServer.loadAssemblyList(const list : TStringList);
var
  i : integer;
begin
  for i := 0 to list.count - 1 do
    theFixture.addBPL(list[i]);
end;

end.

