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
  windows,
  ColumnFixtureTests in 'ColumnFixtureTests.pas',
  fileRunnerTests in 'fileRunnerTests.pas',
  uFitServer in '..\fitServer\source\uFitServer.pas',
  uFitServerTest in 'uFitServerTest.pas',
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
  GracefulNamerTest in 'GracefulNamerTest.pas',
  CountsTest in 'CountsTest.pas',
  BindingTest in 'BindingTest.pas',
  ParseTest in 'ParseTest.pas',
  ClassIsNotFixtureException in '..\fit\source\exception\ClassIsNotFixtureException.pas',
  CouldNotLoadComponentFitFailureException in '..\fit\source\exception\CouldNotLoadComponentFitFailureException.pas',
  CouldNotParseFitFailureException in '..\fit\source\exception\CouldNotParseFitFailureException.pas',
  FitFailureException in '..\fit\source\exception\FitFailureException.pas',
  FitMatcherException in '..\fit\source\exception\FitMatcherException.pas',
  FitParseException in '..\fit\source\exception\FitParseException.pas',
  FixtureException in '..\fit\source\exception\FixtureException.pas',
  NoDefaultConstructorFixtureException in '..\fit\source\exception\NoDefaultConstructorFixtureException.pas',
  NoSuchFieldFitFailureException in '..\fit\source\exception\NoSuchFieldFitFailureException.pas',
  NoSuchFixtureException in '..\fit\source\exception\NoSuchFixtureException.pas',
  NoSuchMethodFitFailureException in '..\fit\source\exception\NoSuchMethodFitFailureException.pas',
  ParseException in '..\fit\source\exception\ParseException.pas',
  ActionFixture in '..\fit\source\ActionFixture.pas',
  Binding in '..\fit\source\Binding.pas',
  CellComparator in '..\fit\source\CellComparator.pas',
  ColumnFixture in '..\fit\source\ColumnFixture.pas',
  Counts in '..\fit\source\Counts.pas',
  DetailedRTTI in '..\fit\source\DetailedRTTI.pas',
  Field in '..\fit\source\Field.pas',
  FileRunner in '..\fit\source\FileRunner.pas',
  FitMatcher in '..\fit\source\FitMatcher.pas',
  Fixture in '..\fit\source\Fixture.pas',
  FixtureListener in '..\fit\source\FixtureListener.pas',
  FixtureLoader in '..\fit\source\FixtureLoader.pas',
  FixtureName in '..\fit\source\FixtureName.pas',
  GracefulNamer in '..\fit\source\GracefulNamer.pas',
  Method in '..\fit\source\Method.pas',
  NullFixtureListener in '..\fit\source\NullFixtureListener.pas',
  Parse in '..\fit\source\Parse.pas',
  RowFixture in '..\fit\source\RowFixture.pas',
  Runtime in '..\fit\source\Runtime.pas',
  StringTokenizer in '..\fit\source\StringTokenizer.pas',
  SummaryFixture in '..\fit\source\SummaryFixture.pas',
  TimedActionFixture in '..\fit\source\TimedActionFixture.pas',
  TypeAdapter in '..\fit\source\TypeAdapter.pas',
  FixtureLoaderTest in 'FixtureLoaderTest.pas',
  FriendlyErrorTest in 'FriendlyErrorTest.pas';

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

