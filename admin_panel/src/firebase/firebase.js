import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyC6tfhEJkyuf-6iEzjgWPBNIxD0Qmkl8Ro",
  authDomain: "apj-kalam-welfare.firebaseapp.com",
  projectId: "apj-kalam-welfare",
  storageBucket: "apj-kalam-welfare.firebasestorage.app",
  messagingSenderId: "633801281536",
  appId: "1:633801281536:web:6e9e81860139e7c01508e5"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
