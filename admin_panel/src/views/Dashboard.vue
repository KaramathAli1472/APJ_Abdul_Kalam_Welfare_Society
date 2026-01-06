<template>
  <div class="admin-dashboard">
    <!-- Main Content Only - Sidebar Removed -->
    <main class="main-content">
      <!-- Top Header -->
      <header class="top-header">
        <div class="header-left">
          <h1 class="page-title">School Management Dashboard</h1>
          <p class="page-subtitle">Welcome back, Admin! Manage all school operations from here.</p>
          <div class="date-time">
            <span class="date">{{ currentDate }}</span>
            <span class="time">{{ currentTime }}</span>
          </div>
        </div>
        
        <div class="header-right">
          <div class="admin-info">
            <div class="admin-avatar">
              <div class="avatar-placeholder">A</div>
              <div class="admin-status online"></div>
            </div>
            <div class="admin-details">
              <p class="admin-name">Administrator</p>
              <p class="admin-role">School Admin</p>
              <p class="admin-id">ID: {{ adminId }}</p>
            </div>
          </div>
          
          <div class="header-actions">
            <button class="icon-btn notification-btn" @click="showNotifications">
              <span class="icon">🔔</span>
              <span v-if="unreadNotifications > 0" class="notification-badge">{{ unreadNotifications }}</span>
            </button>
            <button class="icon-btn" @click="showSettings">
              <span class="icon">⚙️</span>
            </button>
            <button @click="logout" class="logout-button">
              <span class="logout-icon">🚪</span>
              <span class="logout-text">Logout</span>
            </button>
          </div>
        </div>
      </header>

      <!-- Quick Stats - REAL DATA -->
      <div class="quick-stats">
        <div class="stat-card" @click="$router.push('/students')">
          <div class="stat-icon student-icon">
            👨‍🎓
          </div>
          <div class="stat-content">
            <h3 class="stat-value">{{ dashboardStats.totalStudents }}</h3>
            <p class="stat-label">Total Students</p>
            <div class="stat-trend">
              <span class="trend" :class="dashboardStats.newStudentsToday > 0 ? 'positive' : 'neutral'">
                {{ dashboardStats.newStudentsToday > 0 ? `↑ ${dashboardStats.newStudentsToday} new today` : 'No new students' }}
              </span>
            </div>
          </div>
          <button class="stat-action">Manage</button>
        </div>

        <div class="stat-card" @click="$router.push('/id-card')">
          <div class="stat-icon idcard-icon">
            🪪
          </div>
          <div class="stat-content">
            <h3 class="stat-value">{{ dashboardStats.pendingIdCards }}</h3>
            <p class="stat-label">Pending ID Cards</p>
            <div class="stat-trend">
              <span class="trend" :class="dashboardStats.idCardsGenerated > 0 ? 'positive' : 'neutral'">
                {{ dashboardStats.idCardsGenerated > 0 ? `${dashboardStats.idCardsGenerated} generated` : 'No ID cards' }}
              </span>
            </div>
          </div>
          <button class="stat-action">Generate</button>
        </div>

        <div class="stat-card" @click="$router.push('/results')">
          <div class="stat-icon result-icon">
            📈
          </div>
          <div class="stat-content">
            <h3 class="stat-value">{{ dashboardStats.resultsPending }}</h3>
            <p class="stat-label">Results Pending</p>
            <div class="stat-trend">
              <span class="trend" :class="dashboardStats.resultsPublished > 0 ? 'positive' : 'neutral'">
                {{ dashboardStats.resultsPublished > 0 ? `${dashboardStats.resultsPublished} published` : 'No results' }}
              </span>
            </div>
          </div>
          <button class="stat-action">View</button>
        </div>

        <div class="stat-card" @click="$router.push('/payments')">
          <div class="stat-icon payment-icon">
            💰
          </div>
          <div class="stat-content">
            <h3 class="stat-value">₹{{ formatNumber(dashboardStats.totalRevenue) }}</h3>
            <p class="stat-label">Total Revenue</p>
            <div class="stat-trend">
              <span class="trend" :class="dashboardStats.paymentCollectionRate > 0 ? 'positive' : 'neutral'">
                {{ dashboardStats.paymentCollectionRate > 0 ? `${dashboardStats.paymentCollectionRate}% collected` : 'No payments' }}
              </span>
            </div>
          </div>
          <button class="stat-action">Collect</button>
        </div>
      </div>

      <!-- Quick Access Sections -->
      <div class="quick-access">
        <h2 class="section-title">Quick Access</h2>
        <div class="access-grid">
          <!-- Students Management -->
          <div class="access-card" @click="$router.push('/students')">
            <div class="access-icon student-access">
              👨‍🎓
            </div>
            <h3 class="access-title">Students</h3>
            <p class="access-desc">Manage student records, admissions, and profiles</p>
            <div class="access-stats">
              <span>{{ dashboardStats.activeStudents }} Active</span>
              <span>{{ dashboardStats.newAdmissions }} New</span>
            </div>
          </div>

          <!-- ID Card Generator -->
          <div class="access-card" @click="$router.push('/id-card')">
            <div class="access-icon idcard-access">
              🪪
            </div>
            <h3 class="access-title">ID Card Generator</h3>
            <p class="access-desc">Create and manage student ID cards</p>
            <div class="access-stats">
              <span>{{ dashboardStats.idCardsGenerated }} Generated</span>
              <span>{{ dashboardStats.pendingIdCards }} Pending</span>
            </div>
          </div>

          <!-- Results -->
          <div class="access-card" @click="$router.push('/results')">
            <div class="access-icon result-access">
              📈
            </div>
            <h3 class="access-title">Results</h3>
            <p class="access-desc">Upload, manage and publish exam results</p>
            <div class="access-stats">
              <span>{{ dashboardStats.resultsPublished }} Published</span>
              <span>{{ dashboardStats.resultsPending }} Pending</span>
            </div>
          </div>

          <!-- Exams -->
          <div class="access-card" @click="$router.push('/exams')">
            <div class="access-icon exam-access">
              📝
            </div>
            <h3 class="access-title">Exams</h3>
            <p class="access-desc">Schedule and manage examinations</p>
            <div class="access-stats">
              <span>{{ dashboardStats.upcomingExams }} Upcoming</span>
              <span>{{ dashboardStats.examsCompleted }} Completed</span>
            </div>
          </div>

          <!-- Payments -->
          <div class="access-card" @click="$router.push('/payments')">
            <div class="access-icon payment-access">
              💰
            </div>
            <h3 class="access-title">Payments</h3>
            <p class="access-desc">Manage fee collection and payments</p>
            <div class="access-stats">
              <span>{{ dashboardStats.paymentCollectionRate > 0 ? dashboardStats.paymentCollectionRate + '% Collected' : 'No payments' }}</span>
              <span>{{ dashboardStats.pendingPayments }} Pending</span>
            </div>
          </div>

          <!-- Notifications -->
          <div class="access-card" @click="$router.push('/notifications')">
            <div class="access-icon notification-access">
              🔔
            </div>
            <h3 class="access-title">Notifications</h3>
            <p class="access-desc">Send announcements and alerts</p>
            <div class="access-stats">
              <span>{{ dashboardStats.notificationsSent }} Sent</span>
              <span>{{ unreadNotifications }} Unread</span>
            </div>
          </div>

          <!-- Upload Syllabus -->
          <div class="access-card" @click="$router.push('/syllabus/upload')">
            <div class="access-icon syllabus-upload">
              📚
            </div>
            <h3 class="access-title">Upload Syllabus</h3>
            <p class="access-desc">Upload new syllabus and course materials</p>
            <div class="access-stats">
              <span>{{ dashboardStats.syllabusUploaded }} Uploaded</span>
              <span>{{ dashboardStats.latestSyllabus }}</span>
            </div>
          </div>

          <!-- Syllabus List -->
          <div class="access-card" @click="$router.push('/syllabus/list')">
            <div class="access-icon syllabus-list">
              📖
            </div>
            <h3 class="access-title">Syllabus List</h3>
            <p class="access-desc">View and manage all syllabus</p>
            <div class="access-stats">
              <span>{{ dashboardStats.totalSyllabus }} Total</span>
              <span>{{ dashboardStats.activeSyllabus }} Active</span>
            </div>
          </div>
        </div>
      </div>
      <!-- Charts Section -->
      <div class="charts-section">
        <div class="chart-container">
          <div class="chart-header">
            <h3 class="chart-title">Monthly Admissions Trend</h3>
            <select class="chart-select" v-model="selectedTimeRange" @change="updateChartData">
              <option value="month">Last Month</option>
              <option value="quarter">Last 3 Months</option>
              <option value="year">Last Year</option>
            </select>
          </div>
          <div class="chart-wrapper">
            <canvas ref="admissionsChart"></canvas>
          </div>
        </div>
        
        <div class="chart-container">
          <div class="chart-header">
            <h3 class="chart-title">Payment Collection Status</h3>
            <button class="chart-btn" @click="refreshChartData">Refresh</button>
          </div>
          <div class="chart-wrapper">
            <canvas ref="paymentChart"></canvas>
          </div>
        </div>
      </div>

      <!-- Recent Activity - REAL DATA -->
      <div class="recent-activity">
        <div class="activity-header">
          <h2 class="section-title">Recent Activity</h2>
          <button class="view-all-btn" @click="$router.push('/activity')">View All →</button>
        </div>
        <div v-if="recentActivities.length > 0" class="activity-list">
          <div class="activity-item" v-for="activity in recentActivities" :key="activity.id">
            <div class="activity-icon" :class="activity.type">
              {{ getActivityIcon(activity.type) }}
            </div>
            <div class="activity-content">
              <p class="activity-text">{{ activity.description }}</p>
              <p class="activity-time">{{ formatTime(activity.timestamp) }}</p>
            </div>
            <div class="activity-action">
              <button class="action-btn" @click="viewActivity(activity)">View</button>
            </div>
          </div>
        </div>
        <div v-else class="no-data">
          <div class="no-data-icon">📋</div>
          <p class="no-data-text">No recent activities</p>
          <p class="no-data-subtext">Actions will appear here as you use the system</p>
        </div>
      </div>

      <!-- Upcoming Tasks -->
      <div class="upcoming-tasks">
        <h2 class="section-title">Upcoming Tasks</h2>
        <div v-if="upcomingTasks.length > 0" class="tasks-list">
          <div class="task-item" v-for="task in upcomingTasks" :key="task.id">
            <div class="task-checkbox">
              <input type="checkbox" :id="'task-' + task.id" v-model="task.completed" @change="updateTask(task)">
              <label :for="'task-' + task.id"></label>
            </div>
            <div class="task-content">
              <h4 class="task-title">{{ task.title }}</h4>
              <p class="task-desc">{{ task.description }}</p>
              <div class="task-meta">
                <span class="task-deadline">Due: {{ task.deadline }}</span>
                <span class="task-priority" :class="task.priority">{{ task.priority }}</span>
              </div>
            </div>
            <div class="task-actions">
              <button class="task-btn" @click="editTask(task)">Edit</button>
              <button class="task-btn delete" @click="deleteTask(task.id)">Delete</button>
            </div>
          </div>
        </div>
        <div v-else class="no-data">
          <div class="no-data-icon">✅</div>
          <p class="no-data-text">No upcoming tasks</p>
          <p class="no-data-subtext">Add tasks to stay organized</p>
          <button class="add-task-btn" @click="addNewTask">Add Your First Task</button>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { signOut } from "firebase/auth";
