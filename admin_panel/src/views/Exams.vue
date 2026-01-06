<template>
  <div class="exams-container">
    <!-- 🔹 Header Section -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <span class="title-icon">📝</span>
          Exams Management
        </h1>
        <p class="page-subtitle">Create, manage, and schedule examinations for your courses</p>
      </div>
      <div class="header-actions">
        <button class="action-btn primary-btn" @click="exportToExcel">
          <span class="btn-icon">📥</span>
          Export Exams
        </button>
        <button class="action-btn secondary-btn" @click="showStats = !showStats">
          <span class="btn-icon">📊</span>
          View Stats
        </button>
      </div>
    </div>

    <!-- 🔹 Stats Panel -->
    <div v-if="showStats" class="stats-panel">
      <div class="stat-card">
        <div class="stat-icon">📚</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ exams.length }}</h3>
          <p class="stat-label">Total Exams</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">⏰</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ upcomingExams }}</h3>
          <p class="stat-label">Upcoming</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">✅</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ completedExams }}</h3>
          <p class="stat-label">Completed</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">📊</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ totalQuestions }}</h3>
          <p class="stat-label">Total Questions</p>
        </div>
      </div>
    </div>

    <!-- 🔹 Main Content Grid -->
    <div class="content-grid">
      <!-- 🔹 Left Column: Create/Edit Form -->
      <div class="form-column">
        <div class="card form-card">
          <div class="card-header">
            <h2 class="card-title">
              <span class="card-icon">{{ editingExamId ? '✏️' : '➕' }}</span>
              {{ editingExamId ? "Edit Exam" : "Create New Exam" }}
            </h2>
            <div class="card-subtitle">
              {{ editingExamId ? "Update exam details below" : "Fill in exam details to create a new exam" }}
            </div>
          </div>
          
          <form @submit.prevent="createExam" class="exam-form">
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">📝</span>
                  Exam Name
                </label>
                <input 
                  v-model="examName" 
                  class="form-input" 
                  placeholder="Enter exam name"
                  required
                />
              </div>

              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">🎓</span>
                  Course
                </label>
                <select v-model="course" class="form-select" required>
                  <option value="">Select Course</option>
                  <option value="Mathematics">Mathematics</option>
                  <option value="Physics">Physics</option>
                  <option value="Chemistry">Chemistry</option>
                  <option value="Biology">Biology</option>
                  <option value="Computer Science">Computer Science</option>
                  <option value="English">English</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">📅</span>
                  Date & Time
                </label>
                <input 
                  type="datetime-local" 
                  v-model="dateTime" 
                  class="form-input"
                  required
                />
              </div>

              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">⏱️</span>
                  Duration (minutes)
                </label>
                <input 
                  type="number" 
                  v-model="duration" 
                  class="form-input"
                  min="15"
                  max="300"
                  required
                />
                <div class="duration-hints">
                  <span class="duration-hint" :class="{ active: duration === 30 }" @click="duration = 30">30m</span>
                  <span class="duration-hint" :class="{ active: duration === 60 }" @click="duration = 60">1h</span>
                  <span class="duration-hint" :class="{ active: duration === 90 }" @click="duration = 90">1.5h</span>
                  <span class="duration-hint" :class="{ active: duration === 120 }" @click="duration = 120">2h</span>
                </div>
              </div>
            </div>

            <div class="form-actions">
              <button 
                type="submit" 
                class="submit-btn"
                :class="{ 'update-btn': editingExamId }"
                :disabled="!formValid"
              >
                <span class="btn-icon">{{ editingExamId ? '💾' : '➕' }}</span>
                {{ editingExamId ? "Update Exam" : "Create Exam" }}
              </button>
              
              <button 
                v-if="editingExamId" 
                type="button" 
                class="cancel-btn"
                @click="cancelEdit"
              >
                <span class="btn-icon">✖️</span>
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- 🔹 Right Column: Exams List -->
      <div class="list-column">
        <div class="card list-card">
          <div class="card-header">
            <h2 class="card-title">
              <span class="card-icon">📋</span>
              All Exams
              <span class="badge">{{ exams.length }}</span>
            </h2>
            
            <div class="search-filter">
              <div class="search-box">
                <span class="search-icon">🔍</span>
                <input 
                  v-model="searchQuery" 
                  class="search-input" 
                  placeholder="Search exams..."
                />
              </div>
              
              <select v-model="filterCourse" class="filter-select">
                <option value="">All Courses</option>
                <option value="Mathematics">Mathematics</option>
                <option value="Physics">Physics</option>
                <option value="Chemistry">Chemistry</option>
                <option value="Biology">Biology</option>
              </select>
            </div>
          </div>

          <!-- 🔹 Exams List -->
          <div class="exams-list">
            <div 
              v-for="exam in filteredExams" 
              :key="exam.id" 
              class="exam-card"
              :class="{ 
                'upcoming': isUpcoming(exam.dateTime),
                'completed': isCompleted(exam.dateTime),
                'editing': editingExamId === exam.id 
              }"
            >
              <div class="exam-header">
                <div class="exam-status" :class="getStatusClass(exam.dateTime)">
                  {{ getStatusText(exam.dateTime) }}
                </div>
                <div class="exam-actions">
                  <button 
                    class="icon-btn edit-btn"
                    @click="editExam(exam)"
                    title="Edit Exam"
                  >
                    <span class="icon">✏️</span>
                  </button>
                  <button 
                    class="icon-btn delete-btn"
                    @click="deleteExam(exam.id)"
                    title="Delete Exam"
                  >
                    <span class="icon">🗑️</span>
                  </button>
                </div>
              </div>

              <div class="exam-content">
                <h3 class="exam-name">{{ exam.examName }}</h3>
                <div class="exam-meta">
                  <span class="meta-item">
                    <span class="meta-icon">🎓</span>
                    {{ exam.course }}
                  </span>
                  <span class="meta-item">
                    <span class="meta-icon">📅</span>
                    {{ formatDate(exam.dateTime) }}
                  </span>
                  <span class="meta-item">
                    <span class="meta-icon">⏱️</span>
                    {{ exam.duration }} minutes
                  </span>
                </div>

                <div class="questions-info">
                  <div class="questions-count">
                    <span class="count-icon">❓</span>
                    {{ exam.questions ? exam.questions.length : 0 }} questions
                  </div>
                  <button 
                    class="manage-questions-btn"
                    @click="toggleQuestions(exam.id)"
                  >
                    <span class="btn-icon">{{ openQuestions === exam.id ? '👇' : '👉' }}</span>
                    Manage Questions
                  </button>
                </div>
              </div>

              <!-- 🔹 QuestionForm (Collapsible) -->
              <div 
                v-if="openQuestions === exam.id" 
                class="questions-section"
              >
                <div class="section-header">
                  <h4>Questions Management</h4>
                  <button 
                    class="close-section-btn"
                    @click="openQuestions = null"
                  >
                    <span class="icon">✖️</span>
                  </button>
                </div>
                <QuestionForm :examId="exam.id" />
              </div>
            </div>

            <!-- 🔹 Empty State -->
            <div v-if="filteredExams.length === 0" class="empty-state">
              <div class="empty-icon">📚</div>
              <h3>No exams found</h3>
              <p v-if="searchQuery || filterCourse">
                Try changing your search or filter criteria
              </p>
              <p v-else>Create your first exam using the form on the left</p>
            </div>
          </div>
        </div>
      </div>
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
      editingExamId: null,
      searchQuery: "",
      filterCourse: "",
      showStats: true,
      openQuestions: null,
      loading: false
    };
  },
  computed: {
    filteredExams() {
      return this.exams.filter(exam => {
        const matchesSearch = exam.examName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
                            exam.course.toLowerCase().includes(this.searchQuery.toLowerCase());
        const matchesCourse = !this.filterCourse || exam.course === this.filterCourse;
        return matchesSearch && matchesCourse;
      });
    },
    upcomingExams() {
      const now = new Date();
      return this.exams.filter(exam => {
        const examDate = new Date(exam.dateTime.seconds ? exam.dateTime.seconds * 1000 : exam.dateTime);
        return examDate > now;
      }).length;
    },
    completedExams() {
      const now = new Date();
      return this.exams.filter(exam => {
        const examDate = new Date(exam.dateTime.seconds ? exam.dateTime.seconds * 1000 : exam.dateTime);
        return examDate < now;
      }).length;
    },
    totalQuestions() {
      return this.exams.reduce((total, exam) => {
        return total + (exam.questions ? exam.questions.length : 0);
      }, 0);
    },
    formValid() {
      return this.examName && this.course && this.dateTime && this.duration > 0;
    }
  },
  async created() {
    await this.fetchExams();
  },
  methods: {
    async fetchExams() {
      this.loading = true;
      try {
        this.exams = await getExams();
      } catch (err) {
        console.error("Error fetching exams:", err);
        this.showNotification("Failed to load exams", "error");
      } finally {
        this.loading = false;
      }
    },
    async createExam() {
      if (!this.formValid) return;

      const examData = {
        examName: this.examName.trim(),
        course: this.course,
        duration: Number(this.duration),
        dateTime: new Date(this.dateTime),
        questions: [],
        createdAt: new Date(),
        updatedAt: new Date()
      };

      try {
        if (this.editingExamId) {
          await updateExam(this.editingExamId, examData);
          this.showNotification("Exam updated successfully!", "success");
        } else {
          await addExam(examData);
          this.showNotification("Exam created successfully!", "success");
        }

        await this.fetchExams();
        this.resetForm();
      } catch (err) {
        console.error("Error saving exam:", err);
        this.showNotification("Failed to save exam", "error");
      }
    },
    editExam(exam) {
      this.examName = exam.examName;
      this.course = exam.course;
      this.duration = exam.duration;
      this.dateTime = new Date(exam.dateTime.seconds ? exam.dateTime.seconds * 1000 : exam.dateTime).toISOString().slice(0,16);
      this.editingExamId = exam.id;
      
      // Scroll to form
      document.querySelector('.form-column').scrollIntoView({ behavior: 'smooth' });
    },
    cancelEdit() {
      this.resetForm();
      this.showNotification("Edit cancelled", "info");
    },
    resetForm() {
      this.examName = "";
      this.course = "";
      this.duration = 30;
      this.dateTime = "";
      this.editingExamId = null;
    },
    async deleteExam(examId) {
      if (!confirm("Are you sure you want to delete this exam? This action cannot be undone.")) {
        return;
      }

      try {
        await deleteExamById(examId);
        await this.fetchExams();
        this.showNotification("Exam deleted successfully", "success");
      } catch (err) {
        console.error("Error deleting exam:", err);
        this.showNotification("Failed to delete exam", "error");
      }
    },
    toggleQuestions(examId) {
      this.openQuestions = this.openQuestions === examId ? null : examId;
    },
    formatDate(timestamp) {
      if (!timestamp) return "-";
      const date = new Date(timestamp.seconds ? timestamp.seconds * 1000 : timestamp);
      return date.toLocaleDateString('en-US', {
        weekday: 'short',
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    },
    isUpcoming(timestamp) {
      const examDate = new Date(timestamp.seconds ? timestamp.seconds * 1000 : timestamp);
      const now = new Date();
      return examDate > now;
    },
    isCompleted(timestamp) {
      const examDate = new Date(timestamp.seconds ? timestamp.seconds * 1000 : timestamp);
      const now = new Date();
      return examDate < now;
    },
    getStatusClass(timestamp) {
      if (this.isUpcoming(timestamp)) return 'status-upcoming';
      if (this.isCompleted(timestamp)) return 'status-completed';
      return 'status-ongoing';
    },
    getStatusText(timestamp) {
      if (this.isUpcoming(timestamp)) return 'Upcoming';
      if (this.isCompleted(timestamp)) return 'Completed';
      return 'Ongoing';
    },
    exportToExcel() {
      // Implement export functionality
      this.showNotification("Export feature coming soon!", "info");
    },
    showNotification(message, type = "info") {
      // You can replace with your preferred notification system
      alert(`[${type.toUpperCase()}] ${message}`);
    }
  }
};
</script>

<style scoped>
/* ====== Main Container ====== */
.exams-container {
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

/* ====== Header Section ====== */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
  padding: 25px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
}

.header-content {
  flex: 1;
}

.page-title {
  display: flex;
  align-items: center;
  gap: 15px;
  margin: 0;
  font-size: 28px;
  color: #2c3e50;
  font-weight: 700;
}

.title-icon {
  font-size: 32px;
}

.page-subtitle {
  margin: 10px 0 0;
  color: #7f8c8d;
  font-size: 16px;
}

.header-actions {
  display: flex;
  gap: 15px;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border-radius: 10px;
  border: none;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.primary-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.primary-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(102, 126, 234, 0.4);
}

.secondary-btn {
  background: #f8f9fa;
  color: #2c3e50;
  border: 2px solid #e9ecef;
}

.secondary-btn:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

.btn-icon {
  font-size: 18px;
}

/* ====== Stats Panel ====== */
.stats-panel {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-icon {
  font-size: 40px;
  opacity: 0.8;
}

.stat-content {
  flex: 1;
}

.stat-value {
  margin: 0;
  font-size: 32px;
  color: #2c3e50;
  font-weight: 700;
}

.stat-label {
  margin: 5px 0 0;
  color: #7f8c8d;
  font-size: 14px;
}

/* ====== Content Grid ====== */
.content-grid {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: 30px;
}

@media (max-width: 1200px) {
  .content-grid {
    grid-template-columns: 1fr;
  }
}

/* ====== Form Card ====== */
.form-card {
  background: white;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 20px;
}

.card-header {
  padding: 25px 25px 15px;
  border-bottom: 1px solid #f1f3f4;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 0;
  font-size: 20px;
  color: #2c3e50;
}

.card-icon {
  font-size: 24px;
}

.card-subtitle {
  margin: 8px 0 0;
  color: #7f8c8d;
  font-size: 14px;
}

/* ====== Form Styles ====== */
.exam-form {
  padding: 25px;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 25px;
}

@media (max-width: 768px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}

.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2c3e50;
  font-size: 14px;
}

.label-icon {
  font-size: 16px;
}

.form-input, .form-select {
  width: 100%;
  padding: 12px 15px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s;
  background: white;
}

.form-input:focus, .form-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.duration-hints {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}

.duration-hint {
  padding: 6px 12px;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s;
}

.duration-hint:hover {
  background: #e9ecef;
}

.duration-hint.active {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

/* ====== Form Actions ====== */
.form-actions {
  display: flex;
  gap: 15px;
  padding-top: 20px;
  border-top: 1px solid #f1f3f4;
}

.submit-btn, .cancel-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 28px;
  border: none;
  border-radius: 10px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.submit-btn {
  background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);
  color: white;
  flex: 1;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(76, 175, 80, 0.4);
}

.submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.update-btn {
  background: linear-gradient(135deg, #2196F3 0%, #0D47A1 100%);
}

.cancel-btn {
  background: #f8f9fa;
  color: #666;
  border: 2px solid #e9ecef;
}

.cancel-btn:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

/* ====== List Card ====== */
.list-card {
  background: white;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.search-filter {
  display: flex;
  gap: 15px;
  margin-top: 20px;
}

.search-box {
  flex: 1;
  position: relative;
}

.search-icon {
  position: absolute;
  left: 15px;
  top: 50%;
  transform: translateY(-50%);
  color: #7f8c8d;
}

.search-input {
  width: 50%;
  padding: 12px 15px 12px 45px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s;
}

.search-input:focus {
  outline: none;
  border-color: #667eea;
}

.filter-select {
  min-width: 150px;
  padding: 12px 15px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 14px;
  background: white;
}

/* ====== Exams List ====== */
.exams-list {
  padding: 0;
}

.exam-card {
  margin: 0 25px 20px;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s;
}

.exam-card:hover {
  border-color: #667eea;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.15);
  transform: translateY(-2px);
}

.exam-card.upcoming {
  border-left: 4px solid #4CAF50;
}

.exam-card.completed {
  border-left: 4px solid #9E9E9E;
  opacity: 0.9;
}

.exam-card.editing {
  border-color: #2196F3;
  background: #f0f7ff;
}

.exam-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.exam-status {
  padding: 6px 15px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}

.status-upcoming {
  background: #e8f5e9;
  color: #2E7D32;
}

.status-ongoing {
  background: #fff3e0;
  color: #EF6C00;
}

.status-completed {
  background: #f5f5f5;
  color: #616161;
}

.exam-actions {
  display: flex;
  gap: 10px;
}

.icon-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
}

.edit-btn {
  background: #e3f2fd;
  color: #2196F3;
}

.edit-btn:hover {
  background: #bbdefb;
  transform: scale(1.1);
}

.delete-btn {
  background: #ffebee;
  color: #f44336;
}

.delete-btn:hover {
  background: #ffcdd2;
  transform: scale(1.1);
}

/* ====== Exam Content ====== */
.exam-content {
  padding: 20px;
}

.exam-name {
  margin: 0 0 15px;
  font-size: 18px;
  color: #2c3e50;
}

.exam-meta {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-size: 14px;
}

.meta-icon {
  font-size: 16px;
}

.questions-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #f1f3f4;
}

.questions-count {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-weight: 600;
}

.count-icon {
  font-size: 18px;
}

.manage-questions-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  color: #666;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
}

