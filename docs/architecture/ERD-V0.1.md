# SWAFOS Relational ERD V0.1

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001 through ADR-007 and DOMAIN-MODEL-V0.1

## Purpose

This document converts the canonical domain model into a relational design suitable for PostgreSQL. It is intentionally still a design artifact; it is not the migration itself.

## Design Principles

1. Every tenant-owned business record carries an explicit `organization_id` unless it is inherently global reference data.
2. UUIDs are used as primary identifiers exposed by the application.
3. Business codes are separate from primary keys.
4. Money is stored as fixed-precision decimal plus an explicit currency code; floating point is prohibited for monetary values.
5. Quantities use fixed-precision decimal plus explicit unit of measure.
6. Transactional records are append-oriented where mutation would destroy history.
7. Lifecycle state changes are auditable.
8. Foreign keys preserve relational integrity.
9. Database constraints enforce invariants that must never be violated by application code alone.
10. Timestamps are stored in UTC using PostgreSQL `timestamptz`; the organization/location timezone is retained for business presentation and date interpretation.

## Core Tables

### Identity & Organization

```text
organizations
- id PK uuid
- name
- legal_name nullable
- timezone
- base_currency_code
- status
- created_at
- updated_at

users
- id PK uuid
- email
- display_name
- status
- created_at
- updated_at

memberships
- id PK uuid
- organization_id FK organizations
- user_id FK users
- status
- created_at
- updated_at

roles
- id PK uuid
- organization_id FK nullable for system roles
- code
- name

membership_roles
- membership_id FK memberships
- role_id FK roles
- PK (membership_id, role_id)
```

### Business Actors

```text
business_actors
- id PK uuid
- organization_id FK organizations
- party_type (person|organization)
- display_name
- legal_name nullable
- external_reference nullable
- status
- created_at
- updated_at

business_actor_roles
- id PK uuid
- organization_id FK organizations
- business_actor_id FK business_actors
- role_code
- valid_from
- valid_to nullable
- status

business_actor_relationships
- id PK uuid
- organization_id FK organizations
- actor_id FK business_actors
- counterparty_actor_id FK business_actors
- relationship_type
- status
- valid_from
- valid_to nullable
- terms_json nullable
- created_at
- updated_at
```

An organization may maintain its own representation of external actors. Identity matching across organizations is deliberately deferred; external references are not assumed to be globally unique.

## Master Data

```text
units_of_measure
- id PK uuid
- code unique
- name
- dimension
- precision

products
- id PK uuid
- organization_id FK organizations
- sku nullable
- name
- product_type
- base_uom_id FK units_of_measure
- status
- created_at
- updated_at

product_uom_conversions
- id PK uuid
- product_id FK products
- from_uom_id FK units_of_measure
- to_uom_id FK units_of_measure
- factor decimal
- valid_from
- valid_to nullable

locations
- id PK uuid
- organization_id FK organizations
- parent_location_id FK locations nullable
- location_type
- name
- timezone nullable
- status
- created_at
- updated_at
```

## Production

```text
production_units
- id PK uuid
- organization_id FK organizations
- location_id FK locations
- unit_type (plot|pond|coop|greenhouse|other)
- code
- name
- capacity_quantity nullable
- capacity_uom_id FK units_of_measure nullable
- status
- created_at
- updated_at

production_batches
- id PK uuid
- organization_id FK organizations
- production_unit_id FK production_units
- product_id FK products
- batch_code
- planned_quantity nullable
- planned_uom_id FK units_of_measure nullable
- started_at
- expected_end_at nullable
- ended_at nullable
- status
- created_at
- updated_at

production_activities
- id PK uuid
- organization_id FK organizations
- production_batch_id FK production_batches
- activity_type
- occurred_at
- notes nullable
- created_by FK users

input_consumptions
- id PK uuid
- organization_id FK organizations
- production_batch_id FK production_batches
- product_id FK products
- quantity decimal
- uom_id FK units_of_measure
- occurred_at
- source_lot_id FK lots nullable
- cost_id FK costs nullable

production_observations
- id PK uuid
- organization_id FK organizations
- production_batch_id FK production_batches
- observed_at
- metric_code
- numeric_value nullable
- text_value nullable
- uom_id FK units_of_measure nullable
- notes nullable

production_losses
- id PK uuid
- organization_id FK organizations
- production_batch_id FK production_batches
- occurred_at
- quantity decimal
- uom_id FK units_of_measure
- reason_code
- notes nullable

harvests
- id PK uuid
- organization_id FK organizations
- production_batch_id FK production_batches
- harvested_at
- quantity decimal
- uom_id FK units_of_measure
- quality_grade nullable
- notes nullable
```

