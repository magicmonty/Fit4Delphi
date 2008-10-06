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
unit FitServer;

interface
uses
  Fixture,
  Parse,
  classes,
  Counts,
  idTCPClient,
  NullFixtureListener,
  FixtureListener,
  FitProtocol,
  OutputStream,
  StreamReader,
  sysUtils;

type
  TFitServer = class(TObject)
  private
    fixture : TFixture;
    tables : TParse;
    counts : TCounts;
    theTCPClient : TIdTCPClient;
    socketOutput : TOutputStream;
    socketReader : TStreamReader;
    function newFixture : TFixture;
    function makeHTTPRequest : string;
    procedure Usage;
    procedure loadAssemblyList(const list : TStringList);
  protected
    procedure raiseException(e : Exception);
    procedure print(const msg : string);
  public
    verbose : boolean;
    theHost : string;
    thePort : integer;
    theSocketToken : integer;
    input : string;
    fixtureListener : IFixtureListener;
    constructor Create; overload;
    constructor Create(host : string; port : Integer; verbose : boolean); overload;
    destructor Destroy; override;
    procedure run; overload;
    procedure run(arguments : TStringList); overload;
    procedure args(arguments : TStringList);
    procedure process;
    function exitCode : Integer;
    class function readTable(table : TParse) : string;
    procedure establishConnection(); overload;
    procedure establishConnection(httpRequest : string); overload;
    procedure validateConnection();
    procedure closeConnection;
    procedure exit;
    function readDocument(theSize : integer) : string; overload; virtual;
    function readDocument : string; overload; virtual;
    function getCounts : TCounts;
    procedure writeCounts(count : TCounts);
    class function parseAssemblyList(const theList : string) : TStringList;
  end;

  TTablePrintingFixtureListener = class(TNullFixtureListener)
  private
    socket : TIdTCPClient;
    server : TFitServer;
  public
    constructor Create(aSocket : TIdTCPClient; server : TFitServer);
    procedure tableFinished(table : TParse); override;
    procedure tablesFinished(count : TCounts); override;
  end;

implementation

uses
  FitParseException,
  idGlobal,
  IdTCPStream,
  IdTCPConnection, InputStream, TcpInputStream;

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
  System.ExitCode := -1;
  halt;
end;

constructor TFitServer.create;
begin
  fixture := TFixture.Create;
  counts := TCounts.Create;

  theTCPClient := TIdTCPClient.Create(nil);
  fixtureListener := TTablePrintingFixtureListener.Create(theTCPClient, self);
end;

constructor TFitServer.Create(host : string; port : Integer; verbose : boolean);
begin
  Create;

  thehost := host;
  theport := port;
  self.verbose := verbose;
end;

destructor TFitServer.Destroy;
begin
  fixture.Free;
  counts.Free;
  theTCPClient.Free;
  inherited;
end;

procedure TFitServer.establishConnection();
begin
  establishConnection(makeHTTPRequest);
end;

procedure TFitServer.establishConnection(httpRequest : string);
var
  bytes : string;
  socketIn : TInputStream;
  inputStream : TIdTCPStream;
  outputStream : TIdTCPStream;
begin
  theTCPClient.Host := theHost;
  theTCPClient.Port := thePort;
  theTCPClient.Connect;

  inputStream := TIdTCPStream.Create(theTCPClient);
  outputStream := TIdTCPStream.Create(theTCPClient);
  socketOutput := TOutputStream.Create;
  socketIn := TTcpInputStream.Create;
  socketOutput.stream := outputStream; //socket.getOutputStream();
  socketIn.stream := inputStream; // := socket.getInputStream();

//  socketOutput := socket.getOutputStream();
  socketReader := TStreamReader.Create(socketIn{socket.getInputStream()});
  bytes := httpRequest {.getBytes("UTF-8")};
  socketOutput.write(bytes);
  socketOutput.flush();

  print('http request sent');
end;

procedure TFitServer.validateConnection;
var
  statusSize : integer;
  errorMessage : string;
