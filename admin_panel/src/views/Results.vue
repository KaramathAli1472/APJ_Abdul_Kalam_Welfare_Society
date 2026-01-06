<template>
  <div class="results-container">
    <!-- Header -->
    <div class="results-header">
      <div class="header-left">
        <h1 class="page-title">Results Management</h1>
        <p class="page-subtitle">Manage and track student exam results</p>
      </div>
      <div class="header-actions">
        <button @click="showAddModal = true" class="primary-btn">➕ Add Result</button>
        <button @click="refreshResults" class="secondary-btn" :disabled="loading">
          🔄 {{ loading ? 'Loading...' : 'Refresh' }}
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon" style="background: #e3f2fd; color: #1976d2;">📊</div>
        <div class="stat-content">
          <div class="stat-label">Total Results</div>
          <div class="stat-value">{{ results.length }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #e8f5e9; color: #388e3c;">⭐</div>
        <div class="stat-content">
          <div class="stat-label">Toppers (A+)</div>
          <div class="stat-value">{{ getToppersCount() }}</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #fff3e0; color: #f57c00;">📈</div>
        <div class="stat-content">
          <div class="stat-label">Average Score</div>
          <div class="stat-value">{{ calculateAverage() }}%</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: #fce4ec; color: #c2185b;">🎯</div>
        <div class="stat-content">
          <div class="stat-label">Pass Percentage</div>
          <div class="stat-value">{{ calculatePassPercentage() }}%</div>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <div class="search-box">
        <input 
          type="text" 
          v-model="searchQuery" 
          placeholder="Search by student name, class or subject..."
          class="search-input"
        />
        <span class="search-icon">🔍</span>
      </div>
      <div class="filter-controls">
        <select v-model="selectedClass" class="filter-select">
          <option value="">All Classes</option>
          <option v-for="c in classes" :key="c" :value="c">{{ c }} Class</option>
        </select>
        <select v-model="selectedSubject" class="filter-select">
          <option value="">All Subjects</option>
          <option v-for="s in subjects" :key="s" :value="s">{{ s }}</option>
        </select>
        <button @click="clearFilters" class="clear-btn">Clear Filters</button>
      </div>
    </div>

    <!-- Results Table -->
    <div class="results-table-section">
      <div v-if="loading" class="loading-container">
        <div class="loading-spinner"></div>
        <p>Loading results...</p>
      </div>

      <div v-else-if="error" class="error-container">
        <div class="error-icon">⚠️</div>
        <h3>Unable to Load Results</h3>
        <p>{{ error }}</p>
        <button @click="refreshResults" class="retry-btn">Try Again</button>
      </div>

      <div v-else class="table-wrapper">
        <table class="results-table">
          <thead>
            <tr>
              <th>Student Name</th>
              <th>Class</th>
              <th>Subject</th>
              <th>Exam Type</th>
              <th>Marks Obtained</th>
              <th>Total Marks</th>
              <th>Percentage</th>
              <th>Grade</th>
              <th>Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="result in filteredResults" :key="result.id">
              <td>{{ result.studentName }}</td>
              <td>{{ result.class }}</td>
              <td>{{ result.subject }}</td>
              <td>{{ result.examType }}</td>
              <td>{{ result.marksObtained }}</td>
              <td>{{ result.totalMarks }}</td>
              <td>{{ calculatePercentage(result) }}%</td>
              <td>{{ calculateGrade(result) }}</td>
              <td>{{ formatDate(result.examDate) }}</td>
              <td>
                <button @click="editResult(result)">✏️</button>
                <button @click="confirmDelete(result)">🗑️</button>
                <button @click="viewResult(result)">👁️</button>
              </td>
            </tr>
            <tr v-if="filteredResults.length === 0">
              <td colspan="10" class="empty-state-cell">
                <p>No results found. Add your first result!</p>
                <button @click="showAddModal = true">➕ Add Result</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div v-if="showAddModal || showEditModal" class="modal-overlay">
      <div class="modal-container">
        <div class="modal-header">
          <h3>{{ isEditing ? 'Edit Result' : 'Add Result' }}</h3>
          <button @click="closeModal" class="close-btn">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveResult">
            <div class="form-grid">
              <div class="form-group">
                <label>Student Name *</label>
                <input type="text" v-model="currentResult.studentName" required />
              </div>
              <div class="form-group">
                <label>Email</label>
                <input type="email" v-model="currentResult.email" />
              </div>
              <div class="form-group">
                <label>Class *</label>
                <select v-model="currentResult.class" required>
                  <option value="">Select Class</option>
                  <option v-for="c in classes" :key="c" :value="c">{{ c }}</option>
                </select>
              </div>
              <div class="form-group">
                <label>Subject *</label>
                <select v-model="currentResult.subject" required>
                  <option value="">Select Subject</option>
                  <option v-for="s in subjects" :key="s" :value="s">{{ s }}</option>
                </select>
              </div>
              <div class="form-group">
                <label>Exam Type *</label>
                <select v-model="currentResult.examType" required>
                  <option value="">Select Exam Type</option>
                  <option>Mid-Term</option>
                  <option>Final Exam</option>
                  <option>Unit Test</option>
                  <option>Quiz</option>
                </select>
              </div>
              <div class="form-group">
                <label>Exam Date *</label>
                <input type="date" v-model="currentResult.examDate" required />
              </div>
              <div class="form-group">
                <label>Marks Obtained *</label>
                <input type="number" v-model="currentResult.marksObtained" min="0" :max="currentResult.totalMarks" required />
              </div>
              <div class="form-group">
                <label>Total Marks *</label>
                <input type="number" v-model="currentResult.totalMarks" min="1" max="200" required />
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" @click="closeModal" class="cancel-btn">Cancel</button>
              <button type="submit" class="save-btn">{{ isEditing ? 'Update' : 'Save' }}</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Delete Modal -->
    <div v-if="showDeleteModal" class="modal-overlay">
      <div class="delete-modal">
        <h3>Confirm Delete</h3>
        <p>Are you sure you want to delete {{ resultToDelete?.studentName }}?</p>
        <button @click="cancelDelete">Cancel</button>
        <button @click="deleteResult">Delete</button>
      </div>
    </div>
  </div>
</template>

<script>
import { db } from '../firebase/firebase';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, serverTimestamp } from 'firebase/firestore';

