#############################################################################
##
#W  testall.g
#Y  Copyright (C) 2011                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Read(Filename(DirectoriesPackageLibrary("citrus","tst"),"testall.g"));;

#SizeScreen([80]); SetInfoLevel(InfoWarning, 0); TestManualExamples(DirectoriesPackageLibrary("monoid","doc")[1]![1], "monoid.xml", ["../gap/autos.gd", "../gap/general.gd", "../gap/greens.gd", "../gap/orbits.gd", "../gap/properties.gd", "../gap/semigroups.gd", "../gap/semihomo.gd", "../gap/transform.gd"] );

LoadPackage( "citrus" );;
dir_str:=Concatenation(PackageInfo("citrus")[1]!.InstallationPath,"/tst");
tst:=DirectoryContents(dir_str);
dir:=Directory(dir_str);
for x in tst do
  str:=SplitString(x, ".");
  if Length(str)>=2 and str[2]="tst" then
    Print("reading ", dir_str,"/", x, " ...\n");
    ReadTest(Filename(dir, x));
    Print("\n");
  fi;
od;
