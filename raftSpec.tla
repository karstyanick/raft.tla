------------------------------ MODULE raftSpec ------------------------------
\* This is the formal specification for the Raft consensus algorithm.
\* Modified by Ovidiu Marcu. Simplified model and performance invariants added.
\* Modified further to track message counts for entry commitment.
\*
\* Copyright 2014 Diego Ongaro.
\* This work is licensed under the Creative Commons Attribution-4.0
\* International License https://creativecommons.org/licenses/by/4.0/

EXTENDS raftActionsSolution

\* Receive a message.
Receive(m) ==
    LET i == m.mdest
        j == m.msource
    IN \* Any RPC with a newer term causes the recipient to advance
       \* its term first. Responses with stale terms are ignored.
       \/ /\ m.mtype = AppendEntriesRequest
          /\ HandleAppendEntriesRequest(i, j, m)
       \/ /\ m.mtype = AppendEntriesResponse
          /\ HandleAppendEntriesResponse(i, j, m)
       \/ /\ m.mtype = SwitchRequest 
          /\ state[i] = Follower
          /\ HandleSwitchBroadcastFollower(i, m)
       \/ /\ m.mtype = SwitchRequest 
          /\ state[i] = Leader
          /\ HandleSwitchBroadcastLeader(i, m)

MyNextWithSwitch == 
             \/ \E v \in Value, i \in Server : state[i] = Leader /\ ClientRequestSwitch(v, i)
             \/ \E i \in Server : SwitchBroadcast(i)
             \/ \E m \in {msg \in ValidMessage(messages) :
                 msg.mtype \in {SwitchRequest}} : Receive(m)
\*             \/ \E i \in Server : AdvanceCommitIndex(i)
\*             \/ \E i,j \in Server : i /= j /\ AppendEntries(i, j)
\*             \/ \E m \in {msg \in ValidMessage(messages) : \* to visualize possible messages
\*                 msg.mtype \in {AppendEntriesRequest, AppendEntriesResponse}} : Receive(m)


\* The specification must start with the initial state and transition according
\* to Next.

MySpecSwitch == MyInit /\ [][MyNextWithSwitch]_vars

\* -------------------- Invariants --------------------

MoreThanOneLeaderInv ==
    \A i,j \in Server :
        (/\ currentTerm[i] = currentTerm[j]
         /\ state[i] = Leader
         /\ state[j] = Leader)
        => i = j

\* Every (index, term) pair determines a log prefix.
\* From page 8 of the Raft paper: "If two logs contain an entry with the same index and term, then the logs are identical in all preceding entries."
LogMatchingInv ==
    \A i, j \in Server : i /= j =>
        \A n \in 1..min(Len(log[i]), Len(log[j])) :
            log[i][n].term = log[j][n].term =>
            SubSeq(log[i],1,n) = SubSeq(log[j],1,n)

\* The committed entries in every log are a prefix of the
\* leader's log up to the leader's term (since a next Leader may already be
\* elected without the old leader stepping down yet)
LeaderCompletenessInv ==
    \A i \in Server :
        state[i] = Leader =>
        \A j \in Server : i /= j =>
            CheckIsPrefix(CommittedTermPrefix(j, currentTerm[i]),log[i])
            
    
\* Committed log entries should never conflict between servers
LogInv ==
    \A i, j \in Server :
        \/ CheckIsPrefix(Committed(i),Committed(j)) 
        \/ CheckIsPrefix(Committed(j),Committed(i))
        
        
UnorderedRequestsReceivedInv ==
    \E s \in Server : Cardinality(messageStore[s]) <= 2
    
MaxCInvTrace == (\E i \in Server : state[i] = Leader) => maxc <= 2

SwitchNextIndexTraceInv ==
    \A i \in Server : switchNextIndex[i] <= 1

\* Note that LogInv checks for safety violations across space
\* This is a key safety invariant and should always be checked
THEOREM MySpecSwitch => ([]LogInv /\ []LeaderCompletenessInv /\ []LogMatchingInv /\ []MoreThanOneLeaderInv) 

=============================================================================
\* Created by Ovidiu-Cristian Marcu
