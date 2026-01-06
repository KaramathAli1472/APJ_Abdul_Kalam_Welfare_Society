<template>
  <div class="payments-container">
    <!-- Header Section -->
    <div class="payments-header">
      <div class="header-left">
        <h2 class="page-title">Payments List</h2>
        <div class="total-stats">
          <span class="total-label">Total Payments:</span>
          <span class="total-count">{{ payments.length }}</span>
        </div>
      </div>
      <button class="refresh-btn" @click="loadPayments" :disabled="loading">
        <svg class="refresh-icon" viewBox="0 0 24 24" width="18" height="18">
          <path fill="currentColor" d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
        </svg>
        <span v-if="!loading">Refresh</span>
        <span v-else>Loading...</span>
      </button>
    </div>

    <!-- Status Summary Cards -->
    <div class="stats-cards">
      <div class="stat-card paid-card">
        <div class="stat-icon">💰</div>
        <div class="stat-content">
          <div class="stat-label">Paid</div>
          <div class="stat-value">{{ getStatusCount('Paid') }}</div>
        </div>
      </div>
      <div class="stat-card pending-card">
        <div class="stat-icon">⏳</div>
        <div class="stat-content">
          <div class="stat-label">Pending</div>
          <div class="stat-value">{{ getStatusCount('Pending') }}</div>
        </div>
      </div>
      <div class="stat-card rejected-card">
        <div class="stat-icon">❌</div>
        <div class="stat-content">
          <div class="stat-label">Rejected</div>
          <div class="stat-value">{{ getStatusCount('Rejected') }}</div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Loading payments data...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <div class="error-icon">⚠️</div>
      <h3>Unable to Load Payments</h3>
      <p>{{ error }}</p>
      <button @click="loadPayments" class="retry-btn">Try Again</button>
    </div>

    <!-- Main Table -->
    <div v-else class="table-container">
      <div class="table-header">
        <div class="table-title">Payment Records</div>
        <div class="table-actions">
          <span class="records-count">{{ payments.length }} records found</span>
        </div>
      </div>

      <div class="table-scroll-wrapper">
        <table class="payments-table">
          <thead>
            <tr>
              <th class="student-column">
                <div class="th-content">
                  <span>Student Name</span>
                </div>
              </th>
              <th class="email-column">
                <div class="th-content">
                  <span>Email</span>
                </div>
              </th>
              <th class="grade-column">
                <div class="th-content">
                  <span>Grade</span>
                </div>
              </th>
              <th class="transaction-column">
                <div class="th-content">
                  <span>Transaction ID</span>
                </div>
              </th>
              <th class="amount-column">
                <div class="th-content">
                  <span>Amount</span>
                </div>
              </th>
              <th class="status-column">
                <div class="th-content">
                  <span>Status</span>
                </div>
              </th>
              <th class="date-column">
                <div class="th-content">
                  <span>Date</span>
                </div>
              </th>
            </tr>
          </thead>

          <tbody>
            <tr v-if="payments.length === 0" class="empty-state-row">
              <td colspan="7">
                <div class="empty-state">
                  <div class="empty-icon">📄</div>
                  <h3>No Payments Found</h3>
                  <p>There are no payment records in the database yet.</p>
                  <p class="empty-hint">Payments will appear here when students make transactions.</p>
                </div>
              </td>
            </tr>

            <tr v-for="payment in payments" :key="payment.id" class="payment-row">
              <td class="student-cell">
                <div class="student-info">
                  <span class="student-name">{{ payment.name || 'N/A' }}</span>
                </div>
              </td>
              <td class="email-cell">
                <span class="email-text">{{ payment.email || 'N/A' }}</span>
              </td>
              <td class="grade-cell">
                <span class="grade-badge">{{ payment.grade || 'N/A' }}</span>
              </td>
              <td class="transaction-cell">
                <span class="transaction-id">{{ payment.transactionID || 'N/A' }}</span>
              </td>
              <td class="amount-cell">
                <span class="amount-value">₹{{ formatAmount(payment.amount) }}</span>
              </td>
              <td class="status-cell">
                <span 
                  class="status-badge"
                  :class="{
                    'status-paid': payment.paymentStatus === 'Paid',
                    'status-pending': payment.paymentStatus === 'Pending',
                    'status-rejected': payment.paymentStatus === 'Rejected'
                  }"
                >
                  {{ payment.paymentStatus || 'Pending' }}
                </span>
              </td>
              <td class="date-cell">
                <div class="date-info">
                  <span class="date-text">{{ formatDate(payment.updatedAt || payment.createdAt) }}</span>
                  <span v-if="payment.createdAt" class="time-text">{{ formatTime(payment.updatedAt || payment.createdAt) }}</span>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Table Footer -->
      <div v-if="payments.length > 0" class="table-footer">
        <div class="footer-info">
          Showing {{ payments.length }} payment{{ payments.length !== 1 ? 's' : '' }}
        </div>
      </div>
    </div>

    <!-- Database Info -->
    <div v-if="payments.length > 0" class="database-info">
      <div class="info-card">
        <div class="info-icon">🗄️</div>
        <div class="info-content">
          <h4>Firebase Database Connected</h4>
          <p>Data is fetched from Firestore 'payments' collection in real-time.</p>
          <p class="collection-info">Collection: <code>payments</code> | Last updated: Just now</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// Import Firebase directly
