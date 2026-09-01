# ADR-004 — Lot & Supply Chain Model

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001, ADR-002, ADR-003

## Decision

SWAFOS will use `Lot` as the primary traceability unit for physical product moving through the agribusiness value chain.

A lot represents a known quantity of a product at a point in its lifecycle. Lots are distinct from production batches: a batch represents a production cycle, while a lot represents a traceable commercial/physical quantity.

## Production to Lot

```text
Production Batch
      │
    Harvest
      │
      ▼
     Lot
```

One harvest may create one or multiple lots. A lot may also be created from purchased or externally sourced goods when no internal production batch exists.

## Lot Lifecycle

Initial lifecycle:

`created → available → reserved → allocated → fulfilled → closed`

Exception states such as `quarantined`, `expired`, `damaged`, or `cancelled` may be added where the product domain requires them.

Lifecycle transitions must be auditable.

## Lot Identity

A lot has:

- stable system identifier;
- human-readable lot code;
- product identity;
- quantity and unit of measure;
- owner/custodian context;
- current location;
- source reference;
- quality/grade information where applicable;
- creation and lifecycle timestamps.

Lot codes are business identifiers and must not be database primary keys.

## Lot Lineage

Lots must support lineage for splitting, merging, aggregation, and transformation.

### Split

```text
LOT-A 1000 kg
   │
   ├── LOT-A1 300 kg
   ├── LOT-A2 400 kg
   └── LOT-A3 300 kg
```

### Aggregation

```text
LOT-A 500 kg ─┐
LOT-B 300 kg ─┼──→ LOT-C 800 kg
```

### Transformation

```text
Live Chicken Lot
       ↓ processing
Dressed Chicken Lot
```

Lineage must preserve parent-child relationships rather than overwriting the original source.

## Inventory

Inventory is a state derived from posted inventory movements rather than a manually edited number.

Core movement types:

- receive
- issue/consume
- transfer
- adjustment
- reserve/release
- transform input
- transform output
- sale/fulfillment
- return
- loss/write-off

The system should maintain an immutable or append-oriented movement ledger and derive stock balances from it.

## Ownership vs Location

SWAFOS distinguishes:

- who owns a lot;
- who currently possesses/custodies it; and
- where the lot is physically located.

These may be different parties.

Example:

```text
Owner: Farmer A
Custodian: Collector B
Location: Collector B Warehouse
```

This distinction is essential for consignment, third-party storage, and logistics scenarios.

## Supply Chain Movement

A movement records a transfer or state change of a quantity between locations and/or custodians.

A movement may reference:

- source location
- destination location
- source custodian
- destination custodian
- lot
- quantity
- timestamp
- actor
- reason
- related order/fulfillment

## Warehouse / Storage

A physical farm, pond-side store, cold room, warehouse, retail location, or other stockholding place is represented through a generic `Location` hierarchy.

A location can contain stock but is not itself a product owner.

## Quality and Quarantine

Quality observations and quarantine states should be attached to lots or lot segments without destroying lineage. A quarantined lot must remain traceable even when it cannot currently be sold.

## Commercial Allocation

Reservations and allocations do not transfer ownership. They represent commitments against available quantity.

Ownership changes only through explicit business events such as sale, purchase, transfer, or another defined transaction.

## Consequences

### Positive

- End-to-end traceability
- Supports farmer → collector → distributor → retailer flows
- Supports split/merge/processing operations
- Inventory becomes auditable
- Ownership and custody can be modeled separately
- Marketplace and fulfillment can use the same lot model

### Negative

- Lot lineage requires careful data modeling
- Inventory balances should not be edited directly
- UI workflows are more sophisticated than simple stock CRUD

## Next Step

Define commerce and transaction semantics: purchase, offer, order, sale, pricing, fulfillment, settlement, and how they interact with lots and inventory.
