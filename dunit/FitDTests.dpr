// Uncomment the following directive to create a console application
// or leave commented to create a GUI application... 
//{$APPTYPE CONSOLE}

program FitDTests;

{%TogetherDiagram 'ModelSupport_FitDTests\default.txaPackage'}

uses
  TestFramework,
  Forms,
  GUITestRunner,
  TextTestRunner,
  Parse in '..\fit\source\Parse.pas',
  windows,
  Fixture in '..\fit\source\Fixture.pas',
  ColumnFixture in '..\fit\source\ColumnFixture.pas',
  ColumnFixtureTests in 'ColumnFixtureTests.pas',
  fileRunnerTests in 'fileRunnerTests.pas',
  FileRunner in '..\fit\source\FileRunner.pas',
  uFitServer in '..\fitServer\source\uFitServer.pas',
  uFitServerTest in 'uFitServerTest.pas',
  Counts in '..\fit\source\Counts.pas',
  ActionFixture in '..\fit\source\ActionFixture.pas',
  FixtureListener in '..\fit\source\FixtureListener.pas',
  Runtime in '..\fit\source\Runtime.pas',
  SummaryFixture in '..\fit\source\SummaryFixture.pas',
  TimedActionFixture in '..\fit\source\TimedActionFixture.pas',
  RowFixture in '..\fit\source\RowFixture.pas',
  RowFixtureTests in 'RowFixtureTests.pas',
  Browser in '..\eg\music\source\Browser.pas',
  MusicLibrary in '..\eg\music\source\MusicLibrary.pas',
  Music in '..\eg\music\source\Music.pas',
  Simulator in '..\eg\music\source\Simulator.pas',
  MusicPlayer in '..\eg\music\source\MusicPlayer.pas',
  Dialog in '..\eg\music\source\Dialog.pas',
  Display in '..\eg\music\source\Display.pas',
  Realtime in '..\eg\music\source\Realtime.pas',
  FitMatcherTest in 'FitMatcherTest.pas',
  TypeAdapterTests in 'TypeAdapterTests.pas',
  fixtureTests in 'fixtureTests.pas',
  RegexTest in 'RegexTest.pas',
  GracefulNamer in '..\fit\source\GracefulNamer.pas',
  GracefulNamerTest in 'GracefulNamerTest.pas',
  CountsTest in 'CountsTest.pas',
  BindingTest in 'BindingTest.pas',
  ParseTest in 'ParseTest.pas';

{$R *.RES}

begin
  Application.Initialize;

{$IFDEF LINUX}
  QGUITestRunner.RunRegisteredTests;
{$ELSE}
  if System.IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;

  sleep(1000);
{$ENDIF}

end.

