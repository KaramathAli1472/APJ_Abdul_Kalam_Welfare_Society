import { signInWithEmailAndPassword, signOut } from "firebase/auth";
import { auth } from "../firebase/firebase";

export const adminLogin = (email, password) => {
  return signInWithEmailAndPassword(auth, email, password);
};

export const adminLogout = () => signOut(auth);
