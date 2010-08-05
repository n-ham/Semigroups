#############################################################################
##
#W  greens_orb.gi
#Y  Copyright (C) 2006-2010                             James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## $Id: greens.gd 54 2010-07-06 11:09:37Z jamesm $

#############################################################################
## Notes

# - this file is alphabetized, keep it that way!

# - it can be that when you are doing iterator of orbits of images that 
# you create an orbit that is later contained in another orbit
# this will lead to the later orbit not have all of its reps, etc defined. 
# What should be done about the above comment?

# - make test files, write documentation

# - make this file only contain things relating to images/r-classes, and have
# a separate file for those relating to l-classes/kernels, and d-classes etc.

## new for 3.2!
#############################################################################
##  Algorithm E. 

InstallMethod( \in, "for trans. and R-class of trans. semigp.", 
[IsTransformation, IsGreensRClass and IsGreensClassOfTransSemigp],
function(f, r)
local rep, d, o, i, schutz, s;

rep:= r!.rep; 

if DegreeOfTransformation(f) <> DegreeOfTransformation(rep) or
 RankOfTransformation(f) <> RankOfTransformation(rep) or
 KernelOfTransformation(f) <> KernelOfTransformation(rep) then
	return false;
fi;

if f=rep then 
	return true;
fi;

d:=r!.data;
s:=r!.parent;

# check image is in the same weak orbit
o:=RClassImageOrbitFromData(s, d);
i:= Position(o, ImageSetOfTransformation(f));

if i = fail or not o!.truth[d[4]][i] then #check they are in the same scc
	return false;
fi;

schutz:= RClassSchutzGpFromData(s, d)[1];

return schutz=true or SiftedPermutation(schutz, 
 PermLeftQuoTransformationNC(rep, f*o!.perms[i]))=();
end);

# new for 3.2!
#############################################################################
# Algorithm D.

# IteratorOfRClassElements...

InstallOtherMethod(AsList, "for R-class of trans. semigp.", 
[IsGreensRClass and IsGreensClassOfTransSemigp], 
function(r)
local f, s, d, h, elts, p;

f:=r!.rep; #rep should have its image at the first place in the scc
s:=r!.parent;
d:=r!.data;

h:=List(RClassSchutzGpFromData(s, d)[2], x-> f*x);
#JDM is schutz not the H-class containing f?

elts:=[];

for p in RClassPermsFromData(s, d){RClassSCCFromData(s, d)} do 
	elts:=Concatenation(elts, h*p^-1);
od;
return elts;
end);

# new for 3.2!
#############################################################################
#

InstallOtherMethod(AsSSortedList, "for R-class of trans. semigp.",
[IsGreensRClass and IsGreensClassOfTransSemigp], 
r-> EnumeratorSorted(r));

# new for 3.2!
#############################################################################
# Algorithm W.

#InstallOtherMethod(AsSSortedList, "for a transformation semigroup",
#[IsTransformationSemigroup],
#function(s)
#local elts, rrel;

#elts:=Union(List(GreensRClasses(M), Elements));
#if not HasSize(M) then
#	SetSize(M, Size(elts));
#fi;

#return elts;
#end);

# new for 3.2!
#############################################################################
# o is the orbit
# i is the index of the scc of o we are trying to create the Schreier tree for!

InstallGlobalFunction(CreateSchreierTreeOfSCC,
function(o, i)
local gen, pos, seen, oo, graph, j, k, l, scc, t;

#if IsBound(o!.trees[i]) then 
#  Error("Schreier tree already created for this scc");
#fi;

if i=1 then 
  return [o!.schreiergen, o!.schreierpos];
fi;

scc:=o!.scc[i];

gen:=List([1..Length(o)], x-> fail);
pos:=List([1..Length(o)], x-> fail);
seen:=BlistList([1..Length(o)], [scc[1]]);
t:=o!.truth[i];
oo:=[scc[1]];
graph:=OrbitGraph(o);
j:=0;

while Length(oo)<Length(scc) do 
  j:=j+1;
	k:=oo[j];
	l:=0;
	while l<Length(graph[k]) and Length(oo)<Length(scc) do  
		l:=l+1;
		if IsBound(graph[k][l]) and not seen[graph[k][l]] and t[graph[k][l]] then 
			Add(oo, graph[k][l]); seen[graph[k][l]]:=true; 
			gen[graph[k][l]]:=l; pos[graph[k][l]]:=k;
		fi;
	od;
od;

return [gen, pos];
end);

# new for 3.2!
#############################################################################
#

