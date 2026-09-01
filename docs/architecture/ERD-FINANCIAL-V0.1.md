# SWAFOS Financial ERD Extension V0.1

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-006, ADR-008, ADR-009, ERD-V0.1

## Purpose

This extension adds the financial policy, allocation, capital, debt, and growth-fund concepts required by the SWAFOS economic model without conflating them with revenue, expense, assets, liabilities, profit, or cash.

## 1. Business Scope

A business scope identifies an economic operating area within an organization.

```text
business_scopes
- id PK uuid
- organization_id FK organizations
- parent_scope_id FK business_scopes nullable
- code
- name
- scope_type (business|project|production_line|trading|online|other)
- status
- created_at
- updated_at
```

Examples:

```text
Organization
├── Fish Farm
├── Chicken
├── Crop
├── Trading
└── Online Business
```

## 2. Profit Allocation Policy

```text
profit_allocation_policies
- id PK uuid
- organization_id FK organizations
- scope_id FK business_scopes nullable
- code
- name
- status
- created_at
- updated_at

profit_allocation_policy_versions
- id PK uuid
- policy_id FK profit_allocation_policies
- version_number
- effective_from
- effective_to nullable
- profit_basis_code
- status
- created_at

profit_allocation_rules
- id PK uuid
- policy_version_id FK profit_allocation_policy_versions
- beneficiary_type (investor|operator|growth|csr|custom)
- percentage numeric
- destination_type
- priority integer
- created_at
```

Constraint: active policy versions must have allocation rules totaling exactly 100%.

## 3. Allocation Runs

```text
profit_allocation_runs
- id PK uuid
- organization_id FK organizations
- scope_id FK business_scopes nullable
- policy_version_id FK profit_allocation_policy_versions
- period_start
- period_end
- gross_revenue_amount numeric
- eligible_cost_amount numeric
- distributable_profit_amount numeric
- currency_code
- status (draft|calculated|approved|finalized|adjusted)
- calculated_at
- approved_at nullable
- finalized_at nullable
- created_by FK users

profit_allocation_entitlements
- id PK uuid
- allocation_run_id FK profit_allocation_runs
- beneficiary_type
- beneficiary_actor_id FK business_actors nullable
- target_amount numeric
- approved_amount numeric nullable
- committed_amount numeric default 0
- paid_amount numeric default 0
- retained_amount numeric default 0
- deferred_amount numeric default 0
- currency_code
- status
```

`target_amount` is the policy result. It is not automatically a cash payment.

## 4. Growth Fund

```text
growth_funds
- id PK uuid
- organization_id FK organizations
- scope_id FK business_scopes nullable
- name
- currency_code
- status
- created_at

growth_fund_transactions
- id PK uuid
- organization_id FK organizations
- growth_fund_id FK growth_funds
- transaction_type (allocation|commitment|deployment|release|adjustment)
- amount numeric
- currency_code
- allocation_entitlement_id FK profit_allocation_entitlements nullable
- reference_type nullable
- reference_id nullable
- occurred_at
- notes nullable
```

The balance is derived from transactions.

## 5. Capital Sources

```text
capital_sources
- id PK uuid
- organization_id FK organizations
- source_type (investor|owner|retained_cash|loan|other)
- provider_actor_id FK business_actors nullable
- name
- currency_code
- status
- created_at

capital_transactions
- id PK uuid
- organization_id FK organizations
- capital_source_id FK capital_sources
- transaction_type (contribution|drawdown|conversion|return|adjustment)
- amount numeric
- currency_code
- occurred_at
- reference nullable
- notes nullable
```

Capital contributions must never be recognized as revenue.

## 6. Loans

```text
loans
- id PK uuid
- organization_id FK organizations
- lender_actor_id FK business_actors
- loan_number
- principal_amount numeric
- currency_code
- interest_terms nullable
- start_date
- maturity_date nullable
- status

loan_installments
- id PK uuid
- loan_id FK loans
- due_date
- principal_due numeric
- interest_due numeric
- status

loan_payments
- id PK uuid
- loan_id FK loans
- installment_id FK loan_installments nullable
- principal_amount numeric
- interest_amount numeric
- currency_code
- paid_at
- cash_transaction_id FK cash_transactions nullable
```

Principal repayment reduces liability and cash. Interest is an economic cost according to the organization's financial policy.

## 7. Assets

The V0.1 asset model is intentionally minimal.

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
- status

asset_depreciation_entries
- id PK uuid
- organization_id FK organizations
- asset_id FK assets
- period_start
- period_end
- depreciation_amount numeric
- currency_code
- status
```

Asset acquisition is not an operating cost by default. Depreciation may be included in eligible business costs according to policy.

## 8. Expansion Initiatives

```text
expansion_initiatives
- id PK uuid
- organization_id FK organizations
- scope_id FK business_scopes nullable
- name
- description nullable
- status (proposed|approved|funded|in_progress|completed|cancelled)
- estimated_cost numeric nullable
- expected_incremental_revenue numeric nullable
- expected_incremental_profit numeric nullable
- expected_payback_months numeric nullable
- currency_code nullable
- created_at
- approved_at nullable

expansion_funding
- id PK uuid
- organization_id FK organizations
- expansion_initiative_id FK expansion_initiatives
- growth_fund_id FK growth_funds nullable
- cash_account_id FK cash_accounts nullable
- amount numeric
- currency_code
- funded_at
```

Expansion is represented as a decision and funding event. The resulting expenditure is separately classified as asset acquisition, working capital, operating cost, or another appropriate category.

## 9. Financial Planning View

SWAFOS should derive a planning view from actual records rather than storing a single manually edited `available_cash` number.

Conceptual calculation:

```text
Cash on Hand
+ Expected Inflows
- Required Working Capital
- Committed Obligations
- Debt Due
- Minimum Reserve
= Discretionary Cash Capacity
```

This is a planning metric, not an accounting balance.

## 10. Financial Classification Rules

```text
Investor contribution       → Capital
Loan proceeds               → Liability / Financing
Asset purchase              → Asset + Cash decrease
Operating expense           → Cost + Cash decrease/payable
Depreciation                → Economic cost, non-cash
Gross sale                  → Revenue / Receivable or Cash
Debt principal repayment    → Liability decrease + Cash decrease
Debt interest               → Financing cost + Cash/Payable
Profit allocation target    → Entitlement, not automatically Cash
Actual distribution         → Cash decrease + settlement
Growth retention            → Growth Fund balance
Growth deployment           → Funding event + underlying expenditure
CSR payment                 → Actual cash distribution/expense according to policy
```

## 11. Integrity Rules

- Financial records must be tenant-scoped.
- Allocation policy percentages must total 100%.
- Policy versions are immutable after finalization; corrections use new versions.
- Finalized allocation runs are immutable; corrections use adjustments.
- Capital and loan proceeds cannot enter revenue calculations.
- Asset acquisition cannot automatically reduce distributable profit as an operating cost.
- Principal repayment cannot reduce operating profit.
- Growth fund balances are derived from transactions.
- Actual distributions cannot exceed approved/available amounts.
- Cash planning must not mutate accounting records.

## 12. Review Gate

Before generating the first migration, review:

1. Financial classification rules.
2. Policy versioning and 100% validation.
3. Allocation run lifecycle.
4. Growth fund semantics.
5. Loan principal/interest separation.
6. Asset/depreciation treatment.
7. Expansion funding model.
8. Whether V0.1 needs full double-entry accounting or a lighter economic ledger.

## Next Step

After this review gate, consolidate the base ERD and financial extension into the first PostgreSQL migration plan and implement the smallest end-to-end vertical slice.
