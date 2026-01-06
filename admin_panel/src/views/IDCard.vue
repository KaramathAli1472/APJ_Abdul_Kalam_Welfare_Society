<template>
  <div class="id-card-container">
    <div class="page-header">
      <h1>🪪 ID Card / Hall Ticket Generator</h1>
      <p>Generate and download student ID cards</p>
    </div>

    <!-- Student Selection -->
    <div class="student-selection" v-if="!student.id">
      <div class="selection-box">
        <h3>Select Student</h3>
        <div class="search-container">
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search by name or ID..." 
            class="search-input"
          >
          <span class="search-icon">🔍</span>
        </div>
        
        <div class="students-list">
          <div 
            v-for="student in filteredStudents" 
            :key="student.id" 
            class="student-item"
            @click="selectStudent(student)"
          >
            <img 
              :src="student.profilePhoto || student.photoUrl || placeholder" 
              alt="Student" 
              class="student-thumb"
              @error="handleStudentImageError"
            >
            <div class="student-info">
              <h4>{{ student.name }}</h4>
              <p>ID: {{ student.registrationNumber || student.id }}</p>
              <p>Class: {{ student.class || student.grade || 'N/A' }}</p>
            </div>
            <span class="select-arrow">➡️</span>
          </div>
        </div>
      </div>
    </div>

    <!-- ID Card Preview -->
    <div class="id-card-preview" v-if="student.id">
      <div class="preview-header">
        <h2>ID Card Preview</h2>
        <button class="back-btn" @click="clearSelection">
          ← Back to Selection
        </button>
      </div>

      <!-- ID Card Design -->
      <div id="id-card" class="id-card">
        <!-- School Header - FIXED LOGO -->
        <div class="school-header">
          <div class="school-logo-container">
            <!-- ✅ DIRECT PATH: Public folder se -->
            <img 
              src="/school-logo.png" 
              alt="A.P.J Abdul Kalam Welfare Society Logo" 
              class="school-logo"
              @load="handleLogoLoad"
              @error="handleLogoError"
            />
          </div>
          <div class="school-info">
            <h2 class="school-name">A.P.J Abdul Kalam Welfare Society</h2>
            <p class="school-address">Santosh Nagar, Hyderabad-500059</p>
            <p class="school-tagline">Knowledge • Excellence • Integrity</p>
          </div>
        </div>

        <!-- Card Content -->
        <div class="card-content">
          <!-- Left: Student Photo -->
          <div class="photo-section">
            <div class="photo-container">
              <img 
                :src="studentPhoto" 
                alt="Student Photo" 
                class="student-photo"
                @error="handleStudentPhotoError"
              />
              <div class="photo-frame"></div>
            </div>
            <div class="qr-code">
              <div class="qr-placeholder">
                <span class="qr-text">ID: {{ student.registrationNumber }}</span>
              </div>
            </div>
          </div>

          <!-- Right: Student Details -->
          <div class="details-section">
            <div class="detail-row">
              <span class="label">FULL NAME:</span>
              <span class="value">{{ student.name }}</span>
            </div>
            <div class="detail-row">
              <span class="label">FATHER'S NAME:</span>
              <span class="value">{{ student.fatherName }}</span>
            </div>
            <div class="detail-row">
              <span class="label">STUDENT ID:</span>
              <span class="value id-number">{{ student.registrationNumber }}</span>
            </div>
            <div class="detail-row">
              <span class="label">CLASS/GRADE:</span>
              <span class="value">{{ student.class || student.grade || 'N/A' }}</span>
            </div>
            <div class="detail-row">
              <span class="label">PHONE:</span>
              <span class="value">{{ student.phone || student.whatsapp || 'N/A' }}</span>
            </div>
            <div class="detail-row">
              <span class="label">VALID TILL:</span>
              <span class="value">{{ validUntil }}</span>
            </div>
          </div>
        </div>

        <!-- Card Footer -->
        <div class="card-footer">
          <div class="barcode">
            <div class="barcode-placeholder">
              {{ generateBarcode(student.registrationNumber) }}
            </div>
          </div>
          <div class="signature">
            <div class="signature-line"></div>
            <p>Principal's Signature</p>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="card-actions">
        <button class="action-btn print-btn" @click="printCard">
          🖨️ Print ID Card
        </button>
        <button class="action-btn download-btn" @click="downloadPDF">
          ⬇️ Download PDF
        </button>
        <button class="action-btn save-btn" @click="saveCard">
          💾 Save to Database
        </button>
        <button class="action-btn share-btn" @click="shareCard">
          📤 Share
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Loading students...</p>
    </div>

    <!-- Empty State -->
    <div v-if="!loading && students.length === 0" class="empty-state">
      <div class="empty-icon">👨‍🎓</div>
      <h3>No Students Found</h3>
      <p>Add students first to generate ID cards.</p>
      <button class="btn add-btn" @click="goToStudents">
        ➕ Add Students
      </button>
    </div>
  </div>