InstallGlobalFunction(CreateReverseSchreierTreeOfSCC,
function(o, i)
local rev, j, k, l, m, graph, scc, gen, pos, seen, t, oo; 

graph:=OrbitGraph(o);
rev:=List([1..Length(graph)], x-> List([1..Length(o!.gens)], x-> []));

for j in [1..Length(graph)] do
  for k in [1..Length(graph[j])] do 
    if IsBound(graph[j][k]) then 
      Add(rev[graph[j][k]][k], j);
    fi;
  od;
od;

scc:=o!.scc[i];

gen:=List([1..Length(o)], x-> fail);
pos:=List([1..Length(o)], x-> fail);
seen:=BlistList([1..Length(o)], [scc[1]]);
t:=o!.truth[i];
oo:=[scc[1]];

j:=0;

while Length(oo)<Length(scc) do 
  j:=j+1;
  k:=oo[j];
  l:=0;
  while l< Length(rev[k]) and Length(oo)<Length(scc) do 
    l:=l+1;
    m:=0;
    while m< Length(rev[k][l]) and Length(oo)<Length(scc) do 
      m:=m+1;
      if not seen[rev[k][l][m]] and t[rev[k][l][m]] then 
        Add(oo, rev[k][l][m]); seen[rev[k][l][m]]:=true;
        gen[rev[k][l][m]]:=l; pos[rev[k][l][m]]:=k;
      fi;
    od;
  od;
od;


return [gen, pos];
end);

# new for 3.2!
#############################################################################
#

InstallOtherMethod(Enumerator, "for R-class of trans. semigp.", 
[IsGreensRClass and IsGreensClassOfTransSemigp], 
function(r)
local enum;

enum:=EnumeratorByFunctions(r, rec(
	
	rep:=r!.rep,
	
	h:=List(Elements(RClassSchutzGpFromData(r!.parent, r!.data)[2]), x-> 
	r!.rep*x), 
	#maybe use enum here too? JDM
	
	p:=RClassPermsFromData(r!.parent, r!.data),
	
	scc:=RClassSCCFromData(r!.parent, r!.data),
	
	###########################################################################
	
	ElementNumber:=function(enum, pos)
	
		if pos>Length(enum) then 
			return fail;
		fi;
		
		if pos<=Length(enum!.h) then 
			return enum!.h[pos];
		fi;
		
		pos:=QuotientRemainder(pos-1, Length(enum!.h))+1;
		
		return enum!.h[pos[2]]*enum!.p[enum!.scc[pos[1]]]^-1;
	end, 
	
	###########################################################################
	
	NumberElement:=function(enum, f)
		local rep, d, s, o, i, j;
		rep:=enum!.rep;
	
		if DegreeOfTransformation(f) <> DegreeOfTransformation(rep) or
		 RankOfTransformation(f) <> RankOfTransformation(rep) or
		 KernelOfTransformation(f) <> KernelOfTransformation(rep) then
			return fail;
		fi;
		
		if f=rep then 
			return 1;
		fi;
		
		d:=r!.data;
		s:=r!.parent;
		
		# check image is in the same weak orbit
		o:=RClassImageOrbitFromData(s, d);
		i:= Position(o, ImageSetOfTransformation(f));
		
		if i = fail or not o!.truth[d[4]][i] then #check they are in the same scc
			return fail;
		fi;
		
		j:= Position(Elements(RClassSchutzGpFromData(s, d)[2]),
		 PermLeftQuoTransformationNC(rep, f*o!.perms[i]));
		
		if j = fail then 
			return fail;
		fi;
		
		return Length(enum!.h)*(Position(enum!.scc, i)-1)+j;

	end, 

	###########################################################################

	Length:=enum -> Size(r),

	PrintObj:=function(enum)
	Print( "<enumerator of R-class of ", r!.rep ,">");
	return;
	end));

return enum;
end);

#new for 3.2!
#############################################################################
# consider what to do here really! In particular, if 
# OrbitsOfImages(s)!.finished=true, but we don't have GreensRClasses, 
# then is the following really the best?

InstallOtherMethod(Enumerator, "for a transformation semigroup", 
[IsTransformationSemigroup], 
function(s)
local out, iter, i;

out:=[];
iter:=Iterator(s);

for i in iter do 
	out[Length(out)+1]:=i;
od;

return Enumerator(out);
end);

#new for 3.2!
#############################################################################

InstallGlobalFunction(ForwardOrbitOfImage, 
function(s, f)
local img, i, o;

#img:=Set(f![1]);
img:=ImageSetOfTransformation(f);
o:=OrbitsOfImages(s)!.orbits;

if IsBound(o[Length(img)]) then 
  i:=Position(o[Length(img)], x-> img in x);
else
  i:=fail;
fi;

if not i=fail then 
  return o[i];
fi;

return ForwardOrbitOfImageNC(s, f);
end);

#new for 3.2!
#############################################################################

