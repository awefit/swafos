# ADR-001 — SWAFOS Core Architecture

- Status: Proposed
- Date: 2026-09-01

## Context

SWAFOS must serve a real agribusiness operation while remaining capable of becoming a multi-organization SaaS platform. Its scope includes production, aggregation, supply chain, commerce, finance, analytics, and future intelligence.

The architecture must preserve domain integrity and traceability without introducing unnecessary distributed-system complexity at the beginning.

## Decision

SWAFOS will begin as a **modular monolith with an API-first application boundary**.

Microservices are deferred until there is a demonstrated scaling, isolation, or organizational reason to extract a bounded domain.

## Logical Architecture

```text
Clients
  Web / Mobile / Admin / Integrations
                 │
                 ▼
          Application API
     Auth / Commands / Queries
                 │
                 ▼
            Domain Core
 ┌────────┬────────┬────────┬─────────┐
 │Actors  │Produce │Supply  │Commerce │
 │Org     │        │Chain   │Finance  │
 └────────┴────────┴────────┴─────────┘
                 │
                 ▼
           Infrastructure
 PostgreSQL / Storage / Jobs / APIs
                 │
                 ▼
          Intelligence Layer
       Metrics / Forecast / AI
```

## Domain Boundaries

### Identity & Organization

Organizations, users, memberships, roles, permissions, and tenant boundaries.

### Business Actors

Producers, collectors, aggregators, traders, distributors, processors, retailers, and buyers. One actor may have multiple roles.

### Production

Agriculture, aquaculture, poultry, livestock, production units, batches, activities, observations, losses, and harvests.

### Supply Chain

Lots, inventory, warehouses/locations, movements, aggregation, transformation, fulfillment, and traceability.

### Commerce

Products, suppliers, procurement, offers, orders, sales, pricing, customers, and settlement.

### Finance & Economics

Costs, revenue, cash movements, capital expenditure, allocations, margins, profitability, and return on capital.

### Intelligence

KPI definitions, analytics, forecasts, optimization, and AI decision support. Intelligence consumes stable core data and must not be required for core operations.

## Tenant Model

`Organization` is the top-level business boundary. An organization can operate multiple farms, production units, warehouses, sales channels, and business relationships.

```text
Organization
 ├── Users / Memberships
 ├── Farms*
 ├── Business Actors*
 ├── Production Units*
 ├── Warehouses*
 ├── Products*
 ├── Customers*
 └── Suppliers*
```

## Production Model

A `ProductionUnit` represents where production occurs. Examples include a plot, pond, coop, greenhouse, or livestock housing unit.

A `ProductionBatch` represents one bounded production cycle and is the primary production-economic anchor.

```text
Production Unit
      │
      └── Production Batch
             ├── Inputs
             ├── Activities
             ├── Observations
             ├── Losses
             └── Harvest
                    │
                    ▼
                   Lot
```

## Supply Chain Model

A `Lot` represents a traceable quantity of product moving through the value chain. A lot may originate from a harvest and may later be split, aggregated, transformed, moved, committed, or sold.

```text
Harvest → Lot → Movement → Aggregation/Transformation → Lot → Sale
```

The system must preserve lineage when lots are split or combined.

## Commerce Model

Commerce is separated from production. A seller may sell internally produced goods or goods acquired from another actor.

```text
Supplier → Purchase → Inventory

Seller → Offer/Order → Fulfillment → Sale → Settlement
```

## Economic Model

Operational events produce economic effects, but operational state and financial recognition remain separate concepts.

The system must support explicit attribution of costs and revenue to organizational, production, inventory, lot, order, sale, or other relevant scopes.

## Auditability

Material state changes must be auditable. Financial, inventory, production, lot, order, and settlement records must not be silently mutated when doing so would destroy historical meaning.

## API Boundary

Clients and future external systems consume application APIs. Domain persistence must not become a public integration contract by accident.

## Technology Direction

The primary transactional database is expected to be PostgreSQL. Exact backend and frontend frameworks will be decided after the domain/data model is sufficiently specified.

## Consequences

### Positive

- Strong domain boundaries
- Simple initial deployment
- Easier end-to-end testing
- Multi-organization readiness
- AI independence
- Clear path from farm operations to broader agribusiness
- Easier future service extraction

### Negative

- Requires discipline to prevent modules from becoming coupled
- Future service extraction may require explicit integration boundaries
- More up-front modeling than a CRUD-first application

## Deferred Decisions

- Backend framework
- Frontend/mobile framework
- Authentication provider
- Background job infrastructure
- Object storage
- Event bus, if later required
- IoT ingestion architecture
- Final open-source/commercial licensing terms