</template>

<script>
import { db } from "../firebase/firebase";
import { collection, getDocs, addDoc, updateDoc, doc } from "firebase/firestore";
import jsPDF from "jspdf";
import html2canvas from "html2canvas";

export default {
  name: 'IDCard',
  data() {
    return {
      students: [],
      student: {},
      loading: true,
      searchQuery: '',
      logoLoaded: false,
      
      // Images
      placeholder: "https://via.placeholder.com/100?text=Student",
      studentPhoto: "",
      
      // Dates
      validUntil: new Date(new Date().setFullYear(new Date().getFullYear() + 1))
        .toLocaleDateString('en-US', { 
          year: 'numeric', 
          month: 'short' 
        })
    };
  },
  computed: {
    filteredStudents() {
      if (!this.searchQuery) return this.students;
      const query = this.searchQuery.toLowerCase();
      return this.students.filter(student => 
        student.name?.toLowerCase().includes(query) ||
        student.registrationNumber?.toLowerCase().includes(query) ||
        student.id?.toLowerCase().includes(query)
      );
    }
  },
  async created() {
    await this.loadStudents();
    
    // Check for student ID in query params
    const studentId = this.$route.query.studentId;
    if (studentId) {
      await this.selectStudentById(studentId);
    }
  },
  methods: {
    async loadStudents() {
      try {
        this.loading = true;
        const studentsSnapshot = await getDocs(collection(db, "students"));
        this.students = studentsSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        console.log(`✅ Loaded ${this.students.length} students`);
      } catch (error) {
        console.error("❌ Error loading students:", error);
        this.showNotification("Failed to load students", "error");
      } finally {
        this.loading = false;
      }
    },
    
    async selectStudentById(studentId) {
      const student = this.students.find(s => s.id === studentId);
      if (student) {
        this.selectStudent(student);
      } else {
        console.log(`❌ Student not found with ID: ${studentId}`);
      }
    },
    
    selectStudent(student) {
      this.student = student;
      this.loadStudentPhoto();
    },
    
    loadStudentPhoto() {
      const photoSources = [
        this.student.profilePhoto,
        this.student.photoUrl,
        this.student.photo,
        this.placeholder
      ].filter(Boolean);
      
      this.testPhotoSources(photoSources);
    },
    
    testPhotoSources(sources) {
      if (sources.length === 0) {
        this.studentPhoto = this.placeholder;
        return;
      }
      
      const source = sources[0];
      const img = new Image();
      
      img.onload = () => {
        console.log(`✅ Student photo loaded: ${source}`);
        this.studentPhoto = source;
      };
      
      img.onerror = () => {
        console.log(`❌ Failed to load student photo: ${source}`);
        this.testPhotoSources(sources.slice(1));
      };
      
      img.src = source;
    },
    
    handleStudentImageError(event) {
      console.log("❌ Student thumbnail failed to load");
      event.target.src = this.placeholder;
    },
    
    handleStudentPhotoError(event) {
      console.log("❌ Student photo failed to load");
      event.target.src = this.placeholder;
    },
    
    handleLogoLoad() {
      console.log("✅ School logo loaded successfully from /school-logo.png");
      this.logoLoaded = true;
    },
    
    handleLogoError(event) {
      console.log("❌ School logo failed to load from /school-logo.png");
      this.logoLoaded = false;
      
      // Fallback - try other possible locations
      setTimeout(() => {
        const fallbackLogos = [
          '/logo.png',
          '/apj-logo.png',
          'https://via.placeholder.com/120x60/3498db/ffffff?text=A.P.J+Kalam',
          'https://via.placeholder.com/120x60/2c3e50/ffffff?text=APJ+School'
        ];
        
        this.tryLogos(fallbackLogos);
      }, 1000);
    },
    
    tryLogos(logoUrls) {
      if (logoUrls.length === 0) return;
      
      const logoUrl = logoUrls[0];
      const img = new Image();
      
      img.onload = () => {
        console.log(`✅ Fallback logo loaded: ${logoUrl}`);
        // Update the logo src
        const logoElement = document.querySelector('.school-logo');
        if (logoElement) {
          logoElement.src = logoUrl;
        }
        this.logoLoaded = true;
      };
      
      img.onerror = () => {
        console.log(`❌ Fallback logo failed: ${logoUrl}`);
        this.tryLogos(logoUrls.slice(1));
      };
      
      img.src = logoUrl;
    },
    
    clearSelection() {
      this.student = {};
      this.searchQuery = '';
    },
    
    generateBarcode(id) {
      if (!id) return '';
      return id.split('').map(char => {
        const code = char.charCodeAt(0);
        return '█'.repeat((code % 5) + 1) + ' ';
      }).join('');
    },
    
    async downloadPDF() {
      if (!this.student.id) {
        this.showNotification("Please select a student first", "error");
        return;
      }
      
      try {
        this.showNotification("Generating PDF...", "info");
        
        const element = document.getElementById("id-card");
        const canvas = await html2canvas(element, {
          scale: 2,
          backgroundColor: '#ffffff',
          logging: false,
          useCORS: true,
          allowTaint: true
        });
        
        const imgData = canvas.toDataURL("image/png");
        const pdf = new jsPDF({
          orientation: "portrait",
          unit: "mm",
          format: [85, 54]
        });
        
        pdf.addImage(imgData, "PNG", 0, 0, 85, 54);
        pdf.save(`${this.student.name.replace(/\s+/g, '_')}_IDCard.pdf`);
        
        this.showNotification("ID Card downloaded successfully!", "success");
      } catch (error) {
        console.error("❌ Error generating PDF:", error);
        this.showNotification("Failed to download ID Card", "error");
      }
    },
    
    printCard() {
      if (!this.student.id) {
        this.showNotification("Please select a student first", "error");
        return;
      }
      
      // Simple print
      window.print();
      this.showNotification("ID Card sent to printer", "info");
    },
    
    async saveCard() {
      if (!this.student.id) {
        this.showNotification("Please select a student first", "error");
        return;
      }
      
      try {
        this.showNotification("Saving to database...", "info");
        
        const idCardData = {
          studentId: this.student.id,
          studentName: this.student.name,
          studentPhoto: this.studentPhoto,
          registrationNumber: this.student.registrationNumber,
          fatherName: this.student.fatherName,
          class: this.student.class || this.student.grade,
          phone: this.student.phone || this.student.whatsapp,
          generatedAt: new Date().toISOString(),
          generatedBy: this.getAdminId(),
          validUntil: this.validUntil
        };
        
        await addDoc(collection(db, "idCards"), idCardData);
        
        // Update student record
        await updateDoc(doc(db, "students", this.student.id), {
          idCardGenerated: true,
          idCardGeneratedAt: new Date().toISOString(),
          lastIdCardUpdate: new Date().toISOString()
        });
        
        this.showNotification("ID Card saved to database!", "success");
      } catch (error) {
        console.error("❌ Error saving ID card:", error);
        this.showNotification("Failed to save ID Card", "error");
      }
    },
    
    shareCard() {
      if (!this.student.id) {
        this.showNotification("Please select a student first", "error");
        return;
      }
      
      if (navigator.share) {
        navigator.share({
          title: `${this.student.name}'s ID Card`,
          text: `ID Card for ${this.student.name} - ${this.student.registrationNumber}`,
          url: window.location.href
        }).then(() => {
          console.log("✅ Share successful");
        }).catch(error => {
          console.log("❌ Share cancelled:", error);
        });
      } else {
        navigator.clipboard.writeText(window.location.href).then(() => {
          this.showNotification("Link copied to clipboard!", "success");
        }).catch(() => {
          this.showNotification("Cannot share on this device", "error");
        });
      }
    },
    
    goToStudents() {
      this.$router.push('/students');
    },
    
    getAdminId() {
      const user = JSON.parse(localStorage.getItem('user'));
      return user?.uid || 'ADM-' + Date.now().toString().slice(-6);
    },
    
    showNotification(message, type) {
      // Remove existing notifications
      const existingToasts = document.querySelectorAll('.toast-notification');
      existingToasts.forEach(toast => toast.remove());
      
      // Create toast notification
      const toast = document.createElement('div');
      toast.className = `toast-notification ${type}`;
      toast.innerHTML = `
        <span class="toast-icon">${type === 'success' ? '✅' : '❌'}</span>
        <span class="toast-message">${message}</span>
      `;
      
      document.body.appendChild(toast);
      
      // Animate in
      setTimeout(() => {
        toast.classList.add('show');
      }, 10);
      
      // Remove after 3 seconds
      setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => {
          if (toast.parentNode) {
            document.body.removeChild(toast);
          }
        }, 300);
      }, 3000);
    }
  }
};
</script>

