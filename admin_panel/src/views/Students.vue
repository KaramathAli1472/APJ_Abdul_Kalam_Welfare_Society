<template>
  <div class="students-container">
    <!-- Header Section -->
    <div class="header-section">
      <div class="header-left">
        <h1 class="page-title">Students Management</h1>
        <p class="page-subtitle">Manage student records, payments and ID Cards</p>
      </div>
      <div class="header-right">
        <div class="search-box">
          <input v-model="searchQuery" type="text" placeholder="Search students..." class="search-input">
          <span class="search-icon">🔍</span>
        </div>
        <div class="header-actions">
          <button class="action-btn export-btn" @click="exportCSV">
            <span class="btn-icon">📤</span>
            <span class="btn-text">Export</span>
          </button>
          <select v-model="filterBy" class="filter-select">
            <option value="">All Status</option>
            <option value="Paid">Paid</option>
            <option value="Pending">Pending</option>
            <option value="Rejected">Rejected</option>
          </select>
          <button class="action-btn refresh-btn" @click="refreshStudents">
            <span class="btn-icon">🔄</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-cards" v-if="!error">
      <div class="stat-card" v-for="stat in stats" :key="stat.label" :class="stat.type">
        <div class="stat-icon">{{ stat.icon }}</div>
        <div class="stat-content">
          <h3 class="stat-value">{{ stat.value }}</h3>
          <p class="stat-label">{{ stat.label }}</p>
        </div>
      </div>
    </div>

    <!-- Students Table -->
    <div class="table-container" v-if="!error">
      <div class="table-header">
        <h3 class="table-title">Students List</h3>
        <div class="records-count">
          Showing {{ filteredStudents.length }} of {{ students.length }} students
        </div>
      </div>

      <div class="table-wrapper" v-if="!loading && filteredStudents.length > 0">
        <table class="students-table">
          <thead>
            <tr>
              <th>Student</th>
              <th>Email</th>
              <th>Grade</th>
              <th>Payment</th>
              <th>ID Card</th>
              <th>Updated</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="student in filteredStudents" :key="student.studentId">
              <!-- Student Info -->
              <td class="student-info">
                <div class="student-avatar">
                  <img v-if="student.photoUrl" :src="student.photoUrl" :alt="student.name" 
                       @error="handleAvatarError($event, student)" class="avatar-img">
                  <span v-else class="avatar-initials">{{ getInitials(student.name) }}</span>
                </div>
                <div class="student-details">
                  <p class="student-name">{{ student.name }}</p>
                  <p class="student-id">ID: {{ student.registrationNumber || student.studentId?.slice(0, 8) || 'N/A' }}</p>
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
                <span class="grade-badge">{{ student.grade || 'N/A' }}</span>
              </td>
              
              <!-- Payment Status -->
              <td class="payment-cell">
                <span :class="['status-badge', getPaymentStatusClass(student.paymentStatus)]">
                  {{ formatPaymentStatus(student.paymentStatus) }}
                </span>
              </td>
              
              <!-- ID Card Status -->
              <td class="idcard-cell">
                <div v-if="student.idCardGenerated" class="idcard-generated">
                  <div class="idcard-status">
                    <div class="status-icon">✅</div>
                    <span class="status-text">Generated</span>
                  </div>
                  <div class="idcard-actions">
                    <button class="icon-btn download-btn" @click="downloadIDCard(student)" title="Download ID Card">
                      ⬇️
                    </button>
                    <button class="icon-btn view-btn" @click="viewIDCard(student)" title="View ID Card">
                      👁️
                    </button>
                  </div>
                </div>
                <div v-else class="idcard-pending">
                  <div class="idcard-status">
                    <div class="status-icon">⏳</div>
                    <span class="status-text">Not Generated</span>
                  </div>
                  <button v-if="student.paymentStatus === 'Paid' || student.paymentStatus === 'verified'" 
                          class="generate-btn" @click="generateIDCard(student)">
                    Generate
                  </button>
                </div>
              </td>
              
              <!-- Date -->
              <td class="date-cell">
                {{ formatDateShort(student.updatedAt) }}
              </td>
              
              <!-- Actions -->
              <td class="actions-cell">
                <div class="action-buttons">
                  <button @click="approvePayment(student.studentId, student.transactionID)" 
                    class="action-btn approve-btn" 
                    :disabled="student.paymentStatus === 'Paid' || student.paymentStatus === 'verified'" 
                    title="Approve Payment">
                    ✓
                  </button>
                  <button @click="rejectPayment(student.studentId, student.transactionID)" 
                    class="action-btn reject-btn" 
                    :disabled="student.paymentStatus === 'Rejected'" 
                    title="Reject Payment">
                    ✗
                  </button>
                  <button class="action-btn view-btn" @click="viewStudentDetails(student)" title="View Details">
                    👁️
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Empty States -->
      <div v-if="!loading && filteredStudents.length === 0" class="no-results">
        <div class="no-results-icon">📭</div>
        <h3>No students found</h3>
        <button v-if="searchQuery || filterBy" @click="clearFilters" class="clear-filters-btn">
          Clear Filters
        </button>
      </div>

      <div v-if="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Loading students...</p>
      </div>
    </div>

    <!-- ID Card Modal -->
    <div v-if="showIDCardModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>ID Card Preview - {{ selectedStudent?.name }}</h3>
          <button class="modal-close" @click="closeModal">×</button>
        </div>
        
        <div class="idcard-preview">
          <!-- Improved ID Card Design -->
          <div class="idcard-design" :id="'idcard-' + selectedStudent?.studentId">
            <div class="idcard-header">
              <div class="school-logo">
                <div class="logo-circle">🏫</div>
              </div>
              <div class="school-info">
                <h4 class="school-name">A.P.J Abdul Kalam Welfare Society</h4>
                <p class="school-address">Registered Under Society Act 1860</p>
                <p class="idcard-title">STUDENT IDENTITY CARD</p>
              </div>
            </div>
            
            <div class="idcard-body">
              <div class="student-photo-section">
                <div class="photo-frame">
                  <!-- Firebase Photo or Initials -->
                  <div v-if="selectedStudent?.photoUrl" class="student-photo">
                    <img 
                      :src="selectedStudent.photoUrl" 
                      :alt="selectedStudent.name"
                      @error="handlePhotoError"
                      class="photo-img"
                    />
                  </div>
                  <div v-else class="photo-placeholder">
                    {{ getInitials(selectedStudent?.name) }}
                  </div>
                </div>
                <div class="validity">
                  <p class="valid-label">VALID UPTO</p>
                  <p class="valid-date">31 DEC 2026</p>
                </div>
              </div>
              
              <div class="student-details-section">
                <div class="detail-row">
                  <span class="detail-label">NAME:</span>
                  <span class="detail-value">{{ selectedStudent?.name }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">FATHER'S NAME:</span>
                  <span class="detail-value">{{ selectedStudent?.fatherName || 'N/A' }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">GRADE:</span>
                  <span class="detail-value">{{ selectedStudent?.grade }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">STUDENT ID:</span>
                  <span class="detail-value id-number">{{ selectedStudent?.registrationNumber || selectedStudent?.studentId }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">PHONE:</span>
                  <span class="detail-value">{{ selectedStudent?.phone || selectedStudent?.mobile || 'N/A' }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">EMAIL:</span>
                  <span class="detail-value">{{ selectedStudent?.email }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">SCHOOL:</span>
                  <span class="detail-value">{{ selectedStudent?.school || 'N/A' }}</span>
                </div>
              </div>
            </div>
            
            <div class="idcard-footer">
              <div class="barcode-section">
                <div class="barcode-placeholder">
                  <div class="barcode-lines"></div>
                  <div class="barcode-number">{{ (selectedStudent?.registrationNumber || selectedStudent?.studentId)?.slice(0, 12) || 'STUDENTID' }}</div>
                </div>
              </div>
              <div class="signature-section">
                <p class="signature-label">AUTHORIZED SIGNATURE</p>
                <div class="signature-line"></div>
                <p class="principal-name">Principal</p>
              </div>
            </div>
            
            <div class="security-features">
              <div class="hologram">✦</div>
              <div class="watermark">APJ</div>
            </div>
          </div>
        </div>
        
        <div class="modal-actions">
          <button class="modal-btn print-btn" @click="printIDCard">
            🖨️ Print
          </button>
          <button class="modal-btn download-btn" @click="downloadIDCard(selectedStudent)">
            ⬇️ Download
          </button>
          <button class="modal-btn close-btn" @click="closeModal">
            ✕ Close
          </button>
        </div>
      </div>
    </div>

    <!-- Student Details Modal -->
    <div v-if="showStudentDetailsModal" class="modal-overlay" @click="closeStudentDetailsModal">
      <div class="modal-content details-modal" @click.stop>
        <div class="modal-header">
          <h3>Student Details</h3>
          <button class="modal-close" @click="closeStudentDetailsModal">×</button>
        </div>
        
        <div class="student-details-content">
          <div class="student-profile">
            <div class="profile-avatar">
              <img v-if="selectedStudent?.photoUrl" :src="selectedStudent.photoUrl" 
                   :alt="selectedStudent.name" @error="handleProfileAvatarError" class="profile-img">
              <span v-else>{{ getInitials(selectedStudent?.name) }}</span>
            </div>
            <div class="profile-info">
              <h4>{{ selectedStudent?.name }}</h4>
              <p class="student-id">ID: {{ selectedStudent?.registrationNumber || selectedStudent?.studentId }}</p>
            </div>
          </div>
          
          <div class="details-grid">
            <div class="detail-item">
              <label>Father's Name</label>
              <p>{{ selectedStudent?.fatherName || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label>Phone Number</label>
              <p>{{ selectedStudent?.phone || selectedStudent?.mobile || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label>Email</label>
              <p>{{ selectedStudent?.email || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label>Grade</label>
              <p>{{ selectedStudent?.grade || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label>School</label>
              <p>{{ selectedStudent?.school || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label>Payment Status</label>
              <p :class="getPaymentStatusClass(selectedStudent?.paymentStatus)">
                {{ formatPaymentStatus(selectedStudent?.paymentStatus) }}
              </p>
            </div>
            <div class="detail-item">
              <label>Transaction ID</label>
              <p class="transaction-id">{{ selectedStudent?.transactionID || 'N/A' }}</p>
            </div>
            <div class="detail-item">
              <label>Registration Date</label>
              <p>{{ formatDateShort(selectedStudent?.registrationDate) }}</p>
            </div>
            <div class="detail-item full-width" v-if="selectedStudent?.idCardGenerated">
              <label>ID Card Status</label>
              <div class="idcard-status-details">
                <span class="status-badge success">Generated</span>
                <span class="idcard-date">on {{ formatDateShort(selectedStudent?.idCardGeneratedDate) }}</span>
                <button class="view-idcard-btn" @click="viewIDCard(selectedStudent)">
                  View ID Card
                </button>
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-actions">
          <button class="modal-btn close-btn" @click="closeStudentDetailsModal">
            Close
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { db } from "../firebase/firebase";
import { collection, getDocs, setDoc, doc } from "firebase/firestore";
import { approvePayment, rejectPayment } from "../services/paymentService";

export default {
  name: 'StudentsList',
  data() {
    return {
      students: [],
      searchQuery: '',
      filterBy: '',
      loading: true,
      error: null,
      selectedStudent: null,
      showIDCardModal: false,
      showStudentDetailsModal: false,
    };
  },
  async created() {
    await this.fetchStudents();
  },
  computed: {
    filteredStudents() {
      let filtered = this.students;
      
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filtered = filtered.filter(student => 
          (student.name || '').toLowerCase().includes(query) ||
          (student.email || '').toLowerCase().includes(query) ||
          (student.grade || '').toLowerCase().includes(query) ||
          (student.fatherName || '').toLowerCase().includes(query) ||
          (student.registrationNumber || '').toLowerCase().includes(query) ||
          (student.phone || '').toLowerCase().includes(query) ||
          (student.school || '').toLowerCase().includes(query)
        );
      }
      
      if (this.filterBy) {
        filtered = filtered.filter(student => {
          const status = this.formatPaymentStatus(student.paymentStatus).toLowerCase();
          return status === this.filterBy.toLowerCase();
        });
      }
      
      return filtered;
    },
    stats() {
      const paidCount = this.students.filter(s => 
        s.paymentStatus === 'Paid' || s.paymentStatus === 'verified').length;
      const pendingCount = this.students.filter(s => 
        !s.paymentStatus || s.paymentStatus === 'Pending' || s.paymentStatus === 'pending').length;
      
      return [
        { icon: '👥', label: 'Total Students', value: this.students.length, type: 'total' },
        { icon: '💰', label: 'Paid Students', value: paidCount, type: 'paid' },
        { icon: '⏳', label: 'Pending Payments', value: pendingCount, type: 'pending' },
        { icon: '🪪', label: 'ID Cards Generated', value: this.students.filter(s => s.idCardGenerated).length, type: 'id-card' }
      ];
    }
  },
  methods: {
    async fetchStudents() {
      this.loading = true;
      this.error = null;
      
      try {
        const studentsRef = collection(db, "students");
        const studentsSnapshot = await getDocs(studentsRef);
        
        if (studentsSnapshot.docs.length === 0) {
          this.error = 'No students found';
          this.students = [];
          return;
        }
        
        const studentsData = [];
        studentsSnapshot.forEach(doc => {
          const data = doc.data();
          console.log('📄 Student Document:', doc.id, data);
          studentsData.push({ 
            id: doc.id, 
            ...data,
            // Store document ID as studentId if not present
            studentId: data.studentId || data.studentAuthUid || data.parentUserId || doc.id
          });
        });
        
        console.log('📊 Raw Firebase Data:', studentsData);
        
        // Get ID cards data
        let idCardsData = {};
        try {
          const idCardsSnapshot = await getDocs(collection(db, "student_id_cards"));
          idCardsSnapshot.forEach(doc => {
            const data = doc.data();
            if (data.studentId) {
              idCardsData[data.studentId] = data;
            }
          });
          console.log('📋 ID Cards Data:', idCardsData);
        } catch (idError) {
          console.log('ID cards collection not found:', idError);
        }
        
        this.students = studentsData.map(student => {
          console.log('Processing student:', student.name, 'Photo URL:', student.photoUrl);
          
          const studentId = student.studentId || student.id;
          const idCardInfo = idCardsData[studentId] || {};
          
          return {
            // Student Info
            studentId: studentId,
            name: student.name || student.studentName || 'Unknown',
            email: student.email || student.studentEmail || student.contactEmail || 'N/A',
            grade: student.grade || student.class || student.standard || 'N/A',
            fatherName: student.fatherName || student.father_name || student.parentName || 'N/A',
            phone: student.phone || student.mobile || student.contact || student.phoneNumber || 'N/A',
            photoUrl: student.photoUrl || student.photo || student.profileImage || student.imageUrl || null,
            school: student.school || 'N/A',
            registrationNumber: student.registrationNumber || student.regNumber || 'N/A',
            registrationDate: student.registrationDate || student.createdAt,
            
            // Payment Info
            transactionID: student.transactionID || student.transactionId || student.transactionID || 'N/A',
            amount: Number(student.amount) || Number(student.fee) || 0,
            paymentStatus: student.paymentStatus || student.status || 'Pending',
            
            // Dates
            updatedAt: student.updatedAt || student.createdAt || new Date(),
            
            // ID Card Info
            idCardGenerated: !!idCardInfo.generated || student.idCardGenerated || false,
            idCardGeneratedDate: idCardInfo.generatedDate || student.idCardDate || null,
            idCardUrl: idCardInfo.downloadUrl || student.idCardUrl || null,
          };
        });
        
        console.log('✅ Processed Students:', this.students);
        
      } catch (error) {
        console.error('❌ Error fetching students:', error);
        this.error = `Database Error: ${error.message}`;
        this.students = [];
      } finally {
        this.loading = false;
      }
    },
    
    async refreshStudents() {
      await this.fetchStudents();
    },
    
    async approvePayment(studentId, transactionID) {
      if (!studentId || !transactionID) {
        this.showNotification('Student ID and Transaction ID required', 'error');
        return;
      }
      
      try {
        this.loading = true;
        await approvePayment(studentId, transactionID);
        this.showNotification('Payment approved successfully!', 'success');
        await this.fetchStudents();
      } catch (err) {
        this.showNotification(err.message || 'Error approving payment', 'error');
      } finally {
        this.loading = false;
      }
    },
    
    async rejectPayment(studentId, transactionID) {
      if (!studentId || !transactionID) {
        this.showNotification('Student ID and Transaction ID required', 'error');
        return;
      }
      
      try {
        this.loading = true;
        await rejectPayment(studentId, transactionID);
        this.showNotification('Payment rejected successfully!', 'success');
        await this.fetchStudents();
      } catch (err) {
        this.showNotification(err.message || 'Error rejecting payment', 'error');
      } finally {
        this.loading = false;
      }
    },
    
    async generateIDCard(student) {
      if (!(student.paymentStatus === 'Paid' || student.paymentStatus === 'verified')) {
        this.showNotification('Only paid/verified students can have ID Cards', 'error');
        return;
      }
      
      try {
        this.loading = true;
        
        const idCardData = {
          studentId: student.studentId,
          studentName: student.name,
          fatherName: student.fatherName,
          studentEmail: student.email,
          phone: student.phone,
          grade: student.grade,
          school: student.school,
          registrationNumber: student.registrationNumber,
          photoUrl: student.photoUrl,
          generated: true,
          generatedDate: new Date().toISOString(),
          validUntil: new Date(new Date().setFullYear(new Date().getFullYear() + 1)).toISOString(),
          status: 'active',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        };
        
        const idCardRef = doc(db, "student_id_cards", student.studentId);
        await setDoc(idCardRef, idCardData);
        
        this.showNotification(`ID Card generated for ${student.name}!`, 'success');
        await this.fetchStudents();
        // Auto open the ID Card modal after generation
        this.viewIDCard(student);
        
      } catch (err) {
        console.error('Error generating ID Card:', err);
        this.showNotification('Error generating ID Card: ' + err.message, 'error');
      } finally {
        this.loading = false;
      }
    },
    
    downloadIDCard(student) {
      if (!student) {
        student = this.selectedStudent;
      }
      
      if (!student?.idCardGenerated) {
        this.showNotification('ID Card not generated yet', 'error');
        return;
      }
      
      try {
        // Create PDF download
        const printContent = document.getElementById(`idcard-${student.studentId}`);
        if (printContent) {
          const printWindow = window.open('', '_blank');
          printWindow.document.write(`
            <html>
              <head>
                <title>ID Card - ${student.name}</title>
                <style>
                  body { margin: 0; padding: 20px; font-family: Arial, sans-serif; background: #f8fafc; }
                  @media print {
                    @page { size: A4; margin: 0; }
                    body { margin: 0; background: white; }
                  }
                  .idcard-design {
                    max-width: 500px;
                    margin: 0 auto;
                  }
                </style>
              </head>
              <body>
                ${printContent.outerHTML}
              </body>
            </html>
          `);
          printWindow.document.close();
          printWindow.focus();
          printWindow.print();
          printWindow.close();
        }
        
        this.showNotification('ID Card downloaded successfully!', 'success');
      } catch (err) {
        console.error('Error downloading ID Card:', err);
        this.showNotification('Failed to download ID Card', 'error');
      }
    },
    
    viewIDCard(student) {
      if (!student?.idCardGenerated) {
        this.showNotification('ID Card not generated yet', 'error');
        return;
      }
      this.selectedStudent = student;
      this.showIDCardModal = true;
    },
    
    viewStudentDetails(student) {
      this.selectedStudent = student;
      this.showStudentDetailsModal = true;
    },
    
    printIDCard() {
      const printContent = document.getElementById(`idcard-${this.selectedStudent?.studentId}`);
      if (printContent) {
        const printWindow = window.open('', '_blank');
        printWindow.document.write(`
          <html>
            <head>
              <title>ID Card - ${this.selectedStudent?.name}</title>
              <style>
                body { margin: 0; padding: 20px; font-family: Arial, sans-serif; background: #f8fafc; }
                @media print {
                  @page { size: A4; margin: 0; }
                  body { margin: 0; background: white; }
                }
                .idcard-design {
                  max-width: 500px;
                  margin: 0 auto;
                }
              </style>
            </head>
            <body>
              ${printContent.outerHTML}
            </body>
          </html>
        `);
        printWindow.document.close();
        printWindow.focus();
        printWindow.print();
        printWindow.close();
      }
    },
    
    closeModal() {
      this.showIDCardModal = false;
      this.selectedStudent = null;
    },
    
    closeStudentDetailsModal() {
      this.showStudentDetailsModal = false;
      this.selectedStudent = null;
    },
    
    exportCSV() {
      if (this.students.length === 0) {
        this.showNotification('No students to export', 'error');
        return;
      }
      
      try {
        const headers = ['Name', 'Father Name', 'Email', 'Phone', 'Grade', 'School', 'Registration Number', 'Payment Status', 'Transaction ID', 'ID Card Generated'];
        const csvData = this.students.map(s => [
          s.name,
          s.fatherName || 'N/A',
          s.email,
          s.phone,
          s.grade,
          s.school,
          s.registrationNumber,
          this.formatPaymentStatus(s.paymentStatus),
          s.transactionID,
          s.idCardGenerated ? 'Yes' : 'No'
        ]);
        
        let csvContent = "data:text/csv;charset=utf-8,";
        csvContent += headers.join(",") + "\n";
        csvData.forEach(row => {
          csvContent += row.map(cell => `"${cell}"`).join(",") + "\n";
        });
        
        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", `students_${new Date().toISOString().split('T')[0]}.csv`);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        this.showNotification('CSV exported successfully!', 'success');
      } catch (err) {
        this.showNotification('Error exporting CSV', 'error');
      }
    },
    
    clearFilters() {
      this.searchQuery = '';
      this.filterBy = '';
    },
    
    formatDateShort(timestamp) {
      if (!timestamp) return "";
      try {
        let date;
        if (timestamp.seconds) {
          date = new Date(timestamp.seconds * 1000);
        } else if (timestamp instanceof Date) {
          date = timestamp;
        } else {
          date = new Date(timestamp);
        }
        
        if (isNaN(date.getTime())) return "";
        
        return date.toLocaleDateString('en-US', { 
          month: 'short', 
          day: 'numeric',
          year: 'numeric'
        });
      } catch (e) {
        console.error('Date formatting error:', e);
        return "";
      }
    },
    
    formatPaymentStatus(status) {
      if (!status) return 'Pending';
      
      const statusLower = status.toLowerCase();
      if (statusLower === 'paid' || statusLower === 'verified') {
        return 'Paid';
      } else if (statusLower === 'rejected') {
        return 'Rejected';
      } else {
        return 'Pending';
      }
    },
    
    getInitials(name) {
      if (!name) return "??";
      return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
    },
    
    getPaymentStatusClass(status) {
      if (!status) return 'status-pending';
      const formattedStatus = this.formatPaymentStatus(status).toLowerCase();
      
      switch(formattedStatus) {
        case 'paid': return 'status-paid';
        case 'rejected': return 'status-rejected';
        default: return 'status-pending';
      }
    },
    
    handleAvatarError(event, student) {
      console.log('Avatar image error for:', student.name, 'URL:', event.target.src);
      event.target.style.display = 'none';
      const parent = event.target.parentElement;
      const initials = this.getInitials(student.name);
      
      // Check if initials span already exists
      if (!parent.querySelector('.avatar-initials')) {
        const span = document.createElement('span');
        span.className = 'avatar-initials';
        span.textContent = initials;
        parent.appendChild(span);
      }
    },
    
    handlePhotoError(event) {
      console.log('ID Card photo error, showing placeholder');
      const parent = event.target.parentElement;
      event.target.style.display = 'none';
      
      // Create placeholder if not exists
      if (!parent.querySelector('.photo-placeholder')) {
        const placeholder = document.createElement('div');
        placeholder.className = 'photo-placeholder';
        placeholder.textContent = this.getInitials(this.selectedStudent?.name);
        parent.appendChild(placeholder);
      }
    },
    
    handleProfileAvatarError(event) {
      console.log('Profile avatar error, showing initials');
      const parent = event.target.parentElement;
      event.target.style.display = 'none';
      
      // Show initials
      if (!parent.querySelector('span')) {
        const span = document.createElement('span');
        span.textContent = this.getInitials(this.selectedStudent?.name);
        parent.appendChild(span);
      }
    },
    
    showNotification(message, type) {
      // Create toast notification
      const toast = document.createElement('div');
      toast.className = `toast-notification toast-${type}`;
      toast.innerHTML = `
        <div class="toast-icon">${type === 'success' ? '✅' : '❌'}</div>
        <div class="toast-message">${message}</div>
      `;
      
      document.body.appendChild(toast);
      
      // Position the toast
      toast.style.position = 'fixed';
      toast.style.top = '20px';
      toast.style.right = '20px';
      toast.style.zIndex = '10000';
      
      // Remove after 3 seconds
      setTimeout(() => {
        if (toast.parentNode) {
          toast.parentNode.removeChild(toast);
        }
      }, 3000);
    }
  }
};
</script>

<style scoped>
/* Main Container */
.students-container {
  padding: 20px;
  background: #f8fafc;
  min-height: 100vh;
}

/* Header */
.header-section {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 30px;
  gap: 20px;
}

.header-left {
  flex: 1;
}

.page-title {
  margin: 0;
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
}

.page-subtitle {
  margin: 5px 0 0;
  color: #64748b;
}

.header-right {
  display: flex;
  flex-direction: column;
  gap: 15px;
  min-width: 300px;
}

.search-box {
  position: relative;
}

.search-input {
  width: 100%;
  padding: 10px 15px 10px 40px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 14px;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: #4F46E5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
}

.header-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.action-btn {
  padding: 8px 15px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: all 0.3s ease;
}

.export-btn {
  background: #f1f5f9;
  color: #475569;
  border: 1px solid #e2e8f0;
}

.export-btn:hover {
  background: #e2e8f0;
  transform: translateY(-2px);
}

.refresh-btn {
  background: #4F46E5;
  color: white;
  padding: 8px 12px;
}

.refresh-btn:hover {
  background: #4338CA;
  transform: translateY(-2px);
}

.filter-select {
  padding: 8px 15px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background: white;
  color: #475569;
  cursor: pointer;
  min-width: 140px;
  transition: all 0.3s ease;
}

.filter-select:focus {
  outline: none;
  border-color: #4F46E5;
}

/* Stats Cards */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  border: 1px solid #e2e8f0;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 20px rgba(0,0,0,0.1);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.stat-card.total .stat-icon { background: #4F46E5; color: white; }
.stat-card.paid .stat-icon { background: #10b981; color: white; }
.stat-card.pending .stat-icon { background: #f59e0b; color: white; }
.stat-card.id-card .stat-icon { background: #8b5cf6; color: white; }

.stat-value {
  margin: 0;
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
}

.stat-label {
  margin: 5px 0 0;
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
}

/* Table */
.table-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  border: 1px solid #e2e8f0;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.table-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
}

.records-count {
  color: #64748b;
  font-size: 13px;
  font-weight: 500;
}

.table-wrapper {
  overflow-x: auto;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
}

.students-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 1000px;
}

.students-table th {
  padding: 12px 15px;
  text-align: left;
  font-weight: 600;
  color: #475569;
  font-size: 13px;
  border-bottom: 2px solid #e2e8f0;
  background: #f8fafc;
}

.students-table td {
  padding: 15px;
  border-bottom: 1px solid #f1f5f9;
  vertical-align: middle;
}

.students-table tbody tr:hover {
  background: #f8fafc;
}

.students-table tbody tr:last-child td {
  border-bottom: none;
}

/* Student Info */
.student-info {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 200px;
}

.student-avatar {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: #4F46E5;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  flex-shrink: 0;
  overflow: hidden;
  position: relative;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  position: absolute;
  top: 0;
  left: 0;
}

.avatar-initials {
  font-size: 14px;
  font-weight: bold;
  z-index: 1;
}

.student-name {
  margin: 0;
  font-weight: 600;
  font-size: 14px;
  color: #1e293b;
}

.student-id {
  margin: 3px 0 0;
  font-size: 12px;
  color: #64748b;
}

/* Email */
.email-cell {
  min-width: 180px;
}

.email-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
}

.email-icon {
  font-size: 14px;
  opacity: 0.7;
}

.email-text {
  font-size: 14px;
  color: #475569;
}

/* Grade */
.grade-cell {
  min-width: 80px;
}

.grade-badge {
  padding: 5px 10px;
  background: #f1f5f9;
  color: #475569;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  border: 1px solid #e2e8f0;
}

/* Payment Status */
.payment-cell {
  min-width: 120px;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  display: inline-block;
  text-align: center;
  min-width: 80px;
}

.status-paid {
  background: #d1fae5;
  color: #065f46;
  border: 1px solid #86efac;
}

.status-pending {
  background: #fef3c7;
  color: #92400e;
  border: 1px solid #fcd34d;
}

.status-rejected {
  background: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
}

/* ID Card Column */
.idcard-cell {
  min-width: 180px;
}

.idcard-generated, .idcard-pending {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.idcard-status {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-icon {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  flex-shrink: 0;
}

.idcard-generated .status-icon {
  background: #d1fae5;
  color: #10b981;
}

.idcard-pending .status-icon {
  background: #fef3c7;
  color: #f59e0b;
}

.status-text {
  font-size: 13px;
  font-weight: 500;
  color: #475569;
}

.idcard-actions {
  display: flex;
  gap: 5px;
}

.icon-btn {
  width: 28px;
  height: 28px;
  border: none;
  border-radius: 6px;
  background: #f1f5f9;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  transition: all 0.2s;
  border: 1px solid #e2e8f0;
}

.icon-btn:hover {
  transform: translateY(-2px);
}

.download-btn:hover { 
  background: #3b82f6; 
  color: white;
  border-color: #3b82f6;
}

.view-btn:hover { 
  background: #10b981; 
  color: white;
  border-color: #10b981;
}

.generate-btn {
  padding: 6px 12px;
  background: #10b981;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  margin-top: 5px;
  transition: all 0.2s;
}

.generate-btn:hover {
  background: #059669;
  transform: translateY(-2px);
}

/* Date */
.date-cell {
  font-size: 13px;
  color: #64748b;
  white-space: nowrap;
  min-width: 100px;
}

/* Actions */
.actions-cell {
  min-width: 150px;
}

.action-buttons {
  display: flex;
  gap: 5px;
}

.action-buttons .action-btn {
  width: 32px;
  height: 32px;
  padding: 0;
  justify-content: center;
  border-radius: 6px;
  font-size: 14px;
  transition: all 0.2s;
}

.approve-btn {
  background: #10b981;
  color: white;
  border: none;
}

.approve-btn:hover:not(:disabled) {
  background: #059669;
  transform: translateY(-2px);
}

.reject-btn {
  background: #ef4444;
  color: white;
  border: none;
}

.reject-btn:hover:not(:disabled) {
  background: #dc2626;
  transform: translateY(-2px);
}

.view-btn {
  background: #f1f5f9;
  color: #475569;
  border: 1px solid #e2e8f0;
}

.view-btn:hover {
  background: #e2e8f0;
  transform: translateY(-2px);
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
}

/* Empty States */
.no-results, .loading-state {
  text-align: center;
  padding: 50px 20px;
  border-top: 1px solid #e2e8f0;
}

.no-results-icon {
  font-size: 50px;
  margin-bottom: 15px;
  opacity: 0.3;
}

.no-results h3 {
  margin: 0 0 10px;
  color: #64748b;
  font-size: 18px;
}

.clear-filters-btn {
  padding: 8px 20px;
  background: #4F46E5;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  margin-top: 15px;
  transition: all 0.2s;
}

.clear-filters-btn:hover {
  background: #4338CA;
  transform: translateY(-2px);
}

/* Loading */
.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #e2e8f0;
  border-top-color: #4F46E5;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

.loading-state p {
  color: #64748b;
  font-size: 14px;
  font-weight: 500;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Modal Styles */
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
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  background: white;
  border-radius: 16px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  animation: slideUp 0.3s ease;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

@keyframes slideUp {
  from { 
    opacity: 0;
    transform: translateY(20px);
  }
  to { 
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  padding: 24px;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #f8fafc;
  border-radius: 16px 16px 0 0;
}

.modal-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #1e293b;
}

.modal-close {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: #f1f5f9;
  border: none;
  color: #64748b;
  font-size: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.modal-close:hover {
  background: #ef4444;
  color: white;
  transform: rotate(90deg);
}

/* ID Card Preview */
.idcard-preview {
  padding: 24px;
  background: #f8fafc;
}

/* Improved ID Card Design */
.idcard-design {
  background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
  border-radius: 16px;
  padding: 25px;
  color: white;
  border: 3px solid white;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  position: relative;
  overflow: hidden;
  max-width: 500px;
  margin: 0 auto;
}

.idcard-design::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle at center, rgba(255,255,255,0.1) 0%, transparent 70%);
  animation: rotate 20s linear infinite;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.idcard-header {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid rgba(255,255,255,0.3);
  position: relative;
}

.school-logo {
  flex-shrink: 0;
}

.logo-circle {
  width: 70px;
  height: 70px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  color: #4F46E5;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.school-info {
  flex: 1;
}

.school-name {
  margin: 0;
  font-size: 18px;
  font-weight: 800;
  letter-spacing: 0.5px;
  color: white;
  line-height: 1.3;
}

.school-address {
  margin: 3px 0 0;
  font-size: 11px;
  color: #cbd5e1;
  font-weight: 500;
}

.idcard-title {
  margin: 5px 0 0;
  font-size: 14px;
  color: #fbbf24;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.idcard-body {
  display: flex;
  gap: 25px;
  margin-bottom: 20px;
}

.student-photo-section {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.photo-frame {
  width: 120px;
  height: 140px;
  background: white;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 4px solid #fbbf24;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  overflow: hidden;
  position: relative;
}

.student-photo {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: absolute;
  top: 0;
  left: 0;
}

.photo-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.photo-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 32px;
  font-weight: 900;
}

.validity {
  text-align: center;
  padding: 10px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  border: 2px solid rgba(255, 255, 255, 0.2);
}

.valid-label {
  margin: 0;
  font-size: 10px;
  color: #cbd5e1;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-weight: 600;
}

.valid-date {
  margin: 4px 0 0;
  font-size: 14px;
  font-weight: 900;
  color: #fbbf24;
}

.student-details-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.detail-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.detail-row:last-child {
  border-bottom: none;
}

.detail-label {
  font-weight: 700;
  min-width: 100px;
  font-size: 12px;
  color: #cbd5e1;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-value {
  font-size: 14px;
  font-weight: 600;
  color: white;
  flex: 1;
  word-break: break-word;
}

.id-number {
  font-family: 'Courier New', monospace;
  font-weight: 900;
  color: #fbbf24;
  letter-spacing: 1px;
}

.idcard-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 20px;
  border-top: 2px solid rgba(255, 255, 255, 0.2);
}

.barcode-section {
  flex: 1;
}

.barcode-placeholder {
  background: white;
  padding: 12px;
  border-radius: 8px;
  text-align: center;
  max-width: 180px;
}

.barcode-lines {
  height: 40px;
  background: linear-gradient(90deg, 
    #000 0%, #000 10%, transparent 10%, transparent 15%,
    #000 15%, #000 25%, transparent 25%, transparent 30%,
    #000 30%, #000 40%, transparent 40%, transparent 45%,
    #000 45%, #000 55%, transparent 55%, transparent 60%,
    #000 60%, #000 70%, transparent 70%, transparent 75%,
    #000 75%, #000 85%, transparent 85%, transparent 90%,
    #000 90%, #000 100%
  );
  margin-bottom: 6px;
}

.barcode-number {
  font-family: 'Courier New', monospace;
  font-size: 10px;
  font-weight: 900;
  color: #1e293b;
  letter-spacing: 1px;
}

.signature-section {
  text-align: center;
}

.signature-label {
  margin: 0 0 6px;
  font-size: 9px;
  color: #cbd5e1;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-weight: 600;
}

.signature-line {
  width: 120px;
  height: 2px;
  background: white;
  margin: 0 auto 4px;
}

.principal-name {
  margin: 0;
  font-size: 11px;
  font-weight: 700;
  color: white;
}

.security-features {
  position: absolute;
  top: 15px;
  right: 15px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.hologram {
  width: 30px;
  height: 30px;
  background: linear-gradient(45deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4, #feca57, #ff9ff3);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: bold;
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.watermark {
  font-size: 14px;
  font-weight: 900;
  color: rgba(255, 255, 255, 0.05);
  transform: rotate(-45deg);
  position: absolute;
  bottom: -20px;
  right: -20px;
  font-size: 80px;
  pointer-events: none;
}

/* Modal Actions */
.modal-actions {
  padding: 24px;
  border-top: 1px solid #e2e8f0;
  display: flex;
  gap: 10px;
  background: white;
  border-radius: 0 0 16px 16px;
}

.modal-btn {
  flex: 1;
  padding: 12px 16px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.2s;
}

.print-btn {
  background: #f1f5f9;
  color: #475569;
  border: 1px solid #e2e8f0;
}

.print-btn:hover {
  background: #e2e8f0;
  transform: translateY(-2px);
}

.download-btn {
  background: #3b82f6;
  color: white;
  border: 1px solid #3b82f6;
}

.download-btn:hover {
  background: #2563eb;
  transform: translateY(-2px);
}

.close-btn {
  background: #ef4444;
  color: white;
  border: 1px solid #ef4444;
}

.close-btn:hover {
  background: #dc2626;
  transform: translateY(-2px);
}

/* Student Details Modal */
.details-modal {
  max-width: 500px;
}

.student-details-content {
  padding: 24px;
}

.student-profile {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 25px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.profile-avatar {
  width: 70px;
  height: 70px;
  border-radius: 12px;
  background: #4F46E5;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: 700;
  overflow: hidden;
  flex-shrink: 0;
  position: relative;
}

.profile-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  position: absolute;
  top: 0;
  left: 0;
}

.profile-info h4 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: #1e293b;
}

.profile-info .student-id {
  margin: 5px 0 0;
  font-size: 14px;
  color: #64748b;
  font-family: 'Courier New', monospace;
  font-weight: 600;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.detail-item {
  padding: 15px;
  background: white;
  border-radius: 8px;
  border: 2px solid #f1f5f9;
  transition: all 0.2s;
}

.detail-item:hover {
  border-color: #e2e8f0;
  transform: translateY(-2px);
}

.detail-item.full-width {
  grid-column: 1 / -1;
}

.detail-item label {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-item p {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  color: #1e293b;
}

.transaction-id {
  font-family: 'Courier New', monospace;
  font-size: 12px;
  word-break: break-all;
  color: #475569;
}

.idcard-status-details {
  display: flex;
  align-items: center;
  gap: 15px;
  flex-wrap: wrap;
}

.status-badge.success {
  background: #10b981;
  color: white;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 700;
  border: none;
}

.idcard-date {
  color: #64748b;
  font-size: 14px;
  font-weight: 500;
}

.view-idcard-btn {
  padding: 8px 16px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.view-idcard-btn:hover {
  background: #2563eb;
  transform: translateY(-2px);
}

/* Toast Notifications */
.toast-notification {
  position: fixed;
  top: 20px;
  right: 20px;
  background: white;
  border-radius: 10px;
  padding: 15px 20px;
  box-shadow: 0 5px 20px rgba(0,0,0,0.15);
  display: flex;
  align-items: center;
  gap: 12px;
  z-index: 10000;
  animation: slideIn 0.3s ease;
  border-left: 5px solid;
  min-width: 250px;
  max-width: 350px;
}

.toast-success {
  border-left-color: #10b981;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border: 1px solid #86efac;
}

.toast-error {
  border-left-color: #ef4444;
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border: 1px solid #fca5a5;
}

.toast-icon {
  font-size: 20px;
  flex-shrink: 0;
}

.toast-message {
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
  flex: 1;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* Responsive */
@media (max-width: 768px) {
  .header-section {
    flex-direction: column;
  }
  
  .header-right {
    width: 100%;
  }
  
  .stats-cards {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .header-actions {
    flex-wrap: wrap;
  }
  
  .action-btn {
    flex: 1;
    min-width: 100px;
  }
  
  .idcard-body {
    flex-direction: column;
  }
  
  .student-photo-section {
    flex-direction: row;
    justify-content: center;
    gap: 30px;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .details-grid {
    grid-template-columns: 1fr;
  }
  
  .idcard-footer {
    flex-direction: column;
    gap: 15px;
    text-align: center;
  }
  
  .barcode-placeholder {
    max-width: 100%;
  }
  
  .students-table {
    min-width: 800px;
  }
}

@media (max-width: 480px) {
  .students-container {
    padding: 15px;
  }
  
  .stats-cards {
    grid-template-columns: 1fr;
  }
  
  .header-actions {
    flex-direction: column;
  }
  
  .filter-select, .action-btn {
    width: 100%;
  }
  
  .action-buttons {
    flex-direction: column;
    align-items: stretch;
  }
  
  .action-buttons .action-btn {
    width: 100%;
    height: 36px;
  }
  
  .idcard-design {
    padding: 15px;
  }
  
  .school-name {
    font-size: 16px;
  }
  
  .idcard-title {
    font-size: 12px;
  }
  
  .modal-content {
    width: 95%;
    max-width: 95%;
  }
}
</style>