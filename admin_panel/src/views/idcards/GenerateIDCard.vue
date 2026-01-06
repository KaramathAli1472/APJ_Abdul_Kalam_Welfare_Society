<template>
  <div class="generate-id-card">
    <div class="page-header">
      <h1>🖨️ Generate ID Card</h1>
      <p>Create a new ID card for a student</p>
    </div>

    <!-- Student Selection -->
    <div class="section">
      <h2>Select Student</h2>
      <select v-model="selectedStudent" class="student-select">
        <option value="">Select a student...</option>
        <option v-for="student in students" :key="student.id" :value="student">
          {{ student.name }} - {{ student.id }} (Grade {{ student.grade }})
        </option>
      </select>
    </div>

    <!-- ID Card Preview -->
    <div class="section" v-if="selectedStudent">
      <h2>ID Card Preview</h2>
      <div class="id-card-preview-container">
        <!-- Student ID Card Template -->
        <div class="id-card student-id-card">
          <!-- ID Card design here -->
        </div>
      </div>

      <div class="actions">
        <button class="btn generate-btn" @click="generateCard">
          Generate ID Card
        </button>
        <button class="btn print-btn" @click="printCard">
          Print ID Card
        </button>
        <button class="btn save-btn" @click="saveCard">
          Save to Database
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GenerateIDCard',
  data() {
    return {
      selectedStudent: null,
      students: [] // Load from Firebase
    }
  },
  created() {
    // Load students from Firebase
    this.loadStudents();
  },
  methods: {
    async loadStudents() {
      // Load students from Firebase
    },
    generateCard() {
      // Generate ID card logic
    },
    printCard() {
      window.print();
    },
    async saveCard() {
      // Save to Firebase
    }
  }
}
</script>