# ADR-002 — SWAFOS Domain Map

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001

## Purpose

This document establishes the initial bounded-domain map before database schema design.

## Domain Map

```text
                         SWAFOS
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
      Identity          Business          Intelligence
     Organization        Actors           Analytics/KPI
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
       ┌────────────────────┼────────────────────┐
       │                    │                    │
   Production           Supply Chain          Commerce
       │                    │                    │
 Crop / Fish /          Lot / Inventory       Purchase
 Poultry / Livestock    Warehouse / Move      Offer / Order
       │                    │                  Sale / Settle
       └────────────────────┼────────────────────┘
                            │
                         Finance
                            │
                  Cost / Revenue / Cash
                  Margin / ROI / Capital
```

## 1. Identity & Organization

Owns tenant and access boundaries.

Responsibilities:

- organization
- user
- membership
- role
- permission
- organization settings

Must not contain production or commercial business logic.

## 2. Business Actors

Represents participants in the value chain.

Roles include:

- producer
- collector
- aggregator
- trader
- distributor
- processor
- retailer
- buyer

A person or organization may have multiple roles.

## 3. Production

Represents creation of biological/agricultural output.

Shared concepts:

- production unit
- production batch
- activity
- observation
- input consumption
- loss/mortality
- harvest

Production-specific extensions may represent species, cultivar, breed, feeding, planting, water quality, vaccination, and other domain measurements.

## 4. Supply Chain

Represents what happens after an output becomes a traceable commercial quantity and also covers inbound goods.

Core concepts:

- lot
- lot lineage
- inventory item
- stock balance
- inventory movement
- warehouse/storage location
- transfer
- aggregation
- transformation
- fulfillment

## 5. Commerce

Represents buying and selling relationships.

Core concepts:

- product
- supplier
- purchase
- offer
- price
- customer
- order
- sale
- sale line
- settlement

Commerce must support products originating from internal production as well as externally purchased goods.

## 6. Finance & Economics

Represents economic meaning rather than merely cash bookkeeping.

Core concepts:

- cost
- revenue
- cash transaction
- capital expenditure
- allocation
- contribution margin
- profitability
- ROI / return on capital

The finance domain consumes operational facts but owns financial calculations and recognition rules.

## 7. Intelligence

Represents derived knowledge.

Core concepts:

- metric definition
- KPI
- analytical snapshot
- forecast
- experiment
- decision support
- AI recommendation

Derived intelligence must retain links to the underlying data and calculation definition where practical.

## Cross-Domain Flow

```text
Production Batch
      │
   Harvest
      │
      ▼
     Lot
      │
 ┌────┴─────────┐
 │              │
Inventory     Sale
 │              │
Movement       │
 │              ▼
 └──────────→ Revenue
                │
Costs ──────────┤
                ▼
             Margin
                │
                ▼
             KPI/ROI
                │
                ▼
             Decision
```

## Boundary Rules

1. Production owns biological production state.
2. Supply Chain owns stock and physical/commercial movement of lots.
3. Commerce owns commercial commitments and transactions.
4. Finance owns economic recognition and aggregation.
5. Intelligence owns derived metrics and recommendations.
6. No domain may reach directly into another domain's persistence implementation as an informal dependency.
7. Cross-domain interaction should use explicit application services, domain events, or stable interfaces as appropriate.

## Next Step

The next architecture artifact should define the Business Actor model and relationship rules in detail, followed by the Supply Chain/Lot model and then the economic model. Only after those decisions should the first relational schema be generated.
