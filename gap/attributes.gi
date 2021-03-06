#############################################################################
##
#W  attributes.gi
#Y  Copyright (C) 2013-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Note about the difference between One and MultiplicativeNeutralElement
# (the same goes for Zero and MultplicativeZero):
#
# One(s) returns One(Representative(s)) if it belongs to s, so that
# One(s)=Transformation([1..DegreeOfTransformationSemigroup(s)]) if s is a
# transformation semigroup and it returns fail otherwise, or it returns
# PartialPerm([1..DegreeOfPartialPermSemigroup]) if this belongs to s.
#
# MultiplicativeNeutralElement on the other hand returns the element of s that
# acts as the identity, note that this can be equal to One(s) but it can also
# not be equal t One(s).
#
# A semigroup satisfies IsMonoidAsSemigroup(s) if
# MultiplicativeNeutralElement(x)<>fail, so it could be that One(s) returns
# fail but IsMonoidAsSemigroup is still true.

BindGlobal("SEMIGROUPS_InjectionPrincipalFactor",
function(D, constructor)
  local map, inv, G, mat, rep, R, L, x, RR, LL, rms, iso, hom, i, j;

  map := IsomorphismPermGroup(GroupHClass(D));
  inv := InverseGeneralMapping(map);

  G := Range(map);
  mat := [];

  rep := Representative(GroupHClass(D));
  R := HClassReps(LClass(D, rep));
  L := HClassReps(RClass(D, rep));

  for i in [1 .. Length(L)] do
    mat[i] := [];
    for j in [1 .. Length(R)] do
      x := L[i] * R[j];
      if x in D then
        mat[i][j] := x ^ map;
      else
        mat[i][j] := 0;
      fi;
    od;
  od;

  RR := EmptyPlist(Length(R));
  LL := EmptyPlist(Length(L));

  for j in [1 .. Length(R)] do
    for i in [1 .. Length(L)] do
      if mat[i][j] <> 0 then
        RR[j] := ((mat[i][j] ^ -1) ^ inv) * L[i];
        break;
      fi;
    od;
  od;

  for i in [1 .. Length(L)] do
    for j in [1 .. Length(R)] do
      if mat[i][j] <> 0 then
        LL[i] := R[j] * (mat[i][j] ^ -1) ^ inv;
        break;
      fi;
    od;
  od;

  rms := constructor(G, mat);

  iso := function(x)
    i := PositionProperty(R, y -> y in RClass(D, x));
    j := PositionProperty(L, y -> y in LClass(D, x));

    if i = fail or j = fail then
      return fail;
    fi;
    return Objectify(TypeReesMatrixSemigroupElements(rms),
                     [i, (rep * RR[i] * x * LL[j]) ^ map, j, mat]);
  end;

  hom := MappingByFunction(D, rms, iso,
                           function(x)
                             if x![1] = 0 then
                               return fail;
                             fi;
                             return R[x![1]] * (x![2] ^ inv) * L[x![3]];
                           end);
  SetIsInjective(hom, true);
  SetIsTotal(hom, true);
  return hom;
end);

# same method for ideals

InstallMethod(IsMultiplicativeZero,
"for an acting semigroup and element",
[IsActingSemigroup, IsAssociativeElement],
function(S, x)
  return MultiplicativeZero(S) <> fail and x = MultiplicativeZero(S);
end);

# same method for ideals

InstallMethod(IsGreensDLeq, "for an acting semigroup",
[IsActingSemigroup],
function(S)
  local partial, data, comp_index;

  partial := PartialOrderOfDClasses(S);
  data := SemigroupData(S);

  comp_index := function(x, y)
    if y in partial[x] then
      return true;
    elif Length(partial[x]) = 1 and partial[partial[x][1]] = partial[x] then
      return false;
    fi;
    return ForAny(partial[x], z -> z <> x and comp_index(z, y));
  end;

  return function(x, y)
    return comp_index(OrbSCCLookup(data)[Position(data, x)] - 1,
                      OrbSCCLookup(data)[Position(data, y)] - 1);
  end;
end);

# different method for ideals/regular/inverse, although this method also works

InstallMethod(MaximalDClasses, "for an acting semigroup",
[IsActingSemigroup],
function(s)
  local gens, partial, data, pos, i, out, classes, x;

  gens := GeneratorsOfSemigroup(s);
  partial := PartialOrderOfDClasses(s);
  data := SemigroupData(s);
  pos := [];
  for x in gens do
    i := OrbSCCLookup(data)[Position(data, x)] - 1;
    #index of the D-class containing x
    AddSet(pos, i);
  od;

  out := [];
  classes := GreensDClasses(s);
  for i in pos do
    if not ForAny([1 .. Length(partial)], j -> j <> i and i in partial[j]) then
      Add(out, classes[i]);
    fi;
  od;

  return out;
end);

