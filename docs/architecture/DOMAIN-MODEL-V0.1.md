# SWAFOS Canonical Domain Model V0.1

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001 through ADR-007

## Purpose

This document is the canonical conceptual model for SWAFOS V0.1. It defines entities and relationships before physical database implementation.

## 1. Identity and Organization

```text
User
  │
  └── Membership ── Organization
                         │
                         ├── Business Actor
                         ├── Location
                         ├── Product
                         ├── Production Unit
                         └── Account / Economic Scope
```

### User
Authenticated identity.

### Organization
Top-level tenant/business boundary.

### Membership
Connects a user to an organization with authorization context.

### Business Actor
A party participating in the value chain. May represent a person or organization and may hold multiple roles.

## 2. Master Data

### Product
A sellable, purchasable, produced, or transformed item definition.

Examples:

- freshwater fish
- chicken
- rice
- vegetables
- feed
- fertilizer
- packaging

Product is distinct from a physical lot.

### Unit of Measure
Defines quantities such as kg, gram, piece, liter, tray, or sack.

Conversions must be explicit and versionable where required.

### Location
Physical or logical stockholding point such as pond, plot, coop, warehouse, cold room, retail outlet, or transit location.

## 3. Production

```text
Production Unit
      │
      └── Production Batch
              │
              ├── Activity*
              ├── Input Consumption*
              ├── Observation*
              ├── Loss*
              └── Harvest*
                       │
                       └── Lot*
```

### Production Unit
Physical unit where production occurs.

Examples:

- agricultural plot
- tarpaulin pond
- chicken coop
- greenhouse

### Production Batch
Bounded production cycle and primary production-economic anchor.

Fields conceptually include product/species, production unit, start/end dates, planned quantity, actual quantity, and status.

### Activity
Operational event such as feeding, planting, fertilizing, vaccination, water treatment, maintenance, or labor.

### Input Consumption
Records resources consumed by production.

### Observation
Measurements such as weight, count, mortality, water quality, growth, or crop condition.

### Loss
Records mortality, spoilage, damage, or other production loss.

### Harvest
Records output from a production batch and creates one or more lots.

## 4. Lot and Inventory

```text
Harvest ──────────────┐
Purchase Receipt ─────┼──→ Lot
Transformation Output ┘     │
                            ├── Lot Lineage
                            ├── Inventory Movement*
                            ├── Quality Observation*
                            └── Allocation*

Location ← Inventory Movement → Location
```

### Lot
Traceable physical/commercial quantity.

### Lot Lineage
Parent-child relationship for split, merge, aggregation, and transformation.

### Inventory Movement
Append-oriented record of stock changes.

### Inventory Balance
Derived state from posted movements, not a manually edited source of truth.

### Allocation
Commitment of quantity to an order or other demand without transferring ownership.

## 5. Commerce

```text
Offer
  ↓
Order ── Order Line*
  ↓
Fulfillment ── Fulfillment Line*
  ↓
Sale / Purchase
  ↓
Receivable / Payable
  ↓
Settlement ── Allocation*
```

### Offer
Commercial proposal with product, quantity, price, terms, and validity.

### Order
Confirmed commercial commitment.

### Order Line
Product/quantity/pricing detail of an order.

### Fulfillment
Physical or service execution against an order.

### Sale
Sell-side commercial transaction.

### Purchase
Buy-side commercial transaction.

### Receivable / Payable
Economic obligation created by a sale/purchase or other recognized transaction.

### Settlement
Money movement applied to one or more obligations.

## 6. Finance & Economics

```text
Cost ─────────────┐
Revenue ──────────┼──→ Economic Result
Cash Transaction ─┤
Allocation ───────┘
                       │
                       ├── Margin
                       ├── Working Capital
                       └── Return Metrics
```

### Cost
Economic consumption or obligation.

### Revenue
Economic value recognized from sales or other defined sources.

### Cash Transaction
Actual cash/bank movement.

### Allocation
Explicit distribution of indirect costs or shared economic effects.

### Economic Result
Derived calculation of margin/profitability for a defined scope and period.

## 7. Relationships

Core relationships include:

```text
Organization 1─* Membership
Organization 1─* ProductionUnit
Organization 1─* Location
Organization 1─* Product
Organization 1─* BusinessActor

ProductionUnit 1─* ProductionBatch
ProductionBatch 1─* Activity
ProductionBatch 1─* InputConsumption
ProductionBatch 1─* Observation
ProductionBatch 1─* Loss
ProductionBatch 1─* Harvest
Harvest 1─* Lot

Lot 1─* InventoryMovement
Lot *─* Lot (through LotLineage)
Lot *─* OrderLine (through Allocation/Fulfillment)

Order 1─* OrderLine
Order 1─* Fulfillment
Fulfillment 1─* FulfillmentLine
Sale 1─* SaleLine
Purchase 1─* PurchaseLine

Sale → Receivable
Purchase → Payable
Receivable/Payable 1─* SettlementAllocation
Settlement 1─* SettlementAllocation

Cost → EconomicScope
Revenue → EconomicScope
```

## 8. Economic Scope

Economic records need a flexible but controlled attribution mechanism.

A scope may reference:

- organization
- production batch
- production unit
- lot
- purchase
- sale
- order
- asset
- activity

The implementation should avoid a free-form polymorphic foreign-key design if a stronger relational alternative can be used. The physical schema must preserve referential integrity.

## 9. State and Audit

Entities with meaningful lifecycle states require explicit transitions and timestamps.

Examples:

- production batch
- lot
- offer
- order
- purchase
- fulfillment
- settlement

Important state transitions should produce audit records containing actor, timestamp, previous state, next state, and reason where applicable.

## 10. Canonical Business Scenario

The model must support this complete scenario without special-case tables:

```text
Farmer Organization
  ↓
Pond / Production Unit
  ↓
Fish Production Batch
  ↓
Harvest 1,000 kg
  ↓
LOT-FISH-001
  ↓
Sell 400 kg to Collector
  ↓
Fulfillment / Inventory Movement
  ↓
Collector aggregates with another lot
  ↓
LOT-COLLECTED-001
  ↓
Sell 800 kg to Retailer
  ↓
Retailer Inventory
  ↓
Retail Sales
  ↓
Settlement
  ↓
Costs + Revenue
  ↓
Margin by actor / lot / transaction
```

## 11. Design Constraint

No implementation entity should be added solely because it makes a UI screen convenient. New entities must represent a stable business concept, lifecycle, relationship, or auditable fact.

## 12. Next Step

Produce the physical relational schema, including primary keys, foreign keys, uniqueness rules, indexes, money/quantity precision, timestamps, tenant isolation, and audit strategy.