InstallGlobalFunction(ForwardOrbitOfImageNC, 
#function(arg)
function(s, f)
local img, o, scc, t, i, gens, g, bound, graph, j, schutz, schreier, O;
Info(InfoWarning, 2, "Warning: calling this function more than once with the ",
" same arguments will repeatedly add the returned value to OrbitsOfImages. ",
"Use ForwardOrbitOfImage instead.");

#s:=arg[1]; f:=arg[2];

#if Length(arg)=3 then 
#  schreier:=arg[3].schreier;
#else 
#  schreier:=false;
#fi;

if IsMonoid(s) then 
	gens:=GeneratorsOfMonoid(s);
else
	gens:=GeneratorsOfSemigroup(s);
fi;

#img:=Set(f![1]);
img:=ImageSetOfTransformation(f);
o:=Orb(s, img, OnSets, rec(
        treehashsize:=NextPrimeInt(Minimum(100000, 
         3*Binomial(DegreeOfTransformationSemigroup(s), Length(img)))), 
        schreier:=true,
        gradingfunc := function(o,x) return Length(x); end, 
        orbitgraph := true, 
        onlygrades:=[Length(img)], 
        storenumbers:=true));
Enumerate(o);

#strongly connected components
scc:=Set(List(STRONGLY_CONNECTED_COMPONENTS_DIGRAPH(List(OrbitGraph(o), Set)), 
 Set));;
o!.scc:=scc;

#boolean list corresponding to membership in scc[i]
t:=List([1..Length(scc)], i-> BlistList([1..Length(o)], scc[i]));
o!.truth:=t;

#Schreier trees for strongly connected components
o!.trees:=EmptyPlist(Length(scc));
o!.trees[1]:=CreateSchreierTreeOfSCC(o,1);

#representatives of R-classes with image belonging in scc[i] partitioned 
#according to their kernels
o!.reps:=List([1..Length(scc)], x-> []);
Add(o!.reps[1], [f]);


#if schreier then 
#	o!.words:=List([1..Length(scc)], x-> []);
#	o!.reverse:=EmptyPlist(Length(scc));
#	o!.reverse[1]:=CreateReverseSchreierTreeOfSCC(o,1);
#fi;

#kernels of representatives of R-classes with image belonging in scc[i]
o!.kernels_ht:=[];
Add(o!.kernels_ht, HashTableForKernels(KernelOfTransformation(f)));

#calculate the multipliers and schutzenberger groups for the scc containing
#img. 
scc:=scc[1];

#multipliers of scc containing the image of f
o!.perms:=EmptyPlist(Length(o));
#o!.perms:=MultipliersOfSCCOfOrbit(o, 1, rec(schreier:=schreier));
o!.perms:=MultipliersOfSCCOfOrbit(gens, o, 1);

#schutzenberger group corresponding to scc[1]
o!.schutz:=EmptyPlist(Length(scc));
o!.schutz[1]:=SchutzenbergerGroupOfSCCOfOrbit(gens, o, f, 1);

#OrbitsOfImages is partitioned according to image size of the first element in 
# each component!

O:=OrbitsOfImages(s);

if IsBound(O!.orbits[Length(img)]) then 
  Add(O!.orbits[Length(img)], o);
else
  O!.orbits[Length(img)]:=[o];
fi;

O!.data[Length(O!.data)+1]:=[Length(img), Length(O!.orbits[Length(img)]), 
 1, 1, 1, 1];

return o;
end);

# new for 3.2!
#############################################################################
# JDM JDM 
# test the efficiency of this function!

InstallMethod(GreensRClasses, "for a transformation semigroup", 
[IsTransformationSemigroup], 
function(s)
local iter, out, i;

iter:=IteratorOfGreensRClasses(s);
out:=EmptyPlist(Length(OrbitsOfImages(s)!.data));
#JDM is the previous a good idea?

for i in iter do 
	out[Length(out)+1]:=i;
od;

return out;
end);

# new for 3.2!
#############################################################################

InstallMethod(GreensRClassReps, "for a trans. semigroup", 
[IsTransformationSemigroup], 
function(s)
local iter, i, o;

o:=OrbitsOfImages(s);

if not o!.finished then 
	iter:=IteratorOfRClassReps(s);
	iter!.i:=Length(o!.data); 
	# avoids running through those already found.
	for i in iter do od;
fi;

return List(o!.data, x-> RClassRepFromData(s, x));
end);

# new for 3.2!
############################################################################
# this should be removed as the IteratorOfRClassReps runs in approximately 
# the same length of time...

# this should be moved to the graveyard... the schreier parts are still useful!


