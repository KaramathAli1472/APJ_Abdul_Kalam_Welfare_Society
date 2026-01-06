<template>
  <div class="upload-results">
    <h1>Upload Results</h1>

    <input type="file" @change="handleFileUpload" accept=".csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
    
    <button :disabled="isUploading || !file" @click="uploadResults">
      {{ isUploading ? 'Uploading...' : 'Upload Results' }}
    </button>

    <div v-if="message" :class="{'success': success, 'error': !success}">
      {{ message }}
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { getFirestore, collection, addDoc } from 'firebase/firestore';
import * as XLSX from 'xlsx'; // npm install xlsx
import { firebaseApp } from '../firebase/firebase'; // your firebase init

const db = getFirestore(firebaseApp);

const file = ref(null);
const isUploading = ref(false);
const message = ref('');
const success = ref(false);

const handleFileUpload = (event) => {
  file.value = event.target.files[0];
};

const uploadResults = async () => {
  if (!file.value) return;
  isUploading.value = true;
  message.value = '';

  try {
    let results = [];

    // CSV or Excel
    const data = await file.value.arrayBuffer();
    const workbook = XLSX.read(data);
    const sheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[sheetName];
    results = XLSX.utils.sheet_to_json(sheet);

    // 🔹 Upload each row to Firestore
    for (let r of results) {
      await addDoc(collection(db, 'results'), {
        studentId: r.studentId || '',
        examId: r.examId || '',
        score: r.score || 0,
        total: r.total || 0,
        submittedAt: new Date(),
        approved: false, // default false
      });
    }

    message.value = `✅ ${results.length} results uploaded successfully!`;
    success.value = true;
  } catch (e) {
    console.error('Upload error:', e);
    message.value = '❌ Failed to upload results.';
    success.value = false;
  } finally {
    isUploading.value = false;
  }
};
</script>

<style scoped>
.upload-results {
  padding: 20px;
}
button {
  margin-top: 10px;
}
.success {
  color: green;
}
.error {
  color: red;
}
</style>

