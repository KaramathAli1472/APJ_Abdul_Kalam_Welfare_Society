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
          <li class="nav-item">
            <router-link to="/dashboard" class="nav-link" active-class="active">
              <span class="nav-icon">📊</span>
              <span class="nav-text">Dashboard</span>
              <span class="nav-badge" v-if="!isCollapsed">3</span>
            </router-link>
          </li>
          
          <li class="nav-item">
            <router-link to="/students" class="nav-link" active-class="active">
              <span class="nav-icon">👨‍🎓</span>
              <span class="nav-text">Students</span>
              <span class="nav-badge" v-if="!isCollapsed">24</span>
            </router-link>
          </li>
          
          <li class="nav-item">
            <router-link to="/exams" class="nav-link" active-class="active">
              <span class="nav-icon">📝</span>
              <span class="nav-text">Exams</span>
              <span class="nav-badge new" v-if="!isCollapsed">5</span>
            </router-link>
          </li>
          
          <li class="nav-item">
            <router-link to="/payments" class="nav-link" active-class="active">
              <span class="nav-icon">💰</span>
              <span class="nav-text">Payments</span>
              <span class="nav-badge" v-if="!isCollapsed">12</span>
            </router-link>
          </li>
          
          <li class="nav-item">
            <router-link to="/notifications" class="nav-link" active-class="active">
              <span class="nav-icon">🔔</span>
              <span class="nav-text">Notifications</span>
              <span class="nav-badge new" v-if="!isCollapsed">8</span>
            </router-link>
          </li>

          <!-- Divider -->
          <div class="nav-divider" v-if="!isCollapsed">
            <span>Quick Actions</span>
          </div>

          <!-- Quick Actions (Visible when not collapsed) -->
          <div class="quick-actions" v-if="!isCollapsed">
            <button class="quick-btn">
              <span class="quick-icon">📤</span>
              Export Data
            </button>
            <button class="quick-btn">
              <span class="quick-icon">📋</span>
              Generate Report
            </button>
          </div>

          <!-- User Profile -->
          <div class="user-profile" v-if="!isCollapsed">
            <div class="user-avatar">
              <img src="https://via.placeholder.com/40" alt="Admin" class="avatar-img">
            </div>
            <div class="user-info">
              <p class="user-name">Admin User</p>
              <p class="user-role">Administrator</p>
            </div>
            <button class="logout-btn" @click="logout">
              <span class="logout-icon">🚪</span>
            </button>
          </div>
        </ul>
      </div>
    </nav>

    <!-- Main Content Area -->
    <main class="main-content" :class="{ 'sidebar-collapsed': isCollapsed }">
      <!-- This is where your dashboard content will be rendered -->
      <slot></slot>
    </main>
  </div>
</template>

<script>
export default {
  name: 'AdminLayout',
  data() {
    return {
      isCollapsed: false
    };
  },
  methods: {
    toggleMenu() {
      this.isCollapsed = !this.isCollapsed;
    },
    logout() {
      // Add logout logic here
      console.log('Logging out...');
      // Example: this.$store.dispatch('logout');
      // this.$router.push('/login');
    }
  }
};
</script>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: #f5f7fa;
}