.manage-questions-btn:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

/* ====== Questions Section ====== */
.questions-section {
  padding: 20px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h4 {
  margin: 0;
  color: #2c3e50;
}

.close-section-btn {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  border: none;
  background: #e9ecef;
  color: #666;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.close-section-btn:hover {
  background: #dee2e6;
  transform: rotate(90deg);
}

/* ====== Empty State ====== */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #7f8c8d;
}

.empty-icon {
  font-size: 60px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h3 {
  margin: 0 0 10px;
  color: #2c3e50;
}

.empty-state p {
  margin: 5px 0;
}

/* ====== Badge ====== */
.badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 24px;
  height: 24px;
  padding: 0 8px;
  background: #667eea;
  color: white;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
  margin-left: 10px;
}

/* ====== Loading State ====== */
.loading {
  text-align: center;
  padding: 40px;
  color: #667eea;
  font-size: 18px;
}

/* ====== Responsive Design ====== */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 20px;
  }
  
  .header-actions {
    width: 100%;
    justify-content: flex-start;
  }
  
  .exam-meta {
    flex-direction: column;
    gap: 10px;
  }
  
  .questions-info {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
  
  .search-filter {
    flex-direction: column;
  }
}

/* ====== Animations ====== */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.exam-card {
  animation: fadeIn 0.3s ease-out;
}
</style>