import { auth } from "../firebase/firebase";
import { getFirestore, collection, getDocs, query, orderBy, limit, onSnapshot } from "firebase/firestore";
import Chart from 'chart.js/auto';

export default {
  name: 'AdminDashboard',
  data() {
    return {
      adminId: 'ADM-' + Date.now().toString().slice(-6),
      currentDate: new Date().toLocaleDateString('en-US', { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
      }),
      currentTime: new Date().toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit' 
      }),
      unreadNotifications: 0,
      selectedTimeRange: 'month',
      
      // Charts
      admissionsChart: null,
      paymentChart: null,
      
      // REAL DATA - Initially zero, will be updated from Firestore
      dashboardStats: {
        totalStudents: 0,
        newStudentsToday: 0,
        activeStudents: 0,
        newAdmissions: 0,
        pendingIdCards: 0,
        idCardsGenerated: 0,
        resultsPending: 0,
        resultsPublished: 0,
        totalRevenue: 0,
        paymentCollectionRate: 0,
        pendingPayments: 0,
        upcomingExams: 0,
        examsCompleted: 0,
        notificationsSent: 0,
        syllabusUploaded: 0,
        latestSyllabus: 'No syllabus yet',
        totalSyllabus: 0,
        activeSyllabus: 0
      },
      
      recentActivities: [],
      upcomingTasks: [],
      db: null,
      
      // Chart data
      chartData: {
        admissions: [],
        payments: []
      }
    };
  },
  async mounted() {
    this.updateTime();
    setInterval(this.updateTime, 60000);
    
    // Initialize Firestore
    this.db = getFirestore();
    
    // Load real data from Firestore
    await this.loadRealData();
    
    // Set up real-time listeners
    this.setupRealTimeListeners();
    
    // Initialize charts after DOM is rendered
    this.$nextTick(() => {
      this.initCharts();
    });
  },
  beforeUnmount() {
    // Destroy charts to prevent memory leaks
    if (this.admissionsChart) {
      this.admissionsChart.destroy();
    }
    if (this.paymentChart) {
      this.paymentChart.destroy();
    }
  },
  methods: {
    updateTime() {
      this.currentTime = new Date().toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit' 
      });
    },
    
    formatNumber(num) {
      return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    
    formatTime(timestamp) {
      if (!timestamp) return '';
      const now = new Date();
      const diff = now - timestamp.toDate();
      const minutes = Math.floor(diff / 60000);
      const hours = Math.floor(diff / 3600000);
      const days = Math.floor(diff / 86400000);
      
      if (minutes < 1) return 'Just now';
      if (minutes < 60) return `${minutes} minutes ago`;
      if (hours < 24) return `${hours} hours ago`;
      if (days === 1) return 'Yesterday';
      return timestamp.toDate().toLocaleDateString();
    },
    
    getActivityIcon(type) {
      const icons = {
        student: '👨‍🎓',
        idcard: '🪪',
        result: '📈',
        payment: '💰',
        exam: '📝',
        notification: '🔔',
        syllabus: '📚'
      };
      return icons[type] || '📋';
    },
    
    async loadRealData() {
      try {
        // Load students count
        const studentsSnapshot = await getDocs(collection(this.db, 'students'));
        this.dashboardStats.totalStudents = studentsSnapshot.size;
        
        // Load ID Cards count
        const idCardsSnapshot = await getDocs(collection(this.db, 'idCards'));
        this.dashboardStats.idCardsGenerated = idCardsSnapshot.size;
        this.dashboardStats.pendingIdCards = Math.max(0, this.dashboardStats.totalStudents - this.dashboardStats.idCardsGenerated);
        
        // Load results count
        const resultsSnapshot = await getDocs(collection(this.db, 'results'));
        this.dashboardStats.resultsPublished = resultsSnapshot.size;
        this.dashboardStats.resultsPending = Math.max(0, this.dashboardStats.totalStudents - this.dashboardStats.resultsPublished);
        
        // Load payments data
        const paymentsSnapshot = await getDocs(collection(this.db, 'payments'));
        let totalPaid = 0;
        paymentsSnapshot.forEach(doc => {
          const payment = doc.data();
          if (payment.status === 'paid') {
            totalPaid += parseFloat(payment.amount || 0);
          }
        });
        this.dashboardStats.totalRevenue = totalPaid;
        this.dashboardStats.pendingPayments = paymentsSnapshot.size;
        
        // Calculate collection rate
        this.dashboardStats.paymentCollectionRate = this.dashboardStats.totalStudents > 0 
          ? Math.round((paymentsSnapshot.size / this.dashboardStats.totalStudents) * 100)
          : 0;
        
        // Load recent activities
        await this.loadRecentActivities();
        
        // Load upcoming tasks
        await this.loadUpcomingTasks();
        
        // Load chart data
        await this.loadChartData();
        
      } catch (error) {
        console.error('Error loading real data:', error);
      }
    },
    
    async loadRecentActivities() {
      try {
        const activitiesRef = collection(this.db, 'activities');
        const q = query(activitiesRef, orderBy('timestamp', 'desc'), limit(5));
        const snapshot = await getDocs(q);
        
        this.recentActivities = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        
        this.dashboardStats.notificationsSent = this.recentActivities.length;
        
      } catch (error) {
        console.error('Error loading activities:', error);
      }
    },
    
    async loadUpcomingTasks() {
      try {
        const tasksRef = collection(this.db, 'tasks');
        const q = query(tasksRef, orderBy('deadline'), limit(4));
        const snapshot = await getDocs(q);
        
        this.upcomingTasks = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        
      } catch (error) {
        console.error('Error loading tasks:', error);
      }
    },
    
    async loadChartData() {
      // Generate sample data for charts
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const currentMonth = new Date().getMonth();
      
      // Admissions data (last 6 months)
      this.chartData.admissions = months.slice(Math.max(0, currentMonth - 5), currentMonth + 1);
      
      // Payment status data
      this.chartData.payments = [
        { status: 'Paid', count: this.dashboardStats.pendingPayments > 0 ? Math.floor(this.dashboardStats.pendingPayments * 0.7) : 0 },
        { status: 'Pending', count: this.dashboardStats.pendingPayments > 0 ? Math.floor(this.dashboardStats.pendingPayments * 0.3) : 0 },
        { status: 'Overdue', count: this.dashboardStats.pendingPayments > 0 ? Math.floor(this.dashboardStats.pendingPayments * 0.1) : 0 }
      ];
    },
    
    initCharts() {
      // Destroy existing charts
      if (this.admissionsChart) {
        this.admissionsChart.destroy();
      }
      if (this.paymentChart) {
        this.paymentChart.destroy();
      }
      
      // Admissions Trend Chart
      const admissionsCtx = this.$refs.admissionsChart?.getContext('2d');
      if (admissionsCtx) {
        this.admissionsChart = new Chart(admissionsCtx, {
          type: 'line',
          data: {
            labels: this.chartData.admissions,
            datasets: [{
              label: 'Student Admissions',
              data: this.generateAdmissionsData(),
              borderColor: '#667eea',
              backgroundColor: 'rgba(102, 126, 234, 0.1)',
              borderWidth: 2,
              fill: true,
              tension: 0.4
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                display: false
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                grid: {
                  color: 'rgba(0, 0, 0, 0.05)'
                },
                ticks: {
                  stepSize: 1
                }
              },
              x: {
                grid: {
                  color: 'rgba(0, 0, 0, 0.05)'
                }
              }
            }
          }
        });
      }
      
      // Payment Status Chart
      const paymentCtx = this.$refs.paymentChart?.getContext('2d');
      if (paymentCtx) {
        this.paymentChart = new Chart(paymentCtx, {
          type: 'doughnut',
          data: {
            labels: this.chartData.payments.map(p => p.status),
            datasets: [{
              data: this.chartData.payments.map(p => p.count),
              backgroundColor: [
                '#4CAF50', // Paid - Green
                '#FFC107', // Pending - Yellow
                '#F44336'  // Overdue - Red
              ],
              borderWidth: 1,
              borderColor: '#fff'
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                position: 'bottom',
                labels: {
                  padding: 20,
                  usePointStyle: true,
                  pointStyle: 'circle'
                }
              },
              tooltip: {
                callbacks: {
                  label: function(context) {
                    return `${context.label}: ${context.raw} payments`;
                  }
                }
              }
            },
            cutout: '70%'
          }
        });
      }
    },
    
    generateAdmissionsData() {
      // Generate random admissions data based on total students
      const baseValue = Math.max(1, Math.floor(this.dashboardStats.totalStudents / 12));
      return this.chartData.admissions.map(() => 
        Math.floor(Math.random() * baseValue * 2) + 1
      );
    },
    
    updateChartData() {
      // Update chart data based on selected time range
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const currentMonth = new Date().getMonth();
      
      switch(this.selectedTimeRange) {
        case 'month':
          this.chartData.admissions = months.slice(Math.max(0, currentMonth), currentMonth + 1);
          break;
        case 'quarter':
          this.chartData.admissions = months.slice(Math.max(0, currentMonth - 2), currentMonth + 1);
          break;
        case 'year':
          this.chartData.admissions = months;
          break;
      }
      
      this.initCharts();
    },
    
    refreshChartData() {
      this.loadChartData();
      this.initCharts();
    },
    
    setupRealTimeListeners() {
      // Real-time listener for students
      const studentsRef = collection(this.db, 'students');
      onSnapshot(studentsRef, (snapshot) => {
        this.dashboardStats.totalStudents = snapshot.size;
        this.dashboardStats.pendingIdCards = Math.max(0, this.dashboardStats.totalStudents - this.dashboardStats.idCardsGenerated);
        this.dashboardStats.resultsPending = Math.max(0, this.dashboardStats.totalStudents - this.dashboardStats.resultsPublished);
      });
      
      // Real-time listener for ID cards
      const idCardsRef = collection(this.db, 'idCards');
      onSnapshot(idCardsRef, (snapshot) => {
        this.dashboardStats.idCardsGenerated = snapshot.size;
        this.dashboardStats.pendingIdCards = Math.max(0, this.dashboardStats.totalStudents - this.dashboardStats.idCardsGenerated);
      });
      
      // Real-time listener for results
      const resultsRef = collection(this.db, 'results');
      onSnapshot(resultsRef, (snapshot) => {
        this.dashboardStats.resultsPublished = snapshot.size;
        this.dashboardStats.resultsPending = Math.max(0, this.dashboardStats.totalStudents - this.dashboardStats.resultsPublished);
      });
    },
    
    async logout() {
      try {
        await signOut(auth);
        this.$router.push('/login');
      } catch (error) {
        console.error('Logout error:', error);
        alert('Logout failed: ' + error.message);
      }
    },
    
    showNotifications() {
      this.$router.push('/notifications');
    },
    
    showSettings() {
      // Implement settings modal or page
      alert('Settings feature coming soon!');
    },
    
    viewActivity(activity) {
      switch(activity.type) {
        case 'student':
          this.$router.push('/students');
          break;
        case 'idcard':
          this.$router.push('/id-card');
          break;
        case 'result':
          this.$router.push('/results');
          break;
        case 'payment':
          this.$router.push('/payments');
          break;
        default:
          this.$router.push('/activity');
      }
    },
    
    updateTask(task) {
      console.log('Task updated:', task);
      // Implement API call to update task
    },
    
    editTask(task) {
      // Implement task editing
      alert(`Edit task: ${task.title}`);
    },
    
    deleteTask(taskId) {
      if (confirm('Are you sure you want to delete this task?')) {
        this.upcomingTasks = this.upcomingTasks.filter(task => task.id !== taskId);
      }
    },
    
    addNewTask() {
      const newTask = {
        id: Date.now(),
        title: 'Complete system setup',
        description: 'Finish configuring the school management system',
        deadline: 'Today, 6:00 PM',
        priority: 'high',
        completed: false
      };
      this.upcomingTasks.push(newTask);
    }
  }
};
</script>

