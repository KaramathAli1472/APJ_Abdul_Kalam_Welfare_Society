// router/index.js
import { createRouter, createWebHistory } from "vue-router";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "../firebase/firebase";

// Views
import Login from "../views/Login.vue";
import Dashboard from "../views/Dashboard.vue";
import Students from "../views/Students.vue";
import Exams from "../views/Exams.vue";
import Payments from "../views/Payments.vue";
import Notifications from "../views/Notifications.vue";
import IDCard from "../views/IDCard.vue"; // 🔥 EXISTING ID Card component

// Layout
import AdminLayout from "../layouts/AdminLayout.vue";

// Syllabus Screens
import UploadSyllabus from "../views/syllabus/UploadSyllabus.vue";
import SyllabusList from "../views/syllabus/SyllabusList.vue";

const routes = [
  // Public route (Login)
  {
    path: "/",
    component: Login,
    beforeEnter: (to, from, next) => {
      const user = auth.currentUser;
      if (user) next("/dashboard"); // Redirect logged-in users to dashboard
      else next();
    }
  },

  // Protected admin routes
  {
    path: "/",
    component: AdminLayout,
    meta: { requiresAuth: true },
    children: [
      { path: "dashboard", component: Dashboard },
      { path: "students", component: Students },
      
      // 🔥 ID Card Route
      { 
        path: "id-card", 
        component: IDCard,
        name: "IDCard"
      },
      
      { path: "exams", component: Exams },
      { path: "payments", component: Payments },
      { path: "notifications", component: Notifications },

      // Syllabus routes
      { path: "syllabus/upload", component: UploadSyllabus },
      { path: "syllabus/list", component: SyllabusList }
    ]
  },

  // Redirect unknown routes to login
  { path: "/:catchAll(.*)", redirect: "/" }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Auth Guard
router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth) {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      unsubscribe(); // Avoid multiple triggers
      if (user) next();
      else next("/"); // Redirect to login
    });
  } else {
    next();
  }
});

export default router;