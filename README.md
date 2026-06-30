# DCG Firebase App

Polished web UI for **DCG - Daffodil CrisisGuard** with Firebase Auth and Firestore hooks.

## Firebase Setup

1. Create a Firebase web app.
2. Enable **Authentication > Google** and **Authentication > Anonymous**.
3. Create a Firestore database.
4. Replace the placeholder values in `firebase-config.js`.
5. Deploy this folder to Netlify, Firebase Hosting, or any static host.

Reports are saved in the `reports` collection:

```js
{
  name,
  role,
  location,
  priority,
  details,
  anonymous,
  status,
  createdAt,
  createdBy
}
```

## Suggested Firestore Rules

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /reports/{reportId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if false;
    }
  }
}
```