<style scoped>
.admin-dashboard {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Main Content Styles */
.main-content {
  padding: 30px;
  max-width: 1400px;
  margin: 0 auto;
}

/* Top Header */
.top-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 10px;
  padding: 25px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #e1e8f0;
}

.header-left {
  flex: 1;
}

.page-title {
  margin: 0;
  font-size: 32px;
  font-weight: 500;
  color: #2c3e50;
  background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-subtitle {
  margin: 8px 0 15px;
  color: #5d6d7e;
  font-size: 16px;
}

.date-time {
  display: flex;
  gap: 20px;
  align-items: center;
}

.date, .time {
  font-size: 14px;
  color: #7f8c8d;
  background: #f8f9fa;
  padding: 6px 12px;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 25px;
}

.admin-info {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 20px;
  background: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e9ecef;
}

.admin-avatar {
  position: relative;
  width: 50px;
  height: 50px;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  font-weight: bold;
}

.admin-status {
  position: absolute;
  bottom: 2px;
  right: 2px;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 2px solid white;
}

.admin-status.online {
  background: #2ecc71;
}

.admin-details {
  display: flex;
  flex-direction: column;
}

.admin-name {
  margin: 0;
  font-weight: 600;
  color: #2c3e50;
  font-size: 16px;
}

.admin-role {
  margin: 2px 0;
  color: #7f8c8d;
  font-size: 13px;
}

.admin-id {
  margin: 2px 0 0;
  font-size: 11px;
  color: #95a5a6;
  font-family: 'Courier New', monospace;
  background: #ecf0f1;
  padding: 2px 6px;
  border-radius: 4px;
  display: inline-block;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.icon-btn {
  width: 50px;
  height: 50px;
  border: none;
  border-radius: 12px;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 1px solid #e1e8f0;
}

.icon-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border-color: #3498db;
}

.icon-btn .icon {
  font-size: 20px;
}

.notification-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #e74c3c;
  color: white;
  font-size: 10px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  border: 2px solid white;
}

