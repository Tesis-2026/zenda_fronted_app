# Dashboard

Bottom-navigation shell + Home tab content. Entry point after successful login.

## User stories

- US-019 — Show 50/30/20 budget breakdown
- US-022 — Daily streak counter
- US-AI-tip — Inline AI advice card
- US-summary — Recent transactions + today/week totals

## Screens

| Route | Widget | Description |
|-------|--------|-------------|
| `/dashboard` | `DashboardScreen` | Bottom-nav shell with 4 tabs (Home, Transactions, Budget, Profile). Routes to nested screens. |

The Home tab content is composed inline from the widgets in `widgets/`.

## Files

| File | Role |
|------|------|
| `dashboard_screen.dart` | Top-level scaffold + bottom navigation. Owns the active-tab state. |
| `dashboard_providers.dart` | Riverpod providers for accounts / transactions / day-week-month summaries / streak. Most are `FutureProvider` over the corresponding API services. |
| `widgets/summary_card.dart` | Today's spend + this-week total. Reads `daySummaryProvider` + `weekSummaryProvider`. |
| `widgets/streak_card.dart` | Daily streak counter with ICU plural label. |
| `widgets/budget_pie_chart.dart` | 50/30/20 pie chart via `fl_chart`. |
| `widgets/zenda_ai_card.dart` | AI tip card (currently uses `aiAdviceProvider.family` — locale-aware, see UX-07 in audit-issues). |
| `widgets/account_card.dart` | Individual account balance tile (cash / debit / credit). |

## State (Riverpod)

| Provider | Type | Purpose |
|----------|------|---------|
| `daySummaryProvider` | `FutureProvider` | Today's totals (income / expense / net) |
| `weekSummaryProvider` | `FutureProvider` | This ISO week |
| `monthSummaryProvider` | `FutureProvider` | Current month + top categories |
| `accountsProvider` | `AsyncNotifier<List<Account>>` | All accounts for the user |
| `transactionsProvider` | `AsyncNotifier<List<TransactionModel>>` | Recent transactions |
| `streakStateProvider` | `AsyncNotifier<StreakState>` | Days streak + last active date |

`recommendationsProvider`, `aiAdviceProvider.family`, etc. are declared in [`../recommendations/`](../recommendations/) and [`../../providers/`](../../providers/) respectively and consumed here.

## Navigation

- Entry: `/dashboard` (requires JWT — `AuthGate` redirects to `/auth/login` if not authenticated).
- Bottom nav tabs route to: Home (inline), `/transactions/list`, `/budgets`, `/profile`.
- Cards inside the Home tab route to: `/budgets`, `/goals`, `/transactions/new`, `/ai-chat`, etc.

All routes live in [`../../routing/app_router.dart`](../../routing/app_router.dart).

## API services consumed

- `InsightsApiService` — day/week/month summaries.
- `TransactionApiService` — recent transactions list.
- `AccountsRepository` — local-first accounts.
- `StreakRepository` — local-first streak counter.

## i18n keys

All `dashboard*` prefixed keys plus shared `common*`. See [`../../l10n/app_es.arb`](../../l10n/app_es.arb).

Recent additions:
- `dashboardPostSurveyBannerTitle/Body/Action` (post-survey re-invitation, AC-08)
- `dashboardBudgetTitle/Subtitle`
- `dashboardManageBudget` ("Gestionar →" — translated in the i18n batch this week)

## Cross-feature dependencies

- `auth/` — `authNotifierProvider` for sign-out + user.firstName in the greeting.
- `transactions/` — for routing to add-new and detail screens.
- `recommendations/` — `aiAdviceProvider` for the inline AI tip card.

## Open items

- **B10** (frontend, ~2h) — when `TransactionModel` gains the AI-tracking fields, the recent-transactions list could show a small "AI" chip on transactions where `categorySource = AI`. Currently the data is dropped at the parser. See ARCH-11.
- **B5** (frontend, in progress on another branch) — `ai_chat_screen.dart` uses `setState`; once migrated to Riverpod, the AI tip card on the dashboard should consume the same notifier for consistency.