InstallGlobalFunction(GreensRClassRepsNC,
function(arg)
#function(s)
local n, one, gens, O, o, i, j, img, k, l, m, x, ht, y, val, reps, 
 schutz, new, kernels_ht, z, schreier, o_words, x_word, words, s, report, 
 last_report, oo;

s:=arg[1];

if Length(arg)=2 then
  if "schreier" in RecNames(arg[2]) then 
	  schreier:=arg[2].schreier;
	elif "report" in RecNames(arg[2]) then 
	  report:=arg[2].report; last_report:=0;
	fi;
else 
	schreier:=false; report:=false;
fi;

oo:=OrbitsOfImages(s);
i:=oo.at;
gens := oo.gens;
n := oo.deg;
one := oo.one;
ht:= oo.ht;
o := ht!.o;
O := oo.orbits;

##o_words:=[fail];
##x_word:=[];

while i<Length(o) do 
  i:=i+1;
  if not report=false and i>last_report+report then 
    #Info(InfoWarning, 1, Length(o), " candidates, ", Size(O), " elements, ",
    #NrRClassesOrbitsOfImages(O), " R-classes");
    last_report:=i;
  fi;
  
  #img := Set(o[i]![1]);
  img:=ImageSetOfTransformation(o[i]);
  j:=Length(img);
  new:=false;

  #check if img has been seen before
  if IsBound(O[j]) then
    k:=0;
    repeat
      k:=k+1;
      l:=Position(O[j][k], img);
    until not l=fail or k=Length(O[j]);
    
    if l=fail then k:=fail; fi;
  else 
    k:=fail;
  fi;

	if k = fail then #img has not been seen before
		new:=true; x:=o[i]; 
		
		if IsTransformationMonoid( s ) or not o[i] = one then
			ForwardOrbitOfImageNC(s, o[i]);
			#ForwardOrbitOfImageNC(s, o[i], rec(schreier:=schreier));
			#if schreier then 
			#  x_word:=o_words[i];
			#  Add(O[j][Length(O[j])]!.words[1], [x_word]);
			#fi;
		fi;
		
	else #img has been seen before
		if IsTransformationMonoid( s ) or not o[i] = one then
			
			m:=PositionProperty(O[j][k]!.truth, x-> x[l]); #the scc containing img
			reps:=O[j][k]!.reps[m];
			
			#if schreier then 
			#  words:=O[j][k]!.words[m];
			#fi;
			
			#calculate multipliers and schutz!
			if not IsBound(O[j][k]!.perms[l]) then #we never considered this scc before!
			  O[j][k]!.trees[m]:=CreateSchreierTreeOfSCC(O[j][k], m);
			  #if schreier then 
				#  O[j][k]!.reverse[m]:=CreateReverseSchreierTreeOfSCC(O[j][k], m);
				#  x_word:=Concatenation(o_words[i], TraceSchreierTreeOfSCCBack(O[j][k], m, l));
				#  words[Length(reps)+1]:=[x_word];
				#fi;
			  #O[j][k]!.perms:=MultipliersOfSCCOfOrbit(O[j][k], m, rec(schreier:=schreier));
			  O[j][k]!.perms:=MultipliersOfSCCOfOrbit(gens, O[j][k], m);
			  x:= o[i] * O[j][k]!.perms[l];
			  O[j][k]!.schutz[m]:=SchutzenbergerGroupOfSCCOfOrbit(gens, O[j][k], x, m);;
			  O[j][k]!.kernels_ht[m]:=HashTableForKernels(KernelOfTransformation( x ));
				reps[Length(reps)+1]:=[x]; 
				new:=true; 

			else
				kernels_ht:=O[j][k]!.kernels_ht[m];

				x := o[i] * O[j][k]!.perms[l];
				val:=HTValue(kernels_ht, KernelOfTransformation(x));
				
				if not val=fail then #kernel seen before
					schutz:=O[j][k]!.schutz[m][1];
					if not ForAny(reps[val], y-> schutz=true or 
					 SiftedPermutation(schutz, PermLeftQuoTransformationNC(y, x))=()) then 
						reps[val][Length(reps[val])+1]:=x; 
						new:=true;
						#if schreier then 
						#  x_word:=Concatenation(o_words[i], 
				  	#	 TraceSchreierTreeOfSCCBack(O[j][k], m, l));
				  	#	words[val][Length(reps[val])]:=x_word;
						#fi;
						
					fi;
				else #new kernel
					reps[Length(reps)+1]:=[x]; 
					#if schreier then 
					#  x_word:=Concatenation(o_words[i], 
					#   TraceSchreierTreeOfSCCBack(O[j][k], m, l));
					#  words[Length(reps)]:=[x_word];
					#fi;
					HTAdd(kernels_ht, KernelOfTransformation( x ), 
					 Length(reps));
					new:=true; 
				fi;
			fi;
		fi;
	fi;

	if new then #install new pts in the orbit
		for y in [1..Length(gens)] do
		  z:=gens[y]*x; 
		  if HTValue(ht, z)=fail then  
		    HTAdd(ht, z, true);
		    o[Length(o)+1]:=z;
		    #if schreier then
		    #  if not x_word=fail then  
		    #   o_words[Length(o)]:=Concatenation([y], x_word);
		    #  else 
		    #    o_words[Length(o)]:=[y];
		    #  fi;
		    #fi;
		  fi;
		od;
	fi;
od;

oo!.finished:=true; # all info is known!
oo!.at:=i;
return [i, O];
#return Flat(List(O, x-> List(x, y-> y!.reps)));
end);

# new for 3.2!
#############################################################################
# iterator and enumerator of idempotents JDM

# check the following for efficiency!

InstallOtherMethod( Idempotents, "for a R-class of a trans. semigp.",
[IsGreensRClass and IsGreensClassOfTransSemigp], 
function(r)
local out, ker, img, o, i;

out:= EmptyPlist(Size(r));
ker:= KernelOfTransformation(r!.rep);
img:=r!.rep![1];
o:=RClassImageOrbitFromData(r!.parent, r!.data){RClassSCCFromData(r!.parent,
 r!.data)};

for i in o do
	if IsDuplicateFreeList(img{i}) then
		out[Length(out)+1]:=IdempotentNC(ker, i);
	fi;
od;

return out;
end);