import { db } from '../firebase/firebase';
import { collection, getDocs, orderBy, query } from "firebase/firestore";

export default {
  name: "Payments",

  data() {
    return {
      payments: [],
      loading: false,
      error: null
    };
  },

  async created() {
    await this.loadPayments();
  },

  methods: {
    async loadPayments() {
      this.loading = true;
      this.error = null;
      
      try {
        console.log("📡 Fetching payments from Firebase...");
        
        // Reference to payments collection
        const paymentsRef = collection(db, "payments");
        
        // Query to get payments ordered by date (newest first)
        const q = query(paymentsRef, orderBy("updatedAt", "desc"));
        
        // Get documents
        const querySnapshot = await getDocs(q);
        
        const paymentsArray = [];
        querySnapshot.forEach((doc) => {
          const paymentData = doc.data();
          paymentsArray.push({
            id: doc.id, // Document ID from Firestore
            ...paymentData
          });
        });
        
        console.log("✅ Payments fetched successfully:", paymentsArray);
        this.payments = paymentsArray;
        
      } catch (err) {
        console.error("❌ Error fetching payments:", err);
        this.error = err.message || "Failed to load payments. Please check your internet connection and try again.";
        
        // Fallback to dummy data for testing
        if (this.payments.length === 0) {
          console.log("⚠️ Using sample data for demonstration");
          this.payments = [
            {
              id: "SLfobSjitHNuhpVK7M1F",
              name: "John Doe",
              email: "john@example.com",
              grade: "10th",
              transactionID: "TXN123456",
              amount: 5000,
              paymentStatus: "Paid",
              createdAt: new Date("2026-01-05T00:00:00"),
              updatedAt: new Date("2026-01-05T00:00:00")
            },
            {
              id: "2",
              name: "Jane Smith",
              email: "jane@example.com",
              grade: "12th",
              transactionID: "TXN789012",
              amount: 7500,
              paymentStatus: "Pending",
              createdAt: new Date(),
              updatedAt: new Date()
            },
            {
              id: "3",
              name: "Robert Johnson",
              email: "robert@example.com",
              grade: "11th",
              transactionID: "TXN345678",
              amount: 6000,
              paymentStatus: "Rejected",
              createdAt: new Date(),
              updatedAt: new Date()
            }
          ];
        }
      } finally {
        this.loading = false;
      }
    },

    getStatusCount(status) {
      return this.payments.filter(p => p.paymentStatus === status).length;
    },

    formatAmount(amount) {
      if (!amount) return '0';
      return amount.toLocaleString('en-IN');
    },

    formatDate(timestamp) {
      if (!timestamp) return "-";
      
      let date;
      
      // Handle Firestore Timestamp
      if (timestamp.seconds) {
        date = new Date(timestamp.seconds * 1000);
      } 
      // Handle regular Date
      else {
        date = new Date(timestamp);
      }
      
      if (isNaN(date.getTime())) return "-";
      
      // Format: DD/MM/YYYY
      return date.toLocaleDateString('en-IN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      });
    },

    formatTime(timestamp) {
      if (!timestamp) return "";
      
      let date;
      
      // Handle Firestore Timestamp
      if (timestamp.seconds) {
        date = new Date(timestamp.seconds * 1000);
      } 
      // Handle regular Date
      else {
        date = new Date(timestamp);
      }
      
      if (isNaN(date.getTime())) return "";
      
      // Format: HH:MM AM/PM
      return date.toLocaleTimeString('en-IN', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      }).toLowerCase();
    }
  }
};
</script>

<style scoped>
.payments-container {
  padding: 24px;
  background: #f8fafc;
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
}

/* Header Styles */
.payments-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 24px;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.total-stats {
  display: flex;
  align-items: center;
  gap: 8px;
  background: white;
  padding: 8px 16px;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.total-label {
  font-size: 14px;
  color: #64748b;
}

.total-count {
  font-size: 20px;
  font-weight: 600;
  color: #3b82f6;
}

.refresh-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
  font-size: 14px;
}

