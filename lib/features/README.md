# Features

Every folder here is a top-level user journey (a screen or set of related screens). One folder per journey; nothing cross-feature lives in here (shared widgets go in [`../core/widgets/`](../core/widgets/), shared services in [`../core/services/`](../core/services/), shared models in [`../core/models/`](../core/models/)).

## Per-feature README template

Each `<feature>/README.md` should follow this template so a new contributor can find the same kinds of information in the same places across features:

```markdown
# <Feature name>

One-sentence purpose.

## User stories

- US-XXXX — short description
- ...

## Screens

| Route | Widget | Description |
|-------|--------|-------------|
| `/x/y` | `XxxScreen` | ... |

## Files

| File | Role |
|------|------|
| ... |

## State (Riverpod)

| Provider | Type | Purpose |
|----------|------|---------|
| `xxxProvider` | `Notifier` / `AsyncNotifier` / `Provider` / `FutureProvider.family` | ... |

If the feature still uses `setState` for business logic, flag it here with a pointer to B5.

## Navigation

How the feature is entered and where it exits to. Mention any `AuthGate`-style guards.

## API services consumed

- `XxxApiService.method()` — what + when called
- ...

## i18n keys

- `featureKey1`, `featureKey2`, ... (or "all keys are prefixed `<feature>*`")

## Cross-feature dependencies

What other features / shared services this one needs.

## Open items

Refactor batches that affect this feature — link to `docs/architecture-compliance-plan.md`.
```

## Feature index

| Folder | Purpose | README |
|--------|---------|--------|
| `ai_chat/` | Conversational AI assistant | _pending_ |
| `auth/` | Login / register / forgot / reset / verify OTP + AuthGate | _pending_ |
| `badges/` | Badges list with earned status | _pending_ |
| `budget/` | Budgets list + creation/edit | _pending_ |
| `categories/` | Category management (create / rename / delete custom) | _pending_ |
| `challenges/` | Challenges list + accept/complete | _pending_ |
| `consent/` | Ley-29733 consent screen | _pending_ |
| `dashboard/` | Bottom-nav shell + Home tab widgets (50/30/20, streak, AI tip, recent transactions) | [dashboard/README.md](dashboard/README.md) |
| `education/` | Topics + quizzes + learning path | _pending_ |
| `feedback/` | In-app feedback modal | _pending_ |
| `goals/` | Savings goals list + detail | _pending_ |
| `notifications/` | Notification preferences screen | _pending_ |
| `onboarding/` | Splash + 3-page carousel + post-register profile setup | [onboarding/README.md](onboarding/README.md) |
| `predictions/` | Next-month expense prediction | _pending_ |
| `profile/` | Profile read/edit | _pending_ |
| `progress/` | Progress screen (US-0407 stub today) | _pending_ |
| `recommendations/` | Recommendations list with accept/reject | _pending_ |
| `reports/` | Reports screen + PDF export | _pending_ |
| `settings/` | Settings (no language switch — app is Spanish-only) | _pending_ |
| `streak/` | Streak notifier (no screen of its own) | _pending_ |
| `surveys/` | Pre / Post / SUS surveys + comparison | _pending_ |
| `transactions/` | Add / edit / list / delete + classify-with-AI | _pending_ |

> Filling in the remaining 19 feature READMEs is tracked as a follow-up. The 2 done here (`onboarding/`, `dashboard/`) are the exemplars.
