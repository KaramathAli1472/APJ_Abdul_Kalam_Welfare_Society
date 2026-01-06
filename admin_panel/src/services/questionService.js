// src/services/questionService.js
import { db } from "../firebase/firebase";
import {
  collection,
  addDoc,
  getDocs,
  doc,
  updateDoc,
  deleteDoc,
  query,
  where
} from "firebase/firestore";

// 🔹 Main questions collection
const questionCollection = collection(db, "questions");

/* =====================================================
   Get all questions for a specific exam
===================================================== */
export const getQuestionsByExam = async (examId) => {
  try {
    const q = query(questionCollection, where("examId", "==", examId));
    const snapshot = await getDocs(q);

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Error fetching questions:", error);
    return [];
  }
};

/* =====================================================
   Add new question to an exam
===================================================== */
export const addQuestionToExam = async (examId, question) => {
  try {
    const questionData = {
      examId,
      type: question.type,                // MCQ / Subjective
      questionText: question.questionText,
      options: question.options || {},
      correctAnswer: question.correctAnswer || null,
      createdAt: new Date()
    };

    await addDoc(questionCollection, questionData);
  } catch (error) {
    console.error("Error adding question:", error);
    throw error;
  }
};

/* =====================================================
   Update existing question
===================================================== */
export const updateQuestion = async (questionId, updatedQuestion) => {
  try {
    const questionRef = doc(db, "questions", questionId);

    await updateDoc(questionRef, {
      type: updatedQuestion.type,
      questionText: updatedQuestion.questionText,
      options: updatedQuestion.options || {},
      correctAnswer: updatedQuestion.correctAnswer || null,
      updatedAt: new Date()
    });
  } catch (error) {
    console.error("Error updating question:", error);
    throw error;
  }
};

/* =====================================================
   Delete question
===================================================== */
export const deleteQuestion = async (questionId) => {
  try {
    const questionRef = doc(db, "questions", questionId);
    await deleteDoc(questionRef);
  } catch (error) {
    console.error("Error deleting question:", error);
    throw error;
  }
};
