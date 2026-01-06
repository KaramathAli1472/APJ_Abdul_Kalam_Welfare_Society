<template>
  <div class="result-reports">
    <h1>Result Reports</h1>
    <p>Generate detailed reports of approved results</p>

    <div v-if="isLoading">Loading results...</div>

    <table v-else border="1" cellpadding="8" cellspacing="0">
      <thead>
        <tr>
          <th>Student ID</th>
          <th>Exam Name</th>
          <th>Score</th>
          <th>Total</th>
          <th>Submitted At</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="r in results" :key="r.id">
          <td>{{ r.studentId }}</td>
          <td>{{ r.examName }}</td>
          <td>{{ r.score }}</td>
          <td>{{ r.total }}</td>
          <td>{{ formatDate(r.submittedAt) }}</td>
        </tr>
      </tbody>
    </table>

    <div v-if="results.length === 0 && !isLoading">
      No approved results found.
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { getFirestore, collection, query, where, getDocs, doc, getDoc } from 'firebase/firestore';
import { firebaseApp } from '../firebase/firebase'; // your firebase init

const db = getFirestore(firebaseApp);

const results = ref([]);
const isLoading = ref(true);

// ================= FETCH APPROVED RESULTS =================
const fetchResults = async () => {
  try {
    isLoading.value = true;

    // 🔹 Fetch only approved results
    const q = query(
      collection(db, 'results'),
      where('approved', '==', true)
    );

    const snap = await getDocs(q);

    const tempResults = [];

    for (let docSnap of snap.docs) {
      const data = docSnap.data();
      let examName = 'Exam';

      // 🔹 Fetch exam name
      if (data.examId) {
        const examSnap = await getDoc(doc(db, 'exams', data.examId));
        if (examSnap.exists()) {
          const examData = examSnap.data();
          if (examData && examData.examName) {
            examName = examData.examName;
          }
        }
      }

      tempResults.push({
        id: docSnap.id,
        studentId: data.studentId || '',
        examName,
        score: data.score || 0,
        total: data.total || 0,
        submittedAt: data.submittedAt?.toDate ? data.submittedAt.toDate() : new Date(),
      });
    }

    results.value = tempResults;
  } catch (e) {
    console.error('❌ Error fetching results:', e);
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchResults();
});

// ================= FORMAT DATE =================
const formatDate = (dt) => {
  if (!dt) return '';
  const d = new Date(dt);
  return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()} ${d.getHours()}:${d.getMinutes().toString().padStart(2, '0')}`;
};
</script>

<style scoped>
.result-reports {
  padding: 20px;
}

table {
  width: 100%;
  margin-top: 16px;
  border-collapse: collapse;
}

th {
  background-color: #f0f0f0;
}

td, th {
  text-align: left;
  padding: 8px;
}
</style>

