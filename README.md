# Scholr

A Flutter study companion app for university students. Scholr helps you manage tasks, coordinate study groups, book campus rooms, and automatically generate a smart weekly study plan based on your deadlines and workload.

---

## Features

### Tasks
- Create tasks with a title, course, deadline, estimated effort in hours, and course importance weight
- Smart priority scoring that factors in deadline urgency, course weight, and effort
- Filter tasks by All, Pending, or Done
- Mark tasks complete with a checkbox
- Delete tasks with the trash icon or swipe left, with a 4-second undo window
- Tasks due in the next 3 days surface automatically on the Home screen

### Smart Study Plan
- Auto-generated weekly study plan based on all your pending tasks
- Spreads work across available days instead of cramming everything into one session
- Caps each day at 5 hours of total study time
- Splits tasks that are 5+ hours across multiple days proportionally
- Higher priority tasks (urgent deadlines, high course weight) get scheduled first
- If a deadline is tomorrow, everything goes into today regardless of the 5-hour cap
- Visible on the Home screen and shows per-session hours, day, and time slot

### Study Groups
- Create and join study groups tied to a course
- Real-time group chat with file sharing
- File links are shareable via clipboard from within the chat

### Room Booking
- Browse available campus study rooms with location, capacity, and amenities
- Book or cancel time slots directly from the app
- My Bookings tab shows all your active reservations with one-tap cancellation
- Seed demo rooms with the wand icon if no rooms exist yet

### Profile
- Update your display name and profile photo (picked from gallery)
- Manage your course list — add and remove courses
- Toggle push notification preferences

### Auth
- Sign up and sign in with email and password
- Google Sign-In supported
- Auth state persists across sessions, router redirects automatically

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart) |
| Auth | Firebase Authentication |
| Database | Cloud Firestore (real-time streams) |
| File storage | Firebase Storage |
| Push notifications | Firebase Cloud Messaging + flutter_local_notifications |
| State management | Provider |
| Navigation | go_router |
| Fonts | Plus Jakarta Sans, Space Grotesk (google_fonts) |

---

## Project Structure

```
lib/
  app/            # Router and app shell
  models/         # Data models (Task, Group, Room, User, ChatMessage)
  providers/      # State management (Auth, Task, Group, Room)
  screens/        # One folder per screen
  services/       # Firebase wrappers (Auth, Firestore, Storage, Notifications)
  theme/          # App theme and color constants
  utils/          # Shared helpers (date formatters)
  widgets/        # Reusable UI components
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.11 or later
- Dart SDK 3.11 or later
- Android Studio or VS Code with Flutter extension
- A Firebase project

### 1. Clone the repo

```bash
git clone <your-repo-url>
cd scholr
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up Firebase

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and create a project
2. Enable **Authentication** and turn on the **Email/Password** and **Google** sign-in providers
3. Create a **Firestore** database (start in test mode, then apply the security rules below)
4. Enable **Firebase Storage**
5. Install the FlutterFire CLI and run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` automatically.

### 4. Firestore security rules

Paste these into your Firestore rules tab:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /tasks/{taskId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
    match /groups/{groupId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.members;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null && request.auth.uid == resource.data.createdBy;
      match /messages/{messageId} {
        allow read, create: if request.auth != null
          && request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.members;
      }
    }
    match /rooms/{roomId} {
      allow read: if request.auth != null;
      allow update: if request.auth != null
        && request.resource.data.diff(resource.data).changedKeys().hasOnly(['bookedBy']);
      allow create, delete: if false;
    }
  }
}
```

### 5. Run the app

```bash
flutter run
```

For best results use a standard Pixel 6 or Pixel 8 emulator with API 34 or 35 (the `x86_64` image, not `gphone16k`). Give the emulator at least 4GB RAM in AVD Manager since Firebase Messaging spawns a second Dart VM in the background.

### 6. Seed rooms

The room booking feature requires seeding initial room data. After signing in, go to the **Rooms** tab and tap the wand icon in the top right to populate 5 demo rooms.

---

## Notes

- The study plan is generated entirely on-device from your current pending tasks. No data leaves the app beyond what is stored in Firestore.
- Impeller is disabled in `AndroidManifest.xml` for emulator stability. Remove that entry for a production build if you want to use Impeller on real devices.
- The `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files are gitignored. Every developer needs to run `flutterfire configure` against the shared Firebase project.
