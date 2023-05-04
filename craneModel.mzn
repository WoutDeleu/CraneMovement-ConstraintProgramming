%%DATA%%
int: N; %Number of vessels
int: L; %quay length
int: s; %max shift time
int: d; %Minimum safety distance
int: C; %Number of cranes
int: r; %Crane range
array[1..N] of var 0..L: qcbasepositions; 
array[1..N] of var 1..L: lengths;
array[1..N] of var int: arrivaltimes;
array[1..N] of var int: departuretimes;
array[1..N] of var 0..C: minimumnumqcs;


set of int: position = 0..L;
set of int: time = 0..168;
set of int: vessel = 1..N;


%%BESLISSINGSVARIABELEN%%
%enum vesselOrNothing = V(vessel) ++ { Nothing };
%array[1..C,time] of var vesselOrNothing: craneAllocation;
array[vessel] of var time: startingTimes;
array[vessel] of var position: vesselPositions;

%% TUSSENSTAPPEN %%

array[vessel,vessel] of var 0..1: positionOverlap;
array[vessel,vessel] of var 0..1: timeOverlap; 

constraint forall(v1 in vessel, v2 in vessel)%tijdsoverlap);
constraint forall(v1 in vessel, v2 in vessel)%positieoverlap);

%%CONSTRAINTS%%
%1: Time shift mogelijkheid 
constraint forall(v in vessel)(startingTimes[v] >= arrivaltimes[v] /\ startingTimes[v] <= (arrivaltimes[v]+ s) mod 168);

%2: Geen positie overlap op zelfde tijd
% Beide overlappen mogen niet tegelijk voorkomen

%3: Vessel moet door minimaal aantal qc assigned zijn


%4: Afstanden tussen vessels


%5: position van vessel mag niet out of bounds gaan 
constraint forall(v in vessel)(vesselPositions[v] + lengths[v] <= L);

%%DOELFUNCTIE%%
solve satisfy;