<style scoped>
.id-card-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;
}

.page-header h1 {
  color: #2c3e50;
  margin-bottom: 10px;
  font-size: 28px;
}

.page-header p {
  color: #7f8c8d;
  font-size: 16px;
}

/* Student Selection */
.student-selection {
  max-width: 800px;
  margin: 0 auto;
}

.selection-box {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.selection-box h3 {
  margin-bottom: 20px;
  color: #2c3e50;
  font-size: 20px;
}

.search-container {
  position: relative;
  margin-bottom: 20px;
}

.search-input {
  width: 100%;
  padding: 12px 15px 12px 45px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 16px;
  transition: all 0.3s;
}

.search-input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.search-icon {
  position: absolute;
  left: 15px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 18px;
  color: #7f8c8d;
}

.students-list {
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #eee;
  border-radius: 8px;
}

.student-item {
  display: flex;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #eee;
  cursor: pointer;
  transition: all 0.3s;
}

.student-item:last-child {
  border-bottom: none;
}

.student-item:hover {
  background: #f8f9fa;
  border-color: #3498db;
}

.student-thumb {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
  margin-right: 15px;
  border: 2px solid #e0e0e0;
  background: #f8f9fa;
}

.student-info {
  flex: 1;
}

.student-info h4 {
  margin: 0 0 5px 0;
  color: #2c3e50;
  font-size: 16px;
}

.student-info p {
  margin: 2px 0;
  font-size: 13px;
  color: #7f8c8d;
}

.select-arrow {
  color: #3498db;
  font-size: 18px;
  opacity: 0.7;
}

/* ID Card Preview */
.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #eee;
}