export default {
  name: 'Results',
  data() {
    return {
      results: [],
      loading: false,
      error: null,
      saving: false,
      deleting: false,
      searchQuery: '',
      selectedClass: '',
      selectedSubject: '',
      showAddModal: false,
      showEditModal: false,
      showDeleteModal: false,
      isEditing: false,
      currentResult: {},
      resultToDelete: null,
      classes: ['4th','5th','6th','7th','8th','9th','10th'],
      subjects: ['Mathematics','Physics','Chemistry','Biology','English','Computer Science']
    };
  },
  computed: {
    filteredResults() {
      return this.results.filter(r => {
        const search = this.searchQuery.toLowerCase();
        return (
          (!search || r.studentName.toLowerCase().includes(search) || r.class.toLowerCase().includes(search) || r.subject.toLowerCase().includes(search)) &&
          (!this.selectedClass || r.class === this.selectedClass) &&
          (!this.selectedSubject || r.subject === this.selectedSubject)
        );
      });
    }
  },
  async created() {
    await this.loadResults();
  },
  methods: {
    async loadResults() {
      this.loading = true;
      this.error = null;
      try {
        const querySnapshot = await getDocs(collection(db, 'results'));
        this.results = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      } catch (err) {
        this.error = 'Failed to load results.';
        console.error(err);
      } finally {
        this.loading = false;
      }
    },
    refreshResults() { this.loadResults(); },
    clearFilters() { this.searchQuery=''; this.selectedClass=''; this.selectedSubject=''; },
    editResult(result) { this.currentResult = { ...result }; this.isEditing = true; this.showEditModal = true; },
    confirmDelete(result) { this.resultToDelete = result; this.showDeleteModal = true; },
    cancelDelete() { this.showDeleteModal = false; this.resultToDelete = null; },
    async deleteResult() {
      if (!this.resultToDelete) return;
      await deleteDoc(doc(db, 'results', this.resultToDelete.id));
      this.results = this.results.filter(r => r.id !== this.resultToDelete.id);
      this.cancelDelete();
    },
    async saveResult() {
      if (this.isEditing) {
        await updateDoc(doc(db, 'results', this.currentResult.id), { ...this.currentResult, updatedAt: serverTimestamp() });
      } else {
        const docRef = await addDoc(collection(db, 'results'), { ...this.currentResult, createdAt: serverTimestamp(), updatedAt: serverTimestamp() });
        this.results.push({ ...this.currentResult, id: docRef.id });
      }
      this.closeModal();
    },
    closeModal() { this.showAddModal=false; this.showEditModal=false; this.isEditing=false; this.currentResult={}; },
    calculatePercentage(r) { return r.totalMarks ? Math.round((r.marksObtained/r.totalMarks)*100) : 0; },
    calculateGrade(r) {
      const p=this.calculatePercentage(r);
      if(p>=90) return 'A+'; if(p>=80) return 'A'; if(p>=70) return 'B'; if(p>=60) return 'C'; if(p>=33) return 'D'; return 'F';
    },
    getToppersCount() { return this.results.filter(r=>this.calculateGrade(r)==='A+').length; },
    calculateAverage() { return this.results.length ? Math.round(this.results.reduce((s,r)=>s+this.calculatePercentage(r),0)/this.results.length):0; },
    calculatePassPercentage() { return this.results.length ? Math.round((this.results.filter(r=>this.calculatePercentage(r)>=33).length/this.results.length)*100):0; },
    formatDate(date){ return date?new Date(date).toLocaleDateString('en-IN'):'N/A'; },
    viewResult(result){ alert(`${result.studentName} | ${result.class} | ${result.subject} | ${result.examType} | Marks: ${result.marksObtained}/${result.totalMarks} | Grade: ${this.calculateGrade(result)}`); }
  }
};
</script>

<style scoped>
/* Include your previous CSS styles here. */
</style>

