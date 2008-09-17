program fitServer;

{$APPTYPE CONSOLE}

uses
  Forms,
  Classes,
  sysUtils,
  uFitServer in 'source\uFitServer.pas';

{$R *.res}

var
  server : TFitServer;

begin
  Application.Initialize;
  try
    server := TFitServer.Create;
    try
      server.run;
      ExitCode := server.getExitCode;
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