.preview-header h2 {
  color: #2c3e50;
  margin: 0;
}

.back-btn {
  background: #95a5a6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
}

.back-btn:hover {
  background: #7f8c8d;
  transform: translateY(-2px);
}

/* ID Card Design */
.id-card {
  width: 400px;
  margin: 0 auto;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  border: 1px solid #d0d7e2;
  position: relative;
  overflow: hidden;
}

.id-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 5px;
  background: linear-gradient(90deg, #3498db, #2ecc71);
}

.school-header {
  display: flex;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px dashed #d0d7e2;
}

.school-logo-container {
  margin-right: 15px;
  flex-shrink: 0;
}

.school-logo {
  width: 80px;
  height: 80px;
  object-fit: contain;
  border-radius: 10px;
  border: 2px solid #3498db;
  padding: 8px;
  background: white;
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.2);
}

.school-info {
  flex: 1;
}

.school-name {
  margin: 0 0 8px 0;
  font-size: 18px;
  color: #2c3e50;
  font-weight: 700;
  line-height: 1.3;
}

.school-address {
  margin: 0 0 5px 0;
  font-size: 13px;
  color: #7f8c8d;
  font-weight: 500;
}

.school-tagline {
  margin: 0;
  font-size: 12px;
  color: #3498db;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.card-content {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.photo-section {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.photo-container {
  position: relative;
  width: 120px;
  height: 150px;
  border-radius: 10px;
  overflow: hidden;
  background: white;
  border: 3px solid #3498db;
  padding: 5px;
}

.student-photo {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 6px;
  background: #f8f9fa;
}

.photo-frame {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border: 2px solid rgba(52, 152, 219, 0.2);
  border-radius: 6px;
  pointer-events: none;
}

.qr-code {
  background: white;
  border-radius: 8px;
  padding: 10px;
  border: 1px solid #d0d7e2;
  text-align: center;
}