begin
  print('Validating connection...');

  statusSize := TFitProtocol.readSize(socketReader);
  if (statusSize = 0) then
  begin
    print(#9 + '...ok');
  end
  else
  begin
    errorMessage := TFitProtocol.readDocument(socketReader, statusSize);
    print('...Failed because:' + errorMessage);
    writeLn('An error occured while connecting to client.');
    writeLn(errorMessage);
    System.ExitCode := -1;
    halt;
  end;
end;

function TFitServer.makeHTTPRequest : string;
begin
  result := 'GET /?responder=socketCatcher&ticket=' + intToStr(theSocketToken) +
    ' HTTP/1.1' + CR + LF + CR + LF;
end;

function TFitServer.exitCode : Integer;
begin
  Result := counts.wrong + counts.exceptions;
end;

function TFitServer.newFixture : TFixture;
begin
  fixture.Free;

  fixture := TFixture.Create;
  fixture.listener := fixtureListener;
  result := fixture;
end;

procedure TFitServer.process;
var
  size : integer;
  document : string;
begin
  fixture.listener := fixtureListener;
  try
    while true do
    begin
      size := TFitProtocol.readSize(socketReader);
      if (size = 0) then
        break;
      try
        print('processing document of size: ' + IntToStr(size));

        document := TFitProtocol.readDocument(socketReader, size);

        tables := TParse.Create(document);
        newFixture.doTables(tables);
        print(#9'results: ' + fixture.counts.toString());
        counts.tally(fixture.Counts);
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

function TFitServer.readDocument : string;
var
  size : Integer;
begin
  size := TFitProtocol.readSize(socketReader);
  Result := TFitProtocol.readDocument(socketReader, size);
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
  print(#9'tend results: ' + counts.toString());
end;

{ TablePrintingFixtureListener }

constructor TTablePrintingFixtureListener.Create(aSocket : TIdTCPClient; server : TFitServer);
begin
  socket := aSocket;
  self.server := server;
end;

procedure TTablePrintingFixtureListener.tableFinished(table : TParse);
var
  bytes : string;
begin
  try
    bytes := server.readTable(table);
    if (length(bytes) > 0) then
      TFitProtocol.writeData(bytes, server.socketOutput);
  except
    on e : Exception do
      Writeln(e.Message);
    //				e.printStackTrace();
  end;
end;

procedure TTablePrintingFixtureListener.tablesFinished(count : TCounts);
begin
  try
    TFitProtocol.writeCounts(count, server.socketOutput);
  except
    on e : Exception do
      Writeln(e.Message);
    //TODO        e.printStackTrace();
  end;
end;

procedure TFitServer.raiseException(e : Exception);
begin
  print('Exception occurred!');
  print(#9 + e.Message);
  tables := TParse.Create('span', 'Exception occurred: ', nil, nil);
  fixture.DoException(tables, e);
  Inc(counts.exceptions);
  fixture.listener.tableFinished(tables);
  fixture.listener.tablesFinished(counts); //TODO shouldn't this be fixture.counts
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
    fixture.addBPL(list[i]);
end;

// TODO "UTF-8"

function TFitServer.readDocument(theSize : integer) : string;
begin

end;

class function TFitServer.readTable(table : TParse) : string;
var
  more : TParse;
  writer : TStringList;
begin
  //		ByteArrayOutputStream byteBuffer := new ByteArrayOutputStream();
  //		OutputStreamWriter streamWriter := new OutputStreamWriter(byteBuffer, "UTF-8");
  //		PrintWriter writer := new PrintWriter(streamWriter);
  writer := TStringList.create;
  try
    more := table.more;
    table.more := nil;
    //      if(table.trailer = '') then
    //        table.trailer := '';
    table.print(writer);
    table.more := more;
    writer.LineBreak := '';
    Result := writer.Text;
  finally
    writer.Free;
  end;
end;

function TFitServer.getCounts() : TCounts;
begin
  Result := counts;
end;

procedure TFitServer.writeCounts(count : TCounts);
begin
  //TODO This can't be right.... which counts should be used?
  TFitProtocol.writeCounts(counts, socketOutput);
end;

end.

