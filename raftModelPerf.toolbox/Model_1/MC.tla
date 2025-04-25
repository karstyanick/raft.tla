---- MODULE MC ----
EXTENDS raftModelPerf, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
v1, v2, v3
----

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
r1, r2, r3
----

\* MV CONSTANT definitions Value
const_17455772102412000 == 
{v1, v2, v3}
----

\* MV CONSTANT definitions Server
const_17455772102423000 == 
{r1, r2, r3}
----

\* CONSTANT definitions @modelParameterConstants:3MaxTerm
const_17455772102424000 == 
3
----

\* CONSTANT definitions @modelParameterConstants:6MaxBecomeLeader
const_17455772102425000 == 
1
----

\* CONSTANT definitions @modelParameterConstants:14MaxClientRequests
const_17455772102426000 == 
3
----

=============================================================================
\* Modification History
\* Created Fri Apr 25 12:33:30 CEST 2025 by yanick
