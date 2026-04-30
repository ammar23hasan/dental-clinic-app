# Dental Clinic App

Dental Clinic App is a Flutter + Firebase application for a dental clinic.
It supports patient booking, doctor dashboards, and admin management from a
single codebase.

<!-- TODO: Add a hero screenshot of the home screen here -->

## Highlights

- Multi-role authentication (Admin, Doctor, Patient)
- Appointments booking and management
- Admin creates doctors and services
- Doctor dashboard with appointments and patients
- Notifications and settings saved in Firestore
- Arabic and English localization

<!-- TODO: Add a screenshot of the Admin dashboard here -->
<!-- TODO: Add a screenshot of the Doctor dashboard here -->

## Tech Stack

- Flutter (Material 3)
- Firebase Auth, Firestore, FCM
- Provider for state management

## Firebase Collections

- users
	- role: Admin | Doctor | Patient
- doctors
	- name, specialty, email, userId
- services
	- name, category, price, duration, description, recovery
	- doctorId (optional), doctorName (optional)
- appointments
	- serviceName, doctor, date, time, status, patientName
- doctor_patient_notes

## Admin Features

- Create and manage doctor accounts
- Manage services inside the app (no Console required)
- Review appointments and patient list

## Doctor Features

- View appointments and patients
- Add patient notes
- Edit profile and settings

## Patient Features

- Book appointments
- Browse services
- View upcoming appointments

<!-- TODO: Add a screenshot of the Services screen here -->
<!-- TODO: Add a screenshot of the Booking flow here -->

## Setup

1) Install Flutter and run `flutter doctor`.
2) Configure Firebase for your project:
	 - Add `android/app/google-services.json`.
	 - Add `ios/Runner/GoogleService-Info.plist`.
	 - Run FlutterFire CLI if you need to regenerate `lib/firebase_options.dart`.
3) Deploy Firestore rules from [firestore.rules](firestore.rules).
4) Run the app:
	 - `flutter pub get`
	 - `flutter run`

## Data Notes

- Services are now stored in Firestore. Use Admin -> Settings -> Manage Services
	to add them from the app.
- If an Auth user exists without a Firestore profile, the admin flow will
	link it and send a reset password email.

## Screenshots

- Home screen (patient)
- Admin dashboard
- Doctor dashboard
- Services list
- Booking flow

<!-- TODO: Add screenshot grid here -->

## License

This project is provided as-is for the dental clinic use case.