# same method for inverse, different method for inverse ideals

InstallMethod(MaximalDClasses, "for a regular acting semigroup",
[IsActingSemigroup and IsRegularSemigroup],
function(S)
  local gens, partial, pos, o, scc, out, classes, x, i;

  gens := GeneratorsOfSemigroup(S);
  partial := PartialOrderOfDClasses(S);
  pos := [];
  o := LambdaOrb(S);
  scc := OrbSCCLookup(o);

  for x in gens do
    #index of the D-class containing x
    AddSet(pos, scc[Position(o, LambdaFunc(S)(x))] - 1);
  od;

  out := [];
  classes := GreensDClasses(S);
  for i in pos do
    if not ForAny([1 .. Length(partial)], j -> j <> i and i in partial[j]) then
      Add(out, classes[i]);
    fi;
  od;

  return out;
end);

# same method for ideals

InstallMethod(StructureDescriptionSchutzenbergerGroups,
"for an acting semigroup", [IsActingSemigroup],
function(S)
  local o, scc, out, m;

  o := LambdaOrb(S);
  Enumerate(o, infinity);
  scc := OrbSCC(o);
  out := [];

  for m in [2 .. Length(scc)] do
    AddSet(out, StructureDescription(LambdaOrbSchutzGp(o, m)));
  od;

  return out;
end);

# same method for ideals

InstallMethod(StructureDescriptionMaximalSubgroups,
"for an acting semigroup", [IsActingSemigroup],
function(s)
  local out, d;

  out := [];
  for d in DClasses(s) do
    if IsRegularClass(d) then
      AddSet(out, StructureDescription(GroupHClass(d)));
    fi;
  od;

  return out;
end);

# same method for ideals

InstallMethod(GroupOfUnits, "for a transformation semigroup",
[IsTransformationSemigroup],
function(S)
  local r, g, deg, U;

  if MultiplicativeNeutralElement(S) = fail then
    return fail;
  fi;

  r := GreensRClassOfElementNC(S, MultiplicativeNeutralElement(S));
  g := SchutzenbergerGroup(r);
  deg := DegreeOfTransformationSemigroup(S);

  U := Monoid(List(GeneratorsOfGroup(g), x -> AsTransformation(x, deg)));

  SetIsomorphismPermGroup(U, MappingByFunction(U, g, PermutationOfImage,
                                               x -> AsTransformation(x, deg)));

  if not IsGroup(U) then
    SetIsGroupAsSemigroup(U, true);
  fi;
  UseIsomorphismRelation(U, g);

  return U;
end);

# same method for ideals

InstallMethod(GroupOfUnits, "for a partial perm semigroup",
[IsPartialPermSemigroup],
function(S)
  local r, g, deg, U;

  if MultiplicativeNeutralElement(S) = fail then
    return fail;
  fi;

  r := GreensRClassOfElementNC(S, MultiplicativeNeutralElement(S));
  g := SchutzenbergerGroup(r);
  deg := Maximum(DegreeOfPartialPermSemigroup(S),
                 CodegreeOfPartialPermSemigroup(S));

  U := Monoid(List(GeneratorsOfGroup(g), x -> AsPartialPerm(x, deg)));

  SetIsomorphismPermGroup(U, MappingByFunction(U, g, AsPermutation,
                                               x -> AsPartialPerm(x, deg)));

  if not IsGroup(U) then
    SetIsGroupAsSemigroup(U, true);
  fi;
  UseIsomorphismRelation(U, g);

  return U;
end);

# same method for ideals

InstallMethod(GroupOfUnits, "for a bipartition semigroup",
[IsBipartitionSemigroup],
function(S)
  local R, G, deg, U;

  if MultiplicativeNeutralElement(S) = fail then
    return fail;
  fi;

  R := GreensRClassOfElementNC(S, MultiplicativeNeutralElement(S));
  G := SchutzenbergerGroup(R);
  deg := DegreeOfBipartitionSemigroup(S);

  U := Monoid(List(GeneratorsOfGroup(G), x -> AsBipartition(x, deg)));

  SetIsomorphismPermGroup(U, MappingByFunction(U, G, AsPermutation,
                                               x -> AsBipartition(x, deg)));

  if not IsGroup(U) then
    SetIsGroupAsSemigroup(U, true);
  fi;
  UseIsomorphismRelation(U, G);

  return U;
end);

