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
unit uFitServerTest;

interface

uses
  classes,
  testFramework,
  uFitServer,
  idTCPServer, IdContext;

type
  TTestFitServer = class( TFitServer )
  protected
  public
  end;

  TFitServerTest = class( TTestCase )
  private
    // TODO Disabled
    procedure testSimpleConnect;
  published
    procedure testArgs;
    procedure testParseAssemblyList;
  end;

  TFitServerInvoker = class( TThread )
  protected
    theServer : TTestFitServer;
    procedure Execute; override;
  public
    constructor Create;
  end;

  TFitnessServerListener = class( TThread )
  protected
    procedure Execute; override;
  public
    procedure runListener;
    procedure OnExecute(AContext: TIdContext);
  end;

implementation

type
  TMockFitServer = class(TFitServer)

  end;

procedure TFitServerTest.testArgs;
var theServer : TFitServer;
    argList : TStringList;
begin
  theServer := TFitServer.Create;

  argList := TStringList.Create;
  argList.Add( '-v' );
  argList.Add( 'D:\DevelopmentProjects\DelphiFit\exampleFixture1.bpl' );
  argList.Add( 'localhost' );
  argList.Add( '89' );
  argList.Add( '1234' );

  theServer.args( argList );

  check( theServer.Verbose, 'Verbose not set' );
  checkEquals( 'localhost', theServer.theHost );
  checkEquals( 89, theServer.thePort );
  checkEquals( 1234, theServer.theSocketToken );

end;

procedure TFitServerTest.testParseAssemblyList;
var
  theList : String;
  tmpList: TStringList;
begin
  theList := 'c:\test\name and space\one;c:\other\nospace\two.bpl';
  tmpList := TMockFitServer.parseAssemblyList(theList);
  CheckEquals(2, tmpList.Count);
end;

procedure TFitServerTest.testSimpleConnect;
var theServerInvoker : TFitServerInvoker;
    listner : TFitnessServerListener;
    argList : TStringList;
begin
  listner := TFitnessServerListener.Create( true );
  theServerInvoker := TFitServerInvoker.Create;
  argList := TStringList.Create;
//  argList.Add( '-v' );
  argList.Add( 'C:\fitnesse\source\DelphiFit\bin\exampleFixture1;C:\fitnesse\source\DelphiFit\bin\addFixture1.bpl' );
  argList.Add( 'localhost' );
  argList.Add( '89' );
  argList.Add( '1234' );
  listner.runListener;

  theServerInvoker.theServer.run( argList );
  theServerInvoker.Terminate;
  listner.Terminate;
end;

{ FitnessServerListener }

procedure TFitnessServerListener.runListener;
var theServer : TIdTCPServer;
begin
  theServer := TIdTCPServer.Create( nil );
  theServer.DefaultPort := 89;
  theServer.OnExecute := OnExecute;
  theServer.Active := true;
  Resume;
end;

procedure TFitnessServerListener.Execute;
begin
  while not Terminated do
  begin

  end;
end;

procedure TFitnessServerListener.OnExecute(AContext:TIdContext);
begin
  while not Terminated do
  begin

  end;
end;

{ FitServerInvoker }

constructor TFitServerInvoker.Create;
begin
  inherited Create( false );
  theServer := TTestFitServer.create;
end;

procedure TFitServerInvoker.Execute;
begin
  inherited;

end;

initialization
  registerTest( TFitServerTest.Suite );
end.
