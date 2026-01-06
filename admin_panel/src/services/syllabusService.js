import { db, storage } from "../firebase/firebase";
import { collection, addDoc, getDocs, orderBy, query, serverTimestamp } from "firebase/firestore";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";

const syllabusCollection = collection(db, "syllabus");

// 🔹 Upload PDF and save metadata
export const uploadSyllabus = async (file, course) => {
  const storageRef = ref(storage, `syllabus/${file.name}`);
  await uploadBytes(storageRef, file);
  const url = await getDownloadURL(storageRef);

  const data = {
    course,
    fileName: file.name,
    fileURL: url,
    createdAt: serverTimestamp()
  };

  await addDoc(syllabusCollection, data);
};

// 🔹 Get all syllabus PDFs
export const getSyllabusList = async () => {
  const q = query(syllabusCollection, orderBy("createdAt", "desc"));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};
