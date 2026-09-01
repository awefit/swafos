# ADR-007 — Open-Core & Commercial Boundary

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001 through ADR-006

## Decision

SWAFOS will use an **open-core** product strategy. The open core must provide a complete, useful agribusiness operating foundation rather than functioning as a crippled demonstration edition.

Commercial value should primarily come from advanced capabilities, hosted services, enterprise requirements, integrations, and operational convenience—not from withholding the fundamental domain model.

## Recommended Core License

The current recommendation is **Apache License 2.0** for the open SWAFOS Core.

This recommendation is based on:

- permissive commercial and modification rights;
- explicit patent grant;
- broad compatibility with enterprise adoption and integration;
- ability for businesses to build proprietary applications around the core without forcing the entire derivative application to become open source.

This is a strategic recommendation, not legal advice. Before the first public distribution release, the project should perform a license/dependency compatibility review and confirm ownership of all distributed code.

## Open Core

The open core is intended to contain the capabilities required to operate and understand a basic agribusiness:

- Identity and organization model
- Business actor model
- Production core
- Production batches and harvests
- Lot and traceability core
- Inventory and movement core
- Basic purchasing and sales
- Basic settlement records
- Core cost/revenue/economic model
- Configurable profit allocation policy
- Core API/domain engine
- Basic reporting and KPI primitives

The default 30/30/30/10 allocation is business policy data and remains available to the core; it is not a proprietary feature.

## Potential Commercial Modules

Commercial packaging may include:

- managed cloud/SaaS hosting
- advanced analytics
- advanced forecasting and optimization
- AI decision support and agents
- enterprise workflow/approval features
- advanced marketplace services
- premium integrations
- advanced logistics integrations
- high-volume IoT/telemetry services
- enterprise support/SLA
- managed backup, observability, and compliance services

These are candidates, not a final promise. Each commercial module must have a documented boundary.

## Commercial Packaging

Proprietary modules/services should live behind explicit interfaces and should not require changing the semantics of the open core.

A commercial deployment may use the open core plus proprietary services, but customers should not be forced to purchase proprietary components merely to retain access to their core operational data.

## Third-Party Code

SWAFOS will not copy source code from external repositories merely because it is useful. When an external project is used, SWAFOS will choose one of:

1. dependency under a compatible license;
2. clean-room reimplementation based on publicly documented behavior where legally appropriate;
3. contribution/upstream integration;
4. separately licensed commercial dependency.

Required copyright notices, attribution, license texts, and source-distribution obligations will be preserved where applicable.

## Repository Hygiene

SWAFOS source files should describe SWAFOS itself and its own architecture. Historical provenance and third-party notices belong in appropriate documentation such as `NOTICE`, dependency manifests, or `THIRD_PARTY_NOTICES.md` when required.

The project must never remove legally required attribution or notices merely to make the repository appear independently authored.

## Commercial Boundary Rules

1. Do not deliberately cripple the open core to force commercial adoption.
2. Do not place essential domain entities behind a proprietary wall if the open core depends on them.
3. Keep commercial modules behind explicit interfaces.
4. Avoid proprietary dependencies in the core unless there is a strong architectural reason.
5. Document commercial capabilities separately from core domain semantics.
6. Keep the data model portable enough to avoid customer lock-in.
7. Treat business allocation policies as configurable domain data, not licensing controls.

## Consequences

### Positive

- Community can inspect and extend the core.
- Commercial services can fund sustained development.
- Customers can self-host core capabilities.
- Domain architecture remains transparent.
- A permissive core lowers enterprise adoption friction.
- Clear legal and engineering boundaries reduce future migration cost.

### Negative

- Apache-2.0 does not prevent competitors from building commercial products on the core.
- Commercial differentiation must therefore come from execution, services, advanced modules, data/network effects, and product quality.
- License selection requires a legal/dependency review before public distribution.

## Next Step

Complete the V0.1 relational model with configurable allocation-policy and profit-allocation entities, then perform the final architecture review before the first migration.
