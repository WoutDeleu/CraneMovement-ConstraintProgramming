%%DATA%%
int: N; %Number of vessels
int: L; %quay length
int: s; %max shift time
int: d; %Minimum safety distance
int: C; %Number of cranes
int: r; %Crane range
array[int] of var 0..L: qcbasepositions; 
array[1..N] of var 1..L: lengths;
array[1..N] of var int: arrivaltimes;
array[1..N] of var int: departuretimes;
array[1..N] of var 0..C: minimumnumqcs;


set of int: position = 0..L;
set of int: time = 0..168;
set of int: vessel = 1..N;
set of int: cranes = 1..C;


%%BESLISSINGSVARIABELEN%%
array[time,1..C] of var 0..N: craneAllocation;
array[vessel] of var time: startingTimes;
array[vessel] of var time: departureTimes;
array[vessel] of var 0..s: possibleShift;
array[vessel] of var position: vesselPositions;

%% TUSSENSTAPPEN %%

array[vessel,vessel] of var bool: positionOverlap;
array[vessel,vessel] of var bool: timeOverlap; 

%%CONSTRAINTS%%
%Constraint 1: Time shift mogelijkheid 
constraint forall(v in vessel)(startingTimes[v] >= arrivaltimes[v] /\ startingTimes[v] <= (arrivaltimes[v]+ s) mod 168);

constraint forall(v in vessel) (departureTimes[v] = (startingTimes[v] + departuretimes[v]- arrivaltimes[v])mod 168);

%Constraint 2: Geen positie overlap op zelfde tijd
constraint forall(v1 in vessel, v2 in vessel)(not(positionOverlap[v1,v2] /\ timeOverlap[v1,v2] /\ v1 != v2));% Beide overlappen mogen niet tegelijk voorkomen

%constraint forall(v1 in vessel, v2 in vessel)(positionOverlap[v1,v2] = positionOverlap[v2,v1] /\ timeOverlap[v1,v2] = timeOverlap[v2,v1]);
%symmetrie, wordt automatisch gehaald? kan de zoeksnelheid bevorderen

constraint forall(v1 in vessel, v2 in vessel)(if (vesselPositions[v1] <= vesselPositions[v2]+ lengths[v2] + d /\  vesselPositions[v1] + lengths[v1] + d >= vesselPositions[v2]) then positionOverlap[v1,v2] = 1 endif); %position overlap

constraint forall(v1 in vessel, v2 in vessel)(if (startingTimes[v1] <= departureTimes[v2] /\ departureTimes[v1] >= startingTimes[v2]) then timeOverlap[v1,v2] = 1 endif); %time overlap (todo: modulo nog uitzoeken)

%Constraint 3: position van vessel mag niet out of bounds gaan 
constraint forall(v in vessel)(vesselPositions[v] + lengths[v] <= L);

%Constraint 4: Vessel moet door minimaal aantal qc assigned zijn
constraint forall(v in vessel, t in startingTimes[v]..departureTimes[v])(sum(c in cranes)(craneAllocation[t,c] = v)>=minimumnumqcs[v]);

%Constraint 5: Vessel moet door dezelfde qc voor de hele tijdsperiode bediendt worden
constraint forall(v in vessel, 
c in cranes)(sum(t in startingTimes[v]..departureTimes[v])(craneAllocation[t,c] = v) = departureTimes[v] - startingTimes[v] \/ sum(t in startingTimes[v]..departureTimes[v])(craneAllocation[t,c] = v) = 0);

%Constraint 6: Vessel moet door qc kunnen worden geserved

%Constraint 7: Qc kan per tijdsperiode maar 1 vessel bedienen




%%DOELFUNCTIE%%
solve satisfy;