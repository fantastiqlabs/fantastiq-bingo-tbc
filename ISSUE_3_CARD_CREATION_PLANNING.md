# Issue 3: Card creation, persistence, and sharing

## Decision for the standalone candidate

Each player selects a raid deck and receives a locally randomized card. The card layout and marks persist in that player's SavedVariables. A new card is generated with `/rb new`; marks can be cleared with `/rb reset`. No addon messages are sent and no participant's marks are visible to others.

This is not a shared-card design: randomness is local, so different players may receive different squares. Fixed cards, leader distribution, and synchronization are deferred until the owner requests a separate design task.

## Offline and late-join behavior

Players without the addon can still participate in the raid but do not get a bingo card. Joining, disconnecting, or reloading does not distribute state to other players. Saved local card state is restored when available.

## Privacy

The addon stores card and mark state locally. It has no portal connection, account identity, or external verification.
