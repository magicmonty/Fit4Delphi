Delphi Fitnesse Port
--------------------

This is the first version of porting Fit server to delphi. The work is still in its very early stages.

Currently the framework implements just the column fixture. Extending it to other kinds of fixtures shouldnt be difficult.

Framework uses Delphi RTTI. So the properties of fixtures should be published to be available to Fitnesse.

Two simple examples are provided in the eg folder.

The framework was compiled in Delphi 7. It should work in Delphi 6 and Delphi 2005 as well, but havent tested.

Unit Tests
----------
Over 40 unit tests are provided that tests the fitLib part of the framework. The test units are in source\dunit.
There one failing test due to the changes in formatting (use of CSS for formatting). The test fails as the result file (runnerResults.htm) is out of date.

The FitServer tests where written extending the Java Fitserver JUnit tests. I will post them as soon as I unearth them :-)

Installation and Building
-------------------------

Following are the steps to build the servers, examples and tests

1. Define an environment variable (either in delphi/tools/environment or system environment) DelphiFit. Define it to point to the root folder where you have expanded the zip files into

	e.g DelphiFit="c:\fitnesse\source\delphiFit"

2. Load the fitServers.bpg project group to delphi
3. Do a build all.