/* Sidebar Styles */
.sidebar {
  width: 280px;
  min-width: 280px;
  background: linear-gradient(180deg, #2c3e50 0%, #1a2530 100%);
  color: white;
  transition: all 0.3s ease;
  box-shadow: 4px 0 20px rgba(0, 0, 0, 0.2);
  display: flex;
  flex-direction: column;
  height: 100vh;
  position: sticky;
  top: 0;
  left: 0;
  z-index: 100;
}

.sidebar.collapsed {
  width: 80px;
  min-width: 80px;
}

.sidebar-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

/* Sidebar Header */
.sidebar-header {
  padding: 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  min-height: 80px;
  flex-shrink: 0;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 12px;
  transition: opacity 0.3s ease;
}

.logo-icon {
  font-size: 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.logo-text {
  overflow: hidden;
  transition: opacity 0.3s ease;
}

.logo-title {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  line-height: 1.2;
}

.logo-subtitle {
  margin: 2px 0 0;
  font-size: 11px;
  opacity: 0.7;
  font-weight: 500;
}

.menu-toggle {
  width: 35px;
  height: 35px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  flex-shrink: 0;
}

.menu-toggle:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: rotate(90deg);
}

.toggle-icon {
  font-size: 20px;
  font-weight: bold;
}

/* Navigation Menu */
.nav-menu {
  list-style: none;
  padding: 20px 0;
  margin: 0;
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.nav-item {
  margin: 4px 15px;
}

.nav-link {
  display: flex;
  align-items: center;
  padding: 14px 20px;
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  border-radius: 10px;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.nav-link:hover {
  background: rgba(255, 255, 255, 0.05);
  color: white;
  transform: translateX(5px);
}

.nav-link.active {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.2) 0%, rgba(118, 75, 162, 0.2) 100%);
  color: white;
  border-left: 4px solid #667eea;
}

.nav-icon {
  font-size: 20px;
  margin-right: 15px;
  width: 24px;
  text-align: center;
  flex-shrink: 0;
}

.nav-text {
  flex: 1;
  font-size: 15px;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: opacity 0.3s ease;
}

.nav-badge {
  background: #4CAF50;
  color: white;
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 10px;
  font-weight: 600;
  min-width: 20px;
  text-align: center;
}

.nav-badge.new {
  background: #FF5722;
}

/* Divider */
.nav-divider {
  padding: 20px 20px 10px;
  margin-top: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.nav-divider span {
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 1px;
  opacity: 0.5;
  font-weight: 600;
}

/* Quick Actions */
.quick-actions {
  padding: 0 20px 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: auto;
}

.quick-btn {
  padding: 12px 15px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  color: white;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.quick-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-2px);
}

.quick-icon {
  font-size: 16px;
}

/* User Profile */
.user-profile {
  padding: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  gap: 15px;
  background: rgba(0, 0, 0, 0.1);
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.user-info {
  flex: 1;
  min-width: 0;
}

.user-name {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  line-height: 1.2;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-role {
  margin: 2px 0 0;
  font-size: 12px;
  opacity: 0.7;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.logout-btn {
  width: 35px;
  height: 35px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.1);
  border: none;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.logout-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: rotate(15deg);
}

/* Collapsed State */
.sidebar.collapsed .logo-text,
.sidebar.collapsed .nav-text,
.sidebar.collapsed .nav-badge,
.sidebar.collapsed .nav-divider,
.sidebar.collapsed .quick-actions,
.sidebar.collapsed .user-info,
.sidebar.collapsed .logout-btn {
  display: none;
}

.sidebar.collapsed .sidebar-header {
  justify-content: center;
  padding: 20px 10px;
}

.sidebar.collapsed .logo-container {
  justify-content: center;
}

.sidebar.collapsed .nav-link {
  padding: 15px;
  justify-content: center;
}

.sidebar.collapsed .nav-icon {
  margin-right: 0;
  font-size: 22px;
}

.sidebar.collapsed .user-profile {
  padding: 15px 10px;
  justify-content: center;
}

/* Main Content Area */
.main-content {
  flex: 1;
  padding: 30px;
  overflow-y: auto;
  background: #f5f7fa;
  min-height: 100vh;
  transition: margin-left 0.3s ease;
}

.main-content.sidebar-collapsed {
  margin-left: 0;
}

/* Scrollbar Styling */
.nav-menu::-webkit-scrollbar {
  width: 6px;
}

.nav-menu::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
}

.nav-menu::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
}

.nav-menu::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.2);
}

/* Responsive Design */
@media (max-width: 768px) {
  .admin-layout {
    flex-direction: column;
  }
  
  .sidebar {
    width: 100%;
    height: auto;
    position: relative;
    min-height: auto;
  }
  
  .sidebar.collapsed {
    width: 100%;
  }
  
  .main-content {
    padding: 20px;
  }
  
  .nav-menu {
    max-height: 400px;
    overflow-y: auto;
  }
}

/* Animations */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.nav-item {
  animation: fadeIn 0.3s ease forwards;
}

.nav-item:nth-child(1) { animation-delay: 0.05s; }
.nav-item:nth-child(2) { animation-delay: 0.1s; }
.nav-item:nth-child(3) { animation-delay: 0.15s; }
.nav-item:nth-child(4) { animation-delay: 0.2s; }
.nav-item:nth-child(5) { animation-delay: 0.25s; }
</style>