# same method for ideals

InstallMethod(GroupOfUnits, "for a Rees 0-matrix subsemigroup",
[IsReesZeroMatrixSubsemigroup],
function(S)
  local r, g, i, j, U;

  if MultiplicativeNeutralElement(S) = fail then
    return fail;
  fi;

  r := GreensRClassOfElementNC(S, MultiplicativeNeutralElement(S));
  g := SchutzenbergerGroup(r);
  i := MultiplicativeNeutralElement(S)![1];
  j := MultiplicativeNeutralElement(S)![3];

  U := Semigroup(List(GeneratorsOfGroup(g), x -> RMSElement(S, i, x, j)));

  if not IsGroup(U) then
    SetIsGroupAsSemigroup(U, true);
  fi;
  UseIsomorphismRelation(U, g);

  return U;
end);

InstallMethod(GroupOfUnits, "for an matrix over finite field semigroup",
[IsMatrixSemigroup],
function(S)
  local r, g, e, U;

  e := MultiplicativeNeutralElement(S);

  if e = fail then
    return fail;
  fi;

  r := GreensRClassOfElementNC(S, e);
  g := SchutzenbergerGroup(r);

  U := Monoid(GeneratorsOfGroup(g));

  if not IsGroup(U) then
    SetIsGroupAsSemigroup(U, true);
  fi;
  UseIsomorphismRelation(U, g);

  return U;
end);

# same method for ideals

InstallMethod(IdempotentGeneratedSubsemigroup, "for an acting semigroup",
[IsActingSemigroup], s -> Semigroup(Idempotents(s), rec(small := true)));

# same method for ideals

InstallMethod(IdempotentGeneratedSubsemigroup,
"for an inverse op acting semigroup", [IsActingSemigroupWithInverseOp],
s -> InverseSemigroup(Idempotents(s), rec(small := true)));

# same method for ideals

InstallMethod(InjectionPrincipalFactor, "for a Green's D-class (Semigroups)",
[IsGreensDClass and IsActingSemigroupGreensClass],
function(D)
  if not IsRegularDClass(D) then
    ErrorNoReturn("Semigroups: InjectionPrincipalFactor: usage,\n",
                  "the argument <D> must be a regular D-class,");
  fi;
  if NrHClasses(D) = NrIdempotents(D) then
    return SEMIGROUPS_InjectionPrincipalFactor(D, ReesMatrixSemigroup);
  fi;
  return SEMIGROUPS_InjectionPrincipalFactor(D, ReesZeroMatrixSemigroup);
end);

InstallMethod(IsomorphismReesMatrixSemigroup, "for a D-class",
[IsGreensDClass and IsActingSemigroupGreensClass],
function(D)
  if NrIdempotents(D) <> NrHClasses(D) then
    ErrorNoReturn("Semigroups: IsomorphismReesMatrixSemigroup: usage,\n",
                  "the D-class is not a subsemigroup,");
  fi;

  return InjectionPrincipalFactor(D);
end);

# same method for ideal

InstallMethod(IrredundantGeneratingSubset,
"for an associative element collection",
[IsAssociativeElementCollection],
function(coll)
  local gens, nrgens, deg, out, redund, i, f;

  if not (IsActingSemigroup(coll) or IsGeneratorsOfActingSemigroup(coll)) then
    Error("Semigroups: IrredundantGeneratingSubset: usage,\n",
          "<coll> must be a generators of an acting semigroup,");
    return;
  fi;

  if (IsSemigroup(coll) and HasGeneratorsOfSemigroup(coll)) or
      (HasIsSemigroupIdeal(coll) and IsSemigroupIdeal(coll)) then
    coll := ShallowCopy(GeneratorsOfSemigroup(coll));
  fi;

  if Size(coll) = 1 then
    return coll;
  fi;

  gens := Set(ShallowCopy(coll));
  nrgens := Length(gens);
  deg := ActionDegree(coll);
  coll := Permuted(coll, Random(SymmetricGroup(Length(coll))));
  Sort(coll, function(x, y)
               return ActionRank(x, deg) > ActionRank(y, deg);
             end);

  out := EmptyPlist(Length(coll));
  redund := EmptyPlist(Length(coll));
  i := 0;

  repeat
    i := i + 1;
    f := coll[i];
    if InfoLevel(InfoSemigroups) >= 3 then
      Print("at \t", i, " of \t", Length(coll), " with \t", Length(redund),
            " redundant, \t", Length(out), " non-redundant\r");
    fi;

    if not f in redund and not f in out then
      if f in Semigroup(Difference(gens, [f])) then
        AddSet(redund, f);
        gens := Difference(gens, [f]);
      else
        AddSet(out, f);
      fi;
    fi;
  until Length(redund) + Length(out) = nrgens;

  if InfoLevel(InfoSemigroups) > 1 then
    Print("\n");
  fi;
  return out;
end);