.logout-button {
  padding: 14px 28px;
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
  border: none;
  border-radius: 12px;
  color: white;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 10px;
  box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
}

.logout-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 107, 107, 0.4);
  background: linear-gradient(135deg, #ff5252 0%, #e74c3c 100%);
}

/* Quick Stats - ICONS SMALLER */
.quick-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 10px;
  margin-bottom: 0px;
}

.stat-card {
  background: white;
  border-radius: 16px;
  padding: 25px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  border: 1px solid #e1e8f0;
  cursor: pointer;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: #3498db;
}

/* SMALLER ICONS */
.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px; /* Reduced from 32px */
}

.student-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.idcard-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.result-icon {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
}

.exam-icon {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
  color: white;
}

.payment-icon {
  background: linear-gradient(135deg, #ff9a9e 0%, #fad0c4 100%);
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  margin: 0;
  font-size: 32px;
  font-weight: 800;
  color: #2c3e50;
}

.stat-label {
  margin: 5px 0;
  color: #5d6d7e;
  font-size: 15px;
  font-weight: 500;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 8px;
}

.trend {
  font-size: 13px;
  font-weight: 600;
  padding: 3px 8px;
  border-radius: 6px;
}

.trend.positive {
  background: rgba(46, 204, 113, 0.1);
  color: #27ae60;
}

.trend.warning {
  background: rgba(241, 196, 15, 0.1);
  color: #f39c12;
}

.trend.neutral {
  background: rgba(52, 152, 219, 0.1);
  color: #3498db;
}

.stat-period {
  font-size: 12px;
  color: #95a5a6;
}

.stat-action {
  padding: 10px 20px;
  background: #f8f9fa;
  border: 1px solid #e1e8f0;
  border-radius: 8px;
  color: #3498db;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
}

.stat-action:hover {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

/* Charts Section */
.charts-section {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 25px;
  margin-bottom: 40px;
}

.chart-container {
  background: white;
  border-radius: 16px;
  padding: 25px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #e1e8f0;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.chart-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
}

.chart-select {
  padding: 8px 15px;
  border: 1px solid #e1e8f0;
  border-radius: 8px;
  font-size: 14px;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
}

.chart-select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
}

.chart-btn {
  padding: 8px 20px;
  background: #f8f9fa;
  border: 1px solid #e1e8f0;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.chart-btn:hover {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

.chart-wrapper {
  height: 300px;
  position: relative;
}

/* Quick Access - SMALLER ICONS */
.quick-access {
  margin-bottom: 30px;
}

.section-title {
  margin: 0 0 25px 0;
  font-size: 24px;
  font-weight: 700;
  color: #2c3e50;
  position: relative;
  padding-bottom: 10px;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 60px;
  height: 4px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 2px;
}

.access-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 25px;
}

.access-card {
  background: white;
  border-radius: 16px;
  padding: 25px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  border: 1px solid #e1e8f0;
  cursor: pointer;
}

.access-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  border-color: #3498db;
}

