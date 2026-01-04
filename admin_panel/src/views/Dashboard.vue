<template>
  <div class="admin-dashboard">
    <!-- Main Content Only - Sidebar Removed -->
    <main class="main-content">
      <!-- Top Header -->
      <header class="top-header">
        <div class="header-left">
          <h1 class="page-title">Admin Dashboard</h1>
          <p class="page-subtitle">Welcome back! Here's what's happening today.</p>
        </div>
        
        <div class="header-right">
          <div class="search-box">
            <input type="text" placeholder="Search..." class="search-input">
            <span class="search-icon">🔍</span>
          </div>
          <div class="header-actions">
            <button class="icon-btn notification-btn">
              <span class="icon">🔔</span>
              <span class="notification-badge">3</span>
            </button>
            <button class="icon-btn">
              <span class="icon">⚙️</span>
            </button>
            <button @click="logout" class="logout-button">
              <span class="logout-icon">🚪</span>
              <span class="logout-text">Logout</span>
            </button>
          </div>
        </div>
      </header>

      <!-- Stats Cards -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon" style="background: #4CAF50;">
            👥
          </div>
          <div class="stat-content">
            <h3 class="stat-value">1,248</h3>
            <p class="stat-label">Total Users</p>
            <p class="stat-change positive">↑ 12% from last month</p>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon" style="background: #2196F3;">
            📈
          </div>
          <div class="stat-content">
            <h3 class="stat-value">24.5K</h3>
            <p class="stat-label">Page Views</p>
            <p class="stat-change positive">↑ 8% from last week</p>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon" style="background: #FF9800;">
            💰
          </div>
          <div class="stat-content">
            <h3 class="stat-value">$12,450</h3>
            <p class="stat-label">Revenue</p>
            <p class="stat-change positive">↑ 5% from yesterday</p>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon" style="background: #9C27B0;">
            ✅
          </div>
          <div class="stat-content">
            <h3 class="stat-value">89%</h3>
            <p class="stat-label">Engagement Rate</p>
            <p class="stat-change negative">↓ 2% from last month</p>
          </div>
        </div>
      </div>

      <!-- Charts Section -->
      <div class="content-grid">
        <div class="content-card">
          <div class="card-header">
            <h3 class="card-title">Monthly Traffic</h3>
            <select class="card-select">
              <option>Last 30 Days</option>
              <option>Last 90 Days</option>
              <option>This Year</option>
            </select>
          </div>
          <div class="chart-placeholder">
            <div class="chart-bar" style="height: 80%;"></div>
            <div class="chart-bar" style="height: 60%;"></div>
            <div class="chart-bar" style="height: 90%;"></div>
            <div class="chart-bar" style="height: 70%;"></div>
            <div class="chart-bar" style="height: 85%;"></div>
          </div>
        </div>

        <div class="content-card">
          <div class="card-header">
            <h3 class="card-title">Recent Activity</h3>
            <button class="card-btn">View All</button>
          </div>
          <div class="activity-list">
            <div class="activity-item">
              <div class="activity-icon new-user">👤</div>
              <div class="activity-content">
                <p class="activity-text">New user registration</p>
                <p class="activity-time">2 minutes ago</p>
              </div>
            </div>
            <div class="activity-item">
              <div class="activity-icon payment">💳</div>
              <div class="activity-content">
                <p class="activity-text">Payment received</p>
                <p class="activity-time">1 hour ago</p>
              </div>
            </div>
            <div class="activity-item">
              <div class="activity-icon content">📝</div>
              <div class="activity-content">
                <p class="activity-text">Content published</p>
                <p class="activity-time">3 hours ago</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="quick-actions">
        <h3 class="section-title">Quick Actions</h3>
        <div class="actions-grid">
          <button class="action-btn">
            <span class="action-icon">➕</span>
            <span class="action-text">Add User</span>
          </button>
          <button class="action-btn">
            <span class="action-icon">📤</span>
            <span class="action-text">Export Data</span>
          </button>
          <button class="action-btn">
            <span class="action-icon">📋</span>
            <span class="action-text">Generate Report</span>
          </button>
          <button class="action-btn">
            <span class="action-icon">🔧</span>
            <span class="action-text">System Check</span>
          </button>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { adminLogout } from "../services/authService";

