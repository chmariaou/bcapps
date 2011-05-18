(* playground for Mathematica *)

showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

data = ReadList["/home/barrycarter/BCGIT/tmp/moon.csv", {Real,Real,Real}];

(* convert into bizarro xy coords... theta is x, r is y+90 degrees *)

(* no need to convert declination to degrees, but what the heck; note
that r is always between "90 degrees" and "270 degrees" *)

xt1 = Table[{i[[1]], (Pi+i[[3]]*Degree)*Cos[i[[2]]*Degree]}, {i,data}];
yt1 = Table[{i[[1]], (Pi+i[[3]]*Degree)*Sin[i[[2]]*Degree]}, {i,data}];

datareduce[data_, n_] := Module[{halfdata, inthalfdata, tabhalfdata, origdata},
 halfdata = Take[data, {1,Length[data],2^n}];
Print["halfdata complete"];
 inthalfdata = Interpolation[halfdata];
Print["inthalfdata complete"];
 tabhalfdata = Table[inthalfdata[data[[i,1]]], {i, 1, Length[data]}];
Print["tabhalfdata complete"];
 Return[tabhalfdata];
]

(* original ra/dec (doesn't change) *)
origra = Table[i[[2]], {i,data}];
origdec = Table[i[[3]], {i,data}];

(* reduce and compare *)
xred = datareduce[xt1, 7];
yred = datareduce[yt1, 7];

(* reconstruct ra and dec *)
rared=Table[Mod[ArcTan[xred[[i]],yred[[i]]]/Degree,360],{i, 1, Length[data]}];
decred=Table[Norm[{xred[[i]],yred[[i]]}]/Degree-180, {i, 1, Length[data]}];

Max[Abs[rared-origra]]
Max[Abs[decred-origdec]]

(* TODO: Just realized n doesn't have to be a power of 2 *)

Exit[]

(* if we map ra/dec as theta, r (r= 90+dec), do we have something? 
(it's at least only 2D *)

dec[t_] = 23*Sin[t*2*Pi/365]
ra[t_] = t/365*24/24*2*Pi

Plot[{ra[t],dec[t]},{t,0,365}]

x[t_] = (90+dec[t])*Sin[ra[t]]
y[t_] = (90+dec[t])*Cos[ra[t]]

Plot[x[t],{t,0,365}]
Plot[y[t],{t,0,365}]

Exit[]

(* if we have lots of data, can we "compress" it in an odd way? *)

(* trying to do 10 years at a time slow things down a bit, so maybe 1 year *)

data = Take[data, 10000];

(* start with dec *)

moondec = Table[{i[[1]], i[[3]]}, {i,data}];

datareduce[data_, n_] := Module[{halfdata, inthalfdata, tabhalfdata, origdata},
 halfdata = Take[data, {1,Length[data],2^n}];
Print["halfdata complete"];
 inthalfdata = Interpolation[halfdata];
Print["inthalfdata complete"];
 tabhalfdata = Table[inthalfdata[data[[i,1]]], {i, 1, Length[data]}];
Print["tabhalfdata complete"];
 Return[tabhalfdata];
]

t1 = datareduce[moondec, 1];
t2 = Table[moondec[[i,2]], {i, 1, Length[data]}];
t3 = t1-t2;

(* vaguely bad that I'm using data as a parameter, but won't cause
Mathematica problem *)

(* take each 2^nth piece of data *)
halfdata[data_, n_] := Take[data, {1,Length[data],2^n}]

(* interpolate it *)
inthalfdata[data_, n_] := Interpolation[halfdata[data,n]]

(* new data *)
tabhalfdata[data_, n_] := 
 Table[inthalfdata[data,n][data[[i,1]]], {i, 1, Length[data]}]

(* and compare *)
maxdiff[data_, n_] := Max[tabhalfdata[data,n]];

moondechd = halfdata[moondec,1];





mindata = Table[{i, data[[i]]}, {i,1,Length[data],50}]

mindata = Table[{i, data[[i]]}, {i,1,Length[data],500}]

mindata = Table[{i, data[[i]]}, {i,1,Length[data],5000}]

amindata = Interpolation[mindata]
amindata = Interpolation[mindata, InterpolationOrder->1]
amindata = Interpolation[mindata, InterpolationOrder->2]
amindata = Interpolation[mindata, InterpolationOrder->0]
amindata = Interpolation[mindata, InterpolationOrder->5]
amindata = Interpolation[mindata, InterpolationOrder->17]

atab = Table[amindata[x], {x,1,Length[data]}]

ListPlot[data-atab]

Max[Abs[data-atab]]



Exit[]

mod[x_] := Module[{coeff,a},
 coeff= {1,2,3};
 Function[y, Evaluate[x+coeff[[1]]+y]]
]

mod[7]


Exit[]

(* table of inverse normal curve for NADEX vols *)

inv[x_] = y /. Solve[CDF[NormalDistribution[0,1]][y]==x,y][[1]]

Flatten[Table[{N[x,4],N[inv[x],10]},{x,0,1,25/10000}]
 ] >> /home/barrycarter/BCGIT/data/inv-norm-as-list.txt

Exit[]

(* how much worse is linear interpolation for moonpos? *)

t = << /home/barrycarter/BCGIT/sample-data/manytables.txt

Flatten[t[[1,3,3,3]]]

(* the xyz vals from Hermite approx, for 2011 *)

hxval[r_] := t[[1,1,3]][r]
hyval[r_] := t[[1,2,3]][r]
hzval[r_] := t[[1,3,3]][r]

hdec[r_] := ArcSin[hzval[r]/Sqrt[hxval[r]^2+hyval[r]^2+hzval[r]^2]]/Degree

Plot[hdec[r],{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

(* and the domain, range for the x values of the moon *)

Flatten[t[[1,1,3,3]]]
Flatten[t[[1,1,3,4,3]]]

xm1 = Table[{t[[1,1,3,3,1,i]], t[[1,1,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
ym1 = Table[{t[[1,1,3,3,1,i]], t[[1,2,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
zm1 = Table[{t[[1,1,3,3,1,i]], t[[1,3,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]

flatx = Interpolation[xm1, InterpolationOrder -> 1]
flaty = Interpolation[ym1, InterpolationOrder -> 1]
flatz = Interpolation[zm1, InterpolationOrder -> 1]

flatdec[r_] := ArcSin[flatz[r]/Sqrt[flatx[r]^2+flaty[r]^2+flatz[r]^2]]/Degree

Plot[{flatx[r] - hxval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flaty[r] - hyval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatz[r] - hzval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

Plot[{flatdec[r],hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatdec[r]-hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]},
 PlotRange->All]

(* trivial difference, so could've just used linear *)