/* SMALLER ICONS */
.access-icon {
  width: 50px; /* Reduced from 60px */
  height: 50px; /* Reduced from 60px */
  border-radius: 10px; /* Reduced from 12px */
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px; /* Reduced from 28px */
  margin-bottom: 15px; /* Reduced from 20px */
}

.student-access { background: rgba(102, 126, 234, 0.1); color: #667eea; }
.idcard-access { background: rgba(79, 172, 254, 0.1); color: #4facfe; }
.result-access { background: rgba(67, 233, 123, 0.1); color: #43e97b; }
.exam-access { background: rgba(250, 112, 154, 0.1); color: #fa709a; }
.payment-access { background: rgba(255, 154, 158, 0.1); color: #ff9a9e; }
.notification-access { background: rgba(241, 196, 15, 0.1); color: #f1c40f; }
.syllabus-upload { background: rgba(155, 89, 182, 0.1); color: #9b59b6; }
.syllabus-list { background: rgba(52, 152, 219, 0.1); color: #3498db; }

.access-title {
  margin: 0 0 10px 0;
  font-size: 18px;
  font-weight: 700;
  color: #2c3e50;
}

.access-desc {
  margin: 0 0 15px 0;
  color: #5d6d7e;
  font-size: 14px;
  line-height: 1.5;
}

.access-stats {
  display: flex;
  justify-content: space-between;
  padding-top: 15px;
  border-top: 1px solid #e1e8f0;
  font-size: 13px;
  color: #7f8c8d;
}

.access-stats span {
  background: #f8f9fa;
  padding: 4px 10px;
  border-radius: 6px;
  border: 1px solid #e9ecef;
}

/* Recent Activity - SMALLER ICONS */
.recent-activity {
  background: white;
  border-radius: 16px;
  padding: 30px;
  margin-bottom: 40px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #e1e8f0;
}

.activity-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.view-all-btn {
  background: none;
  border: none;
  color: #3498db;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.view-all-btn:hover {
  background: #f8f9fa;
  color: #2980b9;
}

.activity-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.activity-item:hover {
  background: white;
  border-color: #3498db;
  transform: translateX(5px);
}

/* SMALLER ICONS */
.activity-icon {
  width: 40px; /* Reduced from 45px */
  height: 40px; /* Reduced from 45px */
  border-radius: 8px; /* Reduced from 10px */
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px; /* Reduced from 20px */
  flex-shrink: 0;
}

.activity-icon.student { background: rgba(102, 126, 234, 0.1); color: #667eea; }
.activity-icon.idcard { background: rgba(79, 172, 254, 0.1); color: #4facfe; }
.activity-icon.result { background: rgba(67, 233, 123, 0.1); color: #43e97b; }
.activity-icon.payment { background: rgba(255, 154, 158, 0.1); color: #ff9a9e; }
.activity-icon.notification { background: rgba(241, 196, 15, 0.1); color: #f1c40f; }

.activity-content {
  flex: 1;
}

.activity-text {
  margin: 0;
  font-weight: 500;
  color: #2c3e50;
  font-size: 15px;
}

.activity-time {
  margin: 5px 0 0;
  font-size: 13px;
  color: #7f8c8d;
}

.activity-action .action-btn {
  padding: 8px 20px;
  background: white;
  border: 1px solid #3498db;
  border-radius: 6px;
  color: #3498db;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.activity-action .action-btn:hover {
  background: #3498db;
  color: white;
}

/* Upcoming Tasks */
.upcoming-tasks {
  background: white;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #e1e8f0;
}

.tasks-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.task-item {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 12px;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.task-item:hover {
  background: white;
  border-color: #e1e8f0;
}

.task-checkbox {
  flex-shrink: 0;
}

.task-checkbox input[type="checkbox"] {
  display: none;
}

.task-checkbox label {
  width: 24px;
  height: 24px;
  border: 2px solid #bdc3c7;
  border-radius: 6px;
  display: block;
  cursor: pointer;
  position: relative;
  transition: all 0.3s ease;
}

.task-checkbox input[type="checkbox"]:checked + label {
  background: #2ecc71;
  border-color: #2ecc71;
}

.task-checkbox input[type="checkbox"]:checked + label::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 14px;
  font-weight: bold;
}

.task-content {
  flex: 1;
}

.task-title {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.task-desc {
  margin: 0 0 10px 0;
  color: #5d6d7e;
  font-size: 14px;
}

.task-meta {
  display: flex;
  gap: 15px;
  font-size: 13px;
}

.task-deadline {
  color: #e74c3c;
  font-weight: 500;
  background: rgba(231, 76, 60, 0.1);
  padding: 3px 8px;
  border-radius: 4px;
}

.task-priority {
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
}

.task-priority.high {
  background: rgba(231, 76, 60, 0.1);
  color: #e74c3c;
}

.task-priority.medium {
  background: rgba(241, 196, 15, 0.1);
  color: #f39c12;
}

.task-actions {
  display: flex;
  gap: 10px;
}

.task-btn {
  padding: 8px 16px;
  border: 1px solid #e1e8f0;
  background: white;
  border-radius: 6px;
  color: #5d6d7e;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.task-btn:hover {
  background: #f8f9fa;
  border-color: #3498db;
  color: #3498db;
}

.task-btn.delete:hover {
  background: #e74c3c;
  border-color: #e74c3c;
  color: white;
}

/* No Data States */
.no-data {
  text-align: center;
  padding: 60px 20px;
  background: #f8f9fa;
  border-radius: 12px;
  border: 2px dashed #dee2e6;
  margin: 20px 0;
}

.no-data-icon {
  font-size: 48px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.no-data-text {
  font-size: 18px;
  font-weight: 600;
  color: #6c757d;
  margin-bottom: 10px;
}

.no-data-subtext {
  font-size: 14px;
  color: #adb5bd;
  margin-bottom: 20px;
}

.add-task-btn {
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  color: white;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.add-task-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .charts-section {
    grid-template-columns: 1fr;
  }
  
  .access-grid {
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  }
}

@media (max-width: 992px) {
  .top-header {
    flex-direction: column;
    gap: 25px;
  }
  
  .header-right {
    width: 100%;
    justify-content: space-between;
  }
  
  .quick-stats {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .main-content {
    padding: 20px;
  }
  
  .quick-stats {
    grid-template-columns: 1fr;
  }
  
  .access-grid {
    grid-template-columns: 1fr;
  }
  
  .header-right {
    flex-direction: column;
    gap: 20px;
  }
  
  .admin-info {
    width: 100%;
    justify-content: center;
  }
  
  .header-actions {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 576px) {
  .page-title {
    font-size: 24px;
  }
  
  .stat-card {
    flex-direction: column;
    text-align: center;
  }
  
  .activity-item,
  .task-item {
    flex-direction: column;
    text-align: center;
    gap: 15px;
  }
  
  .task-actions {
    width: 100%;
    justify-content: center;
  }
}
</style>
