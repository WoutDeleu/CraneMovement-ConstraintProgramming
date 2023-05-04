%%DATA%%
int: N; %Number of vessels
int: L; %quay length
int: s; %max shift time
int: d; %Minimum safety distance
int: C; %Number of cranes
int: r; %Crane range
array[1..N] of var 1..L: qcbasepositions; 
array[1..N] of var 1..L: lengths;
array[1..N] of var int: arrivaltimes;
array[1..N] of var int: departuretimes;
array[1..N] of var 0..C: minimumnumqcs;

%%BESLISSINGSVARIABELEN%%
%Handig%
set of int: position = 0..L;
set of int: time = 0..168;
set of int: vessel = 1..N;


enum vesselOrNothing = V(vessel) ++ { Nothing };


%Beslissingsvariabelen%
array[vessel] of var time: startingTimes;
array[1..C,time] of var vesselOrNothing: craneAllocation;

%%CONSTRAINTS%%
%1: Time shift mogelijkheid 
constraint forall(v in vessel)(startingTimes[v] >= arrivaltimes[v] /\ startingTimes[v] <= (arrivaltimes[v]+ s) mod 168);
%2: Geen positie overlap op zelfde tijd
%3: Vessel moet door minimaal aantal qc assigned zijn
%4: Afstanden tussen vessels
%5: position van vessel mag niet out of bounds gaan 

%%DOELFUNCTIE%%
solve satisfy;