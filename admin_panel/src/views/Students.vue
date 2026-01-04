<template>
  <div class="students-container">
    <!-- Header -->
    <div class="header">
      <div class="header-left">
        <h1>Students Management</h1>
        <p class="subtitle">Manage student records and payments</p>
      </div>
      <div class="header-right">
        <div class="search-box">
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="Search students..." 
            class="search-input"
          >
          <span class="search-icon">🔍</span>
        </div>
        <button @click="loadData" :disabled="loading" class="refresh-btn">
          <span v-if="loading" class="spinner-small"></span>
          <span v-else class="btn-icon">🔄</span>
          <span class="btn-text">{{ loading ? 'Loading...' : 'Refresh' }}</span>
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-icon total">👥</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ totalStudents }}</h3>
          <p class="stat-label">Total Students</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon paid">💰</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ paidStudents }}</h3>
          <p class="stat-label">Paid Students</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon pending">⏳</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ pendingStudents }}</h3>
          <p class="stat-label">Pending Payments</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon id-card">🪪</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ idCardGenerated }}</h3>
          <p class="stat-label">ID Cards Generated</p>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
      <!-- Error Message -->
      <div v-if="error" class="error-message">
        <div class="error-icon">⚠️</div>
        <div class="error-content">
          <h4>Error Loading Students</h4>
          <p>{{ error }}</p>
          <button @click="loadData" class="retry-btn">Try Again</button>
        </div>
      </div>

      <!-- Students Table -->
      <div class="table-container" v-if="!error">
        <div class="table-header">
          <h3 class="table-title">Students List</h3>
          <div class="table-actions">
            <div class="records-count">
              Showing {{ filteredStudents.length }} of {{ students.length }} students
            </div>
            <div class="filter-dropdown">
              <select v-model="statusFilter" class="filter-select">
                <option value="">All Status</option>
                <option value="Paid">Paid</option>
                <option value="Pending">Pending</option>
                <option value="Rejected">Rejected</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>Loading students data...</p>
        </div>

        <!-- No Data State -->
        <div v-else-if="students.length === 0" class="no-data-state">
          <div class="no-data-icon">📭</div>
          <h3>No Students Found</h3>
          <p>There are no student records in the database yet.</p>
          <button @click="loadData" class="retry-btn">Refresh</button>
        </div>

        <!-- Table -->
        <div v-else class="table-wrapper">
          <table class="students-table">
            <thead>
              <tr>
                <th class="student-col">Student</th>
                <th class="email-col">Email</th>
                <th class="grade-col">Grade</th>
                <th class="payment-col">Payment Status</th>
                <th class="transaction-col">Transaction ID</th>
                <th class="amount-col">Amount</th>
                <th class="actions-col">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="student in filteredStudents" :key="student.studentId" class="student-row">
                <!-- Student Info -->
                <td class="student-info-cell">
                  <div class="student-info">
                    <div class="student-avatar">
                      {{ getInitials(student.name) }}
                    </div>
                    <div class="student-details">
                      <p class="student-name">{{ student.name }}</p>
                      <p class="student-id">ID: {{ student.studentId?.slice(0, 8) || 'N/A' }}</p>
                    </div>
                  </div>
                </td>
                
                <!-- Email -->
                <td class="email-cell">
                  <div class="email-wrapper">
                    <span class="email-icon">✉️</span>
                    <span class="email-text">{{ student.email || 'N/A' }}</span>
                  </div>
                </td>
                
                <!-- Grade -->
                <td class="grade-cell">
                  <span class="grade-badge">{{ student.grade }}</span>
                </td>
                
                <!-- Payment Status -->
                <td class="payment-cell">
                  <span :class="['status-badge', getPaymentStatusClass(student.paymentStatus)]">
                    {{ student.paymentStatus }}
                  </span>
                </td>
                
                <!-- Transaction ID -->
                <td class="transaction-cell">
                  <code class="transaction-id">{{ student.transactionID?.slice(0, 12) || 'N/A' }}</code>
                </td>
                
                <!-- Amount -->
                <td class="amount-cell">
                  <span class="amount-value">₹{{ student.amount || 0 }}</span>
                </td>
                
                <!-- Actions -->
                <td class="actions-cell">
                  <div class="action-buttons">
                    <button 
                      @click="approvePayment(student)"
                      :disabled="student.paymentStatus === 'Paid'"
                      class="action-btn approve-btn"
                      title="Approve Payment"
                    >
                      <span class="btn-icon">✓</span>
                      <span class="btn-text">Approve</span>
                    </button>
                    <button 
                      @click="rejectPayment(student)"
                      :disabled="student.paymentStatus === 'Rejected'"
                      class="action-btn reject-btn"
                      title="Reject Payment"
                    >
                      <span class="btn-icon">✗</span>
                      <span class="btn-text">Reject</span>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- No Search Results -->
        <div v-if="!loading && students.length > 0 && filteredStudents.length === 0" class="no-results">
          <div class="no-results-icon">🔍</div>
          <h3>No matching students found</h3>
          <p>Try adjusting your search or filter criteria</p>
          <button @click="clearFilters" class="clear-filters-btn">Clear Filters</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { db } from "../firebase/firebase";
