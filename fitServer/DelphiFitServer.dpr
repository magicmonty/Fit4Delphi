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
program DelphiFitServer;

{$APPTYPE CONSOLE}

uses
  Forms,
  Classes,
  sysUtils,
  FitServer in '..\fit\source\FitServer.pas',
  FitProtocol in '..\fitnesse\components\FitProtocol.pas',
  OutputStream in '..\fitnesse\streams\OutputStream.pas',
  InputStream in '..\fitnesse\streams\InputStream.pas',
  StreamReader in '..\fitnesse\util\StreamReader.pas',
  TcpInputStream in '..\fitnesse\streams\TcpInputStream.pas';

{$R *.res}

var
  server : TFitServer;

begin
  Application.Initialize;
  try
    server := TFitServer.Create;
    try
      server.run;
      ExitCode := server.exitCode;
    finally
      FreeAndNil(server);
    end;
  except
    on E : Exception do
    begin
      writeln(E.Message);
      with TStringList.Create do
        try
          Add(E.Message);
          SaveToFile(ExtractFilePath(Application.ExeName) + 'debug.txt');
        finally
          Free;
        end;
      ExitCode := -1;
    end;
  end;
end.

