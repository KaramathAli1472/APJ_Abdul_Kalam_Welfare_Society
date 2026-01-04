<template>
  <div class="admin-login-container">
    <div class="login-card">
      <div class="login-header">
        <h2 class="login-title">Admin Login</h2>
        <p class="login-subtitle">Enter your credentials to access the dashboard</p>
      </div>

      <div class="login-form">
        <div class="input-group">
          <label for="email">Email Address</label>
          <input 
            id="email"
            v-model="email"
            type="email" 
            placeholder="admin@example.com"
            class="form-input"
          />
          <i class="input-icon">📧</i>
        </div>

        <div class="input-group">
          <label for="password">Password</label>
          <div class="password-input-wrapper">
            <input 
              id="password"
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="Enter your password"
              class="form-input"
            />
            <i class="input-icon">🔒</i>
            <button 
              type="button"
              class="password-toggle"
              @click="showPassword = !showPassword"
            >
              {{ showPassword ? '👁️' : '👁️‍🗨️' }}
            </button>
          </div>
        </div>

        <button 
          @click="login" 
          class="login-button"
          :disabled="!email || !password"
        >
          <span v-if="!loading">Login</span>
          <div v-else class="spinner"></div>
        </button>

        <div v-if="error" class="error-message">
          ⚠️ {{ error }}
        </div>
      </div>

      <div class="login-footer">
        <p class="footer-text">© 2024 Admin Panel. All rights reserved.</p>
      </div>
    </div>
  </div>
</template>

<script>
import { adminLogin } from "../services/authService";

export default {
  data() {
    return { 
      email: "", 
      password: "", 
      error: "",
      showPassword: false,
      loading: false
    };
  },
  methods: {
    async login() {
      if (!this.email || !this.password) {
        this.error = "Please fill in all fields";
        return;
      }

      this.loading = true;
      this.error = "";

      try {
        await adminLogin(this.email, this.password);
        this.$router.push("/dashboard");
      } catch (e) {
        this.error = "Invalid email or password. Please try again.";
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.admin-login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  width: 100%;
  max-width: 420px;
  overflow: hidden;
}

.login-header {
  padding: 40px 40px 20px;
  text-align: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.login-title {
  margin: 0;
  font-size: 28px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.login-subtitle {
  margin: 8px 0 0;
  opacity: 0.9;
  font-size: 14px;
}

.login-form {
  padding: 40px;
}

.input-group {
  margin-bottom: 24px;
}

.input-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.input-group .form-input {
  width: 100%;
  padding: 14px 16px 14px 48px;
  border: 2px solid #e1e5e9;
  border-radius: 10px;
  font-size: 16px;
  transition: all 0.3s ease;
  box-sizing: border-box;
}

.input-group .form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.password-input-wrapper {
  position: relative;
}

.input-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 18px;
}

.password-toggle {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  font-size: 18px;
  padding: 4px;
}

.login-button {
  width: 100%;
  padding: 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 10px;
  position: relative;
  height: 52px;
}

.login-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.login-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.spinner {
  width: 24px;
  height: 24px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s ease-in-out infinite;
  margin: 0 auto;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-message {
  margin-top: 20px;
  padding: 12px;
  background: #fff5f5;
  border: 1px solid #fed7d7;
  border-radius: 8px;
  color: #c53030;
  font-size: 14px;
  text-align: center;
  animation: shake 0.5s ease-in-out;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

.login-footer {
  padding: 20px;
  text-align: center;
  border-top: 1px solid #e1e5e9;
  background: #f8f9fa;
}

.footer-text {
  margin: 0;
  font-size: 12px;
  color: #6c757d;
}

@media (max-width: 480px) {
  .login-card {
    max-width: 100%;
  }
  
  .login-header,
  .login-form {
    padding: 30px 20px;
  }
}
</style>