## EFREI Flutter Todo App

A production-ready Flutter Todo app with email/password authentication, Firestore-backed data, routing, tests, and CI.

### What it does
- **Authentication**: Email/password via Firebase Authentication.
- **Todos**: Create, stream (real-time), update status, and delete personal todos stored in **Cloud Firestore**.
- **Routing**: `go_router` with an **auth guard** that redirects unauthenticated users to the login page.
- **Testing**: Unit and integration tests using `fake_cloud_firestore` and `firebase_auth_mocks`.
- **CI**: GitHub Actions to analyze, test, run integration tests on web, and build for web on `staging`; deploy placeholder on `main`.

### Project structure (high level)
- `lib/main.dart`: App bootstrap, Firebase init, router, and `AuthGuard`.
- `lib/pages/`: `home.dart` (todos UI), `auth.dart` (login/signup screen).
- `lib/widgets/`: `auth_form.dart` (authentication form).
- `lib/models/Todo/`: `todo.model.dart` (+ generated `.g.dart`).
- `lib/repositories/`: `todo.repository.dart` (Firestore access, injectable).
- `lib/services/`: `todo_service.dart` (domain logic, injectable), `auth_service.dart`.
- `lib/env/firebase_options.dart`: Generated Firebase config (via FlutterFire CLI).
- `test/`: Unit tests for repository and service.
- `integration_test/`: App boot test for web.
- `.github/workflows/`: CI for `staging` and CD placeholder for `main`.

## Run locally
Prereqs: Flutter SDK, Dart SDK, and a Firebase project.

1) Install dependencies
```
flutter pub get
```

2) Run the app (pick your target)
```
flutter run -d chrome
# or: flutter run -d windows / macos / linux / android / ios
```

3) Build for web
```
flutter build web --release
```

## Set up your own Firebase project
The app expects Firebase to be initialized at startup using `lib/env/firebase_options.dart`.

Option A — Use FlutterFire CLI (recommended)
1) Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
2) Login: `firebase login`
3) Configure: in the project root run
```
flutterfire configure \
  --platforms=android,ios,web,windows,macos,linux \
  --project=<your-firebase-project-id>
```
This generates/updates `lib/env/firebase_options.dart` with your Firebase app configs.

Option B — Manual copy
- Create apps for each platform in the Firebase console and ensure the generated config matches `firebase_options.dart`. Only choose this if you already have that file coordinated.

### Firebase Console configuration
- **Enable Authentication**: turn on Email/Password provider.
- **Create Firestore database**: Start in production mode (recommended). Collection used: `todos` with docs keyed by todo `id`.

Suggested Firestore rules (restrict each user to their own docs):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /todos/{todoId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

Data shape (`todos` doc):
```
{
  id: string (doc id),
  title: string,
  description?: string,
  userId: string (owner's uid),
  dueDate?: Timestamp,
  priority: 'high' | 'normal' | 'low',
  createdAt: Timestamp,
  status: 'done' | 'in progress' | 'pending' | 'cancelled',
  tags: string[]
}
```

## How the app works
- On launch `main.dart` initializes Firebase using `DefaultFirebaseOptions.currentPlatform` from `firebase_options.dart`.
- `GoRouter` uses an `AuthGuard` that listens to `FirebaseAuth.instance.authStateChanges()`:
  - If logged in, show `HomePage` (todos UI).
  - If not, navigate to `/auth` which shows `AuthPage` and the `AuthForm` to sign in or register.
- `TodoService` validates auth state and delegates to `TodoRepository`.
- `TodoRepository` performs Firestore queries on the `todos` collection and sets `userId` on writes so rules can enforce per-user access.
- Both repository and service accept injected `FirebaseFirestore`/`FirebaseAuth` instances for testing.

## Testing
Install dependencies first:
```
flutter pub get
```

Run unit tests:
```
flutter test
```

Run integration tests on web (Chrome):
```
flutter test integration_test -d chrome
```

Notes:
- Unit tests use `fake_cloud_firestore` and `firebase_auth_mocks` to avoid real network calls.
- Basic integration test boots the app; ensure Firebase config is present for web.

## Continuous Integration
Workflows in `.github/workflows/`:
- **ci-staging.yml** (on push to `staging`):
  - `flutter analyze`
  - `flutter test --coverage`
  - `flutter test integration_test -d chrome`
  - `flutter build web` and upload artifact
- **cd-main.yml** (on push to `main`):
  - Placeholder deploy job (replace with your hosting provider steps).

## Troubleshooting
- Auth redirect loop: ensure Email/Password provider is enabled in Firebase console.
- Firestore permission errors: verify `userId` is set on created todos and rules match above.
- Web build issues: run `flutter clean && flutter pub get`, then `flutter build web`.
- Integration tests: make sure `firebase_options.dart` matches your Firebase project and Chrome is installed.

## License
MIT
