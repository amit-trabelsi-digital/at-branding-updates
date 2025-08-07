// @ts-nocheck

import firebase from "firebase-admin";

firebase.initializeApp({
  credential: firebase.credential.cert({
    type: "service_account",
    client_id: "113798320233790332643",
    project_id: "mental-coach-c7f94",
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url:
      "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-zzqj6%40mental-coach-3950a.iam.gserviceaccount.com",
    universe_domain: "googleapis.com",

    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
  }),
});