InstallMethod(IsomorphismReesMatrixSemigroup, "for a semigroup", [IsSemigroup],
function(S)
  local D, iso, inv;

  if not IsFinite(S) then
    TryNextMethod();
  fi;

  if not IsSimpleSemigroup(S) then
    ErrorNoReturn("Semigroups: IsomorphismReesMatrixSemigroup: usage,\n",
                  "the argument must be a simple semigroup,");
    #TODO is there another method? I.e. can we turn non-simple/non-0-simple
    # semigroups into Rees (0-)matrix semigroups over non-groups?
  fi;

  D := GreensDClasses(S)[1];
  iso := IsomorphismReesMatrixSemigroup(D);
  inv := InverseGeneralMapping(iso);
  return MagmaIsomorphismByFunctionsNC(S,
                                       Range(iso),
                                       x -> x ^ iso,
                                       x -> x ^ inv);
end);

InstallMethod(IsomorphismReesZeroMatrixSemigroup, "for an acting semigroup",
[IsActingSemigroup],
function(S)
  local D, iso, inv;

  if not IsFinite(S) then
    TryNextMethod();
  fi;

  if not IsZeroSimpleSemigroup(S) then
    ErrorNoReturn("Semigroups: IsomorphismReesZeroMatrixSemigroup: usage,\n",
                  "the argument must be a 0-simple semigroup,");
    #TODO is there another method? I.e. can we turn non-simple/non-0-simple
    # semigroups into Rees (0-)matrix semigroups over non-groups?
  fi;

  D := First(GreensDClasses(S),
             x -> not IsMultiplicativeZero(S, Representative(x)));
  iso := SEMIGROUPS_InjectionPrincipalFactor(D, ReesZeroMatrixSemigroup);
  inv := InverseGeneralMapping(iso);
  return MagmaIsomorphismByFunctionsNC(S, Range(iso),
                                       x -> x ^ iso, x -> x ^ inv);
end);

# same method for ideals

InstallMethod(InversesOfSemigroupElement,
"for an acting semigroup and associative element",
[IsActingSemigroup, IsAssociativeElement],
function(S, x)

  if x in S then
    return InversesOfSemigroupElementNC(S, x);
  fi;

  return fail;
end);

# different method for ideals

InstallMethod(InversesOfSemigroupElementNC,
"for an acting semigroup and associative element",
[IsActingSemigroup and HasGeneratorsOfSemigroup, IsAssociativeElement],
function(s, f)
  local regular, lambda, rank, rhorank, tester, j, o, rhos, opts, grades,
   rho_f, lambdarank, creator, inv, out, k, g, i, name, rho;

  regular := IsRegularSemigroup(s);

  if not (regular or IsRegularSemigroupElementNC(s, f)) then
    return [];
  fi;

  lambda := LambdaFunc(s)(f);
  rank := LambdaRank(s)(LambdaFunc(s)(f));
  rhorank := RhoRank(s);
  tester := IdempotentTester(s);
  j := 0;

  # can't use GradedRhoOrb here since there may be inverses not D-related to f
  # JDM is this really true?
  if HasRhoOrb(s) and IsClosed(RhoOrb(s)) then
    o := RhoOrb(s);
    rhos := EmptyPlist(Length(o));
    for i in [2 .. Length(o)] do
      if rhorank(o[i]) = rank and tester(lambda, o[i]) then
        j := j + 1;
        rhos[j] := o[i];
      fi;
    od;
  else

    opts := rec(treehashsize := SEMIGROUPS_OptionsRec(s).hashlen.M,
                gradingfunc := function(o, x) return rhorank(x); end,
                onlygrades := function(x, y) return x >= rank; end,
                onlygradesdata := fail);

    for name in RecNames(LambdaOrbOpts(s)) do
      opts.(name) := LambdaOrbOpts(s).(name);
    od;

    o := Orb(s, RhoOrbSeed(s), RhoAct(s), opts);
    Enumerate(o, infinity);

    grades := Grades(o);
    rhos := EmptyPlist(Length(o));
    for i in [2 .. Length(o)] do
      if grades[i] = rank and tester(lambda, o[i]) then
        j := j + 1;
        rhos[j] := o[i];
      fi;
    od;
  fi;
  ShrinkAllocationPlist(rhos);

  rho_f := RhoFunc(s)(f);
  lambdarank := LambdaRank(s);
  creator := IdempotentCreator(s);
  inv := LambdaInverse(s);

  out := [];
  k := 0;

  if HasLambdaOrb(s) and IsClosed(LambdaOrb(s)) then
    o := LambdaOrb(s);
    for i in [2 .. Length(o)] do
      if lambdarank(o[i]) = rank and tester(o[i], rho_f) then
        for rho in rhos do
          g := creator(lambda, rho) * inv(o[i], f);
          if regular or g in s then
            k := k + 1;
            out[k] := g;
          fi;
        od;
      fi;
    od;
  else
     opts := rec(treehashsize := SEMIGROUPS_OptionsRec(s).hashlen.M,
                 gradingfunc := function(o, x) return lambdarank(x); end,
                 onlygrades := function(x, y) return x >= rank; end,
                 onlygradesdata := fail);

    for name in RecNames(LambdaOrbOpts(s)) do
      opts.(name) := LambdaOrbOpts(s).(name);
    od;

    o := Orb(s, LambdaOrbSeed(s), LambdaAct(s), opts);
    Enumerate(o);
    grades := Grades(o);

    for i in [2 .. Length(o)] do
      if grades[i] = rank and tester(o[i], rho_f) then
        for rho in rhos do
          g := creator(lambda, rho) * inv(o[i], f);
          if regular or g in s then
            k := k + 1;
            out[k] := g;
          fi;
        od;
      fi;
    od;
  fi;

  return out;
end);

