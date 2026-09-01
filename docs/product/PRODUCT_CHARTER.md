# SWAFOS Product Charter

## 1. Product Definition

SWAFOS (Smart & Wealth Agribusiness Operating System) is an open-core agribusiness operating system that connects production, aggregation, supply chain, commerce, finance, and decision intelligence.

The product is intentionally broader than a farm-management application.

## 2. Problem

Agribusiness data is commonly fragmented across notebooks, spreadsheets, chat applications, accounting tools, inventory records, and informal transactions. This makes it difficult to answer basic management questions:

- What do we own and where is it?
- What was produced, when, and at what cost?
- Which lots are available, committed, moving, or sold?
- What margin was created at each stage?
- Which customer, product, farm, batch, or channel is economically attractive?
- Where should the next unit of capital be allocated?

SWAFOS aims to create one traceable operational and economic model across those stages.

## 3. Primary Users

SWAFOS supports organizations and individuals participating in agribusiness value chains:

- Producers
- Collectors
- Aggregators
- Traders
- Distributors
- Processors
- Retailers
- Buyers

A business actor may hold multiple roles simultaneously.

## 4. Value Flow

```text
Plan
  ↓
Production
  ↓
Harvest
  ↓
Lot
  ↓
Aggregation / Transformation
  ↓
Inventory / Logistics
  ↓
Offer / Order / Sale
  ↓
Settlement
  ↓
Economic Result
  ↓
Decision
```

## 5. Product Objective

The system must turn operational activity into reliable data and reliable data into better commercial and capital-allocation decisions.

The core management loop is:

`Observe → Measure → Understand Economics → Decide → Act → Measure Again`

## 6. Economic Anchor

A production batch is the primary economic anchor for production economics. A lot is the primary traceability and commercial movement unit after output enters the supply chain.

The system should be able to trace, when data exists:

`Capital/Input → Batch → Harvest → Lot → Movement → Sale → Revenue → Margin → ROI`

## 7. First Reference Deployment

The initial real-world validation program starts on **1 September 2026** and runs for **19 months**, with an initial target of **Rp500 million** in measurable accumulated business value/cash-equivalent.

The reference operation includes online business, aquaculture in tarpaulin ponds, village chicken, and agriculture on approximately one hectare, developed in stages.

The deployment is a product validation environment—not the definition of the entire product.

## 8. Product Principles

### Business requirements drive software

Every major feature must correspond to an operational, commercial, financial, or decision-making need.

### Data before dashboards

Metrics and dashboards must derive from an explicit data model and defined calculations.

### Traceability by design

Production outputs, lots, inventory movements, orders, sales, and settlements should be linkable whenever the underlying business process provides that information.

### Economics is first-class

Cost, revenue, margin, cash movement, and return on capital are not reporting afterthoughts.

### Core without AI

The operational core must remain functional if AI and advanced intelligence services are unavailable.

### Modular, not fragmented

The first implementation is a modular monolith. Domains have explicit boundaries without premature microservices.

### Open-core with clean boundaries

Open-source core capabilities should be useful independently. Commercial capabilities must be separated through explicit modules, interfaces, or services.

## 9. V0.1 Success Criteria

V0.1 is successful when SWAFOS can represent a real agribusiness operation with:

1. multiple business actors and roles;
2. production units and production batches;
3. harvest outputs and traceable lots;
4. inventory and movement records;
5. purchase and sales transactions;
6. cost, revenue, cash, and margin records;
7. auditable state transitions; and
8. enough structured data to calculate meaningful unit economics and KPIs.

## 10. Non-Goals for V0.1

- Full accounting/ERP replacement
- Universal tax compliance engine
- High-frequency IoT telemetry platform
- Full consumer marketplace
- Advanced autonomous AI agents
- Microservice infrastructure before scale justifies it
