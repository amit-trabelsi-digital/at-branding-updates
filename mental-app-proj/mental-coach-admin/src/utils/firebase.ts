// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCGFsjkMyMiNUFITHqcEopLNPfaqJ--pNk",
  authDomain: "mental-coach-c7f94.firebaseapp.com",
  projectId: "mental-coach-c7f94",
  storageBucket: "mental-coach-c7f94.firebasestorage.app",
  messagingSenderId: "922833932086",
  appId: "1:922833932086:web:66ca24452c3776d9cfed97",
  measurementId: "G-Q3Q73TFEHN",
};

// Initialize Firebase
export const app = initializeApp(firebaseConfig);
export const fireAuth = getAuth(app);
export const storage = getStorage(app);