export default {
  methods: {
    async logout() {
      try {
        await adminLogout();
        this.$router.push("/");
      } catch (error) {
        console.error("Logout error:", error);
      }
    }
  }
};
</script>

<style scoped>
.admin-dashboard {
  min-height: 100vh;
  background: #f5f7fa;
}

/* Main Content Styles */
.main-content {
  padding: 30px;
  overflow-y: auto;
}

.top-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
  padding-bottom: 20px;
  border-bottom: 1px solid #e0e6ed;
}

.page-title {
  margin: 0;
  font-size: 32px;
  font-weight: 700;
  color: #2c3e50;
}

.page-subtitle {
  margin: 8px 0 0;
  color: #7a828a;
  font-size: 15px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.search-box {
  position: relative;
}

.search-input {
  padding: 12px 20px 12px 45px;
  border: 1px solid #e0e6ed;
  border-radius: 8px;
  width: 300px;
  font-size: 14px;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: #4CAF50;
  box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
}

.search-icon {
  position: absolute;
  left: 15px;
  top: 50%;
  transform: translateY(-50%);
  color: #7a828a;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.icon-btn {
  width: 45px;
  height: 45px;
  border: 1px solid #e0e6ed;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon-btn:hover {
  background: #f8f9fa;
  transform: translateY(-2px);
}

.logout-button {
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  color: white;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 10px;
}

.logout-button:hover {
  background: linear-gradient(135deg, #5a6fd8 0%, #654394 100%);
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.notification-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #FF5722;
  color: white;
  font-size: 10px;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 25px;
  margin-bottom: 40px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 25px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  border: 1px solid #e0e6ed;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  margin: 0;
  font-size: 32px;
  font-weight: 700;
  color: #2c3e50;
}

.stat-label {
  margin: 5px 0;
  color: #7a828a;
  font-size: 14px;
}

.stat-change {
  margin: 5px 0 0;
  font-size: 13px;
  font-weight: 500;
}

.stat-change.positive {
  color: #4CAF50;
}

.stat-change.negative {
  color: #FF5722;
}

/* Content Grid */
.content-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 25px;
  margin-bottom: 40px;
}

.content-card {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #e0e6ed;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.card-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #2c3e50;
}

.card-select {
  padding: 8px 15px;
  border: 1px solid #e0e6ed;
  border-radius: 6px;
  font-size: 14px;
  background: white;
  cursor: pointer;
}

.card-btn {
  padding: 8px 20px;
  background: #f8f9fa;
  border: 1px solid #e0e6ed;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.card-btn:hover {
  background: #e9ecef;
}

.chart-placeholder {
  height: 200px;
  display: flex;
  align-items: flex-end;
  gap: 20px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

.chart-bar {
  flex: 1;
  background: linear-gradient(to top, #4CAF50, #8BC34A);
  border-radius: 4px 4px 0 0;
  min-height: 10px;
}

.activity-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.activity-item:hover {
  background: #e9ecef;
}

.activity-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}

.activity-icon.new-user {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.activity-icon.payment {
  background: rgba(33, 150, 243, 0.1);
  color: #2196F3;
}

.activity-icon.content {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
}

.activity-content {
  flex: 1;
}

.activity-text {
  margin: 0;
  font-weight: 500;
  color: #2c3e50;
}

.activity-time {
  margin: 4px 0 0;
  font-size: 13px;
  color: #7a828a;
}

/* Quick Actions */
.quick-actions {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #e0e6ed;
}

.quick-actions .section-title {
  margin: 0 0 25px 0;
  font-size: 20px;
  font-weight: 600;
  color: #2c3e50;
  opacity: 1;
  text-transform: none;
  letter-spacing: normal;
  padding: 0;
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.action-btn {
  padding: 20px;
  background: #f8f9fa;
  border: 2px dashed #e0e6ed;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn:hover {
  background: white;
  border-color: #4CAF50;
  transform: translateY(-2px);
}

.action-icon {
  font-size: 32px;
}

.action-text {
  font-weight: 500;
  color: #2c3e50;
  font-size: 15px;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .content-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .top-header {
    flex-direction: column;
    gap: 20px;
    text-align: center;
  }
  
  .header-right {
    width: 100%;
    justify-content: center;
    flex-wrap: wrap;
  }
  
  .search-input {
    width: 100%;
  }
}
</style>