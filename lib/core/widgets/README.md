# Modal & Form Standard — Create / Edit / Delete

> Status: **implemented** — rollout complete (2026-05-31), `flutter analyze` clean. This document is
> the single source of truth for how every create / edit / delete interaction must look and behave.
> Decided 2026-05-30. Pattern: **modal bottom sheet** for create/edit, **confirm sheet** for destructive actions.
>
> **Standardized:** contribute-to-goal, create/edit budget, create goal, edit transaction, add account,
> create/rename category, feedback → all on `AppFormSheet`. Add transaction keeps its state-machine save
> (AI classify + saved-screen navigation) but matches the visual standard (radius 28 + `AppPrimaryButton`).
> Destructive/decision confirms (delete budget/goal/category/transaction, sign-out) → `showConfirmSheet`.
> **Exception by decision:** profile edit stays inline (not a sheet).
>
> **Built (2026-05-31):** `AppFormSheet` + `showAppFormSheet` (`app_form_sheet.dart`); `showConfirmSheet`
> with `ConfirmTone.destructive | neutral` (`delete_confirm_sheet.dart`, with `showDeleteConfirmSheet` kept
> as an alias). All three shared sheet containers now add the system bottom inset (`MediaQuery.padding.bottom`)
> so footers clear the gesture / transparent nav bar on edge-to-edge devices.
>
> **Migrated:** contribute-to-goal (`goal_detail_screen.dart`); **Tanda 1** — create + edit budget
> (`budget_screen.dart`) and create goal (`goals_screen.dart`). Multi-field sheets read their form state via a
> `GlobalKey<...State>` in `onSubmit`. `flutter analyze` clean (0 new issues). Profile edit stays inline by
> decision. Remaining: add/edit transaction, add account, feedback, categories (align), sign-out → confirm
> sheet, success dialog → toast (Tandas 2–3).

The app is mobile-only (Android), portrait, locale forced to `es`. Bottom sheets are the chosen
container because they are thumb-reachable, rise with the keyboard, and feel native. The goal of this
standard is **consistency and clarity** — the user learns the pattern once and it never changes between
screens.

---

## 1. Decision: which container for which task

| Task | Container | Helper |
|------|-----------|--------|
| Create / edit any entity (transaction, budget, goal, category, profile, feedback) | **Modal bottom sheet** built from `AppFormSheet` | `showAppFormSheet(...)` |
| Single-value action (contribute amount, rename) | Same `AppFormSheet` (compact body) | `showAppFormSheet(...)` |
| Destructive / irreversible confirm (delete, sign out) | **Confirm bottom sheet** | `showConfirmSheet(tone: destructive)` |

There is exactly **one** create/edit container and **one** confirm container. No screen rolls its own
`Container` / `Padding` / `Row` header / `FilledButton` for these flows.

---

## 2. Design tokens (single source — wire into `AppTheme`/constants)

| Token | Value | Notes |
|-------|-------|-------|
| Sheet top radius | **28** | standardize `AppSheetContainer` default 24 → 28; `delete_confirm_sheet` already 28 |
| Grab handle | **40 × 4, `#E5E7EB`** | `delete_confirm_sheet` currently uses `#D1D5DB` — align to `#E5E7EB` |
| Sheet padding | `EdgeInsets.fromLTRB(24, 12, 24, 40)` | from `AppSheetContainer` |
| Field corner radius | **12** | `AppTextField` / `AmountInputField` |
| Field fill | `#F9FAFB` | |
| Field focus border | `#34D399` | |
| Button corner radius | **16** | `AppPrimaryButton` (no more 28 one-offs) |
| Button height | **52** | already consistent |
| Primary color | `#34D399` | never hardcode per screen — read from theme/`AppPrimaryButton` |
| Title font | 18 / w700 / `#1F2937` | `SheetHeader` |
| Field label | 13 / w600 / `#6B7280` | `FieldLabel` |

---

## 3. Anatomy of the standard form sheet (`AppFormSheet`)

