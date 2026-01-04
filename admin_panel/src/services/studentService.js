import { db } from "../firebase/firebase";
import { collection, getDocs } from "firebase/firestore";

/**
 * 🔹 Get all students
 */
export default async function getStudents() {
  const snapshot = await getDocs(collection(db, "students"));

  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));
}
