#############################################################################
##
#W  greens.gd
#Y  Copyright (C) 2011-12                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
##  This file contains algorithms for computing Green's relations
##  and related notions for transformation semigroups and monoids. 
##  The theory behind these algorithms is developed in 
##  
##  [LPRR1] S. A.   Linton, G.  Pfeiffer, E.  F.  Robertson, and N.   Ruskuc,
##  Groups  and actions in  transformation semigroups, to appear in Math Z.
##  (1998).
##
##  Early versions of the algorithms themselves are described in
##
##  [LPRR2] S. A.   Linton, G.  Pfeiffer, E.  F.  Robertson, and N.   Ruskuc,
##  Computing transformation semigroups, (1998), in preparation.
##  
##  Another reference is
##
##  [LM]  G.  Lallement and R. McFadden, On the   determination of Green's
##  relations in finite transformation semigroups, J. Symbolic Computation 10
##  (1990), 481--489.
##
#############################################################################
#############################################################################

#new

DeclareAttribute("MultiplicativeNeutralElement", IsGreensHClass);

DeclareProperty("IsGreensClassOfPartPermSemigroup", IsGreensClass);
DeclareProperty("IsGreensClassOfInverseSemigroup", IsGreensClass);
DeclareProperty("IsGreensClassNC", IsActingSemigroupGreensClass);

DeclareAttribute("LambdaOrbSCC", IsActingSemigroupGreensClass);
DeclareAttribute("LambdaOrbSCCIndex", IsActingSemigroupGreensClass);

DeclareAttribute("RhoOrbSCC", IsActingSemigroupGreensClass);
DeclareAttribute("RhoOrbSCCIndex", IsActingSemigroupGreensClass);

DeclareAttribute("LambdaCosets", IsActingSemigroupGreensClass);
DeclareAttribute("RhoCosets", IsActingSemigroupGreensClass);

DeclareAttribute("SemigroupDataSCC", IsActingSemigroupGreensClass);
DeclareAttribute("SemigroupDataSCCIndex", IsActingSemigroupGreensClass);
DeclareAttribute("SemigroupDataIndex", IsActingSemigroupGreensClass);

#old

DeclareGlobalFunction("DClass");
DeclareGlobalFunction("DClassNC");
DeclareGlobalFunction("HClass");
DeclareGlobalFunction("HClassNC");
DeclareGlobalFunction("LClass");
DeclareGlobalFunction("LClassNC");
DeclareGlobalFunction("RClass");
DeclareGlobalFunction("RClassNC");

DeclareGlobalFunction("CreateDClass");
DeclareGlobalFunction("CreateDClassNC");
DeclareGlobalFunction("CreateHClass");
DeclareGlobalFunction("CreateHClassNC");
DeclareGlobalFunction("CreateLClass");
DeclareGlobalFunction("CreateLClassNC");
DeclareGlobalFunction("CreateInverseOpLClassNC");
DeclareGlobalFunction("CreateInverseOpLClass");
DeclareGlobalFunction("CreateRClass");
DeclareGlobalFunction("CreateRClassNC");

DeclareAttribute("DClassType", IsSemigroup);
DeclareAttribute("HClassType", IsSemigroup);
DeclareAttribute("LClassType", IsSemigroup);
DeclareAttribute("RClassType", IsSemigroup);

DeclareAttribute("DClassReps", IsSemigroup);
DeclareAttribute("HClassReps", IsSemigroup);
DeclareAttribute("LClassReps", IsSemigroup); 
DeclareAttribute("RClassReps", IsSemigroup);

DeclareOperation("EnumeratorOfRClasses", [IsSemigroup]);

DeclareOperation("GreensDClassOfElementNC", [IsSemigroup]); 
DeclareOperation("GreensHClassOfElementNC", [IsSemigroup]); 
DeclareOperation("GreensLClassOfElementNC", [IsSemigroup]); 
DeclareOperation("GreensRClassOfElementNC", [IsSemigroup]);

DeclareProperty("IsGreensClassOfTransSemigp", IsGreensClass);

DeclareGlobalFunction("IsRegularClass@");
DeclareProperty("IsRegularClass", IsGreensClass);
InstallTrueMethod(IsRegularClass, IsRegularDClass);
DeclareProperty("IsInverseOpClass", IsGreensClass); 
InstallTrueMethod(IsRegularClass, IsInverseOpClass);

DeclareGlobalFunction("Idempotents@");
DeclareGlobalFunction("NrIdempotents@");
DeclareAttribute("NrIdempotents", IsSemigroup);

DeclareAttribute("NrDClasses", IsSemigroup); 
DeclareAttribute("NrHClasses", IsSemigroup);
DeclareAttribute("NrLClasses", IsSemigroup);
DeclareAttribute("NrRClasses", IsSemigroup);
DeclareAttribute("NrRegularDClasses", IsSemigroup); 

DeclareAttribute("PartialOrderOfDClasses", IsSemigroup);

DeclareAttribute("SchutzenbergerGroup", IsGreensClass);

DeclareSynonymAttr("DClasses", GreensDClasses);
DeclareSynonymAttr("HClasses", GreensHClasses);
DeclareSynonymAttr("JClasses", GreensJClasses);
DeclareSynonymAttr("LClasses", GreensLClasses);
DeclareSynonymAttr("RClasses", GreensRClasses);

DeclareAttribute("GroupHClass", IsGreensDClass and
 IsGreensClassOfTransSemigp);

#EOF