import { collection, getDocs } from "firebase/firestore";

export default {
  name: 'StudentsList',
  data() {
    return {
      students: [],
      searchQuery: '',
      statusFilter: '',
      loading: false,
      error: null
    };
  },
  computed: {
    filteredStudents() {
      let filtered = this.students;
      
      // Search filter
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filtered = filtered.filter(student => {
          const name = student.name || '';
          const email = student.email || '';
          const grade = student.grade || '';
          const transactionID = student.transactionID || '';
          
          return name.toLowerCase().includes(query) ||
                 email.toLowerCase().includes(query) ||
                 grade.toLowerCase().includes(query) ||
                 transactionID.toLowerCase().includes(query);
        });
      }
      
      // Status filter
      if (this.statusFilter) {
        filtered = filtered.filter(student => {
          const status = student.paymentStatus || '';
          return status.toLowerCase() === this.statusFilter.toLowerCase();
        });
      }
      
      return filtered;
    },
    
    totalStudents() {
      return this.students.length;
    },
    
    paidStudents() {
      return this.students.filter(s => s.paymentStatus === 'Paid').length;
    },
    
    pendingStudents() {
      return this.students.filter(s => !s.paymentStatus || s.paymentStatus === 'Pending').length;
    },
    
    idCardGenerated() {
      return this.students.filter(s => s.paymentStatus === 'Paid').length;
    }
  },
  mounted() {
    this.loadData();
  },
  methods: {
    async loadData() {
      this.loading = true;
      this.error = null;
      
      try {
        // Get all documents from parent_students collection
        const querySnapshot = await getDocs(collection(db, "parent_students"));
        
        const allStudents = [];
        
        querySnapshot.forEach(docSnap => {
          const docData = docSnap.data();
          
          // Check for students array
          const studentsArray = docData.students || [];
          
          if (Array.isArray(studentsArray) && studentsArray.length > 0) {
            studentsArray.forEach(student => {
              allStudents.push({
                studentId: student.studentId || `student_${Date.now()}`,
                name: student.name || 'Unknown Student',
                email: student.studentEmail || student.email || 'N/A',
                grade: student.grade || 'N/A',
                transactionID: student.transactionID || 'N/A',
                amount: student.amount || 0,
                paymentStatus: student.paymentStatus || 'Pending',
                updatedAt: student.updatedAt || new Date()
              });
            });
          }
        });
        
        this.students = allStudents;
        
        if (allStudents.length === 0) {
          this.error = "No student records found in the database.";
        }
        
      } catch (err) {
        console.error("Error loading students:", err);
        this.error = "Failed to load students. Please check your connection and try again.";
      } finally {
        this.loading = false;
      }
    },
    
    getInitials(name) {
      if (!name) return "??";
      return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
    },
    
    getPaymentStatusClass(status) {
      if (!status) return 'status-pending';
      
      switch(status.toLowerCase()) {
        case 'paid': return 'status-paid';
        case 'rejected': return 'status-rejected';
        default: return 'status-pending';
      }
    },
    
    approvePayment(student) {
      if (confirm(`Approve payment for ${student.name}?`)) {
        // TODO: Implement approve payment logic
        alert(`Payment approved for ${student.name}`);
      }
    },
    
    rejectPayment(student) {
      if (confirm(`Reject payment for ${student.name}?`)) {
        // TODO: Implement reject payment logic
        alert(`Payment rejected for ${student.name}`);
      }
    },
    
    clearFilters() {
      this.searchQuery = '';
      this.statusFilter = '';
    }
  }
};
</script>

