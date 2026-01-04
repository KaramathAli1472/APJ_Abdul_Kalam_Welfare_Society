import { db } from "../firebase/firebase";
import { collection, addDoc, getDocs, query, where } from "firebase/firestore";

const questionCollection = collection(db, "questions");

export const getQuestionsByExam = async (examId) => {
  const q = query(questionCollection, where("examId", "==", examId));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};

export const addQuestion = async (questionData) => {
  return await addDoc(questionCollection, questionData);
};
