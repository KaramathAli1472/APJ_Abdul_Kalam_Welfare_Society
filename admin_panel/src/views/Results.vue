<template>
  <div class="results-container">
    <!-- Header Section -->
    <div class="results-header">
      <div class="header-left">
        <h1 class="page-title">Results Management</h1>
        <p class="page-subtitle">Manage and track student exam results</p>
      </div>
      <div class="header-actions">
        <button @click="showAddModal = true" class="primary-btn">
          <span class="btn-icon">➕</span>
          Add Result
        </button>
        <button @click="refreshResults" class="secondary-btn" :disabled="loading">
          <span class="btn-icon">🔄</span>
          {{ loading ? 'Loading...' : 'Refresh' }}
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

    <!-- Filters and Search -->
    <div class="filters-section">
      <div class="search-box">
        <input 
          type="text" 
          v-model="searchQuery" 
          placeholder="Search by student name, class or subject..."
          class="search-input"
        >
        <span class="search-icon">🔍</span>
      </div>
      <div class="filter-controls">
        <select v-model="selectedClass" class="filter-select">
          <option value="">All Classes</option>
          <option value="4th">4th Class</option>
          <option value="5th">5th Class</option>
          <option value="6th">6th Class</option>
          <option value="7th">7th Class</option>
          <option value="8th">8th Class</option>
          <option value="9th">9th Class</option>
          <option value="10th">10th Class</option>
        </select>
        <select v-model="selectedSubject" class="filter-select">
          <option value="">All Subjects</option>
          <option value="Mathematics">Mathematics</option>
          <option value="Physics">Physics</option>
          <option value="Chemistry">Chemistry</option>
          <option value="Biology">Biology</option>
          <option value="English">English</option>
        </select>
        <button @click="clearFilters" class="clear-btn">Clear Filters</button>
      </div>
    </div>

    <!-- Results Table -->
    <div class="results-table-section">
      <div class="table-header">
        <h3>All Results</h3>
        <div class="table-info">
          Showing {{ filteredResults.length }} of {{ results.length }} results
        </div>
      </div>
      
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="loading-spinner"></div>
        <p>Loading results...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="error-container">
        <div class="error-icon">⚠️</div>
        <h3>Unable to Load Results</h3>
        <p>{{ error }}</p>
        <button @click="refreshResults" class="retry-btn">Try Again</button>
      </div>

      <!-- Results Table -->
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
            <tr v-for="result in filteredResults" :key="result.id" class="result-row">
              <td>
                <div class="student-info">
                  <span class="student-name">{{ result.studentName }}</span>
                  <span class="student-email">{{ result.email }}</span>
                </div>
              </td>
              <td>
                <span class="class-badge">{{ result.class }}</span>
              </td>
              <td>{{ result.subject }}</td>
              <td>
                <span class="exam-type">{{ result.examType }}</span>
              </td>
              <td class="marks-cell">
                <span class="marks-obtained">{{ result.marksObtained }}</span>
              </td>
              <td class="marks-cell">{{ result.totalMarks }}</td>
              <td class="percentage-cell">
                <div class="percentage-display">
                  <span class="percentage-value">{{ calculatePercentage(result) }}%</span>
                  <div class="progress-bar">
                    <div 
                      class="progress-fill" 
                      :style="{ width: calculatePercentage(result) + '%' }"
                      :class="getProgressColor(calculatePercentage(result))"
                    ></div>
                  </div>
                </div>
              </td>
              <td>
                <span class="grade-badge" :class="getGradeClass(calculateGrade(result))">
                  {{ calculateGrade(result) }}
                </span>
              </td>
              <td>
                <span class="date-text">{{ formatDate(result.examDate) }}</span>
              </td>
              <td>
                <div class="action-buttons">
                  <!-- Edit Button -->
                  <button 
                    @click="editResult(result)" 
                    class="action-btn edit-btn"
                    title="Edit Result"
                  >
                    <span class="action-icon">✏️</span>
                  </button>
                  
                  <!-- Delete Button -->
                  <button 
                    @click="confirmDelete(result)" 
                    class="action-btn delete-btn"
                    title="Delete Result"
                  >
                    <span class="action-icon">🗑️</span>
                  </button>
                  
                  <!-- View Button -->
                  <button 
                    @click="viewResult(result)" 
                    class="action-btn view-btn"
                    title="View Details"
                  >
                    <span class="action-icon">👁️</span>
                  </button>
                </div>
              </td>
            </tr>
            
            <!-- Empty State -->
            <tr v-if="filteredResults.length === 0 && !loading">
              <td colspan="10" class="empty-state-cell">
                <div class="empty-state">
                  <span class="empty-icon">📄</span>
                  <h3>No Results Found</h3>
                  <p v-if="searchQuery || selectedClass || selectedSubject">
                    Try changing your search or filters
                  </p>
                  <p v-else>
                    No results available. Add your first result!
                  </p>
                  <button @click="showAddModal = true" class="add-first-btn">
                    ➕ Add First Result
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Add/Edit Result Modal -->
    <div v-if="showAddModal || showEditModal" class="modal-overlay">
      <div class="modal-container">
        <div class="modal-header">
          <h3>{{ isEditing ? 'Edit Result' : 'Add New Result' }}</h3>
          <button @click="closeModal" class="close-btn">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveResult">
            <div class="form-grid">
              <div class="form-group">
                <label>Student Name *</label>
                <input 
                  type="text" 
                  v-model="currentResult.studentName" 
                  required
                  placeholder="Enter student name"
                >
              </div>
              <div class="form-group">
                <label>Email</label>
                <input 
                  type="email" 
                  v-model="currentResult.email" 
                  placeholder="student@example.com"
                >
              </div>
              <div class="form-group">
                <label>Class *</label>
                <select v-model="currentResult.class" required>
                  <option value="">Select Class</option>
                  <option value="4th">4th Class</option>
                  <option value="5th">5th Class</option>
                  <option value="6th">6th Class</option>
                  <option value="7th">7th Class</option>
                  <option value="8th">8th Class</option>
                  <option value="9th">9th Class</option>
                  <option value="10th">10th Class</option>
                </select>
              </div>
              <div class="form-group">
                <label>Subject *</label>
                <select v-model="currentResult.subject" required>
                  <option value="">Select Subject</option>
                  <option value="Mathematics">Mathematics</option>
                  <option value="Physics">Physics</option>
                  <option value="Chemistry">Chemistry</option>
                  <option value="Biology">Biology</option>
                  <option value="English">English</option>
                  <option value="Computer Science">Computer Science</option>
                </select>
              </div>
              <div class="form-group">
                <label>Exam Type *</label>
                <select v-model="currentResult.examType" required>
                  <option value="">Select Exam Type</option>
                  <option value="Mid-Term">Mid-Term</option>
                  <option value="Final Exam">Final Exam</option>
                  <option value="Unit Test">Unit Test</option>
                  <option value="Quiz">Quiz</option>
                </select>
              </div>
              <div class="form-group">
                <label>Exam Date *</label>
                <input 
                  type="date" 
                  v-model="currentResult.examDate" 
                  required
                >
              </div>
              <div class="form-group">
                <label>Marks Obtained *</label>
                <input 
                  type="number" 
                  v-model="currentResult.marksObtained" 
                  required
                  min="0"
                  :max="currentResult.totalMarks || 100"
                  placeholder="0-100"
                >
              </div>
              <div class="form-group">
                <label>Total Marks *</label>
                <input 
                  type="number" 
                  v-model="currentResult.totalMarks" 
                  required
                  min="1"
                  max="200"
                  placeholder="e.g., 100"
                >
              </div>
            </div>
            
            <div class="preview-section" v-if="currentResult.marksObtained && currentResult.totalMarks">
              <h4>Result Preview</h4>
              <div class="preview-cards">
                <div class="preview-card">
                  <span class="preview-label">Percentage</span>
                  <span class="preview-value">{{ calculatePercentage(currentResult) }}%</span>
                </div>
                <div class="preview-card">
                  <span class="preview-label">Grade</span>
                  <span class="preview-value" :class="getGradeClass(calculateGrade(currentResult))">
                    {{ calculateGrade(currentResult) }}
                  </span>
                </div>
                <div class="preview-card">
                  <span class="preview-label">Status</span>
                  <span class="preview-value" :class="getStatusClass(currentResult)">
                    {{ calculatePercentage(currentResult) >= 33 ? 'Pass' : 'Fail' }}
                  </span>
                </div>
              </div>
            </div>
            
            <div class="modal-footer">
              <button type="button" @click="closeModal" class="cancel-btn">
                Cancel
              </button>
              <button type="submit" class="save-btn" :disabled="saving">
                {{ saving ? 'Saving...' : (isEditing ? 'Update' : 'Save') }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="modal-overlay">
      <div class="delete-modal">
        <div class="modal-header">
          <h3>Confirm Delete</h3>
        </div>
        <div class="modal-body">
          <div class="delete-warning">
            <span class="warning-icon">⚠️</span>
            <h4>Are you sure you want to delete this result?</h4>
            <p>This action cannot be undone.</p>
            <div class="result-info">
              <strong>{{ resultToDelete.studentName }}</strong> - {{ resultToDelete.class }} 
              | {{ resultToDelete.subject }} | {{ resultToDelete.examType }}
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button @click="cancelDelete" class="cancel-btn">Cancel</button>
          <button @click="deleteResult" class="delete-confirm-btn" :disabled="deleting">
            {{ deleting ? 'Deleting...' : 'Delete Result' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// Firebase imports
import { db } from '../firebase/firebase';
import { 
  collection, 
  getDocs, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  doc,
  serverTimestamp 
} from "firebase/firestore";

export default {
  name: 'Results',
  data() {
    return {
      // Data
      results: [],
      loading: false,
      error: null,
      saving: false,
      deleting: false,
      
      // Filters
      searchQuery: '',
      selectedClass: '',
      selectedSubject: '',
      
      // Modals
      showAddModal: false,
      showEditModal: false,
      showDeleteModal: false,
      isEditing: false,
      
      // Current result for add/edit
      currentResult: {
        id: null,
        studentName: '',
        email: '',
        class: '',
        subject: '',
        examType: '',
        examDate: '',
        marksObtained: 0,
        totalMarks: 100,
        createdAt: null,
        updatedAt: null
      },
      
      // Result to delete
      resultToDelete: null,
      
      // Default empty result
      emptyResult: {
        studentName: '',
        email: '',
        class: '',
        subject: '',
        examType: '',
        examDate: '',
        marksObtained: 0,
        totalMarks: 100,
        createdAt: null,
        updatedAt: null
      }
    };
  },
  
  computed: {
    filteredResults() {
      return this.results.filter(result => {
        const matchesSearch = this.searchQuery.toLowerCase() === '' || 
          result.studentName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
          result.class.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
          result.subject.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
          (result.email && result.email.toLowerCase().includes(this.searchQuery.toLowerCase()));
        
        const matchesClass = !this.selectedClass || result.class === this.selectedClass;
        const matchesSubject = !this.selectedSubject || result.subject === this.selectedSubject;
        
        return matchesSearch && matchesClass && matchesSubject;
      });
    }
  },
  
  async created() {
    await this.loadResults();
  },
  
  methods: {
    // Load results from Firebase
    async loadResults() {
      this.loading = true;
      this.error = null;
      
      try {
        const resultsRef = collection(db, "results");
        const querySnapshot = await getDocs(resultsRef);
        
        const resultsArray = [];
        querySnapshot.forEach((doc) => {
          const resultData = doc.data();
          resultsArray.push({
            id: doc.id,
            ...resultData
          });
        });
        
        // Sort by date (newest first)
        this.results = resultsArray.sort((a, b) => {
          const dateA = a.examDate ? new Date(a.examDate) : new Date();
          const dateB = b.examDate ? new Date(b.examDate) : new Date();
          return dateB - dateA;
        });
        
        console.log(`✅ Loaded ${this.results.length} results`);
        
      } catch (err) {
        console.error("❌ Error loading results:", err);
        this.error = "Failed to load results. Please check your connection.";
        
        // If no results in Firebase, show sample data
        if (this.results.length === 0) {
          this.results = this.getSampleResults();
        }
      } finally {
        this.loading = false;
      }
    },
    
    // Refresh results
    async refreshResults() {
      await this.loadResults();
    },
    
    // Clear all filters
    clearFilters() {
      this.searchQuery = '';
      this.selectedClass = '';
      this.selectedSubject = '';
    },
    
    // Add new result
    async addResult() {
      this.saving = true;
      
      try {
        const resultData = {
          ...this.currentResult,
          createdAt: serverTimestamp(),
          updatedAt: serverTimestamp()
        };
        
        const docRef = await addDoc(collection(db, "results"), resultData);
        console.log("✅ Result added with ID:", docRef.id);
        
        // Add to local array
        this.results.unshift({
          id: docRef.id,
          ...resultData
        });
        
        this.showSuccessMessage('Result added successfully!');
        this.closeModal();
        
      } catch (err) {
        console.error("❌ Error adding result:", err);
        this.showErrorMessage('Failed to add result. Please try again.');
      } finally {
        this.saving = false;
      }
    },
    
    // Edit result
    async updateResult() {
      this.saving = true;
      
      try {
        const resultRef = doc(db, "results", this.currentResult.id);
        const updateData = {
          ...this.currentResult,
          updatedAt: serverTimestamp()
        };
        
        await updateDoc(resultRef, updateData);
        
        // Update in local array
        const index = this.results.findIndex(r => r.id === this.currentResult.id);
        if (index !== -1) {
          this.results[index] = { ...this.currentResult };
        }
        
        this.showSuccessMessage('Result updated successfully!');
        this.closeModal();
        
      } catch (err) {
        console.error("❌ Error updating result:", err);
        this.showErrorMessage('Failed to update result. Please try again.');
      } finally {
        this.saving = false;
      }
    },
    
    // Delete result
    async deleteResult() {
      this.deleting = true;
      
      try {
        await deleteDoc(doc(db, "results", this.resultToDelete.id));
        
        // Remove from local array
        this.results = this.results.filter(r => r.id !== this.resultToDelete.id);
        
        this.showSuccessMessage('Result deleted successfully!');
        this.closeDeleteModal();
        
      } catch (err) {
        console.error("❌ Error deleting result:", err);
        this.showErrorMessage('Failed to delete result. Please try again.');
      } finally {
        this.deleting = false;
      }
    },
    
    // Open edit modal
    editResult(result) {
      this.currentResult = { ...result };
      this.isEditing = true;
      this.showEditModal = true;
    },
    
    // Open delete confirmation
    confirmDelete(result) {
      this.resultToDelete = { ...result };
      this.showDeleteModal = true;
    },
    
    // Cancel delete
    cancelDelete() {
      this.resultToDelete = null;
      this.showDeleteModal = false;
    },
    
    // Close delete modal
    closeDeleteModal() {
      this.resultToDelete = null;
      this.showDeleteModal = false;
    },
    
    // View result details
    viewResult(result) {
      alert(`Viewing details for ${result.studentName}\n\n` +
            `Class: ${result.class}\n` +
            `Subject: ${result.subject}\n` +
            `Exam: ${result.examType}\n` +
            `Marks: ${result.marksObtained}/${result.totalMarks}\n` +
            `Percentage: ${this.calculatePercentage(result)}%\n` +
            `Grade: ${this.calculateGrade(result)}`
      );
    },
    
    // Save result (add or update)
    async saveResult() {
      if (this.isEditing) {
        await this.updateResult();
      } else {
        await this.addResult();
      }
    },
    
    // Close modal
    closeModal() {
      this.showAddModal = false;
      this.showEditModal = false;
      this.isEditing = false;
      this.currentResult = { ...this.emptyResult };
    },
    
    // Calculate percentage
    calculatePercentage(result) {
      if (!result.marksObtained || !result.totalMarks) return 0;
      return Math.round((result.marksObtained / result.totalMarks) * 100);
    },
    
    // Calculate grade based on percentage
    calculateGrade(result) {
      const percentage = this.calculatePercentage(result);
      if (percentage >= 90) return 'A+';
      if (percentage >= 80) return 'A';
      if (percentage >= 70) return 'B';
      if (percentage >= 60) return 'C';
      if (percentage >= 33) return 'D';
      return 'F';
    },
    
    // Get grade CSS class
    getGradeClass(grade) {
      switch(grade) {
        case 'A+': return 'grade-a-plus';
        case 'A': return 'grade-a';
        case 'B': return 'grade-b';
        case 'C': return 'grade-c';
        case 'D': return 'grade-d';
        case 'F': return 'grade-f';
        default: return 'grade-default';
      }
    },
    
    // Get progress bar color
    getProgressColor(percentage) {
      if (percentage >= 80) return 'progress-excellent';
      if (percentage >= 60) return 'progress-good';
      if (percentage >= 33) return 'progress-average';
      return 'progress-poor';
    },
    
    // Get status class
    getStatusClass(result) {
      return this.calculatePercentage(result) >= 33 ? 'status-pass' : 'status-fail';
    },
    
    // Calculate average score
    calculateAverage() {
      if (this.results.length === 0) return 0;
      const total = this.results.reduce((sum, result) => {
        return sum + this.calculatePercentage(result);
      }, 0);
      return Math.round(total / this.results.length);
    },
    
    // Calculate pass percentage
    calculatePassPercentage() {
      if (this.results.length === 0) return 0;
      const passed = this.results.filter(result => this.calculatePercentage(result) >= 33).length;
      return Math.round((passed / this.results.length) * 100);
    },
    
    // Get toppers count (A+)
    getToppersCount() {
      return this.results.filter(result => this.calculateGrade(result) === 'A+').length;
    },
    
    // Format date
    formatDate(dateString) {
      if (!dateString) return 'N/A';
      const date = new Date(dateString);
      return date.toLocaleDateString('en-IN', {
        day: '2-digit',
        month: 'short',
        year: 'numeric'
      });
    },
    
    // Show success message
    showSuccessMessage(message) {
      alert(`✅ ${message}`);
    },
    
    // Show error message
    showErrorMessage(message) {
      alert(`❌ ${message}`);
    },
    
    // Get sample results (for testing)
    getSampleResults() {
      return [
        {
          id: '1',
          studentName: 'Rahul Sharma',
          email: 'rahul@example.com',
          class: '10th',
          subject: 'Mathematics',
          examType: 'Final Exam',
          examDate: '2024-01-10',
          marksObtained: 85,
          totalMarks: 100,
          createdAt: new Date(),
          updatedAt: new Date()
        },
        {
          id: '2',
          studentName: 'Priya Patel',
          email: 'priya@example.com',
          class: '12th',
          subject: 'Physics',
          examType: 'Mid-Term',
          examDate: '2024-01-08',
          marksObtained: 92,
          totalMarks: 100,
          createdAt: new Date(),
          updatedAt: new Date()
        },
        {
          id: '3',
          studentName: 'Amit Kumar',
          email: 'amit@example.com',
          class: '11th',
          subject: 'Chemistry',
          examType: 'Unit Test',
          examDate: '2024-01-05',
          marksObtained: 76,
          totalMarks: 100,
          createdAt: new Date(),
          updatedAt: new Date()
        }
      ];
    }
  }
};
</script>

<style scoped>
/* ====== Base Container ====== */
.results-container {
  padding: 24px;
  background: #f8fafc;
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
}

/* ====== Header Section ====== */
.results-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
  flex-wrap: wrap;
  gap: 20px;
}

.header-left .page-title {
  font-size: 32px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 8px 0;
}

.page-subtitle {
  font-size: 16px;
  color: #64748b;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.primary-btn, .secondary-btn {
  padding: 12px 24px;
  border-radius: 8px;
  border: none;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.primary-btn {
  background: #3b82f6;
  color: white;
}

.primary-btn:hover {
  background: #2563eb;
  transform: translateY(-2px);
}

.secondary-btn {
  background: white;
  color: #3b82f6;
  border: 2px solid #3b82f6;
}

.secondary-btn:hover {
  background: #f0f9ff;
}

.secondary-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-icon {
  font-size: 16px;
}

/* ====== Stats Grid ====== */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
}

.stat-content {
  flex: 1;
}

.stat-label {
  font-size: 14px;
  color: #64748b;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1e293b;
}

/* ====== Filters Section ====== */
.filters-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 30px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.search-box {
  position: relative;
  margin-bottom: 20px;
}

.search-input {
  width: 100%;
  padding: 12px 20px 12px 45px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s;
}

.search-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.search-icon {
  position: absolute;
  left: 15px;
  top: 50%;
  transform: translateY(-50%);
  color: #94a3b8;
}

.filter-controls {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.filter-select {
  padding: 10px 16px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  color: #475569;
  background: white;
  min-width: 150px;
  flex: 1;
}

.clear-btn {
  padding: 10px 20px;
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  color: #64748b;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
}

.clear-btn:hover {
  background: #e2e8f0;
}

/* ====== Results Table Section ====== */
.results-table-section {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.table-header h3 {
  margin: 0;
  font-size: 20px;
  color: #1e293b;
}

.table-info {
  font-size: 14px;
  color: #64748b;
  background: #f8fafc;
  padding: 6px 12px;
  border-radius: 6px;
}

/* ====== Loading State ====== */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #e2e8f0;
  border-top: 4px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-container p {
  color: #64748b;
  margin: 0;
}

/* ====== Error State ====== */
.error-container {
  text-align: center;
  padding: 40px 20px;
}

.error-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.error-container h3 {
  color: #dc2626;
  margin: 0 0 8px 0;
  font-size: 20px;
}

.error-container p {
  color: #64748b;
  margin: 0 0 20px 0;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.retry-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: background 0.3s;
}

.retry-btn:hover {
  background: #2563eb;
}

/* ====== Table Wrapper ====== */
.table-wrapper {
  overflow-x: auto;
}

.results-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 1000px;
}

.results-table th {
  background: #f8fafc;
  padding: 16px;
  text-align: left;
  font-size: 13px;
  font-weight: 600;
  color: #475569;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 2px solid #e2e8f0;
}

.results-table td {
  padding: 16px;
  border-bottom: 1px solid #f1f5f9;
  font-size: 14px;
  color: #334155;
  vertical-align: middle;
}

.result-row:hover {
  background: #f8fafc;
}

/* ====== Table Cell Styles ====== */
.student-info {
  display: flex;
  flex-direction: column;
}

.student-name {
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 4px;
}

.student-email {
  font-size: 12px;
  color: #64748b;
}

.class-badge {
  background: #e0f2fe;
  color: #0369a1;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  display: inline-block;
}

.exam-type {
  font-size: 13px;
  color: #475569;
}

.marks-cell {
  font-weight: 600;
  color: #1e293b;
}

.percentage-display {
  display: flex;
  align-items: center;
  gap: 12px;
}

.percentage-value {
  font-weight: 600;
  min-width: 45px;
  text-align: right;
}

.progress-bar {
  flex: 1;
  height: 6px;
  background: #e2e8f0;
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 3px;
}

.progress-excellent { background: #10b981; }
.progress-good { background: #3b82f6; }
.progress-average { background: #f59e0b; }
.progress-poor { background: #ef4444; }

/* ====== Grade Badges ====== */
.grade-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  display: inline-block;
  min-width: 40px;
  text-align: center;
}

.grade-a-plus { background: #10b981; color: white; }
.grade-a { background: #34d399; color: white; }
.grade-b { background: #fbbf24; color: white; }
.grade-c { background: #f97316; color: white; }
.grade-d { background: #ef4444; color: white; }
.grade-f { background: #991b1b; color: white; }

.date-text {
  font-size: 13px;
  color: #64748b;
}

/* ====== Action Buttons ====== */
.action-buttons {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  background: #f8fafc;
}

.edit-btn { 
  background: #fef3c7; 
  color: #92400e; 
}
.edit-btn:hover { 
  background: #fde68a; 
  transform: scale(1.1); 
}

.delete-btn { 
  background: #fee2e2; 
  color: #dc2626; 
}
.delete-btn:hover { 
  background: #fecaca; 
  transform: scale(1.1); 
}

.view-btn { 
  background: #e0f2fe; 
  color: #0369a1; 
}
.view-btn:hover { 
  background: #bae6fd; 
  transform: scale(1.1); 
}

.action-icon {
  font-size: 16px;
}

/* ====== Empty State ====== */
.empty-state-cell {
  padding: 60px !important;
}

.empty-state {
  text-align: center;
}

.empty-icon {
  font-size: 48px;
  display: block;
  margin-bottom: 16px;
  opacity: 0.5;
}

.empty-state h3 {
  font-size: 20px;
  color: #1e293b;
  margin: 0 0 12px 0;
}

.empty-state p {
  color: #64748b;
  margin: 0 0 20px 0;
  font-size: 15px;
}

.add-first-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.add-first-btn:hover {
  background: #2563eb;
}

/* ====== Modal Overlay ====== */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

/* ====== Add/Edit Modal ====== */
.modal-container {
  background: white;
  border-radius: 12px;
  width: 800px;
  max-width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #e2e8f0;
}

.modal-header h3 {
  margin: 0;
  font-size: 20px;
  color: #1e293b;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #64748b;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.close-btn:hover {
  background: #f1f5f9;
  color: #dc2626;
}

.modal-body {
  padding: 24px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.form-group {
  margin-bottom: 0;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #374151;
  font-size: 14px;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.preview-section {
  background: #f8fafc;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 24px;
}

.preview-section h4 {
  margin: 0 0 16px 0;
  color: #1e293b;
  font-size: 16px;
}

.preview-cards {
  display: flex;
  gap: 16px;
}

.preview-card {
  flex: 1;
  background: white;
  padding: 16px;
  border-radius: 8px;
  text-align: center;
  border: 1px solid #e2e8f0;
}

.preview-label {
  display: block;
  font-size: 12px;
  color: #64748b;
  margin-bottom: 4px;
}

.preview-value {
  display: block;
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
}

.status-pass { color: #10b981; }
.status-fail { color: #ef4444; }

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
}

.cancel-btn,
.save-btn,
.delete-confirm-btn {
  padding: 10px 24px;
  border-radius: 8px;
  border: none;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  min-width: 100px;
}

.cancel-btn {
  background: #f3f4f6;
  color: #374151;
}

.cancel-btn:hover {
  background: #e5e7eb;
}

.save-btn {
  background: #3b82f6;
  color: white;
}

.save-btn:hover:not(:disabled) {
  background: #2563eb;
}

.save-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ====== Delete Modal ====== */
.delete-modal {
  background: white;
  border-radius: 12px;
  width: 500px;
  max-width: 90%;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.delete-warning {
  text-align: center;
  padding: 20px;
}

.warning-icon {
  font-size: 48px;
  display: block;
  margin-bottom: 16px;
}

.delete-warning h4 {
  margin: 0 0 8px 0;
  color: #1e293b;
}

.delete-warning p {
  color: #64748b;
  margin: 0 0 20px 0;
}

.result-info {
  background: #fef3c7;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #fde68a;
  color: #92400e;
  font-size: 14px;
  line-height: 1.5;
}

.delete-confirm-btn {
  background: #dc2626;
  color: white;
}

.delete-confirm-btn:hover:not(:disabled) {
  background: #b91c1c;
}

.delete-confirm-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ====== Responsive Design ====== */
@media (max-width: 768px) {
  .results-container {
    padding: 16px;
  }
  
  .results-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .header-actions {
    width: 100%;
  }
  
  .primary-btn, .secondary-btn {
    flex: 1;
    justify-content: center;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .filter-controls {
    flex-direction: column;
  }
  
  .filter-select {
    width: 100%;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .preview-cards {
    flex-direction: column;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .modal-footer {
    flex-direction: column;
  }
  
  .cancel-btn,
  .save-btn,
  .delete-confirm-btn {
    width: 100%;
  }
  
  .results-table {
    font-size: 12px;
  }
  
  .results-table th,
  .results-table td {
    padding: 12px 8px;
  }
}

@media (max-width: 480px) {
  .page-title {
    font-size: 24px;
  }
  
  .stat-value {
    font-size: 24px;
  }
  
  .action-btn {
    width: 30px;
    height: 30px;
    font-size: 14px;
  }
}
</style>