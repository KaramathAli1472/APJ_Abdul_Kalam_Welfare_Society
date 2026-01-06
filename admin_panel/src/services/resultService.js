import { db } from "../firebase/firebase";
import { collection, doc, getDoc, getDocs, updateDoc, setDoc, query, where } from "firebase/firestore";

// 🔹 Get exam results along with questions
export const getExamResults = async (examId) => {
  const examRef = doc(db, "exams", examId);
  const examSnap = await getDoc(examRef);

  if (!examSnap.exists()) return { students: [], questions: [] };

  const examData = examSnap.data();
  const questions = examData.questions || [];

  // 🔹 Fetch students who appeared / assigned for this exam
  const studentsCol = collection(db, "students");
  const q = query(studentsCol, where("exams", "array-contains", examId));
  const snapshot = await getDocs(q);

  const students = snapshot.docs.map(docSnap => {
    const student = docSnap.data();
    return {
      studentId: docSnap.id,
      name: student.name,
      email: student.email,
      grade: student.grade,
      answers: student.examAnswers?.[examId] || [], // student answers for this exam
      status: student.examStatus?.[examId] || "Pending",
      published: student.examPublished?.[examId] || false
    };
  });

  return { students, questions };
};

// 🔹 Update student's exam result
export const updateExamResult = async (examId, studentId, data) => {
  const studentRef = doc(db, "students", studentId);

  // 🔹 Prepare nested fields
  const updatedData = {};
  if ("answers" in data) updatedData[`examAnswers.${examId}`] = data.answers;
  if ("status" in data) updatedData[`examStatus.${examId}`] = data.status;
  if ("published" in data) updatedData[`examPublished.${examId}`] = data.published;

  await updateDoc(studentRef, updatedData);
};
