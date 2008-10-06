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
unit FileUtilTest;

interface

uses
  TestFramework, FileUnit;

type
  TFileUtilTest = class(TTestCase)
  private
//    function createFileInDir(dir : TFile; fileName : string) : TFile;
//    function createSubDir(dir : TFile; subDirName : string) : TFile;
  published
{    procedure testCreateDir();
    procedure testGetDirectoryListingEmpty();
    procedure testOrganizeFilesOneFile();
    procedure testOrganizeFilesFiveFiles();
    procedure testOrganizeFilesOneSubDir();
    procedure testOrganizeFilesFiveSubDirs();
    procedure testOrganizeFilesMixOfFilesAndDirs();
    procedure testBuildPathEmpty();
    procedure testBuildPathOneElement();
    procedure testBuildPathThreeElements();
}  end;

implementation

uses
  FileUtil;

{ TFileUtilTest }
{
procedure TFileUtilTest.testCreateDir();
var
  dir : TFile;
begin
  dir := TFileUtil.createDir('temp');
  CheckTrue(dir.exists());
  CheckTrue(dir.isDirectory());
  FileUtil.deleteFileSystemDirectory(dir);
end;

procedure TFileUtilTest.testGetDirectoryListingEmpty();
var
  dir : TFile;
begin
  dir := FileUtil.createDir('temp');
  CheckEquals(0, FileUtil.getDirectoryListing(dir).length);
  FileUtil.deleteFileSystemDirectory(dir);
end;

procedure TFileUtilTest.testOrganizeFilesOneFile();
var
  dir : TFile;
  TFile : TFile;
begin
  dir := FileUtil.createDir('temp');
  TFile := createFileInDir(dir, 'TFile.txt');
  CheckEquals(1, FileUtil.getDirectoryListing(dir).length);
  CheckEquals(TFile, FileUtil.getDirectoryListing(dir)[0]);
  FileUtil.deleteFileSystemDirectory(dir);
end;

procedure TFileUtilTest.testOrganizeFilesFiveFiles();
var
  file4 : TFile;
  dir : TFile;
  file3 : TFile;
  file2 : TFile;
  file1 : TFile;
  file0 : TFile;
begin
  dir := FileUtil.createDir('temp');
  file3 := createFileInDir(dir, 'dFile.txt');
  file1 := createFileInDir(dir, 'bFile.txt');
  file4 := createFileInDir(dir, 'eFile.txt');
  file0 := createFileInDir(dir, 'aFile.txt');
  file2 := createFileInDir(dir, 'cFile.txt');
  CheckEquals(5, FileUtil.getDirectoryListing(dir).length);
  CheckEquals(file0, FileUtil.getDirectoryListing(dir)[0]);
  CheckEquals(file1, FileUtil.getDirectoryListing(dir)[1]);
  CheckEquals(file2, FileUtil.getDirectoryListing(dir)[2]);
  CheckEquals(file3, FileUtil.getDirectoryListing(dir)[3]);
  CheckEquals(file4, FileUtil.getDirectoryListing(dir)[4]);
  FileUtil.deleteFileSystemDirectory(dir);
end;

procedure TFileUtilTest.testOrganizeFilesOneSubDir();
var
  dir : TFile;
  subDir : TFile;
begin
  dir := FileUtil.createDir('temp');
  subDir := createSubDir(dir, 'subDir');
  CheckEquals(1, FileUtil.getDirectoryListing(dir).length);
  CheckEquals(subDir, FileUtil.getDirectoryListing(dir)[0]);
  FileUtil.deleteFileSystemDirectory(dir);
end;

procedure TFileUtilTest.testOrganizeFilesFiveSubDirs();
var
  dir : TFile;
  dir4 : TFile;
  dir3 : TFile;
  dir2 : TFile;
  dir1 : TFile;
  dir0 : TFile;
begin
  dir := FileUtil.createDir('temp');
  dir3 := createSubDir(dir, 'dDir');
  dir1 := createSubDir(dir, 'bDir');
  dir4 := createSubDir(dir, 'eDir');
  dir0 := createSubDir(dir, 'aDir');
  dir2 := createSubDir(dir, 'cDir');
  CheckEquals(5, FileUtil.getDirectoryListing(dir).length);
  CheckEquals(dir0, FileUtil.getDirectoryListing(dir)[0]);
  CheckEquals(dir1, FileUtil.getDirectoryListing(dir)[1]);
  CheckEquals(dir2, FileUtil.getDirectoryListing(dir)[2]);
  CheckEquals(dir3, FileUtil.getDirectoryListing(dir)[3]);
  CheckEquals(dir4, FileUtil.getDirectoryListing(dir)[4]);
  FileUtil.deleteFileSystemDirectory(dir);
end;

procedure TFileUtilTest.testOrganizeFilesMixOfFilesAndDirs();
var
  dir : TFile;
  dir4 : TFile;
  file4 : TFile;
  dir3 : TFile;
  file3 : TFile;
  file2 : TFile;
  dir2 : TFile;
  file1 : TFile;
  dir1 : TFile;
  dir0 : TFile;
  file0 : TFile;
begin
  dir := FileUtil.createDir('temp');
  dir3 := createSubDir(dir, 'dDir');
  file3 := createFileInDir(dir, 'dFile.txt');
  file0 := createFileInDir(dir, 'aFile.txt');
  dir1 := createSubDir(dir, 'bDir');
  file4 := createFileInDir(dir, 'eFile.txt');
  dir4 := createSubDir(dir, 'eDir');
  dir0 := createSubDir(dir, 'aDir');
  file1 := createFileInDir(dir, 'bFile.txt');
  dir2 := createSubDir(dir, 'cDir');
  file2 := createFileInDir(dir, 'cFile.txt');
  CheckEquals(10, FileUtil.getDirectoryListing(dir).length);
  CheckEquals(dir0, FileUtil.getDirectoryListing(dir)[0]);
  CheckEquals(dir1, FileUtil.getDirectoryListing(dir)[1]);
  CheckEquals(dir2, FileUtil.getDirectoryListing(dir)[2]);
  CheckEquals(dir3, FileUtil.getDirectoryListing(dir)[3]);
  CheckEquals(dir4, FileUtil.getDirectoryListing(dir)[4]);
  CheckEquals(file0, FileUtil.getDirectoryListing(dir)[5]);
  CheckEquals(file1, FileUtil.getDirectoryListing(dir)[6]);
  CheckEquals(file2, FileUtil.getDirectoryListing(dir)[7]);
  CheckEquals(file3, FileUtil.getDirectoryListing(dir)[8]);
  CheckEquals(file4, FileUtil.getDirectoryListing(dir)[9]);
  FileUtil.deleteFileSystemDirectory(dir);
end;

function TFileUtilTest.createFileInDir(dir : TFile; fileName : string) : TFile;
begin
   result := TFileUtil.createFile(TFileUtil.buildPath(dir.getPath(), fileName), '');
end;

function TFileUtilTest.createSubDir(dir : TFile; subDirName : string) : TFile;
begin
    result := FileUtil.createDir(FileUtil.buildPath(dir.getPath(), subDirName));
end;

procedure TFileUtilTest.testBuildPathEmpty();
begin
    CheckEquals('', FileUtil.buildPath(''));
end;

procedure TFileUtilTest.testBuildPathOneElement();
begin
    CheckEquals('a', FileUtil.buildPath('a'));
end;

procedure TFileUtilTest.testBuildPathThreeElements();
var
  separator : string;
begin
  separator := System.getProperty('file.separator');
    CheckEquals('a' + separator + 'b' + separator + 'c', FileUtil.buildPath("a", "b", "c"));
end;
}
initialization

  TestFramework.RegisterTest(TFileUtilTest.Suite);

end.