<style scoped>
.students-container {
  padding: 24px;
  background: #f8fafc;
  min-height: 100vh;
}

/* Header Styles */
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 16px;
}

.header-left {
  flex: 1;
  min-width: 300px;
}

.header h1 {
  margin: 0;
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
}

.subtitle {
  margin: 4px 0 0;
  color: #64748b;
  font-size: 16px;
}

.header-right {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 300px;
}

.search-box {
  position: relative;
}

.search-input {
  width: 100%;
  padding: 10px 16px 10px 40px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 14px;
  background: white;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
  font-size: 14px;
}

.refresh-btn {
  padding: 10px 20px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
  align-self: flex-end;
}

.refresh-btn:hover:not(:disabled) {
  background: #2563eb;
  transform: translateY(-1px);
}

.refresh-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.spinner-small {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s ease-in-out infinite;
}

/* Stats Cards */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #e2e8f0;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  flex-shrink: 0;
}

.stat-icon.total { background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); color: white; }
.stat-icon.paid { background: linear-gradient(135deg, #10b981 0%, #34d399 100%); color: white; }
.stat-icon.pending { background: linear-gradient(135deg, #f59e0b 0%, #fbbf24 100%); color: white; }
.stat-icon.id-card { background: linear-gradient(135deg, #8b5cf6 0%, #d946ef 100%); color: white; }

.stat-content {
  flex: 1;
}

.stat-value {
  margin: 0;
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
}

.stat-label {
  margin: 4px 0 0;
  color: #64748b;
  font-size: 14px;
  font-weight: 500;
}

/* Main Content */
.main-content {
  margin-top: 24px;
}

/* Error Message */
.error-message {
  background: #fee2e2;
  border: 1px solid #fecaca;
  border-radius: 10px;
  padding: 20px;
  margin-bottom: 24px;
  display: flex;
  align-items: flex-start;
  gap: 16px;
  animation: fadeIn 0.3s ease;
}

.error-icon {
  font-size: 24px;
  flex-shrink: 0;
  margin-top: 2px;
}

.error-content {
  flex: 1;
}

.error-content h4 {
  margin: 0 0 8px;
  color: #991b1b;
  font-size: 18px;
  font-weight: 600;
}

.error-content p {
  margin: 0 0 16px;
  color: #7f1d1d;
  font-size: 14px;
  line-height: 1.5;
}

.retry-btn {
  padding: 8px 20px;
  background: #ef4444;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.retry-btn:hover {
  background: #dc2626;
  transform: translateY(-1px);
}

/* Table Container */
.table-container {
  background: white;
  border-radius: 12px;
  padding: 0;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #e2e8f0;
  overflow: hidden;
}

.table-header {
  padding: 24px 24px 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 16px;
}

.table-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #1e293b;
}

.table-actions {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.records-count {
  color: #64748b;
  font-size: 14px;
  font-weight: 500;
  white-space: nowrap;
}

.filter-select {
  padding: 8px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 6px;
  font-size: 14px;
  background: white;
  color: #475569;
  cursor: pointer;
  min-width: 140px;
  transition: all 0.3s ease;
}

.filter-select:focus {
  outline: none;
  border-color: #3b82f6;
}

/* Loading State */
.loading-state {
  text-align: center;
  padding: 60px 20px;
  border-top: 1px solid #e2e8f0;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #e2e8f0;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

.loading-state p {
  color: #64748b;
  font-size: 14px;
  margin: 0;
}

/* No Data State */
.no-data-state {
  text-align: center;
  padding: 60px 20px;
  border-top: 1px solid #e2e8f0;
}

.no-data-icon {
  font-size: 60px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.no-data-state h3 {
  margin: 0 0 8px;
  color: #64748b;
  font-size: 20px;
}

.no-data-state p {
  margin: 0 0 20px;
  color: #94a3b8;
  font-size: 14px;
}

/* Table Wrapper */
.table-wrapper {
  overflow-x: auto;
}

.students-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  min-width: 1000px;
}

.students-table thead {
  background: #f8fafc;
}

.students-table th {
  padding: 16px 20px;
  text-align: left;
  font-weight: 600;
  color: #475569;
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  border-bottom: 2px solid #e2e8f0;
  white-space: nowrap;
}

.students-table tbody tr {
  transition: all 0.3s ease;
  border-bottom: 1px solid #f1f5f9;
}

.students-table tbody tr:hover {
  background: #f8fafc;
}

.students-table tbody tr:last-child {
  border-bottom: none;
}

.students-table td {
  padding: 16px 20px;
  vertical-align: middle;
}

/* Student Column */
.student-info-cell {
  min-width: 220px;
}

.student-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.student-avatar {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  color: white;
  flex-shrink: 0;
  font-size: 14px;
}

.student-details {
  min-width: 0;
}

.student-name {
  margin: 0;
  font-weight: 600;
  color: #1e293b;
  font-size: 15px;
  line-height: 1.4;
}

.student-id {
  margin: 2px 0 0;
  font-size: 12px;
  color: #64748b;
}

/* Email Column */
.email-cell {
  min-width: 200px;
}

.email-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
}

.email-icon {
  opacity: 0.6;
  font-size: 14px;
  flex-shrink: 0;
}

.email-text {
  color: #475569;
  font-size: 14px;
  word-break: break-word;
}

/* Grade Column */
.grade-cell {
  min-width: 80px;
}

.grade-badge {
  padding: 6px 12px;
  background: #f1f5f9;
  color: #475569;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  display: inline-block;
  white-space: nowrap;
}

/* Payment Status Column */
.payment-cell {
  min-width: 120px;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  display: inline-block;
  white-space: nowrap;
}

.status-paid {
  background: #d1fae5;
  color: #065f46;
}

.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.status-rejected {
  background: #fee2e2;
  color: #991b1b;
}

/* Transaction Column */
.transaction-cell {
  min-width: 140px;
}

.transaction-id {
  background: #f1f5f9;
  padding: 6px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-family: 'Courier New', monospace;
  color: #475569;
  display: inline-block;
  max-width: 180px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* Amount Column */
.amount-cell {
  min-width: 100px;
}

.amount-value {
  font-weight: 600;
  color: #059669;
  font-size: 15px;
}

/* Actions Column */
.actions-cell {
  min-width: 160px;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
  white-space: nowrap;
}

.approve-btn {
  background: #10b981;
  color: white;
}

.approve-btn:hover:not(:disabled) {
  background: #059669;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.reject-btn {
  background: #ef4444;
  color: white;
}

.reject-btn:hover:not(:disabled) {
  background: #dc2626;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
  box-shadow: none !important;
}

.btn-icon {
  font-size: 12px;
}

/* No Results */
.no-results {
  text-align: center;
  padding: 40px 20px;
  border-top: 1px solid #e2e8f0;
}

.no-results-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.5;
}

.no-results h3 {
  margin: 0 0 8px;
  color: #64748b;
  font-size: 18px;
}

.no-results p {
  margin: 0 0 16px;
  color: #94a3b8;
  font-size: 14px;
}

.clear-filters-btn {
  padding: 8px 20px;
  background: #f1f5f9;
  color: #475569;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.clear-filters-btn:hover {
  background: #e2e8f0;
  transform: translateY(-1px);
}

/* Animations */
@keyframes spin {
  to { transform: rotate(360deg); }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Responsive Design */
@media (max-width: 1024px) {
  .header {
    flex-direction: column;
  }
  
  .header-left,
  .header-right {
    width: 100%;
  }
  
  .stats-cards {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .students-container {
    padding: 16px;
  }
  
  .stats-cards {
    grid-template-columns: 1fr;
  }
  
  .table-actions {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .filter-select {
    width: 100%;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .action-btn {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .search-input {
    font-size: 16px; /* Prevents zoom on iOS */
  }
  
  .header h1 {
    font-size: 24px;
  }
  
  .stat-card {
    padding: 16px;
  }
  
  .stat-value {
    font-size: 24px;
  }
}
</style>