# new for 3.2!
#############################################################################

InstallGlobalFunction(InOrbitsOfImages, 
function(s, f)
local O, img, j, k, l, m, val, schutz;

O:=OrbitsOfImages(s);

#is the following worth it?

if not HTValue(O!.ht, f)=fail then 
	return true;
fi;

O:=O!.orbits;

img:=ImageSetOfTransformation(f);
j:=Length(img);

if not IsBound(O[j]) then
	return false;
fi;

k:=0;

repeat
	k:=k+1;
	l:=Position(O[j][k], img);
until not l=fail or k=Length(O[j]);

if l = fail then 
	return false;
fi;

m:=PositionProperty(O[j][k]!.truth, x-> x[l]);

if not IsBound(O[j][k]!.kernels_ht[m]) then 
	return false;
fi;

val:=HTValue(O[j][k]!.kernels_ht[m], KernelOfTransformation(f));

if val=fail then 
  return false;
fi;

schutz:=O[j][k]!.schutz[m][1];

return schutz or ForAny(O[j][k]!.reps[m][val], x-> SiftedPermutation(schutz, 
 PermLeftQuoTransformationNC(x, f*O[j][k]!.perms[l]))=());
end);

# new for 3.2!
#############################################################################
# this could be moved to greens.gi... 
# it could probably be more efficient (and complicated) if 
# lower level things were used that R-classes.
# should AsSSortedList be set after this is complete?

# need Enumerator method but that's 

InstallMethod(Iterator, "for a transformation semigroup",
[IsTransformationSemigroup], 
function(s)
local iter;

iter:= IteratorByFunctions( rec( 
	
	R:=IteratorOfGreensRClasses(s), 
	
	r:=fail,
	
	NextIterator:=function(iter)
	
	if IsDoneIterator(iter) then 
		return fail;
	fi;
	
	if iter!.r=fail or IsDoneIterator(iter!.r) then 
		iter!.r:=Iterator(NextIterator(iter!.R));
	fi;
	
	return NextIterator(iter!.r);
	end,
	
	IsDoneIterator:= iter -> IsDoneIterator(iter!.R) and IsDoneIterator(iter!.r),
	
	ShallowCopy:= iter -> rec(R:=IteratorOfGreensRClasses(s), r:=fail)
));

SetIsIteratorOfSemigroup(iter, true);

return iter;
end);


# new for 3.2!
#############################################################################
# if we do this until IsDoneIterator then shouldn't we store all the RClasses?
# I guess not. This will make the iterator more complicated and involve
# storing the already produced R-classes somewhere. Better just set 
# GreensRClasses by making one instance of this iterator and running through it.

# if not, then should we provide an EnumeratorOfGreensRClasses command for the
# situation when OrbitsOfImages(s)!.finished=true but GreensRClasses has not
# been defined? Probably not in the first instance. Storing the RClasses only 
# really requires storing their representatives and 6 small ints per class. 
# Hence if we can't store this, then we probably can't reach the end of the 
# iterator in the first place.

InstallGlobalFunction(IteratorOfGreensRClasses, 
function(s)
local iter;

iter:=IteratorByFunctions( rec(
	
	i:=0,
	
	type:=NewType( FamilyObj( s ), IsEquivalenceClass and 
	 IsEquivalenceClassDefaultRep and IsGreensRClass and 
	 IsGreensClassOfTransSemigp),
	
	s:=s, 
	
	reps:=IteratorOfRClassReps(s),
	
	IsDoneIterator := iter -> IsDoneIterator(iter!.reps), 
	
	NextIterator:= function(iter)
	local c, rep;
	
	rep:=NextIterator(iter!.reps);
	
	if rep=fail then 
		return fail;
	fi;
	
	iter!.i:=iter!.i+1;
	
	#c:=GreensRClassOfElement(iter!.s, rep, type);
	c:=Objectify( iter!.type, rec(parent:=s, 
	 data:=OrbitsOfImages(s)!.data[iter!.i], rep:=rep));
	SetRepresentative(c, rep);
	SetEquivalenceClassRelation(c, GreensRRelation(s));
	return c; end,
	
	ShallowCopy:=iter-> rec(i:=0, s:=iter!.s, reps:=IteratorOfRClassReps(s))
));

SetIsIteratorOfGreensRClasses(iter, true);

return iter;
end);

# new for 3.2!
#############################################################################
# add some more info statements?

