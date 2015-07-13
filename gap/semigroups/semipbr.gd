############################################################################
##
#W  semipbr.gd
#Y  Copyright (C) 2015                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################

# This file contains declarations for semigroups of PBRs.


DeclareSynonym("IsPBRSemigroup", 
               IsSemigroup and IsPBRCollection);

InstallTrueMethod(IsFinite, IsPBRSemigroup);
DeclareAttribute("DegreeOfPBRSemigroup",
                 IsPBRSemigroup);

DeclareAttribute("IsomorphismPBRSemigroup", IsSemigroup);
DeclareAttribute("AsPBRSemigroup", IsSemigroup);