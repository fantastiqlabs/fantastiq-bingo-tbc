# Issue 5: Relationship to the guild portal

## Decision

The Raid Bingo addon is a standalone tool. It does not connect to Hello There Guild, share identity, or send card/mark data to a service.

## Rationale

A standalone addon works without network access or portal credentials and keeps marks private. Portal synchronization would add authentication, reliability, and privacy requirements that are unnecessary for the bingo experience.

## Deferred work

Any future portal handoff or shared raid card requires a new owner-approved design covering identity, consent, data retention, and compatibility. No placeholder integration is included in the current candidate.
