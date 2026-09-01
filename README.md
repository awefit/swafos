# SWAFOS

**Smart & Wealth Agribusiness Operating System**

SWAFOS is an open-core operating system for agribusiness: connecting production, aggregation, supply chain, commerce, finance, and decision intelligence in one coherent system.

## Vision

SWAFOS is designed around the complete agribusiness value flow:

`Production → Harvest → Lot → Aggregation → Inventory → Trade → Sale → Settlement → Economics → Decision`

It is intended for producers, collectors, aggregators, distributors, processors, retailers, and buyers—not only farmers.

## Product Principles

- Business requirements drive the software.
- Data before dashboards.
- Every production batch is an economic unit.
- Every material movement should be traceable when the data exists.
- Measure before scaling.
- Core functionality must work without AI.
- Modular monolith first; extract services only when justified by scale.
- API-first application boundary.
- Open-core with explicit commercial boundaries.
- Third-party software is used compliantly, including required notices and license obligations.

## Core Domains

- Identity & Organizations
- Business Actors
- Production
- Supply Chain
- Inventory & Warehousing
- Commerce
- Finance & Economics
- Analytics & Intelligence

## Production Domains

- Agriculture
- Aquaculture
- Poultry
- Livestock

## Business Actors

A single organization or person may hold multiple roles, including:

- Producer
- Collector
- Aggregator
- Trader
- Distributor
- Processor
- Retailer
- Buyer

## Reference Deployment

The first real-world validation program begins **1 September 2026** and runs for **19 months**, targeting **Rp500 million** of measurable accumulated business value/cash-equivalent.

This program is a reference deployment and validation environment. It does not limit the product to the initial farm operation.

## Architecture Status

**V0.1 — Foundation**

Architecture and domain decisions are being established before application implementation.

## Repository Structure

```text
docs/
  product/
  architecture/
  domain/
  economics/

src/                  # application implementation after foundation
  core/
  modules/

infra/                # deployment and infrastructure configuration

tests/
```

## Licensing

SWAFOS is planned as an open-core project. The exact open-source license and commercial module boundaries will be documented through an architecture decision before production distribution.

Third-party notices will be maintained separately where required.
