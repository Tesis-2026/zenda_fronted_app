# Onboarding feature

3-screen carousel shown the first time a user opens the app. Decides where to go (onboarding → auth → dashboard) on every cold start via a splash decider.

## Files

| File | Role |
|------|------|
| `splash_decider.dart` | Initial route at `/`. Reads `OnboardingPrefs` and `AuthController` state, redirects to `/onboarding`, `/auth/login`, or `/dashboard` accordingly. |
| `onboarding_screen.dart` | The 3-page `PageView` carousel itself. Wires `Skip`, `Next`, `Start` and `I already have an account` buttons. Marks completion in `OnboardingPrefs` when finished or skipped. |
| `onboarding_page.dart` | Reusable per-page widget: hero icon with gradient, title + subtitle + microcopy, content card. |
| `onboarding_prefs.dart` | Thin wrapper over `SharedPreferences` for the `onboarding_completed` boolean. Non-sensitive, so SharedPreferences (not FlutterSecureStorage) is correct here. |
| `profile_setup_screen.dart` | Post-register profile collection (age, university, income type, financial-literacy level) — US-0105. |

## Navigation contract

```
App cold start
      ↓
SplashDecider (/)
      ↓
      ├─ onboarding_completed = false  → /onboarding
      │                                    ↓
      │                                 [Skip] or [Start]
      │                                    ↓
      ├─ authenticated                  → /dashboard
      └─ not authenticated              → /auth/login (via AuthGate)
```

All routes are declared in [`lib/routing/app_router.dart`](../../routing/app_router.dart) — never push routes ad-hoc.

## State

- `onboardingPrefsProvider` exposes the `OnboardingPrefs` instance.
- No Riverpod notifier yet — the screen reads/writes prefs directly. Acceptable because the state is single-write (set once, then read-only).
- Auth state comes from `authNotifierProvider` (declared in [`features/auth/`](../auth/)).

## i18n

All UI strings come from `context.l10n.*` (see [`lib/l10n/app_es.arb`](../../l10n/app_es.arb) for the authoritative copy). The 3 onboarding pages use keys:

- `onboardingPage1Title` / `onboardingPage1Subtitle` / `onboardingPage1Micro`
- Same shape for pages 2 and 3
- `onboardingSkip`, `onboardingNext`, `onboardingStart`, `onboardingHaveAccount`

When changing copy, edit the ARB file then run `flutter gen-l10n` (config in [`l10n.yaml`](../../../l10n.yaml)).

## Resetting onboarding (dev)

Call `OnboardingPrefs.resetOnboarding()` from a debug action, or uninstall the app. There is no in-app reset for end users by design.