## Lot & Inventory

```text
lots
- id PK uuid
- organization_id FK organizations
- product_id FK products
- lot_code
- source_type
- source_harvest_id FK harvests nullable
- quantity_created decimal
- uom_id FK units_of_measure
- owner_actor_id FK business_actors nullable
- custodian_actor_id FK business_actors nullable
- current_location_id FK locations nullable
- status
- created_at
- closed_at nullable

lot_lineage
- id PK uuid
- organization_id FK organizations
- parent_lot_id FK lots
- child_lot_id FK lots
- relation_type (split|merge|transform|aggregate|repack)
- quantity decimal nullable
- uom_id FK units_of_measure nullable
- created_at

inventory_movements
- id PK uuid
- organization_id FK organizations
- lot_id FK lots
- movement_type
- quantity decimal
- uom_id FK units_of_measure
- source_location_id FK locations nullable
- destination_location_id FK locations nullable
- source_custodian_actor_id FK business_actors nullable
- destination_custodian_actor_id FK business_actors nullable
- occurred_at
- reference_type nullable
- reference_id nullable
- posted_at
- posted_by FK users

inventory_allocations
- id PK uuid
- organization_id FK organizations
- lot_id FK lots
- order_line_id FK order_lines
- quantity decimal
- uom_id FK units_of_measure
- status
- created_at
- released_at nullable
```

`inventory_movements` are the stock ledger. `inventory_balances` should be a derived/read-optimized projection, not the authoritative source.

## Commerce

```text
offers
- id PK uuid
- organization_id FK organizations
- seller_actor_id FK business_actors
- buyer_actor_id FK business_actors nullable
- offer_number
- status
- valid_from
- valid_until
- currency_code
- payment_terms nullable
- delivery_terms nullable
- created_at

offer_lines
- id PK uuid
- offer_id FK offers
- product_id FK products
- quantity decimal
- uom_id FK units_of_measure
- unit_price decimal
- discount_amount decimal

orders
- id PK uuid
- organization_id FK organizations
- seller_actor_id FK business_actors
- buyer_actor_id FK business_actors
- order_number
- source_offer_id FK offers nullable
- status
- ordered_at
- currency_code
- payment_terms nullable
- delivery_terms nullable

order_lines
- id PK uuid
- order_id FK orders
- product_id FK products
- quantity_ordered decimal
- uom_id FK units_of_measure
- unit_price decimal
- discount_amount decimal

fulfillments
- id PK uuid
- organization_id FK organizations
- order_id FK orders
- fulfillment_number
- status
- fulfilled_at nullable

fulfillment_lines
- id PK uuid
- fulfillment_id FK fulfillments
- order_line_id FK order_lines
- lot_id FK lots nullable
- quantity decimal
- uom_id FK units_of_measure

sales
- id PK uuid
- organization_id FK organizations
- seller_actor_id FK business_actors
- buyer_actor_id FK business_actors
- sale_number
- order_id FK orders nullable
- sale_date
- status
- currency_code
- subtotal_amount decimal
- discount_amount decimal
- total_amount decimal

sale_lines
- id PK uuid
- sale_id FK sales
- product_id FK products
- quantity decimal
- uom_id FK units_of_measure
- unit_price decimal
- discount_amount decimal

purchases
- id PK uuid
- organization_id FK organizations
- buyer_actor_id FK business_actors
- supplier_actor_id FK business_actors
- purchase_number
- purchase_date
- status
- currency_code
- subtotal_amount decimal
- total_amount decimal

purchase_lines
- id PK uuid
- purchase_id FK purchases
- product_id FK products
- quantity_ordered decimal
- quantity_received decimal
- uom_id FK units_of_measure
- unit_price decimal
```

## Finance & Economics