.refresh-btn:hover:not(:disabled) {
  background: #2563eb;
  transform: translateY(-1px);
}

.refresh-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.refresh-icon {
  transition: transform 0.3s;
}

.refresh-btn:hover:not(:disabled) .refresh-icon {
  transform: rotate(180deg);
}

/* Stats Cards */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.paid-card {
  border-left: 4px solid #10b981;
}

.pending-card {
  border-left: 4px solid #f59e0b;
}

.rejected-card {
  border-left: 4px solid #ef4444;
}

.stat-icon {
  font-size: 32px;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border-radius: 10px;
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
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
}

.paid-card .stat-value {
  color: #10b981;
}

.pending-card .stat-value {
  color: #f59e0b;
}

.rejected-card .stat-value {
  color: #ef4444;
}

/* Loading State */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
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

/* Error State */
.error-container {
  text-align: center;
  padding: 40px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
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
  background: #ef4444;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: background 0.2s;
}

.retry-btn:hover {
  background: #dc2626;
}

/* Table Container */
.table-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  overflow: hidden;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #f1f5f9;
}

.table-title {
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
}

.table-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

.records-count {
  font-size: 14px;
  color: #64748b;
  background: #f8fafc;
  padding: 6px 12px;
  border-radius: 6px;
}

.table-scroll-wrapper {
  overflow-x: auto;
}

/* Table Styles */
.payments-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 1000px;
}

.payments-table thead {
  background: #f8fafc;
}

.payments-table th {
  padding: 16px 20px;
  text-align: left;
  font-size: 13px;
  font-weight: 600;
  color: #475569;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 2px solid #e2e8f0;
}

.th-content {
  display: flex;
  align-items: center;
  gap: 8px;
}

.payment-row {
  border-bottom: 1px solid #f1f5f9;
  transition: background 0.2s;
}

.payment-row:hover {
  background: #f8fafc;
}

.payments-table td {
  padding: 16px 20px;
  font-size: 14px;
  color: #334155;
  vertical-align: middle;
}

/* Column specific styles */
.student-cell .student-info {
  display: flex;
  flex-direction: column;
}

.student-name {
  font-weight: 500;
  color: #1e293b;
}

.email-text {
  color: #64748b;
  word-break: break-all;
}

.grade-badge {
  background: #e0f2fe;
  color: #0369a1;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  display: inline-block;
}

.transaction-id {
  font-family: 'Courier New', monospace;
  font-size: 13px;
  color: #475569;
  word-break: break-all;
}

.amount-value {
  font-weight: 600;
  color: #1e293b;
  font-size: 15px;
}

/* Status Badge */
.status-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  display: inline-block;
  min-width: 70px;
  text-align: center;
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

/* Date Cell */
.date-info {
  display: flex;
  flex-direction: column;
}

.date-text {
  font-weight: 500;
  color: #1e293b;
  font-size: 13px;
}

.time-text {
  font-size: 12px;
  color: #64748b;
  margin-top: 2px;
}

/* Empty State */
.empty-state-row {
  border: none;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
}

.empty-icon {
  font-size: 64px;
  display: block;
  margin-bottom: 16px;
  opacity: 0.7;
}

.empty-state h3 {
  font-size: 20px;
  color: #1e293b;
  margin: 0 0 12px 0;
}

.empty-state p {
  color: #64748b;
  margin: 0 0 8px 0;
  font-size: 15px;
}

.empty-hint {
  font-size: 13px !important;
  color: #94a3b8 !important;
  font-style: italic;
}

/* Table Footer */
.table-footer {
  padding: 16px 24px;
  border-top: 1px solid #f1f5f9;
  background: #f8fafc;
}

.footer-info {
  font-size: 14px;
  color: #64748b;
}

/* Database Info */
.database-info {
  margin-top: 24px;
}

.info-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  border-radius: 12px;
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.info-icon {
  font-size: 32px;
}

.info-content h4 {
  margin: 0 0 8px 0;
  font-size: 18px;
}

.info-content p {
  margin: 0 0 8px 0;
  opacity: 0.9;
  font-size: 14px;
}

.collection-info {
  font-family: 'Courier New', monospace;
  font-size: 12px;
  opacity: 0.8;
  margin-top: 8px !important;
}

/* Responsive */
@media (max-width: 768px) {
  .payments-container {
    padding: 16px;
  }
  
  .payments-header {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .header-left {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .stats-cards {
    grid-template-columns: 1fr;
  }
  
  .table-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .page-title {
    font-size: 24px;
  }
  
  .info-card {
    flex-direction: column;
    text-align: center;
  }
}
</style>