# same method for ideals

InstallMethod(MultiplicativeNeutralElement, "for an acting semigroup",
[IsActingSemigroup],
function(s)
  local gens, rank, lambda, max, r, rep, f;

  gens := Generators(s);
  rank := LambdaRank(s);
  lambda := LambdaFunc(s);
  max := 0;
  rep := gens[1];

  for f in gens do
    r := rank(lambda(f));
    if r > max then
      max := r;
      rep := f;
    fi;
  od;

  if max = ActionDegree(s) and IsMultiplicativeElementWithOneCollection(s) then
    return One(s);
  fi;

  r := GreensRClassOfElementNC(s, rep);

  if not NrIdempotents(r) = 1 then
    Info(InfoSemigroups, 2, "the number of idempotents in the R-class of the",
         " first maximum rank");
    Info(InfoSemigroups, 2, " generator is not 1");
    return fail;
  fi;

  f := Idempotents(r)[1];

  if ForAll(gens, x -> x * f = x and f * x = x) then
    return f;
  fi;

  Info(InfoSemigroups, 2, "the unique idempotent in the R-class of the first",
       " maximum rank");
  Info(InfoSemigroups, 2, " generator is not the identity");
  return fail;
end);

# it just so happens that the MultiplicativeNeutralElement of a semigroup of
# partial permutations has to coincide with the One. This is not the case for
# transformation semigroups

# same method for ideals

InstallMethod(MultiplicativeNeutralElement, "for a partial perm semigroup",
[IsPartialPermSemigroup], One);

# same method for ideals

InstallMethod(MultiplicativeZero, "for an acting semigroup",
[IsActingSemigroup],
function(s)
  local d, rep, gens;

  if IsSemigroupIdeal(s)
      and HasMultiplicativeZero(SupersemigroupOfIdeal(s)) then
    return MultiplicativeZero(SupersemigroupOfIdeal(s));
  fi;

  if HasMinimalDClass(s) then
    d := MinimalDClass(s);
    if HasSize(d) then
      if Size(d) = 1 then
        return Representative(d);
      else
        return fail;
      fi;
    fi;
  fi;

  if not HasGeneratorsOfSemigroup(s) then
    return MultiplicativeZero(SupersemigroupOfIdeal(s));
  fi;

  rep := RepresentativeOfMinimalIdeal(s);
  gens := GeneratorsOfSemigroup(s);
  if ForAll(gens, x -> x * rep = rep and rep * x = rep) then
    return rep;
  fi;

  return fail;
end);

# same method for ideals

InstallMethod(MinimalIdeal, "for an acting semigroup", [IsActingSemigroup],
function(S)
  local I;
  I := SemigroupIdeal(S, RepresentativeOfMinimalIdeal(S));
  SetIsSimpleSemigroup(I, true);
  return I;
end);

# same method for inverse/ideals

