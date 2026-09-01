# ADR-005 — Commerce & Transaction Model

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-001 through ADR-004

## Decision

SWAFOS will separate commercial intent, fulfillment, invoicing/recognition, and settlement. A single sale or purchase may be fulfilled and paid in multiple stages.

## Commercial Flow

```text
Price / Offer
     ↓
   Order
     ↓
 Fulfillment
     ↓
   Sale / Purchase
     ↓
 Invoice / Economic Recognition
     ↓
 Settlement
```

The exact documents used by a business may vary, but the domain model must not assume that an order equals a delivery or that a sale equals immediate payment.

## Buy-Side

```text
Supplier
   ↓
Purchase Request / Order
   ↓
Receipt
   ↓
Inventory
   ↓
Payable
   ↓
Settlement
```

A purchase may receive only part of the ordered quantity. Received quantities create inventory movements; unreceived quantities remain commitments.

## Sell-Side

```text
Customer
   ↓
Offer / Order
   ↓
Reservation / Allocation
   ↓
Fulfillment
   ↓
Sale
   ↓
Receivable
   ↓
Settlement
```

A sale may be partially fulfilled and partially paid.

## Offers and Pricing

An offer represents a commercial proposal and may contain:

- seller
- buyer or target market
- product
- quantity
- unit price
- currency
- validity period
- minimum order quantity
- delivery terms
- payment terms
- quality/grade requirements

Pricing must be versioned or snapshotted at transaction time so later price-list changes do not rewrite historical transactions.

## Order

An order is a commercial commitment. It may reference an offer but must retain the agreed transaction terms.

An order supports:

- multiple lines
- partial fulfillment
- cancellation of remaining quantity
- allocation against one or more lots
- delivery/fulfillment records
- payment terms

## Fulfillment

Fulfillment represents physical or service delivery against an order.

For physical goods, fulfillment creates or references inventory movements and lot allocations.

```text
Order Line: 1,000 kg
        ↓
Fulfillment #1: 400 kg from LOT-A
Fulfillment #2: 600 kg from LOT-B
```

## Sale

A sale records the commercial transaction resulting from fulfilled or otherwise recognized goods/services.

A sale line should preserve:

- product
- quantity
- unit price
- discount
- tax fields if enabled by a future tax module
- currency
- source lot(s) where traceable

## Purchase

Purchase records acquisition from an external supplier. It may create inventory and payable obligations independently of payment timing.

## Settlement

Settlement records payment against one or more receivable/payable obligations.

Settlement must support:

- full payment
- partial payment
- multiple payments
- payment date
- payment method/account
- reference
- allocation to obligations

Cash movement is separate from the commercial document.

## Returns and Cancellations

Cancellation prevents further fulfillment or settlement according to transaction state. It does not erase the historical transaction.

Returns are explicit business events that can reverse or adjust quantities, inventory, receivables/payables, and economic recognition as appropriate.

## Ownership Transfer

An order or reservation does not transfer ownership. Ownership changes through the relevant completed transaction/event according to the business process.

## Lot Allocation

Lot allocation links demand to available supply without mutating the lot's historical origin.

A single order may consume multiple lots. A single lot may fulfill multiple orders, subject to available quantity and reservation rules.

## Transaction State

Initial state patterns:

### Offer
`draft → issued → accepted | rejected | expired | cancelled`

### Order
`draft → confirmed → partially_fulfilled → fulfilled | cancelled`

### Purchase
`draft → ordered → partially_received → received | cancelled`

### Settlement
`pending → partially_settled → settled | failed | reversed`

Transitions must be auditable and validated.

## Consequences

### Positive

- Supports real-world partial delivery and payment
- Separates commercial commitment from physical inventory
- Supports collector/distributor/retailer workflows
- Allows future marketplace workflows without redesigning the transaction core
- Preserves historical prices and terms

### Negative

- More entities than a simple sales CRUD model
- Requires careful state-machine implementation
- Requires reconciliation between commerce, inventory, and finance

## Next Step

Define the economic model: cost attribution, revenue recognition, cash, margin, capital, allocation, and ROI.
