import { db } from "../firebase/firebase";
import { collection, addDoc, doc, getDoc, updateDoc, getDocs, deleteDoc } from "firebase/firestore";

// 🔹 Get all exams
export async function getExams() {
  const snapshot = await getDocs(collection(db, "exams"));
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// 🔹 Add new exam
export async function addExam(exam) {
  return await addDoc(collection(db, "exams"), exam);
}

// 🔹 Update exam
export async function updateExam(examId, data) {
  const examRef = doc(db, "exams", examId);
  await updateDoc(examRef, data);
}

// 🔹 Delete exam (soft delete example, can also use deleteDoc)
export async function deleteExamById(examId) {
  const examRef = doc(db, "exams", examId);
  // Soft delete (keep data but mark as deleted)
  await updateDoc(examRef, { deleted: true });
  // Hard delete option:
  // await deleteDoc(examRef);
}

// 🔹 Get questions of a specific exam
export async function getExamQuestions(examId) {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);
  if (examSnap.exists()) {
    return examSnap.data().questions || [];
  }
  return [];
}

// 🔹 Add a question to exam
export async function addQuestionToExam(examId, question) {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);
  const existingQuestions = examSnap.exists() ? examSnap.data().questions || [] : [];
  const updatedQuestions = [...existingQuestions, question];
  await updateDoc(examRef, { questions: updatedQuestions });
}

// 🔹 Update a specific question
export async function updateQuestion(examId, questionIndex, questionData) {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);
  const questions = examSnap.exists() ? examSnap.data().questions || [] : [];
  questions[questionIndex] = questionData;
  await updateDoc(examRef, { questions });
}

// 🔹 Delete a specific question
export async function deleteQuestion(examId, questionIndex) {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);
  const questions = examSnap.exists() ? examSnap.data().questions || [] : [];
  questions.splice(questionIndex, 1);
  await updateDoc(examRef, { questions });
}
