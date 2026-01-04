import { db } from "../firebase/firebase";
import { collection, addDoc, getDocs, query, orderBy } from "firebase/firestore";

const notificationCollection = collection(db, "notifications");

// 🔹 Get all notifications
export const getNotifications = async () => {
  const q = query(notificationCollection, orderBy("timestamp", "desc"));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};

// 🔹 Add notification
export const addNotification = async (notificationData) => {
  await addDoc(notificationCollection, {
    ...notificationData,
    timestamp: new Date()
  });
};
