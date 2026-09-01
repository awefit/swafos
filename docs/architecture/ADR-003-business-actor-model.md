# ADR-003 — Business Actor Model

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001, ADR-002

## Decision

SWAFOS will model people and organizations separately from the business roles they perform. A `Business Actor` may be a person or organization and may hold multiple roles simultaneously.

## Model

```text
Party
 ├── Person
 └── Organization
       │
       └── Business Actor
              └── Role*
```

A business actor participates in transactions through explicit roles rather than through a fixed actor type.

## Roles

Initial role vocabulary:

- Producer
- Collector
- Aggregator
- Trader
- Distributor
- Processor
- Retailer
- Buyer
- Supplier
- Logistics Provider
- Service Provider

The vocabulary is extensible. A role is a capability/context, not a separate account type.

## Why roles are not mutually exclusive

The same business may produce fish, buy fish from neighboring farms, aggregate several lots, and sell to restaurants. Modeling those as separate actor types would force duplicate records and make the supply chain harder to trace.

Example:

```text
Actor: Budi Farm & Trading
  ├── Producer
  ├── Collector
  └── Trader
```

## Relationships

A business actor may have relationships with other actors:

- supplier relationship
- customer relationship
- producer relationship
- collection relationship
- distribution relationship
- processing relationship
- logistics relationship

Relationships should have their own lifecycle where terms, status, or commercial conditions need to be recorded.

## Organization vs Actor

`Organization` is the SWAFOS tenant/business boundary. `Business Actor` represents a participant in a value-chain relationship.

An organization may represent itself as a business actor and may also transact with external actors.

This separation allows SWAFOS to represent both:

1. the company using SWAFOS; and
2. the other parties it buys from, sells to, aggregates for, or works with.

## User vs Business Actor

A user account is an authenticated identity. It is not automatically a business actor.

```text
User
  ↓ membership
Organization
  ↓ represents / operates as
Business Actor
```

A user may act on behalf of one or more organizations according to membership and permissions.

## Transaction Participation

Commercial and operational records should reference the participating business actor and, where necessary, the role under which the actor participates.

Examples:

```text
Purchase
  buyer_actor
  supplier_actor

Sale
  seller_actor
  buyer_actor

Collection
  collector_actor
  producer_actor

Logistics
  provider_actor
  sender_actor
  receiver_actor
```

## Privacy and Data Ownership

An organization must only access private actor data according to authorization and relationship rules. Shared transaction data should expose the minimum information required for the business process.

## Consequences

### Positive

- One actor can operate across multiple value-chain roles.
- No duplicate identities for vertically integrated businesses.
- Better support for farmer + collector + retailer scenarios.
- Commerce and supply-chain domains can remain role-neutral.
- Future marketplace participation is easier to model.

### Negative

- Authorization must distinguish user permissions from actor roles.
- Relationship and role lifecycle need explicit modeling.
- UI must avoid assuming every organization is only a producer.

## Next Step

Define the `Lot`, inventory, movement, aggregation, transformation, and traceability model before generating the relational schema.