InstallGlobalFunction(IteratorOfRClassReps, 
function(s)
local iter;

iter:=IteratorByFunctions( rec(
			
			IsDoneIterator := iter-> iter!.chooser(iter, IsDoneIterator)=fail,
			
			NextIterator := iter-> iter!.chooser(iter, NextIterator),
			
			ShallowCopy := iter -> rec( i:=0, s:=iter!.s, 
			last_called := NextIterator, last_value := 0, 
			chooser:=iter!.chooser, next:=iter!.next),
			
			i:=0, # in case one iterator is started but not finished, then 
			      # another iterator is started. 
			
			s:= s,
			
			last_called := NextIterator,
				
			last_value := 0,
			
			######################################################################
			
			chooser := function( iter, called_by )
			local o;
			
			if iter!.last_called = IsDoneIterator then 
				iter!.last_called := called_by;
				return iter!.last_value; 
			fi;

			if iter!.last_called = NextIterator then
				iter!.last_called := called_by;
				if iter!.last_value=fail then 
					return fail;
				fi;
				
				o:=OrbitsOfImages(iter!.s);
				
				if iter!.i < Length(o!.data) then 
					# we already know this rep
					iter!.i:=iter!.i+1;
					iter!.last_value:=RClassRepFromData(iter!.s, 
					 o!.data[iter!.i]);
				elif o!.finished then  
					iter!.last_value:=fail;
				else
					# must find a new rep if it exists
					iter!.i:=o!.at;
					iter!.last_value:=iter!.next(iter);
				fi;
				return iter!.last_value;
			fi;
			
			end,
			
			######################################################################

			next:=function(iter) 
			local O, o, j, img, k, l, m, x, ht, y, val, reps, schutz, new, kernels_ht, 
			z, schreier, report, last_report, n, gens, s, one, i, data, oo;
			
			s := iter!.s;
			oo:=OrbitsOfImages(s);
			gens := oo!.gens;
			n := oo!.deg;
			one := oo!.one;
			ht:= oo!.ht;
			o := ht!.o;
			O := oo!.orbits;
			data := oo!.data;
			
			if iter!.i=Length(o) then 
				oo!.finished:=true;
				return fail;
			fi;
			
			iter!.i:=iter!.i+1;
			oo!.at:=iter!.i;
			i := iter!.i;

			if iter!.i=1 then 
				HTAdd(ht, one, true);
			fi;

			img:=ImageSetOfTransformation(o[i]);
			j:=Length(img);
			new:=false;
			
			#check if img has been seen before
			if IsBound(O[j]) then
				k:=0;
				repeat
					k:=k+1;
					l:=Position(O[j][k], img);
				until not l=fail or k=Length(O[j]);
				
				if l=fail then k:=fail; fi;
			else 
				k:=fail;
			fi;
		
			if k = fail then #img has not been seen before
				new:=true; x:=o[i]; 
				
				if IsTransformationMonoid( s ) or not o[i] = one then
					ForwardOrbitOfImageNC(s, o[i]);
					#scheier words here!
				fi;
				
			else #img has been seen before
				if IsTransformationMonoid( s ) or not o[i] = one then
					
					m:=PositionProperty(O[j][k]!.truth, x-> x[l]); #the scc containing img
					reps:=O[j][k]!.reps[m];
					
					#scheier words here!
					
					if not IsBound(O[j][k]!.perms[l]) then 
						#we never considered this scc before!
						O[j][k]!.trees[m]:=CreateSchreierTreeOfSCC(O[j][k], m);
						
						#schreier words here
						
						O[j][k]!.perms:=MultipliersOfSCCOfOrbit(gens, O[j][k], m);
						x:= o[i] * O[j][k]!.perms[l];
						O[j][k]!.schutz[m]:=SchutzenbergerGroupOfSCCOfOrbit(gens, 
						 O[j][k], x, m);;
						O[j][k]!.kernels_ht[m]:=
						 HashTableForKernels(KernelOfTransformation( x ));
						reps[Length(reps)+1]:=[x];
						data[Length(data)+1]:=[j, k, l, m, 1, 1];
						new:=true; 
		
					else #we have considered scc before
						kernels_ht:=O[j][k]!.kernels_ht[m];
						x := o[i] * O[j][k]!.perms[l];
						val:=HTValue(kernels_ht, KernelOfTransformation(x));
						
						if not val=fail then #kernel seen before
							schutz:=O[j][k]!.schutz[m][1];
							if not ForAny(reps[val], y-> schutz=true or 
							 SiftedPermutation(schutz, 
							 PermLeftQuoTransformationNC(y, x))=()) then 
								reps[val][Length(reps[val])+1]:=x;
								data[Length(data)+1]:=[j, k, l, m, val, Length(reps[val])];
								new:=true;
								#schreier words here
							fi;
						else #new kernel
							reps[Length(reps)+1]:=[x];
							data[Length(data)+1]:=[j, k, l, m, Length(reps), 1];
							#schreier words here
							HTAdd(kernels_ht, KernelOfTransformation( x ), 
							 Length(reps));
							new:=true; 
						fi;
					fi;
				fi;
			fi;
			
			if new then #install new pts in the orbit
				
				for y in [1..Length(gens)] do
					z:=gens[y]*x; 
					if HTValue(ht, z)=fail then  
						HTAdd(ht, z, true);
						o[Length(o)+1]:=z;
						#schreier words here
					fi;
				od;
				
				if (IsTransformationMonoid( s ) or not o[i] = one) then 
					return x;
				fi;
			fi;
			
			return iter!.next(iter);
			end
			######################################################################
));

SetIsIteratorOfRClassReps(iter, true);
SetSemigroupOfIteratorOfRClassReps(iter, s);

return iter;
end);