InstallMethod(RepresentativeOfMinimalIdeal,
"for a semigroup",
[IsSemigroup],
function(S)
  if IsSemigroupIdeal(S) and
      (HasRepresentativeOfMinimalIdeal(SupersemigroupOfIdeal(S))
       or not HasGeneratorsOfSemigroup(S)) then
    return RepresentativeOfMinimalIdeal(SupersemigroupOfIdeal(S));
  fi;

  # This catches known trivial semigroups
  # WW: The idea is to quickly get at an arbitrary element of the semigroup
  if HasIsSimpleSemigroup(S) and IsSimpleSemigroup(S) then
    return GeneratorsOfSemigroup(S)[1];
  fi;

  return RepresentativeOfMinimalIdealNC(S);
end);

InstallMethod(RepresentativeOfMinimalIdealNC,
"for an acting semigroup",
[IsActingSemigroup and HasGeneratorsOfSemigroup],
function(S)
  local rank, o, pos, min, len, m, i;

  rank := LambdaRank(S);
  o := LambdaOrb(S);

  pos := LookForInOrb(o, function(o, x)
                           return rank(x) = MinActionRank(S);
                         end, 2);

  if pos = false then
    min := rank(o[2]);
    pos := 2;
    len := Length(o);
    for i in [3 .. len] do
      m := rank(o[i]);
      if m < min then
        pos := i;
        min := m;
      fi;
    od;
  fi;

  return EvaluateWord(o, TraceSchreierTreeForward(o, pos));
end);

#

InstallMethod(MinimalDClass, "for an acting semigroup", [IsActingSemigroup],
x -> GreensDClassOfElementNC(x, RepresentativeOfMinimalIdeal(x)));

#

InstallMethod(PrincipalFactor, "for a D-class",
[IsGreensDClass and IsActingSemigroupGreensClass],
d -> Range(InjectionPrincipalFactor(d)));

#

InstallMethod(PrincipalFactor, "for a D-class",
[IsGreensDClass], AssociatedReesMatrixSemigroupOfDClass);

# different method for ideals, not yet implemented

InstallMethod(SmallSemigroupGeneratingSet,
"for an associative element collection",
[IsAssociativeElementCollection],
function(coll)
  if not IsGeneratorsOfActingSemigroup(coll) then
    TryNextMethod();
  elif Length(coll) < 2 then
    return coll;
  else
    return GeneratorsOfSemigroup(Semigroup(coll, rec(small := true)));
  fi;
end);

# different method for ideals, not yet implemented

InstallMethod(SmallSemigroupGeneratingSet,
"for an acting semigroup", [IsActingSemigroup],
S -> SmallSemigroupGeneratingSet(GeneratorsOfSemigroup(S)));

#

InstallMethod(SmallMonoidGeneratingSet,
"for an associative element with one collection",
[IsAssociativeElementCollection and IsMultiplicativeElementWithOneCollection],
function(coll)
  if not IsGeneratorsOfActingSemigroup(coll) then
    TryNextMethod();
  elif Length(coll) < 2 then
    return coll;
  else
    return GeneratorsOfMonoid(Monoid(coll, rec(small := true)));
  fi;
end);

# same method for ideals

InstallMethod(SmallMonoidGeneratingSet,
"for an acting monoid", [IsActingSemigroup and IsMonoid],
function(S)
  if IsEmpty(GeneratorsOfMonoid(S)) then
    return [];
  fi;
  return SmallMonoidGeneratingSet(GeneratorsOfMonoid(S));
end);

#

InstallMethod(SmallInverseSemigroupGeneratingSet,
"for generators of an inverse semigroup",
[IsGeneratorsOfInverseSemigroup],
function(coll)
  if not IsGeneratorsOfActingSemigroup(coll) then
    TryNextMethod();
  elif Length(coll) < 2 then
    return coll;
  else
    return GeneratorsOfInverseSemigroup(InverseSemigroup(coll,
                                                         rec(small := true)));
  fi;
end);

#

InstallMethod(SmallInverseSemigroupGeneratingSet,
"for an acting inverse semigroup with generators",
[IsActingSemigroup and IsInverseSemigroup],
S -> SmallSemigroupGeneratingSet(GeneratorsOfInverseSemigroup(S)));

#

InstallMethod(SmallInverseMonoidGeneratingSet,
"for generators of an inverse monoid",
[IsGeneratorsOfInverseSemigroup and IsMultiplicativeElementWithOneCollection],
function(coll)
  if not IsGeneratorsOfActingSemigroup(coll) then
    TryNextMethod();
  elif Length(coll) < 2 then
    return coll;
  else
    return GeneratorsOfInverseMonoid(InverseMonoid(coll, rec(small := true)));
  fi;
end);