```
╭───────────────────────────────╮  ← top radius 28, white
│              ▁▁▁              │  ← grab handle (40×4, #E5E7EB), swipe-down to close
│  Nueva meta              [✕]  │  ← SheetHeader: title (always) + close button (always)
│  Define cuánto quieres ahorrar │  ← optional one-line subtitle (helps the user understand)
│                               │
│  Nombre                       │  ← FieldLabel
│  ┌─────────────────────────┐  │  ← AppTextField
│  │ Viaje a Cusco           │  │
│  └─────────────────────────┘  │
│  Meta                         │
│  ┌─────────────────────────┐  │  ← AmountInputField
│  │ S/ 0.00                 │  │
│  └─────────────────────────┘  │
│                               │
│  ┌─────────────────────────┐  │  ← AppPrimaryButton: ONE primary, verb label,
│  │       Crear meta        │  │     full-width, bottom, isLoading during async
│  └─────────────────────────┘  │
╰───────────────────────────────╯  ← lifts with keyboard (viewInsets)
```

**`AppFormSheet` API (to build):** a single scaffold that composes the existing widgets so screens only
pass content + actions:

```dart
showAppFormSheet(
  context,
  title: 'Nueva meta',
  subtitle: 'Define cuánto quieres ahorrar', // optional
  body: [ /* FieldLabel + AppTextField + ... */ ],
  primaryLabel: 'Crear meta',
  onPrimary: () async { ... },   // sheet shows isLoading + closes on success
);
```

Internally it wraps `AppSheetContainer` (handle + radius + keyboard avoidance) + `SheetHeader`
(title + close, always) + scrollable body + a pinned `AppPrimaryButton` footer.

---

## 4. Confirm sheet (`showConfirmSheet`) — destructive actions

Generalize the current `delete_confirm_sheet.dart` so it also covers sign-out and future confirmations.
`showDeleteConfirmSheet(...)` stays as a thin alias for `tone: destructive`.

```
╭───────────────────────────────╮
│              ▁▁▁              │
│            ( 🗑 )             │  ← 80×80 tonal circle; red for destructive
│        ¿Eliminar meta?        │  ← title 22 / w800
│  Esta acción no se puede      │  ← consequence text — say what happens
│  deshacer.                    │
│  ┌─────────────────────────┐  │
│  │        Eliminar         │  │  ← destructive action (red), NOT default-focused
│  └─────────────────────────┘  │
│  ┌─────────────────────────┐  │
│  │        Cancelar         │  │  ← neutral, listed second
│  └─────────────────────────┘  │
╰───────────────────────────────╯
```

`tone: neutral` swaps the red for the primary color and a neutral icon (e.g. sign-out).

---

## 5. UX rules — "more understandable"

1. **Always a title** stating the task in plain Spanish ("Nueva meta", "Editar categoría").
2. **Always a close (✕) affordance** in the header, in addition to swipe-down — discoverability.
3. **Optional one-line subtitle** under the title when the task isn't self-evident.
4. **One primary action**, full-width at the bottom, **labeled with the verb** ("Guardar", "Crear meta",
   "Agregar transacción") — never a bare "OK".
5. **`FieldLabel` above every input** — no placeholder-only fields for required data.
6. **Inline validation**: show the error under the field; keep the primary enabled and surface errors on
   tap, or disable until valid — pick one and apply it everywhere.
7. **Loading state**: primary button shows its spinner (`AppPrimaryButton.isLoading`) during async; the
   sheet does not close until success.
8. **Destructive = confirm sheet**, red action, never the default/focused button, always state the
   consequence ("no se puede deshacer").
9. **Localized strings only** via `context.l10n.*` — no hardcoded copy in the sheet body.
10. **One field-selection UI** — unify the transaction category picker (today: a 4-col grid in *add* vs a
    horizontal scroll in *edit*) into a single reusable widget.

---

## 6. Do / Don't

**Do**
- **List-item edit/delete affordance (standardized 2026-06):** every row/card in a list exposes the
  same two trailing `IconActionButton`s — a pencil (`Icons.edit_outlined`, `AppColors.fillLight` bg /
  `AppColors.textSubtle` icon) that opens the edit `AppFormSheet`, and a trash (`Icons.delete_outline`,
  `#FEE2E2` bg / `#EF4444` icon) that opens `showDeleteConfirmSheet`. Reference: `budget_screen.dart`
  `_BudgetCard`, `category_management_screen.dart`, `transaction_list_screen.dart`, `goals_screen.dart`
  `_GoalCard`. Do NOT mix in swipe-to-delete or tap-the-row-to-edit — pick the two icons everywhere so
  the gesture is identical across features. Goals also keep tap→detail (for contribute / complete) since
  they are master-detail, but still expose the same pencil/trash icons on the card.
- **Create entry point:** trigger every create flow with the shared `GreenPillButton` (never a bespoke
  `Container`/`TextButton`). Reference: budget, categories, goals, transactions headers.
