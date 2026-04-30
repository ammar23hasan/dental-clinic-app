# Dental Clinic App

Dental Clinic App is a Flutter + Firebase application for a dental clinic.
It supports patient booking, doctor dashboards, and admin management from a
single codebase.

<img width="411" height="859" alt="image" src="https://github.com/user-attachments/assets/b41cca6a-21bc-4d81-9bd3-7fe0378fcf03" />

## Highlights

- Multi-role authentication (Admin, Doctor, Patient)
- Appointments booking and management
- Admin creates doctors and services
- Doctor dashboard with appointments and patients
- Notifications and settings saved in Firestore
- Arabic and English localization

<img width="1197" height="745" alt="image" src="https://github.com/user-attachments/assets/6711f582-acb5-45ad-9014-ad862ba61a76" />

<img width="1205" height="750" alt="image" src="https://github.com/user-attachments/assets/baf3bbf4-ab45-4dc5-918f-c6c5cdf73a75" />

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
- 
<img width="402" height="852" alt="image" src="https://github.com/user-attachments/assets/5561862e-3906-43da-800c-98a485a2a0df" />

<img width="379" height="755" alt="image" src="https://github.com/user-attachments/assets/4b2b793f-58b7-47d2-b7f7-b9e4baecda24" />

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

<img width="1203" height="745" alt="image" src="https://github.com/user-attachments/assets/c2cec37c-b380-4bd9-a412-cd1b0a35e22b" />

<img width="1198" height="749" alt="image" src="https://github.com/user-attachments/assets/22b42a17-d4b7-436b-8dcd-330f639a3d59" />

<img width="1205" height="750" alt="image" src="https://github.com/user-attachments/assets/f54f48c2-5c1c-4184-a186-5023e53903af" />

<img width="1218" height="758" alt="image" src="https://github.com/user-attachments/assets/2f1cb924-80fa-4e5b-af86-f5f2f6a59022" />

<img width="1214" height="752" alt="image" src="https://github.com/user-attachments/assets/8bfd310a-a60b-4b82-ad14-701c067e7020" />

<img width="411" height="859" alt="image" src="https://github.com/user-attachments/assets/2b3a0ea6-36ea-4a71-9df4-ed3d47a2c712" />

<img width="379" height="755" alt="image" src="https://github.com/user-attachments/assets/b323e285-2616-42b5-9f26-8840cbd2d30a" />

<img width="402" height="852" alt="image" src="https://github.com/user-attachments/assets/ef9f15f0-7c44-4c43-8de1-19b127bd58b1" />

<img width="395" height="828" alt="image" src="https://github.com/user-attachments/assets/b572c4ec-6909-40bf-9be2-d0c3414ea853" />







## License

This project is provided as-is for the dental clinic use case.