.qr-placeholder {
  padding: 10px;
  background: #f8f9fa;
  border-radius: 4px;
  min-height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.qr-text {
  font-family: 'Courier New', monospace;
  font-size: 11px;
  color: #2c3e50;
  letter-spacing: 1px;
}

.details-section {
  flex: 1;
}

.detail-row {
  display: flex;
  margin-bottom: 12px;
  padding-bottom: 10px;
  border-bottom: 1px dotted #e0e0e0;
}

.detail-row:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.label {
  flex: 0 0 120px;
  font-weight: 600;
  color: #2c3e50;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.value {
  flex: 1;
  color: #34495e;
  font-weight: 500;
  font-size: 13px;
}

.id-number {
  font-family: 'Courier New', monospace;
  font-weight: 700;
  color: #e74c3c;
  font-size: 14px;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding-top: 15px;
  border-top: 2px dashed #d0d7e2;
}

.barcode {
  flex: 1;
}

.barcode-placeholder {
  font-family: 'Courier New', monospace;
  font-size: 20px;
  letter-spacing: 2px;
  color: #2c3e50;
  background: white;
  padding: 8px;
  border-radius: 4px;
  border: 1px solid #d0d7e2;
  text-align: center;
  min-height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.signature {
  text-align: right;
}

.signature-line {
  width: 120px;
  height: 2px;
  background: #2c3e50;
  margin-bottom: 5px;
}

.signature p {
  margin: 0;
  font-size: 10px;
  color: #7f8c8d;
  text-transform: uppercase;
}

/* Actions */
.card-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
  margin-top: 30px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 12px 25px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 600;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 180px;
  justify-content: center;
}

.print-btn {
  background: #3498db;
  color: white;
}

.print-btn:hover {
  background: #2980b9;
  transform: translateY(-2px);
}

.download-btn {
  background: #27ae60;
  color: white;
}

.download-btn:hover {
  background: #219653;
  transform: translateY(-2px);
}

.save-btn {
  background: #9b59b6;
  color: white;
}

.save-btn:hover {
  background: #8e44ad;
  transform: translateY(-2px);
}

.share-btn {
  background: #e67e22;
  color: white;
}

.share-btn:hover {
  background: #d35400;
  transform: translateY(-2px);
}

/* Loading State */
.loading-state {
  text-align: center;
  padding: 50px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 50px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  max-width: 500px;
  margin: 0 auto;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 15px;
  opacity: 0.5;
}

.empty-state h3 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.empty-state p {
  color: #7f8c8d;
  margin-bottom: 20px;
  font-size: 16px;
}

.add-btn {
  background: #3498db;
  color: white;
  border: none;
  padding: 12px 25px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 600;
  transition: all 0.3s;
}

.add-btn:hover {
  background: #2980b9;
  transform: translateY(-2px);
}

/* Toast Notifications */
.toast-notification {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: white;
  padding: 15px 20px;
  border-radius: 8px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  display: flex;
  align-items: center;
  gap: 10px;
  transform: translateY(100px);
  opacity: 0;
  transition: all 0.3s;
  z-index: 1000;
  border-left: 4px solid #3498db;
  max-width: 350px;
}

.toast-notification.success {
  border-left-color: #27ae60;
  background: #f7fef9;
}

.toast-notification.error {
  border-left-color: #e74c3c;
  background: #fff5f5;
}

.toast-notification.info {
  border-left-color: #3498db;
  background: #f0f7ff;
}

.toast-notification.show {
  transform: translateY(0);
  opacity: 1;
}

.toast-icon {
  font-size: 18px;
}

.toast-message {
  font-weight: 500;
  color: #2c3e50;
  font-size: 14px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .id-card {
    width: 100%;
    padding: 20px;
  }
  
  .card-content {
    flex-direction: column;
    text-align: center;
  }
  
  .photo-section {
    align-items: center;
  }
  
  .detail-row {
    flex-direction: column;
    text-align: center;
    gap: 5px;
  }
  
  .label {
    flex: none;
    margin-bottom: 0;
  }
  
  .card-actions {
    flex-direction: column;
  }
  
  .action-btn {
    width: 100%;
    min-width: auto;
  }
  
  .school-header {
    flex-direction: column;
    text-align: center;
    gap: 15px;
  }
  
  .school-logo-container {
    margin-right: 0;
  }
}

@media print {
  .page-header,
  .preview-header,
  .card-actions,
  .student-selection,
  .loading-state,
  .empty-state,
  .toast-notification {
    display: none !important;
  }
  
  .id-card {
    box-shadow: none;
    border: 1px solid #000;
    margin: 0;
    width: 85mm !important;
    height: 54mm !important;
    padding: 10px;
    background: white !important;
  }
  
  .id-card::before {
    display: none;
  }
  
  .school-logo {
    width: 60px !important;
    height: 60px !important;
  }
}
</style>