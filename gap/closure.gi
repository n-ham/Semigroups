############################################################################# 
## 
#W  closure.gi 
#Y  Copyright (C) 2011                                   James D. Mitchell 
## 
##  Licensing information can be found in the README file of this package. 
## 
############################################################################# 
##

# new for 0.5! - ClosureSemigroup - "for a trans. semi. and trans. coll."
#############################################################################

InstallGlobalFunction(ClosureSemigroup,
function(arg)

  if not IsTransformationSemigroup(arg[1]) or not 
   (IsTransformationCollection(arg[2]) or IsTransformation(arg[2])) then 
    Error("Usage: arg. must be a trans. semigroup and transformation or ", 
    "collection of transformations.");
    return;
  fi;

  if Length(arg)=3 then 
    if not IsRecord(arg[3]) then 
      Error("Usage: 3rd arg. must be a record.");
      return;
    fi;
    if not "schreier" in RecNames(arg[3]) then  
      arg[3]!.schreier:=false;
    fi;
  else
    arg[3]:=arg[1]!.opts;
  fi;

  arg[3]!.small:=false;

  if IsTransformationSemigroup(arg[2]) then 
    arg[2]:=Generators(arg[2]);
  elif IsTransformation(arg[2]) then 
    arg[2]:=[arg[2]];
  fi;

  if not Degree(arg[1])=Degree(arg[2][1]) then 
    Error("Usage: degrees of transformations must equal degree of semigroup.");
    return;
  fi;

  return ClosureSemigroupNC(arg[1], Filtered(arg[2], x-> not x in arg[1]), 
   arg[3]);
end);

# new for 0.5! - ClosureSemigroupNC - "for a trans. semi. and trans. coll."
#############################################################################
# Usage: s = a transformation semigroup; coll = a list of transformations not
# belonging to s but with degree equal to that of s.  

InstallGlobalFunction(ClosureSemigroupNC,
function(s, coll, opts)
  local t, old_data, n, max_rank, orbits, lens, data_ht, data, data_len, images, old_lens, old_orbits, gens, ht, o, r, j, scc, reps, out, old_reps, old_data_list, old_reps_len, old_o, new_data, d, g, m, z, i, k, val, y;
 
  if coll=[] then 
    Info(InfoCitrus, 2, "All the elements in the collection belong to the ",
    " semigroup.");
    return s;
  fi;
  
  if IsTransformationMonoid(s) then 
    t:=Monoid(s, coll, opts);
  else
    t:=Semigroup(s, coll, opts);
  fi;

  if not HasOrbitsOfImages(s) or opts!.schreier then 
    return t;
  fi;

  #no schreier###############################################################
  
  old_data:=OrbitsOfImages(s);
  n:=Degree(t);
  
  # set up orbits of images of t

  max_rank:=Maximum(List(coll, Rank)); 
  gens:=List(Generators(t), x-> x![1]);
  orbits:=EmptyPlist(n); 
  lens:=[1..n]*0;
  data_ht:=HTCreate([1,1,1,1,1,1], rec(forflatplainlists:=true,
   hashlen:=old_data!.data_ht!.len));
  data:=EmptyPlist(Length(old_data!.data)); 
  data_len:=0;
  images:=HTCreate(SSortedList(gens[1]), rec(forflatplainlists:=true,
   hashlen:=old_data!.images!.len));
  old_lens:=old_data!.lens; old_orbits:=old_data!.orbits;

  # initialize R-class reps orbit
  
  ht:=StructuralCopy(old_data!.ht); o:=ht!.o; 
  r:=Length(o);
  
  for i in [1..Length(coll)] do 
    j:=HTAdd(ht, coll[i]![1], r+i);
    o[r+i]:=ht!.els[j];
  od;
  
  # process orbits of large images
 
  for j in [n, n-1..max_rank+1] do
    if old_lens[j]>0 then
      lens[j]:=old_lens[j];
      orbits[j]:=EmptyPlist(lens[j]);
      for k in [1..lens[j]] do
        o:=StructuralCopy(old_orbits[j][k]);
        o!.onlygradesdata:=images;
        AddGeneratorsToOrbit(o, coll);
        scc:=o!.scc; reps:=o!.reps;

        for m in [1..Length(scc)] do
          for val in [1..Length(reps[m])] do
            for n in [1..Length(reps[m][val])] do
              data_len:=data_len+1;
              out:=[j, k, scc[m][1], m, val, n];
              HTAdd(data_ht, out, data_len);
              data[data_len]:=out;
            od;
          od;
        od;  
        for i in o do 
          HTAdd(images, i, k);
        od;  
        orbits[j][k]:=o;
      od;
    fi;
  od;

  # process orbits of small images

  old_reps:=EmptyPlist(Length(old_data!.data));
  old_data_list:=EmptyPlist(Length(old_data!.data));
  old_reps_len:=0;

  for j in [max_rank, max_rank-1..1] do 
    if old_lens[j]>0 then 
      orbits[j]:=[];
      for k in [1..old_lens[j]] do
        old_o:=old_orbits[j][k];
        if HTValue(images, old_o[1])=fail then 
          lens[j]:=lens[j]+1;
          o:=StructuralCopy(old_o);
          o!.onlygradesdata:=images;
          AddGeneratorsToOrbit(o, coll);
          Unbind(o!.scc); Unbind(o!.rev);

          r:=Length(OrbSCC(o));

          o!.trees:=EmptyPlist(r);
          o!.reverse:=EmptyPlist(r);
          o!.reps:=List([1..r], x-> []);
          o!.kernels_ht:=[];
          o!.perms:=EmptyPlist(Length(o));
          o!.schutz:=EmptyPlist(r);
          o!.nr_idempotents:=List([1..r], m-> []);  
          for i in o do 
            HTAdd(images, i, lens[j]);
          od;
          orbits[j][lens[j]]:=o;
        fi;
        Append(old_reps, Concatenation(Concatenation(old_o!.reps)));
      od;
    fi;
  od;

  # set orbits of images of t

  new_data:= Objectify(NewType(FamilyObj(t), IsOrbitsOfImages), 
   rec(finished:=false, orbits:=orbits, lens:=lens, images:=images,
    at:=old_data!.at, gens:=gens, ht:=ht, data_ht:=data_ht, data:=data));

  SetOrbitsOfImages(t, new_data); 
 
  # process old R-reps 

  for i in [1..Length(old_reps)] do 
    j:=InOrbitsOfImages(old_reps[i], false, 
     [fail, fail, fail, fail, fail, 0, fail], orbits, images);
    if not j[1] then
      AddToOrbitsOfImages(t, old_reps[i], j[2], new_data, false);
    fi;
  od;
  
  # install new pts in the orbit
  
  coll:=List(coll, x-> x![1]); n:=Length(Generators(s)); 

  for i in [1..Length(data)] do 
    d:=data[i];
    g:=orbits[d[1]][d[2]]!.reps[d[4]][d[5]][d[6]];
    m:=Length(coll); j:=Length(ht!.o);
    for y in [1..m] do 
      z:=g{coll[y]};
      if HTValue(ht, z)=fail then
        j:=j+1; z:=HTAdd(ht, z, j); ht!.o[j]:=ht!.els[z];
      fi;
    od;
  od;
  
  # process kernel orbits here too!
  # if IsBound(OrbitsOfKernels(s)) then 
  # fi;

  return t;
end);

#EOF
