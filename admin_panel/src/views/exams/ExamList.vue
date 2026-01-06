<template>
  <div>
    <h2>Your Exams</h2>
    <div v-if="exams.length === 0">No exams assigned yet.</div>
    <ul>
      <li v-for="exam in exams" :key="exam.id">
        <b>{{ exam.examName }} ({{ exam.course }})</b> |
        Date: {{ formatDate(exam.dateTime) }}
        <button @click="startExam(exam.id)">Start Exam</button>
      </li>
    </ul>
  </div>
</template>

<script>
import { getExamsByStudent } from "../services/examService";

export default {
  data() {
    return {
      exams: []
    };
  },
  async created() {
    this.exams = await getExamsByStudent("STUDENT_ID"); // 🔹 Replace with logged-in student ID
  },
  methods: {
    formatDate(timestamp) {
      if (!timestamp) return "-";
      const date = new Date(timestamp.seconds ? timestamp.seconds * 1000 : timestamp);
      return date.toLocaleDateString() + " " + date.toLocaleTimeString();
    },
    startExam(examId) {
      this.$router.push({ name: "TakeExam", params: { examId } });
    }
  }
};
</script>
