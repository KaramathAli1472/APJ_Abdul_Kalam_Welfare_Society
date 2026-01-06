import { 
  collection, 
  addDoc, 
  getDocs, 
  updateDoc, 
  deleteDoc, 
  doc, 
  query, 
  where,
  orderBy 
} from "firebase/firestore";
import { db } from "../firebase/firebase";

const ID_CARDS_COLLECTION = "idCards";

// Generate new ID card
export async function generateIDCard(studentData) {
  try {
    const idCardData = {
      ...studentData,
      generatedAt: new Date().toISOString(),
      cardNumber: `IDC-${Date.now()}`,
      status: 'active',
      printed: false,
      printedAt: null
    };

    const docRef = await addDoc(collection(db, ID_CARDS_COLLECTION), idCardData);
    return { id: docRef.id, ...idCardData };
  } catch (error) {
    console.error("Error generating ID card:", error);
    throw error;
  }
}

// Get all ID cards
export async function getAllIDCards() {
  try {
    const querySnapshot = await getDocs(collection(db, ID_CARDS_COLLECTION));
    return querySnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error("Error fetching ID cards:", error);
    throw error;
  }
}

// Get ID card by student ID
export async function getIDCardByStudentId(studentId) {
  try {
    const q = query(
      collection(db, ID_CARDS_COLLECTION),
      where("studentId", "==", studentId)
    );
    const querySnapshot = await getDocs(q);
    
    if (!querySnapshot.empty) {
      const doc = querySnapshot.docs[0];
      return { id: doc.id, ...doc.data() };
    }
    return null;
  } catch (error) {
    console.error("Error fetching ID card:", error);
    throw error;
  }
}

// Update ID card
export async function updateIDCard(idCardId, updateData) {
  try {
    const idCardRef = doc(db, ID_CARDS_COLLECTION, idCardId);
    await updateDoc(idCardRef, updateData);
    return true;
  } catch (error) {
    console.error("Error updating ID card:", error);
    throw error;
  }
}

// Delete ID card
export async function deleteIDCard(idCardId) {
  try {
    await deleteDoc(doc(db, ID_CARDS_COLLECTION, idCardId));
    return true;
  } catch (error) {
    console.error("Error deleting ID card:", error);
    throw error;
  }
}

// Mark ID card as printed
export async function markAsPrinted(idCardId) {
  try {
    const idCardRef = doc(db, ID_CARDS_COLLECTION, idCardId);
    await updateDoc(idCardRef, {
      printed: true,
      printedAt: new Date().toISOString()
    });
    return true;
  } catch (error) {
    console.error("Error marking ID card as printed:", error);
    throw error;
  }
}

// Bulk generate ID cards
export async function bulkGenerateIDCards(students) {
  try {
    const promises = students.map(student => generateIDCard(student));
    return await Promise.all(promises);
  } catch (error) {
    console.error("Error bulk generating ID cards:", error);
    throw error;
  }
}