# new for 3.2!
#############################################################################
# <j> is the index of the scc we are computing the multipliers for!

InstallGlobalFunction(MultipliersOfSCCOfOrbit,
#function(arg)
function(gens, o, j)
local i, p, f, scc, schreier;

#o:=arg[1]; j:=arg[2]; 
#gens:=o!.gens;

#if Length(arg)=3 then 
#  schreier:=arg[3].schreier;
#else
#  schreier:=false;
#fi;

p:=o!.perms;
scc:=o!.scc[j];

#if schreier then 
#	for i in scc do
#		f:=EvaluateWord(gens, TraceSchreierTreeOfSCCBack(o, j, i));
#		p[i]:=PermList(MappingPermListList(o[i], OnTuples(o[i], f)));
#	od;
#else
	for i in scc do
		f:=EvaluateWord(gens, TraceSchreierTreeOfSCCForward(o, j, i)); 
		p[i]:=MappingPermListList(OnTuples(o[scc[1]], f), o[scc[1]]);
	od;
#fi;

return p;
end);

# new for 3.2!
#############################################################################

InstallGlobalFunction(NrRClassesOrbitsOfImages,
function(s)
local i, j, k, l, m, c;

c:=OrbitsOfImages(s);
m:=[];

c:=c!.orbits;

for i in c do
  for j in i do 
    for k in j!.reps do 
      for l in k do 
        Add(m, Length(l));
      od;
    od;
  od;
od;

return Sum(m);
end);

# new for 3.2!
#############################################################################

InstallMethod(OrbitsOfImages, "for a trans. semigroup",
[IsTransformationSemigroup], 
function(s)
local gens, n, one, ht;

if IsTransformationMonoid( s ) then
	gens := GeneratorsOfMonoid( s );
else
	gens := GeneratorsOfSemigroup( s );
fi;

n := DegreeOfTransformationSemigroup( s );
one := TransformationNC( [ 1 .. n ] );
ht := HTCreate(one);
ht!.o := [one];

return rec(
  finished:=false,
  orbits:=EmptyPlist(DegreeOfTransformationSemigroup(s)), 
  at:=0, 
  gens:=gens,
  s:=s,
	deg := n,
	one := one,
	ht:=ht,
	data:=[]
);
end);

# new for 3.2!
############################################################################

InstallMethod(ParentAttr, "for a R-class of a trans. semigroup", 
[IsGreensRClass and IsGreensClassOfTransSemigp], x-> x!.parent);

# new for 3.2!
############################################################################

InstallMethod(PrintObj, [IsIteratorOfRClassReps], 
function(iter)
local O, s;

s:=SemigroupOfIteratorOfRClassReps(iter);
O:=OrbitsOfImages(s);

Print( "<iterator of R-class reps, ", Length(O!.ht!.o), " candidates, ", 
 SizeOrbitsOfImages(s), " elements, ", NrRClassesOrbitsOfImages(s), 
 " R-classes>");
return;
end);

# new for 3.2!
############################################################################

InstallMethod(PrintObj, [IsIteratorOfGreensRClasses], 
function(iter)
Print( "<iterator of Green's R-classes>");
return;
end);

# new for 3.2!
############################################################################

InstallMethod(PrintObj, [IsIteratorOfSemigroup], 
function(iter)
Print("<iterator of transformation semigroup>");
return;
end);

# new for 3.2!
############################################################################

InstallGlobalFunction(RClassImageOrbitFromData,
function(s, d)
return OrbitsOfImages(s)!.orbits[d[1]][d[2]];
end);

# new for 3.2!
############################################################################
# take care using the following, it returns all of the perms for the weak orbit

InstallGlobalFunction(RClassPermsFromData, 
function(s, d)

return OrbitsOfImages(s)!.orbits[d[1]][d[2]]!.perms;
end);

# new for 3.2!
############################################################################

InstallGlobalFunction(RClassRepFromData,
function(s, d)
return OrbitsOfImages(s)!.orbits[d[1]][d[2]]!.reps[d[4]][d[5]][d[6]];
end);

# new for 3.2!
############################################################################

InstallGlobalFunction(RClassSCCFromData,
function(s,d)
return OrbitsOfImages(s)!.orbits[d[1]][d[2]]!.scc[d[4]];
end);

# new for 3.2!
############################################################################

InstallGlobalFunction(RClassSchutzGpFromData, 
function(s, d)
return OrbitsOfImages(s)!.orbits[d[1]][d[2]]!.schutz[d[4]];
end);

# new for 3.2!
############################################################################

InstallOtherMethod(SchutzenbergerGroup, "for a R-class of a trans. semigp.",
[IsGreensRClass and IsGreensClassOfTransSemigp], 
function(r)
local s, d, o;

s:=r!.parent;
d:=r!.data;
o:=RClassImageOrbitFromData(s, d);

return RClassSchutzGpFromData(s, d)[2]^(o!.perms[d[3]]^-1);
# replace the above with function calls? JDM
end);