#

InstallMethod(SmallInverseMonoidGeneratingSet,
"for an acting inverse semigroup with generators",
[IsActingSemigroup and IsInverseMonoid],
S -> SmallSemigroupGeneratingSet(GeneratorsOfInverseMonoid(S)));

#

InstallMethod(SmallGeneratingSet, "for a semigroup",
[IsSemigroup],
function(S)

  if HasGeneratorsOfSemigroupIdeal(S) then
    return MinimalIdealGeneratingSet(S);
  elif HasGeneratorsOfGroup(S) then
    return SmallGeneratingSet(GeneratorsOfGroup(S));
  elif HasGeneratorsOfInverseMonoid(S) then
    return SmallInverseMonoidGeneratingSet(S);
  elif HasGeneratorsOfInverseSemigroup(S) then
    return SmallInverseSemigroupGeneratingSet(S);
  elif HasGeneratorsOfMonoid(S) then
    return SmallMonoidGeneratingSet(S);
  fi;

  return SmallSemigroupGeneratingSet(S);
end);

#

InstallMethod(StructureDescription, "for an acting Brandt semigroup",
[IsActingSemigroup and IsBrandtSemigroup],
function(s)
  local x, d;

  x := First(Generators(s), x -> x <> MultiplicativeZero(s));
  d := GreensDClassOfElementNC(s, x);

  return Concatenation("B(", StructureDescription(GroupHClass(d)), ", ",
                       String(NrRClasses(d)), ")");
end);

# same method for ideals

InstallMethod(StructureDescription,
"for an acting group as semigroup",
[IsActingSemigroup and IsGroupAsSemigroup],
s -> StructureDescription(Range(IsomorphismPermGroup(s))));

#

InstallMethod(IsomorphismTransformationMonoid,
"for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
function(s)
  local id, dom, gens, inv;

  if IsMonoid(s) then
    return MappingByFunction(s, s, IdFunc, IdFunc);
  fi;

  if MultiplicativeNeutralElement(s) = fail then
    Error("Semigroups: IsomorphismTransformationMonoid: usage,\n",
          "the argument <s> must have a multiplicative neutral element,");
    return;
  fi;

  id := MultiplicativeNeutralElement(s);
  dom := ImageSetOfTransformation(id);

  gens := List(Generators(s), x -> TransformationOp(x, dom));

  inv := function(f)
    local out, i;

    out := [1 .. DegreeOfTransformationSemigroup(s)];
    for i in [1 .. Length(dom)] do
      out[dom[i]] := dom[i ^ f];
    od;
    return id * Transformation(out);
  end;

  return MappingByFunction(s,
                           Monoid(gens),
                           f -> TransformationOp(f, dom),
                           inv);
end);

# different method for ideals

InstallMethod(IsomorphismTransformationSemigroup,
"for a matrix semigroup with generators",
[IsMatrixSemigroup and HasGeneratorsOfSemigroup],
function(S)
  local n, F, T, M;
  n := DegreeOfMatrixSemigroup(S);
  F := BaseDomain(S);
  M := Elements(F ^ n);
  T := Semigroup(List(GeneratorsOfSemigroup(S),
                      x -> TransformationOp(x, M, OnRight)));
  return MappingByFunction(S, T,
                           x -> TransformationOp(x,
                                                 Elements(F ^ Size(F)),
                                                 OnRight));
end);

# same method for ideals

InstallMethod(IsomorphismPermGroup,
"for a transformation semigroup",
[IsTransformationSemigroup],
function(S)
  local G, id;

  if not IsGroupAsSemigroup(S) then
    ErrorNoReturn("Semigroups: IsomorphismPermGroup: usage,\n",
                  "the argument <S> must satisfy IsGroupAsSemigroup,");
  fi;

  G := Group(List(GeneratorsOfSemigroup(S), PermutationOfImage));
  UseIsomorphismRelation(S, G);
  id := MultiplicativeNeutralElement(S);

  return MagmaIsomorphismByFunctionsNC(S,
                                       G,
                                       PermutationOfImage,
                                       x -> id * x);
end);

# same method for ideals

