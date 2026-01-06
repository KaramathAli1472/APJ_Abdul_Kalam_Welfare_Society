<template>
  <div class="question-form">
    <h4>{{ editingQuestionId ? "Edit Question" : "Add Question" }}</h4>

    <form @submit.prevent="saveQuestion">
      <!-- Question Type -->
      <div>
        <label>Question Type:</label>
        <select v-model="type">
          <option value="MCQ">MCQ</option>
          <option value="Subjective">Subjective</option>
        </select>
      </div>

      <!-- Question Text -->
      <div>
        <label>Question Text:</label>
        <input v-model="questionText" required />
      </div>

      <!-- MCQ Options -->
      <div v-if="type === 'MCQ'">
        <div v-for="opt in ['A','B','C','D']" :key="opt">
          <label>{{ opt }}:</label>
          <input v-model="options[opt]" required />
        </div>

        <div>
          <label>Correct Answer:</label>
          <select v-model="correctAnswer">
            <option v-for="opt in ['A','B','C','D']" :key="opt" :value="opt">
              {{ opt }}
            </option>
          </select>
        </div>
      </div>

      <button type="submit">
        {{ editingQuestionId ? "Update Question" : "Add Question" }}
      </button>

      <button
        v-if="editingQuestionId"
        type="button"
        @click="cancelEdit"
        style="margin-left:5px;"
      >
        Cancel
      </button>
    </form>

    <!-- Questions List -->
    <div v-if="questions.length > 0" style="margin-top:15px;">
      <h5>Questions List:</h5>
      <ul>
        <li v-for="(q, index) in questions" :key="q.id">
          {{ index + 1 }}. {{ q.questionText }}
          <span v-if="q.type === 'MCQ'">
            (MCQ: Correct - {{ q.correctAnswer }})
          </span>

          <button @click="editQuestion(q)" style="margin-left:5px;">
            Edit
          </button>

          <button
            @click="removeQuestion(q.id)"
            style="margin-left:5px; background-color:red;"
          >
            Delete
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import {
  addQuestionToExam,
  getQuestionsByExam,
  updateQuestion,
  deleteQuestion
} from "../services/questionService";

export default {
  name: "QuestionForm",
  props: {
    examId: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      type: "MCQ",
      questionText: "",
      options: { A: "", B: "", C: "", D: "" },
      correctAnswer: "A",
      questions: [],
      editingQuestionId: null
    };
  },
  async created() {
    await this.loadQuestions();
  },
  methods: {
    async loadQuestions() {
      this.questions = await getQuestionsByExam(this.examId);
    },

    async saveQuestion() {
      const questionData = {
        type: this.type,
        questionText: this.questionText,
        options: this.type === "MCQ" ? this.options : {},
        correctAnswer: this.type === "MCQ" ? this.correctAnswer : null
      };

      if (this.editingQuestionId) {
        await updateQuestion(this.editingQuestionId, questionData);
      } else {
        await addQuestionToExam(this.examId, questionData);
      }

      await this.loadQuestions();
      this.resetForm();
    },

    editQuestion(question) {
      this.type = question.type;
      this.questionText = question.questionText;
      this.options = question.options || { A: "", B: "", C: "", D: "" };
      this.correctAnswer = question.correctAnswer || "A";
      this.editingQuestionId = question.id;
    },

    async removeQuestion(questionId) {
      if (confirm("Are you sure you want to delete this question?")) {
        await deleteQuestion(questionId);
        await this.loadQuestions();
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
      this.editingQuestionId = null;
    }
  }
};
</script>

<style scoped>
.question-form {
  border: 1px solid #ddd;
  padding: 12px;
  margin-top: 10px;
  background-color: #fafafa;
}

form div {
  margin-bottom: 8px;
}

input,
select {
  padding: 5px;
  width: 220px;
}

button {
  padding: 5px 10px;
  cursor: pointer;
}
</style>
