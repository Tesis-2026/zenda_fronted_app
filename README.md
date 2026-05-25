# Zenda — Flutter app

Mobile frontend for the Zenda AI-assisted personal-finance app (thesis project, Peruvian university students 18–24). Backend lives at [`../zenda_backend_app`](../zenda_backend_app).

> ⚠️ The folder name `zenda_fronted_app` has a typo. It is intentional — git history preserves it. Do not rename.

---

## Stack

| Concern | Choice |
|---------|--------|
| SDK | Flutter 3.10+ / Dart |
| State management | Riverpod 3 (`Notifier` + `Provider` + `AsyncNotifier`) |
| Routing | GoRouter 17 — all routes declared in [`lib/routing/app_router.dart`](lib/routing/app_router.dart) |
| HTTP | `package:http` wrapped by [`lib/core/services/api_client.dart`](lib/core/services/api_client.dart) (token storage + 401 refresh-and-retry + single-flight) |
| Secure storage | `flutter_secure_storage` for JWT, refresh token, balances, transactions, streak, pending sync queue |
| Non-sensitive prefs | `SharedPreferences` (onboarding flag, etc.) |
| i18n | `flutter_localizations` + ARB files. **Spanish-only.** App locale forced to `es` in [`lib/app.dart`](lib/app.dart). |
| Theme | Light only (see [`lib/core/theme/`](lib/core/theme/)) |
| Charts | `fl_chart` |
| Local storage helper | `LocalKvStore` (typed wrapper over secure storage) |

---

## Run

```bash
flutter pub get
flutter run                  # full debug build
flutter analyze              # static checks (the canonical lint command for this repo)
flutter gen-l10n             # regenerate localizations after editing ARB files
```

Backend must be running at `http://localhost:3000` (default). Override with `API_BASE_URL` build-time env var if needed.

---

## Directory layout

```
lib/
├── main.dart                       # Bootstrap. Sets Intl.defaultLocale = 'es' + initializeDateFormatting('es').
├── app.dart                        # MaterialApp.router. locale hardcoded to Locale('es'); supportedLocales = [es].
├── core/
│   ├── models/                     # Entities consumed by the UI: User, Transaction, Account, Budget, SavingsGoal, ...
│   ├── services/                   # ApiClient + per-entity API services (AuthApiService, TransactionApiService, etc.)
│   ├── theme/                      # AppTheme (light), color/text-style tokens.
│   ├── widgets/                    # Reusable widgets (app_card, app_toast, sheet_header, ...).
│   └── utils/                      # Pure helpers (category_utils, date_formatter, ...).
├── features/                       # Feature-scoped folders. One folder per top-level user journey.
│   ├── auth/                       # login / register / forgot password / reset / verify OTP + AuthGate
│   ├── budget/                     # BudgetScreen + providers
│   ├── categories/                 # CategoryManagementScreen
│   ├── dashboard/                  # Bottom-nav shell + widgets (summary, streak, pie chart, AI tip)
│   ├── education/                  # Topics, quizzes, learning path
│   ├── feedback/                   # In-app feedback modal
│   ├── goals/                      # GoalsScreen + GoalDetailScreen
│   ├── notifications/              # Notification preferences screen
│   ├── onboarding/                 # Splash + 3-page carousel + profile setup (see lib/features/onboarding/README.md)
│   ├── predictions/                # Next-month expense prediction
│   ├── profile/                    # ProfileScreen (edit demographics + literacy level)
│   ├── progress/                   # ProgressScreen
│   ├── recommendations/            # Recommendations list + accept/reject
│   ├── reports/                    # Reports + PDF export
│   ├── settings/                   # Settings (categories, notifications, surveys, sign-out — no language switch)
│   ├── surveys/                    # Pre / Post / SUS + comparison screen
│   ├── transactions/               # Add / edit / list / delete + classify-with-AI
│   └── ai_chat/                    # Conversational assistant
├── l10n/                           # ARB files (es authoritative; en is the codegen template) + generated AppLocalizations.
├── providers/                      # Global Riverpod providers (services_providers, repositories_providers, ...).
└── routing/
    └── app_router.dart             # All GoRouter routes + auth guard.
```

---

## Conventions

- **State lives in providers, not widgets.** Widgets read and display only.
- **No `setState` for business logic.** Use Riverpod `Notifier` / `AsyncNotifier`. Pure UI ephemera (animation controllers, focus nodes) is OK in `StatefulWidget`.
- **No imperative navigation from business logic.** Use `context.go(...)` / `context.push(...)` from widget callbacks; route shape is declared centrally in `app_router.dart`.
- **No hardcoded UI strings** in widgets — always go through `context.l10n.*`. Hardcoded Spanish copy is only allowed inside mocked/demo data (`lib/core/mock/`), where it stands in for backend payloads.
- **All code, comments, and variable names in English.** Only user-facing strings (ARB values + mock data) are Spanish.
- **Failures must be visible.** Always render `loading` / `error` / `data` branches; never swallow async errors silently.

The full list of platform rules is in [`../skills/platform/platform-mobile/flutter/SKILLS.md`](../skills/platform/platform-mobile/flutter/SKILLS.md).

---

## Pointers

- Backend setup: [`../zenda_backend_app/README.md`](../zenda_backend_app/README.md)
- Project conventions: [`../CLAUDE.md`](../CLAUDE.md)
- Repository setup: [`../SETUP.md`](../SETUP.md)
- Architecture overview: [`../docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md)
- Pending refactor work: [`../docs/architecture-compliance-plan.md`](../docs/architecture-compliance-plan.md)
- Onboarding flow detail: [`lib/features/onboarding/README.md`](lib/features/onboarding/README.md)