InstallMethod(IsomorphismPermGroup, "for a partial perm semigroup",
[IsPartialPermSemigroup],
function(s)

  if not IsGroupAsSemigroup(s)  then
    Error("Semigroups: IsomorphismPermGroup: usage,\n",
          "the argument <s> must be a partial perm semigroup ",
          "satisfying IsGroupAsSemigroup,");
    return;
  fi;

  # gaplint: ignore 3
  return MagmaIsomorphismByFunctionsNC(s,
           Group(List(GeneratorsOfSemigroup(s), AsPermutation)),
           AsPermutation,
           x -> AsPartialPerm(x, DomainOfPartialPermCollection(s)));
end);

# same method for ideals

InstallMethod(IsomorphismPermGroup,
"for a subsemigroup of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup],
function(S)
  local rep;

  if not IsGroupAsSemigroup(S)  then
    Error("Semigroups: IsomorphismPermGroup: usage,\n",
          "the argument <S> must be a subsemigroup of a Rees 0-matrix ",
          "semigroup satisfying IsGroupAsSemigroup,");
    return;
  fi;

  rep := S.1;
  if rep![1] = 0 then # special case for the group consisting of 0
    return MagmaIsomorphismByFunctionsNC(S, Group(()), x -> (), x -> rep);
  fi;

  # gaplint: ignore 4
  return MagmaIsomorphismByFunctionsNC(S,
           Group(List(GeneratorsOfSemigroup(S), x -> x![2])),
           x -> x![2],
           x -> RMSElement(S, rep![1], x, rep![3]));
end);

# fall back method, same method for ideals

InstallMethod(IsomorphismPermGroup, "for a semigroup", [IsSemigroup],
function(S)
  local en, act, gens;

  if not IsGroupAsSemigroup(S)  then
    Error("Semigroups: IsomorphismPermGroup: usage,\n",
          "the argument must be a semigroup satisfying ",
          "IsGroupAsSemigroup,");
    return;
  fi;

  en := EnumeratorSorted(S);

  act := function(i, x)
    return Position(en, en[i] * x);
  end;

  gens := List(GeneratorsOfSemigroup(S),
               x -> Permutation(x, [1 .. Length(en)], act));

  # gaplint: ignore 3
  return MagmaIsomorphismByFunctionsNC(S, Group(gens),
           x -> Permutation(x, [1 .. Length(en)], act),
           x -> en[Position(en, MultiplicativeNeutralElement(S)) ^ x]);
end);

# not relevant for ideals

InstallMethod(IsomorphismTransformationSemigroup,
"for semigroup of binary relations with generators",
[IsSemigroup and IsGeneralMappingCollection and HasGeneratorsOfSemigroup],
function(s)
  local n, pts, o, t, pos, i;
  if not IsBinaryRelationOnPointsRep(Representative(s)) then
    TryNextMethod();
  fi;
  n := DegreeOfBinaryRelation(GeneratorsOfSemigroup(s)[1]);
  pts := EmptyPlist(2 ^ n);

  for i in [1 .. n] do
    o := Orb(s, [i], OnPoints); #JDM multiseed orb
    Enumerate(o);
    pts := Union(pts, AsList(o));
  od;
  ShrinkAllocationPlist(pts);
  pos := List([1 .. n], x -> Position(pts, [x]));
  t := Semigroup(List(GeneratorsOfSemigroup(s),
                      x -> TransformationOpNC(x, pts, OnPoints)));
  # gaplint: ignore 3
  return MappingByFunction(s, t,
           x -> TransformationOpNC(x, pts, OnPoints),
           x -> BinaryRelationOnPoints(List([1 .. n], i -> pts[pos[i] ^ x])));
end);

# not relevant for ideals

InstallMethod(Size, "for a monogenic transformation semigroup",
[IsTransformationSemigroup and IsMonogenicSemigroup],
function(s)
  local ind;

  ind := IndexPeriodOfTransformation(GeneratorsOfSemigroup(s)[1]);
  if ind[1] > 0 then
    return Sum(ind) - 1;
  fi;
  return Sum(ind);
end);

InstallMethod(UnderlyingSemigroupOfSemigroupWithAdjoinedZero,
"for a semigroup",
[IsSemigroup],
function(S)
  local zero, gens, T;

  if HasIsSemigroupWithAdjoinedZero(S)
      and not IsSemigroupWithAdjoinedZero(S) then
    return fail;
  fi;

  zero := MultiplicativeZero(S);
  if zero = fail then
    return fail;
  fi;

  gens := GeneratorsOfSemigroup(S);
  if Length(gens) = 1 then
    return fail;
  fi;
  if not zero in gens then
    return fail;
  fi;

  T := Semigroup(Difference(gens, [zero]));

  if zero in T then
    return fail;
  fi;
  return T;
end);
