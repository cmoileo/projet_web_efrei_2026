// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAmryy6YQ2DZy8IpularJUJRhDYEeE9qgU",
  authDomain: "projet-web-c1561.firebaseapp.com",
  projectId: "projet-web-c1561",
  storageBucket: "projet-web-c1561.firebasestorage.app",
  messagingSenderId: "797872319437",
  appId: "1:797872319437:web:94dcc1c20ba868bb547284",
  measurementId: "G-S3X02BSRES"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);