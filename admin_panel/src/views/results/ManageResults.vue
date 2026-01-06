<template>
  <div class="manage-results">
    <h1>Manage Results</h1>
    <p>View, approve, edit, or delete student results</p>

    <div v-if="loading">Loading results...</div>

    <div v-else>
      <table border="1" cellpadding="8" cellspacing="0">
        <thead>
          <tr>
            <th>Student ID</th>
            <th>Name</th>
            <th>Class</th>
            <th>Exam</th>
            <th>Obtained Marks</th>
            <th>Total Marks</th>
            <th>Percentage</th>
            <th>Result</th>
            <th>Submitted At</th>
            <th>Approved</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="r in results" :key="r.id">
            <td>{{ r.studentId }}</td>
            <td>{{ r.studentName }}</td>
            <td>{{ r.studentClass }}</td>
            <td>{{ r.examName }}</td>
            <td>{{ r.obtainedMarks ?? 0 }}</td>
            <td>{{ r.totalMarks ?? 0 }}</td>
            <td>{{ r.percentage?.toFixed(2) ?? 0 }}%</td>
            <td :style="{ color: r.result === 'Pass' ? 'green' : 'red', fontWeight: 'bold' }">
              {{ r.result || 'N/A' }}
            </td>
            <td>{{ r.submittedAt?.toDate()?.toLocaleString() || 'N/A' }}</td>

            <!-- ✅ APPROVED COLUMN -->
            <td>
              <button
                v-if="!r.approved && !approving[r.id]"
                @click="approveResult(r.id)"
              >
                Approve
              </button>

              <span v-else-if="approving[r.id]">Approving...</span>

              <span v-else style="color: green; font-weight: bold;">Approved</span>
            </td>

            <!-- ✅ ACTIONS COLUMN -->
            <td>
              <button @click="editResult(r.id)">Edit</button>
              <button @click="deleteResult(r.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import {
  collection,
  getDocs,
  doc,
  getDoc,
  updateDoc,
  deleteDoc
} from 'firebase/firestore';
import { db } from '../../firebase/firebase';

export default {
  setup() {
    const results = ref([]);
    const loading = ref(true);
    const approving = ref({});

    const fetchResults = async () => {
      loading.value = true;
      try {
        const snap = await getDocs(collection(db, 'results'));
        const data = [];

        for (const d of snap.docs) {
          const r = { id: d.id, ...d.data() };

          // Exam name
          if (r.examId) {
            const examDoc = await getDoc(doc(db, 'exams', r.examId));
            r.examName = examDoc.exists() ? examDoc.data().examName : 'Exam';
          } else {
            r.examName = 'Exam';
          }

          // Student details
          if (r.studentId) {
            const studentDoc = await getDoc(doc(db, 'students', r.studentId));
            if (studentDoc.exists()) {
              const s = studentDoc.data();
              r.studentName = s.name || 'Student';
              r.studentClass = s.grade || s.class || 'N/A';
            } else {
              r.studentName = 'Student';
              r.studentClass = 'N/A';
            }
          }

          // Calculate percentage & result
          const obtained = r.obtainedMarks ?? 0;
          const total = r.totalMarks ?? 100;
          r.percentage = total > 0 ? (obtained / total) * 100 : 0;
          r.result = r.percentage >= 85 ? 'Pass' : 'Fail';

          data.push(r);
        }

        results.value = data;
      } catch (e) {
        console.error('❌ Error fetching results:', e);
      } finally {
        loading.value = false;
      }
    };

    const approveResult = async (id) => {
      try {
        approving.value[id] = true;
        await updateDoc(doc(db, 'results', id), { approved: true });
        fetchResults();
      } catch (e) {
        console.error('❌ Error approving result:', e);
      } finally {
        approving.value[id] = false;
      }
    };

    // ✅ EDIT RESULT
    const editResult = async (id) => {
      const rDoc = doc(db, 'results', id);
      const rSnap = await getDoc(rDoc);
      if (!rSnap.exists()) return alert('Result not found');
      const r = rSnap.data();

      const newObtained = prompt('Enter obtained marks:', r.obtainedMarks ?? 0);
      const newTotal = prompt('Enter total marks:', r.totalMarks ?? 100);
      if (newObtained === null || newTotal === null) return;

      const obtained = Number(newObtained);
      const total = Number(newTotal);
      if (isNaN(obtained) || isNaN(total) || total <= 0)
        return alert('Invalid marks entered');

      const percentage = (obtained / total) * 100;
      const result = percentage >= 85 ? 'Pass' : 'Fail';

      await updateDoc(rDoc, {
        obtainedMarks: obtained,
        totalMarks: total,
        percentage,
        result
      });

      alert('Result updated successfully');
      fetchResults();
    };

    const deleteResult = async (id) => {
      if (!confirm('Are you sure you want to delete this result?')) return;
      await deleteDoc(doc(db, 'results', id));
      alert('Result deleted');
      fetchResults();
    };

    onMounted(fetchResults);

    return {
      results,
      loading,
      approving,
      approveResult,
      editResult,
      deleteResult
    };
  }
};
</script>

<style scoped>
.manage-results {
  padding: 20px;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  background-color: #f0f0f0;
}

button {
  margin-right: 6px;
  padding: 4px 8px;
  background-color: green;
  color: white;
  border: none;
  cursor: pointer;
}

button:hover {
  background-color: darkgreen;
}

td button:last-child {
  background-color: red;
}

td button:last-child:hover {
  background-color: darkred;
}
</style>

