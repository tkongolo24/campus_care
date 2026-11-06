# campus_care

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
CampusCare
CampusCare is a Flutter mobile application for reporting and
managing campus incidents. It gives students a way to submit and track
reports, while authorized campus staff can review reports and update
their status.
Features
Student
- Register and sign in with email and password.
- Verify an email address before accessing the application.
- Submit an incident with a description, category, and location.
- View personal incident reports.
- Search reports by category, description, or location.
- Filter reports by status.
- Open a report to view its details and current status.
Authorized staff
- Access a staff dashboard when the account has the staff role.
- View reports submitted by students.
- See report totals grouped by status.
- Search and filter campus reports.
- Open a report and update its status to:
  - Pending
  - Under Review
  - Resolved
Current limitation
Photo attachment is not currently available. Firebase Storage has not
yet been configured, so the application does not upload or store
incident photos. The report form indicates that photo uploads are
unavailable. This feature should only be described as complete after an
approved storage solution is configured and tested.
Technology
- Flutter and Dart --- mobile application
- Firebase Authentication --- account registration, sign-in, and
  email verification
- Cloud Firestore --- user profiles and incident reports
- Provider --- application state management
- Firebase Storage --- dependency included; photo upload
  functionality is not yet configured
Project structure
lib/
├── models/
│   └── incident.dart
├── providers/
│   ├── auth_provider.dart
│   └── incident_provider.dart
├── screens/
│   ├── auth/
│   ├── staff/
│   └── student/
├── services/
│   ├── auth_service.dart
│   ├── incident_service.dart
│   └── user_service.dart
├── firebase_options.dart
└── main.dart
The application separates data models, state providers, Firebase
services, and user-interface screens.
Firebase configuration
CampusCare uses Firebase. To run the project with your own Firebase
configuration:
1. Create or select a Firebase project.
2. Register the Android application using the package name configured
   in the project.
3. Enable Email/Password under Firebase Authentication.
4. Create a Cloud Firestore database.
5. Configure the FlutterFire CLI and generate
   lib/firebase_options.dart for your Firebase project.
6. Apply Firestore security rules that enforce verified-user access,
   student ownership of reports, and staff-only status updates.
Do not commit private credentials or service-account keys to a public
repository. The generated Firebase client configuration is used by the
Flutter application, but it is not a replacement for correctly
configured Firebase security rules.
Firestore data structure
users collection
Each user document is stored using the Firebase Authentication UID as
its document ID.

  Field         Description
  uid         Firebase Authentication user ID
email       User email address
role        Account role, such as student or staff
createdAt   Profile creation timestamp

New profiles are assigned the student role. Staff access must be
granted through an authorized administrative process; users must not be
able to grant themselves staff privileges.
incidents collection
Each incident is stored as a separate document.
  Field                               Description
  description                       Student's description of the
incident

  category                          Incident category

  location                          Where the incident happened

  reporterId                        UID of the student who submitted
the report

  status                            pending, under review, or
resolved

  photoUrl                          Optional photo URL; photo upload is
not currently implemented
createdAt                         Firestore server timestamp
Access control
The Firestore security rules are responsible for enforcing access, not
just the visibility of buttons or screens in the Flutter interface.

The intended access model is:
- A verified student can create an incident linked to their own UID.
- A student can read only their own incident reports.
- A verified staff account can read all incident reports.
- Only staff can update an incident's status.
- Status updates are restricted to the supported status values.
- Users cannot change their own role through their user profile.
Review and test the deployed Firestore rules before using the
application with real campus reports.
Run locally
Requirements
- Flutter SDK
- Dart SDK compatible with the version in pubspec.yaml
- Android Studio or another configured Android development environment
- A configured Firebase project
Commands
Clone the repository:
git clone https://github.com/tkongolo24/campus_care.git
cd campus_care
Install dependencies:
flutter pub get
Run static analysis:
flutter analyze
Run tests:
flutter test
Run on a connected device or Android emulator:
flutter run
A working Firebase configuration is required for authentication and
Firestore features.
Testing checklist
Before a demonstration, verify the following on a device or emulator:
- [ ] A student can register and receive an email verification
  message.
- [ ] An unverified account cannot access the main application.
- [ ] A verified student can sign in.
- [ ] A student can submit an incident.
- [ ] A student can see their own reports and open report details.
- [ ] Search and status filtering work on the student reports screen.
- [ ] A student cannot access another student's reports.
- [ ] A staff account can access the staff dashboard.
- [ ] Staff can view campus reports and update a report's status.
- [ ] The updated status is reflected in the report list.
- [ ] Firestore rules reject unauthorized reads and writes.
- [ ] Photo upload is recorded as incomplete until an approved storage
  solution is configured and tested.

Repository
https://github.com/tkongolo24/campus_care