# Firebase study distribution

This feature branch prepares Zenda for thesis validation before Play Store
production release. The app can be distributed to controlled testers through
Firebase App Distribution while collecting usability and usage evidence.

## What is included

- Firebase Analytics for study events and flow metrics.
- Firebase Crashlytics for crash and non-fatal error visibility.
- Firebase Remote Config flags to control the SUS prompt without rebuilding.
- Backend analytics mirror for authenticated study events.
- Contextual SUS prompt on the dashboard.
- Final satisfaction survey for usefulness, AI clarity, personalization,
  intention to continue using the app, and qualitative feedback.
- Per-answer AI assistant rating from the chat screen.
- `BETA_DISTRIBUTION_ID` attached to Firebase and backend analytics events.

## Firebase App Distribution

Install the Firebase CLI once:

```powershell
npm install -g firebase-tools
firebase login
```

Create a tester group in Firebase Console, for example:

```text
tesis-testers
```

Build a release APK for private testing:

```powershell
cd C:\Development\zenda_monorepo_app\zenda_fronted_app
flutter clean
flutter pub get
flutter build apk --release --flavor prod --dart-define-from-file=dart_defines/prod.json
```

The production dart-define file includes:

```json
{
  "APP_ENV": "prod",
  "API_BASE_URL": "https://api.zenda.app/api",
  "BETA_DISTRIBUTION_ID": "firebase-zenda-pilot-v1",
  "DEMO": false
}
```

Upload it to Firebase App Distribution:

```powershell
firebase appdistribution:distribute build\app\outputs\flutter-apk\app-prod-release.apk `
  --app 1:143147353185:android:4e4cf351f410ce12c6d620 `
  --groups tesis-testers `
  --release-notes "Beta de tesis: SUS contextual, Analytics, Crashlytics y Remote Config."
```

For Play Store later, build an AAB instead:

```powershell
flutter build appbundle --release --flavor prod --dart-define-from-file=dart_defines/prod.json
```

## Remote Config keys

Create these keys in Firebase Remote Config:

| Key | Type | Default | Purpose |
| --- | --- | --- | --- |
| `zenda_study_enabled` | Boolean | `true` | Enables study telemetry in the app. |
| `zenda_sus_prompt_enabled` | Boolean | `true` | Enables the dashboard SUS prompt. |
| `zenda_sus_force_prompt` | Boolean | `false` | Shows SUS prompt even if usage thresholds are not met. |
| `zenda_sus_min_sessions` | Number | `3` | Minimum app sessions before prompting. |
| `zenda_sus_min_transactions` | Number | `5` | Minimum transaction records before prompting. |
| `zenda_sus_min_chat_messages` | Number | `3` | Minimum AI chat messages before prompting. |

## Events

Firebase receives client events. The backend also stores authenticated events in
`AnalyticsEvent` through `POST /api/analytics/events`.

Important events:

```text
app_session_started
screen_view
transaction_created
chat_message_sent
sus_prompt_shown
sus_prompt_accepted
sus_prompt_dismissed
sus_submit_started
sus_submit_success
sus_submit_failed
satisfaction_submit_started
satisfaction_submit_success
satisfaction_submit_failed
ai_answer_feedback
```

The backend also records server-side events such as:

```text
login
register
record_transaction
classify_transaction
voice_transaction_draft
view_topic
submit_quiz
learning_path_personalized
```

## SUS prompt rule

The dashboard prompt is optional and non-blocking. It is hidden when:

- The user already submitted SUS.
- The user dismissed it recently.
- Remote Config disables the study or SUS prompt.

The backend recommends showing it after enough usage:

- At least 3 sessions, or
- At least 5 transactions, or
- At least 3 AI chat messages, or
- At least 3 days since first tracked event.

The app applies Remote Config thresholds on top of that recommendation.

## Final pilot surveys

Use the in-app Research menu after the student has completed the pilot period:

```text
Investigacion -> Encuesta SUS
Investigacion -> Satisfaccion final
Investigacion -> Comparacion PRE/POST
```

The backend stores:

- SUS individual answers and computed SUS score in `SurveyResponse`.
- Satisfaction Likert answers, open answers, average Likert value and
  normalized score in `SurveyResponse`.
- Assistant-answer rating on `AiMessage.feedbackRating` plus optional
  usefulness, clarity and personalization flags.
- Authenticated study events in `AnalyticsEvent`, including the beta version
  sent as `metadata.beta_distribution_id`.
