# SWAFOS Financial Schema V0.1

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-008, ADR-009

## Purpose

Defines the minimum relational model required for SWAFOS business economics, capital, debt, assets, cash flow, and configurable profit allocation without implementing a full double-entry accounting system.

## 1. Economic Scope

```text
economic_scopes
- id PK uuid
- organization_id FK organizations
- scope_type
- name
- parent_scope_id FK economic_scopes nullable
- status
- created_at
- updated_at
```

A scope can represent an organization, business unit, project, production batch, production unit, commercial activity, or other controlled management scope. Domain-specific links should be explicit rather than relying on arbitrary polymorphic references where possible.

## 2. Costs & Revenue

```text
costs
- id PK uuid
- organization_id FK organizations
- economic_scope_id FK economic_scopes nullable
- cost_code
- cost_type (operating|tax|depreciation|financing|capital)
- category_code
- amount numeric
- currency_code
- occurred_at timestamptz
- cash_effect_type (cash|non_cash)
- source_type nullable
- source_id nullable
- status
- created_at

revenues
- id PK uuid
- organization_id FK organizations
- economic_scope_id FK economic_scopes nullable
- revenue_code
- category_code
- amount numeric
- currency_code
- recognized_at timestamptz
- source_sale_id FK sales nullable
- status
- created_at
```

Capital expenditure is identifiable as `cost_type=capital` but must not be automatically deducted from the distributable result. It produces an asset/capital event.

## 3. Capital Sources

```text
capital_sources
- id PK uuid
- organization_id FK organizations
- source_type (investor|owner|retained|other_equity)
- actor_id FK business_actors nullable
- name
- currency_code
- committed_amount numeric nullable
- received_amount numeric
- received_at timestamptz nullable
- status
- created_at

capital_transactions
- id PK uuid
- organization_id FK organizations
- capital_source_id FK capital_sources
- transaction_type (contribution|return|transfer|adjustment)
- amount numeric
- currency_code
- occurred_at timestamptz
- cash_transaction_id FK cash_transactions nullable
- notes nullable
```

## 4. Loans

```text
loans
- id PK uuid
- organization_id FK organizations
- lender_actor_id FK business_actors nullable
- principal_amount numeric
- currency_code
- issued_at timestamptz
- maturity_at nullable
- interest_policy nullable
- status
- created_at

loan_installments
- id PK uuid
- organization_id FK organizations
- loan_id FK loans
- installment_number
- due_at timestamptz
- principal_due numeric
- interest_due numeric
- status

loan_payments
- id PK uuid
- organization_id FK organizations
- loan_installment_id FK loan_installments nullable
- loan_id FK loans
- principal_paid numeric
- interest_paid numeric
- paid_at timestamptz
- cash_transaction_id FK cash_transactions
```

Principal repayment is a balance-sheet/cash event, not operating expense. Interest is separately identifiable.

## 5. Assets

```text
assets
- id PK uuid
- organization_id FK organizations
- asset_code
- name
- asset_type
- acquisition_date
- acquisition_cost numeric
- currency_code
- useful_life_months nullable
- residual_value numeric nullable
- depreciation_method nullable
- status
- location_id FK locations nullable
- production_unit_id FK production_units nullable
- capital_source_id FK capital_sources nullable
- created_at

asset_depreciation_entries
- id PK uuid
- organization_id FK organizations
- asset_id FK assets
- period_start date
- period_end date
- depreciation_amount numeric
- currency_code
- cost_id FK costs
- created_at

asset_disposals
- id PK uuid
- organization_id FK organizations
- asset_id FK assets
- disposed_at timestamptz
- proceeds_amount numeric nullable
- currency_code nullable
- reason nullable
- status
```

## 6. Cash

The existing cash ledger is retained as the authoritative record of actual cash movement.

```text
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
- amount numeric
- currency_code
- occurred_at timestamptz
- reference_type nullable
- reference_id nullable
- description nullable
- status
```

Every capital receipt, loan receipt, sale receipt, cost payment, loan payment, and actual allocation distribution that affects cash should be traceable to a cash transaction.

## 7. Profit Allocation Policy

```text
profit_allocation_policies
- id PK uuid
- organization_id FK organizations
- name
- effective_from date
- effective_to date nullable
- scope_id FK economic_scopes nullable
- status
- created_at

profit_allocation_rules
- id PK uuid
- policy_id FK profit_allocation_policies
- beneficiary_type (investor|operator|growth|csr|other)
- percentage numeric
- priority integer
- created_at
```

A policy version is valid only when the rule percentages total exactly 100%.

## 8. Allocation Runs

```text
allocation_runs
- id PK uuid
- organization_id FK organizations
- policy_id FK profit_allocation_policies
- economic_scope_id FK economic_scopes
- period_start date
- period_end date
- distributable_result numeric
- currency_code
- status (calculated|approved|partially_executed|executed|deferred|cancelled)
- calculated_at timestamptz
- approved_at timestamptz nullable
- approved_by FK users nullable

allocation_entitlements
- id PK uuid
- allocation_run_id FK allocation_runs
- beneficiary_type
- target_amount numeric
- approved_amount numeric nullable
- committed_amount numeric nullable
- executed_amount numeric
- deferred_amount numeric
- retained_amount numeric
- currency_code
- status
```

The engine must preserve the distinction between policy target and actual cash movement.

## 9. Growth Fund

```text
growth_funds
- id PK uuid
- organization_id FK organizations
- economic_scope_id FK economic_scopes nullable
- name
- currency_code
- status

 growth_fund_transactions
- id PK uuid
- organization_id FK organizations
- growth_fund_id FK growth_funds
- allocation_entitlement_id FK allocation_entitlements nullable
- transaction_type (allocation|release|reinvestment|return|adjustment)
- amount numeric
- currency_code
- occurred_at timestamptz
- reference_type nullable
- reference_id nullable
- notes nullable
```

A growth allocation may remain in the fund without immediate spending.

## 10. Expansion

```text
expansion_initiatives
- id PK uuid
- organization_id FK organizations
- economic_scope_id FK economic_scopes
- name
- objective
- planned_amount numeric
- currency_code
- expected_start date nullable
- expected_end date nullable
- status

expansion_funding
- id PK uuid
- organization_id FK organizations
- expansion_initiative_id FK expansion_initiatives
- growth_fund_id FK growth_funds nullable
- capital_source_id FK capital_sources nullable
- amount numeric
- currency_code
- funded_at timestamptz
```

Expansion decisions must retain the source of funding and later performance metrics.

## 11. Financial Controls

- All financial amounts use fixed precision numeric types.
- Currency is explicit.
- Actual cash movements are immutable after posting; corrections use reversals/adjustments.
- Allocation calculations retain the policy version.
- Executed distributions require an actual cash transaction when cash changes.
- Capital contributions cannot be classified as revenue.
- Loan principal cannot be classified as revenue.
- Asset acquisition cannot be classified as operating expense solely because cash was paid.
- Depreciation can create a non-cash cost.
- Growth allocation is not automatically an expense.

## 12. Future Accounting Adapter

Every material economic event should expose a stable source identifier and enough attributes for a future adapter to create accounting journal entries.

No V0.1 table should require a general ledger account ID.
