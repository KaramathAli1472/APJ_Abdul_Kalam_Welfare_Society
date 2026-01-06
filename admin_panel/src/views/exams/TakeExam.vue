<template>
  <div>
    <h2>Take Exam: {{ exam.examName }}</h2>
    <p>Course: {{ exam.course }} | Duration: {{ exam.duration }} min</p>
    <p>Date: {{ formatDate(exam.dateTime) }}</p>

    <div v-if="questions.length === 0">
      Loading questions...
    </div>

    <form v-else @submit.prevent="submitExam">
      <div v-for="(q, index) in questions" :key="index" class="question-item">
        <p><b>{{ index + 1 }}. {{ q.questionText }}</b></p>

        <!-- MCQ -->
        <div v-if="q.type === 'MCQ'">
          <div v-for="opt in ['A','B','C','D']" :key="opt">
            <label>
              <input type="radio" :name="'q'+index" :value="opt" v-model="answers[index]" />
              {{ opt }}. {{ q.options[opt] }}
            </label>
          </div>
        </div>

        <!-- Subjective -->
        <div v-else>
          <textarea v-model="answers[index]" rows="3" style="width:100%;"></textarea>
        </div>
      </div>

      <button type="submit" style="margin-top:10px;">Submit Exam</button>
    </form>
  </div>
</template>

<script>
import { getExamById, getExamQuestions, submitExamAnswers } from "../services/examService";

export default {
  props: ["examId"],
  data() {
    return {
      exam: {},
      questions: [],
      answers: []
    };
  },
  async created() {
    this.exam = await getExamById(this.examId);
    this.questions = await getExamQuestions(this.examId);
    this.answers = Array(this.questions.length).fill(""); // initialize answers array
  },
  methods: {
    formatDate(timestamp) {
      if (!timestamp) return "-";
      const date = new Date(timestamp.seconds ? timestamp.seconds * 1000 : timestamp);
      return date.toLocaleDateString() + " " + date.toLocaleTimeString();
    },
    async submitExam() {
      // 🔹 Prepare payload
      const payload = this.questions.map((q, i) => ({
        questionId: q.id,
        type: q.type,
        answer: this.answers[i] || ""
      }));

      try {
        await submitExamAnswers(this.examId, "STUDENT_ID", payload); // replace STUDENT_ID
        alert("Exam submitted successfully!");
        this.$router.push({ name: "ExamList" }); // go back to exam list
      } catch (err) {
        console.error(err);
        alert("Error submitting exam.");
      }
    }
  }
};
</script>

<style scoped>
.question-item {
  border: 1px solid #ddd;
  padding: 10px;
  margin-bottom: 15px;
}
</style>
