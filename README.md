# Hammer Technician App

Standalone Flutter project for the **Technician** app. Matches your Technician API document.

- **Static token:** create, login, forgot-password (send & verify OTP) use `TECHNICIAN_DEFAULT_BEARER_TOKEN`.
- **Session token:** all other APIs use the token from login/create/verify-forgot-password-otp.

## Run

```bash
cd C:\cursor_trial\hammer_technician
flutter pub get
flutter run --dart-define=TECHNICIAN_DEFAULT_BEARER_TOKEN=your_static_token
```

Base URL: `lib/core/config/env_url.dart`.