- Use `AppFormSheet` + `AppTextField` + `AmountInputField` + `FieldLabel` + `AppPrimaryButton`.
- For any category picker use **`CategoryDropdownField`** (`category_dropdown_field.dart`) — a single bordered field that opens a bottom-sheet list of bordered category rows. It is generic over the selected value, so the same widget serves the fixed `TransactionCategory` enum (transactions) and backend `CategoryModel` ids (budget); build the `CategoryOption`s and pass them in. Never re-implement a grid/scroll/dropdown per screen. Use `CategoryUtils.iconForCategory(...)` for icons and `CategorySelector.labelFor(context, cat)` for enum labels (`CategorySelector` now holds only that label helper — the old chip grid was removed).
- For a date field use **`AppDateField`** (`app_date_field.dart`); for a month/year period use the same `AppDateField` with `displayText` + `showMonthYearPicker` (`month_year_picker.dart`). Never roll a custom date tile or period dropdowns.
- Use `showConfirmSheet` for every destructive/irreversible action.
- Read colors/radii from tokens, never inline hex per screen.

**Don't**
- Don't build a raw `Container`/`Padding` sheet body (add transaction, contribute, feedback do this today).
- Don't make a custom `FilledButton` with hardcoded `#34D399` / radius 28.
- Don't use a custom `Row` header instead of `SheetHeader`.
- Don't confirm deletes with `AlertDialog` (profile sign-out does this today) — use `showConfirmSheet`.

---

## 7. Migration map (presentation only — no business-logic changes)

| File | Today | Target |
|------|-------|--------|
| `features/categories/category_management_screen.dart` | ✅ already the reference (all shared widgets) | no change — golden sample |
| `features/transactions/edit_transaction_screen.dart` | `AppSheetContainer` + custom note field | move to `AppFormSheet`; note → `AppTextField` |
| `features/budget/budget_screen.dart` (create/edit) | `AppSheetContainer` + inline dropdowns | `AppFormSheet`; fields → shared widgets |
| `features/goals/goals_screen.dart` (create) | `AppSheetContainer` + custom fields | `AppFormSheet`; fields → `AppTextField`/`AmountInputField` |
| `features/transactions/add_transaction_screen.dart` | custom `Container` + custom `FilledButton` (r28) | `AppFormSheet` + `AppPrimaryButton`; unify category picker |
| `features/goals/goal_detail_screen.dart` (contribute) | custom `Container` + custom header + custom button | `AppFormSheet` (compact) + `AmountInputField` + `AppPrimaryButton` |
| `features/feedback/feedback_modal.dart` | custom `Padding` + custom header + custom button | `AppFormSheet` (body = chips + rating + `AppTextField`) |
| `features/profile/profile_screen.dart` (edit) | inline edit in-screen | `AppFormSheet` (or keep inline if explicitly decided) |
| `features/profile/profile_screen.dart` (sign out) | `AlertDialog` | `showConfirmSheet(tone: neutral)` |
| `core/widgets/delete_confirm_sheet.dart` | own handle `#D1D5DB`, radius 28, raw `Navigator.pop` | rebuild on tokens; becomes `tone: destructive` of `showConfirmSheet` |

---

## 8. Implementation phases (each its own small PR, `flutter analyze` clean before+after)

1. ✅ **Tokens** — `AppFormSheet` + the confirm sheet read the shared tokens (sheet radius 28, handle
   `#E5E7EB` via `AppColors.border`, button radius 16). Existing `AppSheetContainer` default (24) is left
   as-is until its callers migrate onto `AppFormSheet`. *(done 2026-05-31)*
2. ✅ **Components** — `AppFormSheet`/`showAppFormSheet` built; `showConfirmSheet` generalized with tones;
   additive, no existing screen changed. *(done 2026-05-31)*
3. 🟡 **Pilot** — **contribute-to-goal** (`goal_detail_screen.dart`) migrated onto `AppFormSheet` as the
   reference migration. *(done 2026-05-31)* `add_transaction_screen.dart` still pending.
4. ⚪ **Roll out** — add transaction, budget create/edit, create goal, feedback, profile edit, edit
   transaction → `AppFormSheet`; profile sign-out → `showConfirmSheet(tone: neutral)`.
5. ⚪ **Close out** — unify the transaction category picker; `flutter analyze` clean; flip this README's
   status to "implemented".
