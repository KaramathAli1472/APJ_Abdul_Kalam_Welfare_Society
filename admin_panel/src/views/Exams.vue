<template>
  <div>
    <h2>Exams Management</h2>

    <!-- 🔹 Create/Edit Exam Form -->
    <div class="form-container">
      <h3>{{ editingExamId ? "Edit Exam" : "Create New Exam" }}</h3>
      <form @submit.prevent="createExam">
        <div>
          <label>Exam Name:</label>
          <input v-model="examName" required />
        </div>
        <div>
          <label>Course:</label>
          <input v-model="course" required />
        </div>
        <div>
          <label>Date & Time:</label>
          <input type="datetime-local" v-model="dateTime" required />
        </div>
        <div>
          <label>Duration (minutes):</label>
          <input type="number" v-model="duration" required />
        </div>
        <button type="submit">{{ editingExamId ? "Update Exam" : "Create Exam" }}</button>
        <button v-if="editingExamId" type="button" @click="cancelEdit" style="margin-left:10px;">Cancel</button>
      </form>
    </div>

    <!-- 🔹 Exams List + Add Questions -->
    <h3 style="margin-top:30px;">Existing Exams</h3>
    <div v-for="exam in exams" :key="exam.id" class="exam-item">
      <p>
        <b>{{ exam.examName }} ({{ exam.course }})</b>
      </p>
      <p>
        Date: {{ formatDate(exam.dateTime) }} | Duration: {{ exam.duration }} min
      </p>

      <!-- 🔹 Action Buttons -->
      <button @click="editExam(exam)">Edit</button>
      <button @click="deleteExam(exam.id)" class="delete-btn">Delete</button>

      <!-- 🔹 QuestionForm for this exam -->
      <QuestionForm :examId="exam.id" />
    </div>
  </div>
</template>

<script>
import { getExams, addExam, updateExam, deleteExamById } from "../services/examService";
import QuestionForm from "../components/QuestionForm.vue";

export default {
  name: "Exams",
  components: { QuestionForm },
  data() {
    return {
      exams: [],
      examName: "",
      course: "",
      duration: 30,
      dateTime: "",
      editingExamId: null, // 🔹 Track exam being edited
    };
  },
  async created() {
    await this.fetchExams();
  },
  methods: {
    async fetchExams() {
      try {
        this.exams = await getExams();
      } catch (err) {
        console.error("Error fetching exams:", err);
      }
    },
    async createExam() {
      if (!this.examName || !this.course || !this.dateTime || !this.duration) return;

      const examData = {
        examName: this.examName,
        course: this.course,
        duration: Number(this.duration),
        dateTime: new Date(this.dateTime),
        questions: []
      };

      try {
        if (this.editingExamId) {
          await updateExam(this.editingExamId, examData);
        } else {
          await addExam(examData);
        }

        await this.fetchExams();
        this.resetForm();
      } catch (err) {
        console.error("Error saving exam:", err);
      }
    },
    editExam(exam) {
      this.examName = exam.examName;
      this.course = exam.course;
      this.duration = exam.duration;
      this.dateTime = new Date(exam.dateTime).toISOString().slice(0,16);
      this.editingExamId = exam.id;
    },
    cancelEdit() {
      this.resetForm();
    },
    resetForm() {
      this.examName = "";
      this.course = "";
      this.duration = 30;
      this.dateTime = "";
      this.editingExamId = null;
    },
    async deleteExam(examId) {
      if (confirm("Are you sure you want to delete this exam?")) {
        try {
          await deleteExamById(examId);
          await this.fetchExams();
        } catch (err) {
          console.error("Error deleting exam:", err);
        }
      }
    },
    formatDate(timestamp) {
      if (!timestamp) return "-";
      const date = new Date(timestamp.seconds ? timestamp.seconds * 1000 : timestamp);
      return date.toLocaleDateString() + " " + date.toLocaleTimeString();
    }
  }
};
</script>

<style scoped>
.form-container {
  margin-bottom: 30px;
  padding: 15px;
  border: 1px solid #ccc;
  background-color: #fafafa;
}

form div {
  margin-bottom: 10px;
}

input {
  padding: 5px;
  width: 220px;
}

button {
  padding: 5px 12px;
  cursor: pointer;
  background-color: #007bff;
  border: none;
  color: white;
  border-radius: 4px;
}

button:hover {
  background-color: #0056b3;
}

.delete-btn {
  margin-left: 5px;
  background-color: red;
}

.exam-item {
  margin-bottom: 20px;
  border: 1px solid #ddd;
  padding: 10px;
}
</style>