# new for 3.2!
#############################################################################
#

#gens are the generators of the semigroup
#o is orbit
#f is a representative of scc with index k
#k is the index of scc containing index of image of f

InstallGlobalFunction(SchutzenbergerGroupOfSCCOfOrbit,
function(gens, o, f, k) 
local p, t, g, bound, graph, i, j, scc, is_sym;

#gens:=o!.gens;
scc:=o!.scc[k];

if Length(o[scc[1]])<1000 then 
	bound:=Factorial(Length(o[scc[1]]));
else
	bound:=infinity;
fi;

g:=Group(());
p:=o!.perms;
t:=o!.truth;
graph:=OrbitGraph(o);
is_sym:=false;

for i in scc do 
	for j in [1..Length(gens)] do 
		if IsBound(graph[i][j]) and t[k][graph[i][j]] then
  		g:=ClosureGroup(g, PermLeftQuoTransformationNC(f, f/p[i] *
  		 (gens[j]*p[graph[i][j]])));
		fi; #keep track of schreier gens here!
		if Size(g)>=bound then 
		  is_sym:=true;
			break;
		fi;
	od;
	if Size(g)>=bound then 
		break;
	fi;
od;

if not is_sym then 
	return [StabChainImmutable(g), g];
else
	return [is_sym, g];
fi;
end);

# new for 3.2!
#############################################################################
##  Algorithm C. 

InstallOtherMethod(Size, "for an R-class of a trans. semigp.", 
[IsGreensRClass and IsGreensClassOfTransSemigp],
function(r)
local d, o;

d:=r!.data;
o:=RClassImageOrbitFromData(r!.parent, d);

return Size(o!.schutz[d[4]][2])*Length(o!.scc[d[4]]);
# replace the above with function calls? JDM
end);

#############################################################################
##  Algorithm V.

InstallMethod(Size, "for a transformation semigroup", 
[IsTransformationSemigroup], 
function(s)
local iter, o, i;

o:=OrbitsOfImages(s);

if not o!.finished then 
	iter:=IteratorOfRClassReps(s);
	iter!.i:=Length(o!.data); 
	for i in iter do od;
fi;

return SizeOrbitsOfImages(s);
end);

# new for 3.2!
#############################################################################
# returns the size of the semigroup <s> with OrbitsOfImages(s)=c so far

InstallGlobalFunction(SizeOrbitsOfImages, 
function(s)
local i, o, j, c;
i:=0;

c:=OrbitsOfImages(s)!.orbits;

for o in Concatenation(Compacted(c)) do 
  for j in [1..Length(o!.scc)] do
    if IsBound(o!.schutz[j]) and IsBound(o!.reps[j]) and IsBound(o!.scc[j]) then 
      i:=i+Size(o!.schutz[j][2])*
      Sum(List(o!.reps[j]), Length)*Length(o!.scc[j]);
    fi;
  od;
od;

return i;
end);

# new for 3.2!
#############################################################################
# returns a word in generators that takes o!.scc[i][1] to o[j] assuming that
# j in scc[i]

InstallGlobalFunction(TraceSchreierTreeOfSCCForward, 
function( o, i, j)
local word;
word := [];
while j > o!.scc[i][1] do
	Add(word, o!.trees[i][1][j]);
	j := o!.trees[i][2][j];
od;
return Reversed(word);
end );

# new for 3.2!
#############################################################################

InstallGlobalFunction(TraceSchreierTreeOfSCCBack,
function( o, i, j)
local word;
word := [];
while j > o!.scc[i][1] do
	Add(word, o!.reverse[i][1][j]);
	j := o!.reverse[i][2][j];
od;
return word;
end);

#############################################################################
# DELETE!

CheckSchreierWords:=function(o)
local scc, words, reps, i, j, k, f, gens;
gens:=o!.gens;
scc:=o!.scc;
words:=o!.words;
reps:=o!.reps;

for i in [1..Length(scc)] do 
  for j in [1..Length(words[i])] do #words related to scc[i]
    for k in [1..Length(words[i][j])] do #words of reps of scc[i] with a given kernel
			#f:=EvaluateWord(gens, words[i][j][k]);
			#if not KernelOfTransformationNC(f)=KernelOfTransformationNC(reps[i][j][k]) 
			# or not Set(f![1])=Set(reps[i][j][k]![1]) then 
			if not EvaluateWord(gens, words[i][j][k])=reps[i][j][k] then 
				return [i,j,k];
			fi;
    od;
  od;
od;

return true;
end;

#############################################################################

ConvertToOldStyle:=function(c)
local out, i, j, k;

out:=[[],[],[],[]];

for i in c do 
  for j in i do 
    for k in [1..Length(j!.scc)] do 
      if IsBound(j!.reps[k][1]) then
				Add(out[1], j{j!.scc[k]});
				Add(out[2], j!.perms{j!.scc[k]});
				Add(out[3], j!.schutz[k][2]);
				Add(out[4], j!.scc[k]);
			fi;
    od;
  od;
od;

return out;
end;
