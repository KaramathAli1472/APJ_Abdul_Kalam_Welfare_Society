import { db } from "../firebase/firebase";
import { collection, addDoc, doc, getDoc, updateDoc, getDocs } from "firebase/firestore";

// Get all exams
export async function getExams() {
  const snapshot = await getDocs(collection(db, "exams"));
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Add new exam
export async function addExam(exam) {
  await addDoc(collection(db, "exams"), exam);
}

// Update exam
export async function updateExam(examId, data) {
  const examRef = doc(db, "exams", examId);
  await updateDoc(examRef, data);
}

// Delete exam
export async function deleteExamById(examId) {
  const examRef = doc(db, "exams", examId);
  await updateDoc(examRef, { deleted: true }); // or deleteDoc(examRef)
}

// Get questions of exam
export async function getExamQuestions(examId) {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);
  if (examSnap.exists()) {
    return examSnap.data().questions || [];
  }
  return [];
}

// Add question
export async function addQuestionToExam(examId, question) {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);
  const existingQuestions = examSnap.data().questions || [];
  const updatedQuestions = [...existingQuestions, question];
  await updateDoc(examRef, { questions: updatedQuestions });
}

// Update question
export async function updateQuestion(examId, questionIndex, questionData) {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);
  const questions = examSnap.data().questions || [];
  questions[questionIndex] = questionData;
  await updateDoc(examRef, { questions });
}

// Delete question
export async function deleteQuestion(examId, questionIndex) {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);
  const questions = examSnap.data().questions || [];
  questions.splice(questionIndex, 1);
  await updateDoc(examRef, { questions });
}
