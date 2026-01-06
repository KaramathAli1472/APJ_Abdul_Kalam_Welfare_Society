<template>
  <div class="notifications-container">
    <div class="header-section">
      <h2 class="page-title">📢 Notifications Management</h2>
      <p class="page-subtitle">Send and manage notifications for students</p>
    </div>

    <div class="card send-notification-card">
      <h3 class="card-title">Send New Notification</h3>
      <form @submit.prevent="sendNotification" class="notification-form">
        <div class="form-group">
          <label for="title">Title</label>
          <input
            v-model="title"
            id="title"
            placeholder="Enter notification title"
            required
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label for="message">Message</label>
          <textarea
            v-model="message"
            id="message"
            placeholder="Enter notification message"
            required
            rows="4"
            class="form-textarea"
          ></textarea>
        </div>

        <div class="form-group">
          <label for="target">Target Audience</label>
          <select v-model="target" id="target" class="form-select">
            <option value="all">All Students</option>
            <option value="course">Specific Course</option>
            <option value="year">By Year Level</option>
            <option value="department">By Department</option>
          </select>
        </div>

        <div class="form-actions">
          <button type="button" class="btn btn-secondary" @click="clearForm">
            Clear
          </button>
          <button type="submit" class="btn btn-primary">
            <span class="btn-icon">✉️</span> Send Notification
          </button>
        </div>
      </form>
    </div>

    <div class="card notifications-list-card">
      <div class="card-header">
        <h3 class="card-title">All Notifications</h3>
        <div class="notification-count">{{ notifications.length }} total</div>
      </div>

      <div v-if="notifications.length === 0" class="empty-state">
        <div class="empty-icon">📭</div>
        <p>No notifications sent yet</p>
      </div>

      <ul v-else class="notifications-list">
        <li v-for="note in notifications" :key="note.id" class="notification-item">
          <div class="notification-header">
            <span class="notification-title">{{ note.title }}</span>
            <span class="notification-target" :class="getTargetClass(note.target)">
              {{ formatTarget(note.target) }}
            </span>
          </div>
          <p class="notification-message">{{ note.message }}</p>
          <div class="notification-footer">
            <span class="notification-time">Sent: {{ formatDate(note.timestamp) }}</span>
            <span class="notification-status">Status: {{ note.status || 'Sent' }}</span>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import { getNotifications, addNotification } from "../services/notificationService";

export default {
  data() {
    return {
      notifications: [],
      title: "",
      message: "",
      target: "all"
    };
  },
  async created() {
    this.notifications = await getNotifications();
  },
  methods: {
    async sendNotification() {
      // Add timestamp for demo purposes
      const newNotification = {
        title: this.title,
        message: this.message,
        target: this.target,
        timestamp: new Date().toISOString(),
        status: 'Sent'
      };

      await addNotification(newNotification);
      this.notifications = await getNotifications();
      this.title = this.message = "";
      this.showToast("Notification sent successfully!");
    },

    clearForm() {
      this.title = "";
      this.message = "";
      this.target = "all";
    },

    getTargetClass(target) {
      const targetClasses = {
        all: 'target-all',
        course: 'target-course',
        year: 'target-year',
        department: 'target-department'
      };
      return targetClasses[target] || 'target-all';
    },

    formatTarget(target) {
      const targetLabels = {
        all: 'All Students',
        course: 'Specific Course',
        year: 'Year Level',
        department: 'Department'
      };
      return targetLabels[target] || target;
    },

    formatDate(timestamp) {
      if (!timestamp) return 'Just now';
      const date = new Date(timestamp);
      return date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    },

    showToast(message) {
      // Simple toast notification
      const toast = document.createElement('div');
      toast.className = 'toast-notification';
      toast.textContent = message;
      document.body.appendChild(toast);

      setTimeout(() => {
        toast.classList.add('show');
      }, 10);

      setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => {
          document.body.removeChild(toast);
        }, 300);
      }, 3000);
    }
  }
};
</script>

<style scoped>
.notifications-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.header-section {
  margin-bottom: 30px;
  text-align: center;
}

.page-title {
  font-size: 28px;
  color: #2c3e50;
  margin-bottom: 8px;
}

.page-subtitle {
  color: #7f8c8d;
  font-size: 16px;
}

.card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  padding: 24px;
  margin-bottom: 24px;
  border: 1px solid #eaeaea;
}

.send-notification-card {
  border-top: 4px solid #3498db;
}

.notifications-list-card {
  border-top: 4px solid #2ecc71;
}

.card-title {
  font-size: 20px;
  color: #2c3e50;
  margin-bottom: 20px;
  font-weight: 600;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.notification-count {
  background: #f8f9fa;
  color: #6c757d;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #495057;
}

.form-input,
.form-textarea,
.form-select {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  transition: border 0.3s, box-shadow 0.3s;
  box-sizing: border-box;
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2);
}

.form-textarea {
  resize: vertical;
  min-height: 100px;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 24px;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-primary {
  background: #3498db;
  color: white;
}

.btn-primary:hover {
  background: #2980b9;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(52, 152, 219, 0.3);
}

.btn-secondary {
  background: #f8f9fa;
  color: #495057;
  border: 1px solid #dee2e6;
}

.btn-secondary:hover {
  background: #e9ecef;
}

.btn-icon {
  font-size: 18px;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #95a5a6;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.5;
}

.notifications-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.notification-item {
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  transition: background 0.2s;
}

.notification-item:hover {
  background: #f8fafc;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.notification-title {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
}

.notification-target {
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 12px;
  font-weight: 500;
}

.target-all {
  background: #e3f2fd;
  color: #1565c0;
}

.target-course {
  background: #e8f5e9;
  color: #2e7d32;
}

.target-year {
  background: #fff3e0;
  color: #ef6c00;
}

.target-department {
  background: #f3e5f5;
  color: #7b1fa2;
}

.notification-message {
  color: #546e7a;
  line-height: 1.6;
  margin-bottom: 16px;
}

.notification-footer {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  color: #78909c;
}

.notification-status {
  color: #43a047;
  font-weight: 500;
}

/* Toast notification styles */
.toast-notification {
  position: fixed;
  bottom: 24px;
  right: 24px;
  background: #27ae60;
  color: white;
  padding: 16px 24px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  opacity: 0;
  transform: translateY(20px);
  transition: opacity 0.3s, transform 0.3s;
}

.toast-notification.show {
  opacity: 1;
  transform: translateY(0);
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .notifications-container {
    padding: 16px;
  }

  .card {
    padding: 20px;
  }

  .notification-header {
    flex-direction: column;
    gap: 8px;
  }

  .notification-footer {
    flex-direction: column;
    gap: 8px;
  }

  .form-actions {
    flex-direction: column;
  }

  .btn {
    width: 100%;
  }
}
</style>