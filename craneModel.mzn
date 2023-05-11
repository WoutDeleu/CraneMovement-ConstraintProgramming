include "member.mzn";
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


%%DECISSIONVARIABLES%%
array[vessel] of var time: startingTimes;
array[vessel] of var time: departureTimes;
array[vessel] of var 0..s: possibleShift;
array[vessel] of var position: vesselPositions;
array[time,1..C] of var 0..N: craneSchedule;
array[vessel, cranes] of var bool: craneAllocation;


array[vessel,vessel] of var bool: positionOverlap;
array[vessel,vessel] of var bool: timeOverlap; 

%%CONSTRAINTS%%
%Constraint 1: Time shift possibility 
constraint forall(v in vessel)(startingTimes[v] >= arrivaltimes[v] /\ startingTimes[v] <= (arrivaltimes[v]+ s)mod 168);

constraint forall(v in vessel) (departureTimes[v] = (startingTimes[v] + departuretimes[v]- arrivaltimes[v])mod 168);

%Constraint 2: No position overlap on same time
constraint forall(v1 in vessel, v2 in vessel)(not(positionOverlap[v1,v2] /\ timeOverlap[v1,v2] /\ v1 != v2));

constraint forall(v1 in vessel, v2 in vessel)(if (vesselPositions[v1] <= vesselPositions[v2]+ lengths[v2] + d /\  vesselPositions[v1] + lengths[v1] + d >= vesselPositions[v2]) then positionOverlap[v1,v2] = 1 endif); %position overlap

constraint forall(v1 in vessel, v2 in vessel)(if ((startingTimes[v1] <= departureTimes[v2] /\ departureTimes[v1] >= startingTimes[v2]) \/ (departureTimes[v2] <= startingTimes[v2]/\ departureTimes[v1] >= startingTimes[v2]) \/ (departureTimes[v1] <= startingTimes[v1] /\ departureTimes[v2] >= startingTimes[v1])) then timeOverlap[v1,v2] = 1 endif); %time overlap 

%Constraint 3: Position of a vessel within bounds 
constraint forall(v in vessel)(vesselPositions[v] + lengths[v] <= L);


%Constraint 4: Vessel needs to be seved the minimal amount QC
constraint forall(v in vessel,c in cranes)(if craneSchedule[startingTimes[v],c] = v then craneAllocation[v,c] = 1 else craneAllocation[v,c] = 0 endif); 
constraint forall(v in vessel)(sum(c in cranes)(craneSchedule[startingTimes[v],c] = v)>=minimumnumqcs[v] /\ sum(c in cranes) (craneSchedule[departureTimes[v],c] = v)>=minimumnumqcs[v]);

%Constraint 5: Vessel needs to be served by same QC over entire time period
constraint forall(c in cranes, v in vessel)(if startingTimes[v] < departureTimes[v] then (sum(t in startingTimes[v]..departureTimes[v])(craneSchedule[t,c] = v) = departureTimes[v] - startingTimes[v]+1) \/ (sum(t in startingTimes[v]..departureTimes[v])(craneSchedule[t,c] = v) = 0)endif);

constraint forall(c in cranes, v in vessel)(if startingTimes[v] > departureTimes[v] then (sum(t in 0..departureTimes[v])(craneSchedule[t,c] = v) = departureTimes[v]+1) \/ (sum(t in 0..departureTimes[v])(craneSchedule[t,c] = v) = 0)endif);

constraint forall(c in cranes, v in vessel)(if startingTimes[v] > departureTimes[v] then (sum(t in startingTimes[v]..168)(craneSchedule[t,c] = v) = 168 - startingTimes[v]+1) \/ (sum(t in startingTimes[v]..168)(craneSchedule[t,c] = v) = 0)endif);
% Cyclic


%Constraint 6: Vessel cant be served outside the possible hours
constraint forall(c in cranes, v in vessel)(if startingTimes[v] < departureTimes[v] then sum(t in 0..(startingTimes[v]-1))(craneSchedule[t,c] = v) = 0 endif);

constraint forall(c in cranes, v in vessel)(if startingTimes[v] < departureTimes[v] then sum(t in (departureTimes[v]+1)..168)(craneSchedule[t,c] = v) = 0 endif);

constraint forall(c in cranes, v in vessel)(if startingTimes[v] > departureTimes[v] then sum(t in (departureTimes[v]+1)..startingTimes[v]-1)(craneSchedule[t,c] = v) = 0 endif);
% Cyclic


%Constraint 7: Vessel must be in range of the QC
constraint forall(c in cranes, v in vessel)(if craneSchedule[startingTimes[v], c] = v then vesselPositions[v] >= qcbasepositions[c] /\ qcbasepositions[c] + r >= vesselPositions[v] + lengths[v] endif);


%%SOLVE%%
solve satisfy;

%%OUTPUT%%
output [
   "\(v):\(vesselPositions[v])-\(vesselPositions[v] + lengths[v]);\(startingTimes[v])..\(departureTimes[v]);" ++ 
   (join(",", [show(c) | c in cranes where fix(craneAllocation[v,c]=1)]))++ 
   "\n" | v in vessel];

