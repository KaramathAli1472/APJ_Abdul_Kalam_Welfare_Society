<template>
  <div class="question-form">
    <h4>Add/Edit Question</h4>
    <form @submit.prevent="saveQuestion">
      <div>
        <label>Question Type:</label>
        <select v-model="type">
          <option value="MCQ">MCQ</option>
          <option value="Subjective">Subjective</option>
        </select>
      </div>

      <div>
        <label>Question Text:</label>
        <input v-model="questionText" required />
      </div>

      <div v-if="type === 'MCQ'">
        <div v-for="opt in ['A','B','C','D']" :key="opt">
          <label>{{ opt }}:</label>
          <input v-model="options[opt]" required />
        </div>
        <div>
          <label>Correct Answer:</label>
          <select v-model="correctAnswer">
            <option v-for="opt in ['A','B','C','D']" :key="opt" :value="opt">{{ opt }}</option>
          </select>
        </div>
      </div>

      <button type="submit">{{ editingIndex !== null ? 'Update Question' : 'Add Question' }}</button>
      <button v-if="editingIndex !== null" type="button" @click="cancelEdit" style="margin-left:5px;">Cancel</button>
    </form>

    <div v-if="questions.length > 0" style="margin-top:10px;">
      <h5>Questions List:</h5>
      <ul>
        <li v-for="(q, index) in questions" :key="index">
          {{ index + 1 }}. {{ q.questionText }} 
          <span v-if="q.type === 'MCQ'">(MCQ: Correct - {{ q.correctAnswer }})</span>
          <button @click="editQuestion(index)" style="margin-left:5px;">Edit</button>
          <button @click="deleteQuestion(index)" style="margin-left:5px; background-color:red;">Delete</button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import { addQuestionToExam, getExamQuestions, updateQuestion, deleteQuestion } from "../services/examService";

export default {
  props: ["examId"],
  data() {
    return {
      type: "MCQ",
      questionText: "",
      options: { A: "", B: "", C: "", D: "" },
      correctAnswer: "A",
      questions: [],
      editingIndex: null
    };
  },
  async created() {
    this.questions = await getExamQuestions(this.examId);
  },
  methods: {
    async saveQuestion() {
      const newQuestion = {
        type: this.type,
        questionText: this.questionText,
        options: this.type === "MCQ" ? this.options : {},
        correctAnswer: this.type === "MCQ" ? this.correctAnswer : null
      };

      if (this.editingIndex !== null) {
        await updateQuestion(this.examId, this.editingIndex, newQuestion);
      } else {
        await addQuestionToExam(this.examId, newQuestion);
      }

      this.questions = await getExamQuestions(this.examId);
      this.resetForm();
    },
    editQuestion(index) {
      const q = this.questions[index];
      this.type = q.type;
      this.questionText = q.questionText;
      this.options = { ...q.options };
      this.correctAnswer = q.correctAnswer || "A";
      this.editingIndex = index;
    },
    deleteQuestion(index) {
      if (confirm("Are you sure you want to delete this question?")) {
        deleteQuestion(this.examId, index).then(() => {
          this.questions.splice(index, 1);
        });
      }
    },
    cancelEdit() {
      this.resetForm();
    },
    resetForm() {
      this.type = "MCQ";
      this.questionText = "";
      this.options = { A: "", B: "", C: "", D: "" };
      this.correctAnswer = "A";
      this.editingIndex = null;
    }
  }
};
</script>
