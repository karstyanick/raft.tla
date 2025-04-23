## Initial ideas

I need to create a new switch component
This switch component will have some variables like a log
I will initialize these variable in the myInit

Finally I need to create new actions:
BroadCastAction --> switch receives a client request and send messages to all servers
ReceiveBroadCastAction --> server receives broadcast message

## 23 · 04 · 25

- **Implement `SwitchBroadcast`**
- **Adapt `ClientRequest` to act before switch**
- **Implement `HandleSwitchBroadCastFollower`**
- **Implement `HandleSwitchBroadCastLeader`** (same as old `ClientRequest`)
- **Add new `Next`** which first calls the new `ClientRequest`, then calls `SwitchBroadcast`
- **Adapt `Receive` function** to handle the new message type **`"SwitchRequest"`**