```text
costs
- id PK uuid
- organization_id FK organizations
- cost_code
- cost_type (direct|indirect|capital)
- category_code
- amount decimal
- currency_code
- occurred_at
- source_type nullable
- source_id nullable
- description nullable

revenues
- id PK uuid
- organization_id FK organizations
- revenue_code
- category_code
- amount decimal
- currency_code
- recognized_at
- source_sale_id FK sales nullable

cash_accounts
- id PK uuid
- organization_id FK organizations
- account_type
- name
- currency_code
- status

cash_transactions
- id PK uuid
- organization_id FK organizations
- cash_account_id FK cash_accounts
- direction (in|out)
- amount decimal
- currency_code
- occurred_at
- reference_type nullable
- reference_id nullable
- description nullable

receivables_payables
- id PK uuid
- organization_id FK organizations
- obligation_type (receivable|payable)
- actor_id FK business_actors
- source_type
- source_id
- original_amount decimal
- currency_code
- due_at nullable
- status

settlements
- id PK uuid
- organization_id FK organizations
- actor_id FK business_actors
- cash_account_id FK cash_accounts
- direction (in|out)
- amount decimal
- currency_code
- settled_at
- reference nullable
- status

settlement_allocations
- id PK uuid
- settlement_id FK settlements
- obligation_id FK receivables_payables
- amount decimal

cost_allocations
- id PK uuid
- organization_id FK organizations
- cost_id FK costs
- target_type
- target_id
- basis_code
- basis_quantity decimal nullable
- allocated_amount decimal
- currency_code
- rule_version
- created_at
```

For the first physical implementation, `target_type/target_id` in economic allocation should be replaced by strongly constrained relation tables or a dedicated economic-scope table if PostgreSQL referential integrity cannot be guaranteed adequately.

## Audit

```text
audit_events
- id PK uuid
- organization_id FK organizations
- actor_user_id FK users nullable
- entity_type
- entity_id
- event_type
- previous_state nullable
- new_state nullable
- occurred_at
- reason nullable
- metadata_json nullable
```

Audit events are append-only.

## Key Constraints

- `organizations.id`, all entity IDs: UUID primary keys.
- Organization-owned foreign keys must resolve within the same organization where both records are tenant-owned.
- Quantity must be positive for normal receive/issue records; signed effects belong to movement semantics, not ambiguous quantity values.
- Money amounts use `numeric`, never floating point.
- Currency is explicit on every monetary transaction.
- UOM is explicit on every quantity-bearing transaction.
- Order line, fulfillment line, sale line, purchase line, and settlement allocation quantities cannot exceed their relevant business limits.
- A lot cannot be allocated beyond available unreserved quantity.
- A settlement cannot allocate more than the outstanding obligation.
- Historical transaction prices are snapshots and must not depend on mutable current price lists.

## Indexing Strategy

Initial indexes should cover:

- `(organization_id, status)` on lifecycle-heavy tables;
- `(organization_id, created_at)` for operational timelines;
- `(organization_id, lot_code)` unique where appropriate;
- `(organization_id, batch_code)` unique where appropriate;
- `(organization_id, order_number)` unique;
- `(organization_id, sale_number)` unique;
- `(organization_id, purchase_number)` unique;
- inventory movement queries by `(organization_id, lot_id, occurred_at)`;
- lot location queries by `(organization_id, current_location_id)`;
- financial source lookups by `(organization_id, source_type, source_id)` where used.

## Soft Delete Policy

Core transactional records should not use ordinary soft deletion as a substitute for auditability. Instead:

- master data may have `status=archived`;
- transactions remain historically visible;
- corrections use explicit reversal/adjustment events;
- destructive deletion is restricted and exceptional.

## Tenant Isolation

Application-level organization scoping is mandatory. PostgreSQL Row Level Security may be introduced when deployment architecture and authentication claims are stable enough to support it safely.

## Migration Strategy

The first migration should create reference/master tables first, followed by production, lots/inventory, commerce, finance, and audit tables. Foreign keys should be added in dependency order.

No production migration should be generated from this document until the following review points are accepted:

1. Business Actor model
2. Lot/lineage semantics
3. Money and quantity precision
4. Tenant isolation strategy
5. Economic attribution strategy
6. Audit/reversal policy
