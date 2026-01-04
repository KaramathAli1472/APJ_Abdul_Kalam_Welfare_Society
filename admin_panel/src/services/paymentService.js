// src/services/paymentService.js - FULLY WORKING
import { db } from "../firebase/firebase";
import { 
  collection, 
  getDocs, 
  query, 
  where, 
  updateDoc,
  doc 
} from "firebase/firestore";

/**
 * 🔹 Get all student payments
 */
export async function getPayments() {
  const querySnapshot = await getDocs(collection(db, "parent_students"));
  const payments = [];

  querySnapshot.forEach(docSnap => {
    const data = docSnap.data();

    if (data.students && Array.isArray(data.students)) {
      data.students.forEach(student => {
        if (student.transactionID) {
          payments.push({
            studentId: student.studentId,
            name: student.name,
            email: student.studentEmail,
            grade: student.grade,
            transactionID: student.transactionID,
            amount: student.amount || 200,
            paymentStatus: student.paymentStatus || "Pending",
            updatedAt: student.updatedAt || null
          });
        }
      });
    }
  });

  return payments;
}

/**
 * 🔹 Approve payment for a student
 */
export async function approvePayment(studentId, transactionID) {
  if (!studentId || !transactionID) {
    throw new Error("Student ID and Transaction ID are required");
  }

  try {
    // Find all parent documents
    const querySnapshot = await getDocs(collection(db, "parent_students"));
    
    let parentDoc = null;
    let parentData = null;
    let docId = null;
    
    // Search through all documents for the student
    querySnapshot.forEach(docSnap => {
      const data = docSnap.data();
      if (data.students && Array.isArray(data.students)) {
        const studentExists = data.students.some(s => 
          s.studentId === studentId && s.transactionID === transactionID
        );
        if (studentExists) {
          parentDoc = data;
          docId = docSnap.id;
        }
      }
    });
    
    if (!parentDoc || !docId) {
      throw new Error("Student not found");
    }

    // Update the payment status
    const updatedStudents = parentDoc.students.map(student => {
      if (student.studentId === studentId && student.transactionID === transactionID) {
        return {
          ...student,
          paymentStatus: "Paid",
          updatedAt: new Date().toISOString()
        };
      }
      return student;
    });

    // Update the document in Firestore
    await updateDoc(doc(db, "parent_students", docId), {
      students: updatedStudents
    });

    console.log(`✅ Payment approved for student: ${studentId}`);
    return { success: true, message: "Payment approved successfully" };
  } catch (error) {
    console.error("❌ Error approving payment:", error);
    throw error;
  }
}

/**
 * 🔹 Reject payment for a student
 */
export async function rejectPayment(studentId, transactionID) {
  if (!studentId || !transactionID) {
    throw new Error("Student ID and Transaction ID are required");
  }

  try {
    // Find all parent documents
    const querySnapshot = await getDocs(collection(db, "parent_students"));
    
    let parentDoc = null;
    let parentData = null;
    let docId = null;
    
    // Search through all documents for the student
    querySnapshot.forEach(docSnap => {
      const data = docSnap.data();
      if (data.students && Array.isArray(data.students)) {
        const studentExists = data.students.some(s => 
          s.studentId === studentId && s.transactionID === transactionID
        );
        if (studentExists) {
          parentDoc = data;
          docId = docSnap.id;
        }
      }
    });
    
    if (!parentDoc || !docId) {
      throw new Error("Student not found");
    }

    // Update the payment status
    const updatedStudents = parentDoc.students.map(student => {
      if (student.studentId === studentId && student.transactionID === transactionID) {
        return {
          ...student,
          paymentStatus: "Rejected",
          updatedAt: new Date().toISOString()
        };
      }
      return student;
    });

    // Update the document in Firestore
    await updateDoc(doc(db, "parent_students", docId), {
      students: updatedStudents
    });

    console.log(`❌ Payment rejected for student: ${studentId}`);
    return { success: true, message: "Payment rejected successfully" };
  } catch (error) {
    console.error("❌ Error rejecting payment:", error);
    throw error;
  }
}

/**
 * 🔹 Get single student by ID
 */
export async function getStudentById(studentId) {
  try {
    const querySnapshot = await getDocs(collection(db, "parent_students"));
    
    let foundStudent = null;
    
    querySnapshot.forEach(docSnap => {
      const data = docSnap.data();
      if (data.students && Array.isArray(data.students)) {
        const student = data.students.find(s => s.studentId === studentId);
        if (student) {
          foundStudent = student;
        }
      }
    });
    
    return foundStudent;
  } catch (error) {
    console.error("Error getting student:", error);
    throw error;
  }
}