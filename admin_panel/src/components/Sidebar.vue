<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <nav class="sidebar">
      <div class="sidebar-container">
        <!-- Sidebar Header -->
        <div class="sidebar-header">
          <div class="logo-container">
            <div class="logo-icon">⚙️</div>
            <div class="logo-text">
              <h3 class="logo-title">Admin Panel</h3>
              <p class="logo-subtitle">Management System</p>
            </div>
          </div>
          <div class="menu-toggle" @click="toggleMenu">
            <span class="toggle-icon">≡</span>
          </div>
        </div>

        <!-- Navigation Menu -->
        <ul class="nav-menu" :class="{ 'collapsed': isCollapsed }">
          <!-- Dashboard -->
          <li class="nav-item">
            <router-link to="/dashboard" class="nav-link" active-class="active">
              <span class="nav-icon">📊</span>
              <span class="nav-text">Dashboard</span>
            </router-link>
          </li>

          <!-- Student Management -->
          <li class="nav-item">
            <router-link to="/students" class="nav-link" active-class="active">
              <span class="nav-icon">👨‍🎓</span>
              <span class="nav-text">Students</span>
            </router-link>
          </li>

          <!-- 🔥 NEW: ID Cards Management -->
          <li class="nav-item">
             <router-link to="/id-card" class="nav-link" active-class="active">
    <span class="nav-icon">🪪</span>
    <span class="nav-text">ID Card Generator</span>
  </router-link>
          </li>

          <!-- Results Management -->
          <li class="nav-item">
            <router-link to="/results" class="nav-link" active-class="active">
              <span class="nav-icon">📈</span>
              <span class="nav-text">Results</span>
            </router-link>
          </li>

          <!-- Exam Management -->
          <li class="nav-item">
            <router-link to="/exams" class="nav-link" active-class="active">
              <span class="nav-icon">📝</span>
              <span class="nav-text">Exams</span>
            </router-link>
          </li>

          <!-- Payment Management -->
          <li class="nav-item">
            <router-link to="/payments" class="nav-link" active-class="active">
              <span class="nav-icon">💰</span>
              <span class="nav-text">Payments</span>
            </router-link>
          </li>

          <!-- Notifications -->
          <li class="nav-item">
            <router-link to="/notifications" class="nav-link" active-class="active">
              <span class="nav-icon">🔔</span>
              <span class="nav-text">Notifications</span>
            </router-link>
          </li>

          <!-- Syllabus Management -->
          <li class="nav-item">
            <router-link to="/syllabus/upload" class="nav-link" active-class="active">
              <span class="nav-icon">📚</span>
              <span class="nav-text">Upload Syllabus</span>
            </router-link>
          </li>
          <li class="nav-item">
            <router-link to="/syllabus/list" class="nav-link" active-class="active">
              <span class="nav-icon">📖</span>
              <span class="nav-text">Syllabus List</span>
            </router-link>
          </li>

          <!-- 🔥 NEW: ID Cards Section -->
          <div class="nav-divider" v-if="!isCollapsed">
            <span>ID Card Section</span>
          </div>
          
          <!-- ID Cards Sub-menu -->
          <div v-if="!isCollapsed" class="sub-menu">
            <li class="nav-item sub-item">
              <router-link to="/id-cards/generate" class="nav-link" active-class="active">
                <span class="nav-icon">🖨️</span>
                <span class="nav-text">Generate ID Cards</span>
              </router-link>
            </li>
            <li class="nav-item sub-item">
              <router-link to="/id-cards/manage" class="nav-link" active-class="active">
                <span class="nav-icon">✏️</span>
                <span class="nav-text">Manage ID Cards</span>
              </router-link>
            </li>
            <li class="nav-item sub-item">
              <router-link to="/id-cards/print" class="nav-link" active-class="active">
                <span class="nav-icon">🖨️</span>
                <span class="nav-text">Print ID Cards</span>
              </router-link>
            </li>
          </div>

          <!-- 🔥 NEW: More Results Options -->
          <div class="nav-divider" v-if="!isCollapsed">
            <span>Results Section</span>
          </div>
          
          <!-- Results Sub-menu -->
          <div v-if="!isCollapsed" class="sub-menu">
            <li class="nav-item sub-item">
              <router-link to="/results/upload" class="nav-link" active-class="active">
                <span class="nav-icon">📤</span>
                <span class="nav-text">Upload Results</span>
              </router-link>
            </li>
            <li class="nav-item sub-item">
              <router-link to="/results/manage" class="nav-link" active-class="active">
                <span class="nav-icon">✏️</span>
                <span class="nav-text">Manage Results</span>
              </router-link>
            </li>
            <li class="nav-item sub-item">
              <router-link to="/results/reports" class="nav-link" active-class="active">
                <span class="nav-icon">📋</span>
                <span class="nav-text">Result Reports</span>
              </router-link>
            </li>
          </div>

          <!-- Divider & Quick Actions -->
          <div class="nav-divider" v-if="!isCollapsed">
            <span>Quick Actions</span>
          </div>
          <div class="quick-actions" v-if="!isCollapsed">
            <button class="quick-btn" @click="generateIdCard">
              <span class="quick-icon">🪪</span>
              Generate ID Card
            </button>
            <button class="quick-btn" @click="exportResults">
              <span class="quick-icon">📤</span>
              Export Results
            </button>
            <button class="quick-btn" @click="generateReport">
              <span class="quick-icon">📋</span>
              Generate Report
            </button>
            <button class="quick-btn" @click="quickAddStudent">
              <span class="quick-icon">➕</span>
              Add Student
            </button>
          </div>

          <!-- User Profile with Logout -->
          <div class="user-profile" v-if="!isCollapsed">
            <div class="user-avatar">
              <img :src="userAvatar" alt="Admin" class="avatar-img">
              <div class="admin-badge">A</div>
            </div>
            <div class="user-info">
              <p class="user-name">{{ userName }}</p>
              <p class="user-role">
                <span class="role-badge">Administrator</span>
              </p>
              <p class="user-id">
                <span class="id-label">ID:</span> 
                <span class="id-value">{{ adminId }}</span>
              </p>
              <p class="user-status">
                <span class="status-dot online"></span> Online
              </p>
            </div>
            <div class="user-actions">
              <button class="user-action-btn" @click="viewProfile" title="View Profile">
                👤
              </button>
              <button class="user-action-btn" @click="showIdCard" title="Show ID Card">
                🪪
              </button>
              <button class="logout-btn" @click="logout">
                <span class="logout-icon">🚪</span>
                <span class="logout-text">Logout</span>
              </button>
            </div>
          </div>

          <!-- 🔥 Logout Button for Collapsed Sidebar -->
          <div class="logout-collapsed" v-if="isCollapsed">
            <button class="logout-btn-collapsed" @click="logout" title="Logout">
              <span class="logout-icon-collapsed">🚪</span>
            </button>
          </div>
        </ul>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content" :class="{ 'sidebar-collapsed': isCollapsed }">
      <slot></slot>
    </main>

    <!-- Logout Confirmation Modal -->
    <div v-if="showLogoutModal" class="logout-modal-overlay">
      <div class="logout-modal">
        <div class="modal-header">
          <h3>Confirm Logout</h3>
        </div>
        <div class="modal-body">
          <p>Are you sure you want to logout?</p>
          <div class="user-details">
            <div class="detail-item">
              <span class="detail-label">User ID:</span>
              <span class="detail-value">{{ adminId }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">Name:</span>
              <span class="detail-value">{{ userName }}</span>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="modal-btn cancel-btn" @click="cancelLogout">Cancel</button>
          <button class="modal-btn confirm-btn" @click="confirmLogout">Logout</button>
        </div>
      </div>
    </div>

    <!-- Quick Add Student Modal -->
    <div v-if="showQuickAddModal" class="quick-add-modal-overlay">
      <div class="quick-add-modal">
        <div class="modal-header">
          <h3>Quick Add Student</h3>
          <button class="close-modal" @click="closeQuickAddModal">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="submitQuickStudent">
            <div class="form-group">
              <label>Student ID *</label>
              <div class="input-with-action">
                <input 
                  type="text" 
                  v-model="quickStudent.studentId" 
                  placeholder="Enter or generate student ID" 
                  required
                  class="form-input"
                >
                <button type="button" class="generate-btn" @click="generateStudentId">
                  🔄 Generate
                </button>
              </div>
              <div class="form-hint">Unique student identification number</div>
            </div>
            
            <div class="form-group">
              <label>Student Name *</label>
              <input 
                type="text" 
                v-model="quickStudent.fullName" 
                placeholder="Enter full name" 
                required
                class="form-input"
              >
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>Grade/Class *</label>
                <select v-model="quickStudent.grade" required class="form-select">
                  <option value="">Select Grade</option>
                  <option value="9th">9th</option>
                  <option value="10th">10th</option>
                  <option value="11th">11th</option>
                  <option value="12th">12th</option>
                </select>
              </div>
              <div class="form-group">
                <label>Section</label>
                <select v-model="quickStudent.section" class="form-select">
                  <option value="">Select Section</option>
                  <option value="A">A</option>
                  <option value="B">B</option>
                  <option value="C">C</option>
                  <option value="D">D</option>
                </select>
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>Roll Number *</label>
                <input 
                  type="number" 
                  v-model="quickStudent.rollNumber" 
                  placeholder="Roll number" 
                  required
                  class="form-input"
                  min="1"
                >
              </div>
              <div class="form-group">
                <label>Academic Year</label>
                <input 
                  type="text" 
                  v-model="quickStudent.academicYear" 
                  placeholder="e.g., 2024-2025"
                  class="form-input"
                >
              </div>
            </div>
            
            <div class="form-group">
              <label>Generate ID Card?</label>
              <div class="checkbox-group">
                <input 
                  type="checkbox" 
                  id="generateIdCard" 
                  v-model="quickStudent.generateIdCard"
                  class="form-checkbox"
                >
                <label for="generateIdCard" class="checkbox-label">
                  Yes, generate ID Card for this student
                </label>
              </div>
            </div>
            
            <div class="modal-footer">
              <button type="button" class="modal-btn cancel-btn" @click="closeQuickAddModal">
                Cancel
              </button>
              <button type="submit" class="modal-btn confirm-btn" :disabled="saving">
                {{ saving ? 'Saving...' : 'Save Student' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Admin ID Card Modal -->
    <div v-if="showIdCardModal" class="idcard-modal-overlay">
      <div class="idcard-modal">
        <div class="modal-header">
          <h3>Admin ID Card</h3>
          <button class="close-modal" @click="closeIdCardModal">×</button>
        </div>
        <div class="modal-body">
          <div class="id-card-preview">
            <!-- Admin ID Card Template -->
            <div class="id-card admin-id-card">
              <div class="id-card-header">
                <div class="school-logo">🏫</div>
                <div class="school-info">
                  <h3 class="school-name">Educational Institution</h3>
                  <p class="school-address">123 Learning Street, Education City</p>
                </div>
              </div>
              
              <div class="id-card-body">
                <div class="id-photo-section">
                  <div class="photo-container">
                    <img :src="userAvatar" alt="Admin Photo" class="id-photo">
                    <div class="admin-badge-large">ADMIN</div>
                  </div>
                </div>
                
                <div class="id-details-section">
                  <div class="detail-row">
                    <span class="detail-label">Name:</span>
                    <span class="detail-value">{{ userName }}</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">ID Number:</span>
                    <span class="detail-value id-number">{{ adminId }}</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Position:</span>
                    <span class="detail-value">Administrator</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Department:</span>
                    <span class="detail-value">Administration</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Issued Date:</span>
                    <span class="detail-value">{{ currentDate }}</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Valid Until:</span>
                    <span class="detail-value">{{ validUntilDate }}</span>
                  </div>
                </div>
              </div>
              
              <div class="id-card-footer">
                <div class="barcode">
                  <div class="barcode-placeholder">
                    {{ generateBarcode(adminId) }}
                  </div>
                </div>
                <div class="signature">
                  <div class="signature-line"></div>
                  <p class="signature-label">Principal Signature</p>
                </div>
              </div>
            </div>
          </div>
          
          <div class="id-card-actions">
            <button class="action-btn print-btn" @click="printIdCard">
              🖨️ Print ID Card
            </button>
            <button class="action-btn download-btn" @click="downloadIdCard">
              ⬇️ Download ID Card
            </button>
            <button class="action-btn share-btn" @click="shareIdCard">
              📤 Share ID Card
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { signOut } from "firebase/auth";
import { auth } from "../firebase/firebase";

export default {
  name: 'AdminLayout',
  data() {
    return {
      isCollapsed: false,
      showLogoutModal: false,
      showQuickAddModal: false,
      showIdCardModal: false,
      saving: false,
      
      // Admin Details
      adminId: this.generateAdminId(),
      userName: "Admin User",
      userAvatar: "https://via.placeholder.com/150",
      currentDate: new Date().toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
      }),
      validUntilDate: new Date(new Date().setFullYear(new Date().getFullYear() + 1))
        .toLocaleDateString('en-US', { 
          year: 'numeric', 
          month: 'long', 
          day: 'numeric' 
        }),
      
      // Quick Add Student Data
      quickStudent: {
        studentId: '',
        fullName: '',
        grade: '',
        section: '',
        rollNumber: '',
        academicYear: new Date().getFullYear() + '-' + (new Date().getFullYear() + 1),
        generateIdCard: true
      }
    };
  },
  created() {
    this.generateStudentId();
  },
  methods: {
    toggleMenu() {
      this.isCollapsed = !this.isCollapsed;
    },
    
    // Generate Admin ID
    generateAdminId() {
      const prefix = 'ADM';
      const timestamp = Date.now().toString().slice(-6);
      const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
      return `${prefix}-${timestamp}-${random}`;
    },
    
    // Generate Student ID
    generateStudentId() {
      const prefix = 'STU';
      const year = new Date().getFullYear().toString().slice(-2);
      const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
      this.quickStudent.studentId = `${prefix}${year}${random}`;
    },
    
    // Generate Barcode for ID Card
    generateBarcode(id) {
      // Simple barcode simulation
      return id.split('').map(char => {
        const code = char.charCodeAt(0);
        return '█'.repeat((code % 5) + 1) + ' ';
      }).join('');
    },
    
    // Logout function with confirmation
    logout() {
      this.showLogoutModal = true;
    },
    
    confirmLogout() {
      signOut(auth)
        .then(() => {
          this.showLogoutModal = false;
          this.$router.push("/login");
          console.log("User logged out successfully");
          this.showNotification("Logged out successfully!", "success");
        })
        .catch((error) => {
          console.error("Logout error:", error);
          this.showNotification("Logout failed: " + error.message, "error");
        })
        .finally(() => {
          this.showLogoutModal = false;
        });
    },
    
    cancelLogout() {
      this.showLogoutModal = false;
    },
    
    // Quick Actions
    generateIdCard() {
      this.$router.push("/id-cards/generate");
      this.showNotification("Redirecting to ID Card generator...", "info");
    },
    
    exportResults() {
      this.showNotification("Exporting results data...", "info");
    },
    
    generateReport() {
      this.showNotification("Generating report...", "info");
    },
    
    quickAddStudent() {
      this.generateStudentId();
      this.showQuickAddModal = true;
    },
    
    closeQuickAddModal() {
      this.showQuickAddModal = false;
      this.resetQuickStudent();
    },
    
    submitQuickStudent() {
      this.saving = true;
      
      // Simulate API call
      setTimeout(() => {
        console.log("Quick student submitted:", this.quickStudent);
        
        if (this.quickStudent.generateIdCard) {
          this.showNotification(
            `Student ${this.quickStudent.fullName} added successfully! ID Card will be generated.`, 
            "success"
          );
        } else {
          this.showNotification(
            `Student ${this.quickStudent.fullName} added successfully!`, 
            "success"
          );
        }
        
        this.saving = false;
        this.closeQuickAddModal();
        
        // Redirect to student management if ID Card generation is requested
        if (this.quickStudent.generateIdCard) {
          this.$router.push("/id-cards/generate");
        }
      }, 1000);
    },
    
    resetQuickStudent() {
      this.quickStudent = {
        studentId: '',
        fullName: '',
        grade: '',
        section: '',
        rollNumber: '',
        academicYear: new Date().getFullYear() + '-' + (new Date().getFullYear() + 1),
        generateIdCard: true
      };
    },
    
    // ID Card Modal Functions
    showIdCard() {
      this.showIdCardModal = true;
    },
    
    closeIdCardModal() {
      this.showIdCardModal = false;
    },
    
    printIdCard() {
      window.print();
      this.showNotification("ID Card sent to printer", "info");
    },
    
    downloadIdCard() {
      this.showNotification("ID Card download started", "success");
      // Implement actual download logic here
    },
    
    shareIdCard() {
      this.showNotification("ID Card sharing options", "info");
      // Implement share logic here
    },
    
    viewProfile() {
      this.$router.push("/admin/profile");
    },
    
    // Notification function
    showNotification(message, type = "info") {
      // You can use any notification library here
      alert(`${type.toUpperCase()}: ${message}`);
    }
  }
};
</script>

<style scoped>
/* ====== Base Layout ====== */
.admin-layout {
  display: flex;
  min-height: 100vh;
  background-color: #f5f7fa;
}

/* ====== Sidebar Styles ====== */
.sidebar {
  width: 280px;
  background: linear-gradient(180deg, #2c3e50 0%, #1a2530 100%);
  color: white;
  transition: all 0.3s ease;
  box-shadow: 3px 0 15px rgba(0, 0, 0, 0.1);
  z-index: 100;
}

.sidebar.collapsed {
  width: 70px;
}

.sidebar-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

/* Sidebar Header */
.sidebar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 15px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  font-size: 28px;
  background: rgba(255, 255, 255, 0.1);
  width: 45px;
  height: 45px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-text {
  display: flex;
  flex-direction: column;
}

.logo-title {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
}

.logo-subtitle {
  margin: 2px 0 0;
  font-size: 11px;
  opacity: 0.7;
}

.menu-toggle {
  background: rgba(255, 255, 255, 0.1);
  border: none;
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
}

.menu-toggle:hover {
  background: rgba(255, 255, 255, 0.2);
}

.toggle-icon {
  font-size: 24px;
  font-weight: bold;
}

/* ====== Navigation Menu ====== */
.nav-menu {
  flex: 1;
  padding: 20px 0;
  list-style: none;
  margin: 0;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.nav-menu.collapsed {
  padding: 10px 0;
}

.nav-item {
  margin: 5px 15px;
}

.nav-link {
  display: flex;
  align-items: center;
  padding: 14px 18px;
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  border-radius: 10px;
  transition: all 0.3s;
  gap: 15px;
}

.nav-link:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  transform: translateX(5px);
}

.nav-link.active {
  background: linear-gradient(90deg, #3498db, #2ecc71);
  color: white;
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.nav-icon {
  font-size: 20px;
  min-width: 24px;
  text-align: center;
}

.nav-text {
  font-size: 15px;
  font-weight: 500;
  white-space: nowrap;
  transition: opacity 0.3s;
}

.nav-menu.collapsed .nav-text {
  opacity: 0;
  width: 0;
  overflow: hidden;
}

/* Results Sub-menu */
.sub-menu {
  margin: 0 15px 10px;
}

.sub-item .nav-link {
  padding: 12px 18px;
  margin-left: 20px;
  background: rgba(255, 255, 255, 0.05);
}

.sub-item .nav-link:hover {
  background: rgba(255, 255, 255, 0.1);
}

.sub-item .nav-link.active {
  background: linear-gradient(90deg, #9b59b6, #8e44ad);
}

/* ====== Divider ====== */
.nav-divider {
  padding: 20px 25px 10px;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 1px;
  opacity: 0.5;
  margin-top: 10px;
}

/* ====== Quick Actions ====== */
.quick-actions {
  padding: 0 20px 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.quick-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 18px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 14px;
  text-align: left;
}

.quick-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.quick-icon {
  font-size: 18px;
  min-width: 24px;
}

/* ====== User Profile ====== */
.user-profile {
  margin-top: auto;
  padding: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
}

.user-avatar {
  position: relative;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid rgba(255, 255, 255, 0.3);
  margin-bottom: 15px;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.admin-badge {
  position: absolute;
  bottom: -5px;
  right: -5px;
  background: #e74c3c;
  color: white;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
  border: 2px solid white;
}

.user-info {
  margin-bottom: 15px;
}

.user-name {
  margin: 0 0 8px 0;
  font-weight: 700;
  font-size: 16px;
  color: white;
}

.user-role {
  margin: 0 0 8px 0;
}

.role-badge {
  background: rgba(52, 152, 219, 0.3);
  color: #3498db;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.user-id {
  margin: 0 0 8px 0;
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 5px;
}

.id-label {
  opacity: 0.7;
}

.id-value {
  font-family: 'Courier New', monospace;
  font-weight: bold;
  color: #2ecc71;
  background: rgba(46, 204, 113, 0.1);
  padding: 2px 6px;
  border-radius: 4px;
  border: 1px solid rgba(46, 204, 113, 0.3);
}

.user-status {
  margin: 0;
  font-size: 11px;
  display: flex;
  align-items: center;
  gap: 5px;
  opacity: 0.8;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-dot.online {
  background: #2ecc71;
  box-shadow: 0 0 5px #2ecc71;
}

.user-actions {
  display: flex;
  gap: 8px;
}

.user-action-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: white;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.3s;
}

.user-action-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

/* Logout Button - Expanded View */
.logout-btn {
  flex: 1;
  background: rgba(231, 76, 60, 0.2);
  border: 1px solid rgba(231, 76, 60, 0.3);
  color: #f3eeed;
  padding: 10px 15px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
}

.logout-btn:hover {
  background: rgba(231, 76, 60, 0.3);
  transform: scale(1.05);
}

.logout-text {
  white-space: nowrap;
}

/* Logout Button - Collapsed View */
.logout-collapsed {
  margin-top: auto;
  padding: 20px 0;
  display: flex;
  justify-content: center;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.logout-btn-collapsed {
  background: rgba(231, 76, 60, 0.2);
  border: 1px solid rgba(231, 76, 60, 0.3);
  color: #e74c3c;
  width: 45px;
  height: 45px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
}

.logout-btn-collapsed:hover {
  background: rgba(231, 76, 60, 0.3);
  transform: scale(1.1);
}

.logout-icon-collapsed {
  font-size: 20px;
}

/* ====== Main Content ====== */
.main-content {
  flex: 1;
  padding: 25px;
  overflow-y: auto;
  transition: all 0.3s ease;
  margin-left: 0;
}

.main-content.sidebar-collapsed {
  margin-left: -210px;
}

/* ====== Logout Modal ====== */
.logout-modal-overlay {
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
  backdrop-filter: blur(4px);
}

.logout-modal {
  background: white;
  border-radius: 12px;
  width: 400px;
  max-width: 90%;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.modal-header {
  background: linear-gradient(90deg, #e74c3c, #c0392b);
  color: white;
  padding: 20px;
  text-align: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 20px;
}

.modal-body {
  padding: 30px 20px;
  font-size: 16px;
  color: #333;
}

.user-details {
  margin-top: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #eee;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
}

.detail-item:last-child {
  margin-bottom: 0;
}

.detail-label {
  font-weight: 600;
  color: #666;
}

.detail-value {
  font-weight: 600;
  color: #2c3e50;
  font-family: 'Courier New', monospace;
}

.modal-footer {
  padding: 20px;
  display: flex;
  justify-content: center;
  gap: 15px;
  border-top: 1px solid #eee;
}

.modal-btn {
  padding: 10px 25px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.3s;
  min-width: 100px;
}

.cancel-btn {
  background: #ecf0f1;
  color: #34495e;
}

.cancel-btn:hover {
  background: #d5dbdb;
}

.confirm-btn {
  background: #e74c3c;
  color: white;
}

.confirm-btn:hover {
  background: #c0392b;
  transform: translateY(-2px);
}

/* ====== Quick Add Student Modal ====== */
.quick-add-modal-overlay {
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
  backdrop-filter: blur(4px);
}

.quick-add-modal {
  background: white;
  border-radius: 12px;
  width: 500px;
  max-width: 90%;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.quick-add-modal .modal-header {
  background: linear-gradient(90deg, #9b59b6, #8e44ad);
  color: white;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.close-modal {
  background: none;
  border: none;
  color: white;
  font-size: 24px;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.close-modal:hover {
  background: rgba(255, 255, 255, 0.2);
}

.quick-add-modal .modal-body {
  padding: 30px 20px;
  text-align: left;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2c3e50;
}

.input-with-action {
  display: flex;
  gap: 10px;
}

.form-input {
  flex: 1;
  padding: 12px 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  transition: all 0.3s;
}

.form-input:focus {
  outline: none;
  border-color: #9b59b6;
  box-shadow: 0 0 0 2px rgba(155, 89, 182, 0.2);
}

.generate-btn {
  background: #3498db;
  color: white;
  border: none;
  padding: 12px 15px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
  transition: all 0.3s;
}

.generate-btn:hover {
  background: #2980b9;
}

.form-hint {
  font-size: 12px;
  color: #7f8c8d;
  margin-top: 5px;
  font-style: italic;
}

.form-select {
  width: 100%;
  padding: 12px 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  background: white;
  cursor: pointer;
  transition: all 0.3s;
}

.form-select:focus {
  outline: none;
  border-color: #9b59b6;
  box-shadow: 0 0 0 2px rgba(155, 89, 182, 0.2);
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.checkbox-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.form-checkbox {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.checkbox-label {
  font-weight: normal;
  cursor: pointer;
  user-select: none;
}

/* ====== ID Card Modal ====== */
.idcard-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(8px);
}

.idcard-modal {
  background: white;
  border-radius: 12px;
  width: 600px;
  max-width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
}

.idcard-modal .modal-header {
  background: linear-gradient(90deg, #2c3e50, #34495e);
  color: white;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.id-card-preview {
  padding: 30px;
  display: flex;
  justify-content: center;
  background: #f8f9fa;
}

/* Admin ID Card Design */
.admin-id-card {
  width: 100%;
  max-width: 400px;
  background: white;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  border: 1px solid #e0e0e0;
}

.id-card-header {
  background: linear-gradient(90deg, #2c3e50, #34495e);
  color: white;
  padding: 20px;
  text-align: center;
}

.school-logo {
  font-size: 40px;
  margin-bottom: 10px;
}

.school-name {
  margin: 0 0 5px 0;
  font-size: 18px;
  font-weight: 700;
}

.school-address {
  margin: 0;
  font-size: 12px;
  opacity: 0.9;
}

.id-card-body {
  display: flex;
  padding: 25px;
  gap: 20px;
}

.id-photo-section {
  flex-shrink: 0;
}

.photo-container {
  position: relative;
  width: 120px;
  height: 150px;
  border-radius: 10px;
  overflow: hidden;
  border: 3px solid #3498db;
}

.id-photo {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.admin-badge-large {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(231, 76, 60, 0.9);
  color: white;
  text-align: center;
  padding: 5px;
  font-size: 11px;
  font-weight: bold;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.id-details-section {
  flex: 1;
}

.detail-row {
  display: flex;
  margin-bottom: 12px;
  padding-bottom: 10px;
  border-bottom: 1px dashed #eee;
}

.detail-row:last-child {
  margin-bottom: 0;
  border-bottom: none;
}

.detail-label {
  flex: 0 0 100px;
  font-weight: 600;
  color: #666;
  font-size: 13px;
}

.detail-value {
  flex: 1;
  color: #2c3e50;
  font-weight: 500;
}

.id-number {
  font-family: 'Courier New', monospace;
  font-weight: bold;
  color: #e74c3c;
  font-size: 14px;
}

.id-card-footer {
  padding: 20px;
  background: #f8f9fa;
  border-top: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.barcode {
  flex: 1;
  text-align: center;
}

.barcode-placeholder {
  font-family: 'Courier New', monospace;
  font-size: 24px;
  letter-spacing: 2px;
  color: #333;
  padding: 10px;
  background: white;
  border-radius: 5px;
  border: 1px solid #ddd;
}

.signature {
  text-align: center;
}

.signature-line {
  width: 150px;
  height: 1px;
  background: #333;
  margin-bottom: 5px;
}

.signature-label {
  margin: 0;
  font-size: 10px;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.id-card-actions {
  padding: 20px;
  display: flex;
  gap: 10px;
  justify-content: center;
  border-top: 1px solid #eee;
}

.action-btn {
  padding: 12px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.print-btn {
  background: #3498db;
  color: white;
}

.print-btn:hover {
  background: #2980b9;
}

.download-btn {
  background: #27ae60;
  color: white;
}

.download-btn:hover {
  background: #219653;
}

.share-btn {
  background: #9b59b6;
  color: white;
}

.share-btn:hover {
  background: #8e44ad;
}

/* ====== Responsive Design ====== */
@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    height: 100vh;
    transform: translateX(0);
  }
  
  .sidebar.collapsed {
    transform: translateX(-100%);
  }
  
  .main-content {
    margin-left: 0;
    width: 100%;
  }
  
  .menu-toggle {
    display: flex;
  }
  
  .logout-modal,
  .quick-add-modal,
  .idcard-modal {
    width: 95%;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .id-card-body {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }
  
  .detail-row {
    flex-direction: column;
    text-align: center;
  }
  
  .detail-label {
    flex: none;
    margin-bottom: 5px;
  }
  
  .id-card-actions {
    flex-direction: column;
  }
  
  .action-btn {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .main-content {
    padding: 15px;
  }
  
  .sidebar-header {
    padding: 15px 10px;
  }
  
  .nav-item {
    margin: 3px 10px;
  }
  
  .nav-link {
    padding: 12px 15px;
  }
  
  .modal-footer {
    flex-direction: column;
  }
  
  .modal-btn {
    width: 100%;
  }
  
  .user-profile {
    flex-direction: column;
    text-align: center;
  }
  
  .user-actions {
    width: 100%;
  }
  
  .logout-btn {
    width: 100%;
  }
}

/* ====== Scrollbar Styling ====== */
.nav-menu::-webkit-scrollbar {
  width: 5px;
}

.nav-menu::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
}

.nav-menu::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 10px;
}

.nav-menu::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}
</style>