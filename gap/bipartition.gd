############################################################################
##
#W  bipartition.gd
#Y  Copyright (C) 2013-14                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareCategory("IsBipartition", IsMultiplicativeElementWithInverse and
 IsAssociativeElementWithStar);
DeclareCategoryCollections("IsBipartition");
DeclareCategoryCollections("IsBipartitionCollection");

DeclareGlobalFunction("BipartitionNC");
DeclareGlobalFunction("Bipartition");

DeclareAttribute("DegreeOfBipartition", IsBipartition);
DeclareAttribute("RankOfBipartition", IsBipartition);
DeclareAttribute("TransverseBlocksLookup", IsBipartition);
DeclareAttribute("NrTransverseBlocks", IsBipartition);

DeclareOperation("OneMutable", [IsBipartitionCollection]);
DeclareAttribute("ExtRepOfBipartition", IsBipartition);
DeclareSynonymAttr("LeftProjection", LeftOne);
DeclareSynonymAttr("RightProjection", RightOne);
DeclareOperation("RandomBipartition", [IsPosInt]);

DeclareOperation("NaturalLeqBlockBijection", [IsBipartition, IsBipartition]);
DeclareOperation("NaturalLeqPartialPermBipartition", [IsBipartition,
 IsBipartition]);
DeclareOperation("PartialPermLeqBipartition", [IsBipartition, IsBipartition]);

DeclareOperation("IdentityBipartition", [IsPosInt]);
DeclareOperation("BipartitionByIntRepNC", [IsList]);
DeclareOperation("BipartitionByIntRep", [IsList]);

DeclareOperation("AsBipartition", [IsPerm, IsInt]);
DeclareOperation("AsBipartition", [IsPerm]);
DeclareOperation("AsBipartition", [IsTransformation, IsPosInt]);
DeclareOperation("AsBipartition", [IsTransformation, IsZeroCyc]);
DeclareOperation("AsBipartition", [IsTransformation]);
DeclareOperation("AsBipartition", [IsPartialPerm, IsPosInt]);
DeclareOperation("AsBipartition", [IsPartialPerm, IsZeroCyc]);
DeclareOperation("AsBipartition", [IsPartialPerm]);
DeclareOperation("AsBipartition", [IsBipartition, IsPosInt]);
DeclareOperation("AsBipartition", [IsBipartition, IsZeroCyc]);
DeclareOperation("AsBipartition", [IsBipartition]);
DeclareOperation("AsBlockBijection", [IsPartialPerm, IsPosInt]);
DeclareOperation("AsBlockBijection", [IsPartialPerm, IsZeroCyc]);
DeclareOperation("AsBlockBijection", [IsPartialPerm]);

DeclareProperty("IsBlockBijection", IsBipartition);
DeclareProperty("IsUniformBlockBijection", IsBipartition);
DeclareProperty("IsTransBipartition", IsBipartition);
DeclareProperty("IsDualTransBipartition", IsBipartition);
DeclareProperty("IsPermBipartition", IsBipartition);
DeclareProperty("IsPartialPermBipartition", IsBipartition);

DeclareGlobalFunction("PermLeftQuoBipartitionNC");
DeclareOperation("PermLeftQuoBipartition", [IsBipartition, IsBipartition]);
DeclareGlobalFunction("OnRightBlocksBipartitionByPerm");

#collections
DeclareAttribute("DegreeOfBipartitionCollection", IsBipartitionCollection);

# implications

InstallTrueMethod(IsPermBipartition, IsTransBipartition and
IsDualTransBipartition);
InstallTrueMethod(IsBlockBijection, IsPermBipartition);

#internal...
DeclareGlobalFunction("BipartRightBlocksConj");

