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
import IDCard from "../views/IDCard.vue";

// Layout
import AdminLayout from "../layouts/AdminLayout.vue";

const routes = [
  // 🔓 Public route
  { path: "/", component: Login },

  // 🔐 Protected admin routes under AdminLayout
  {
    path: "/",
    component: AdminLayout,
    meta: { requiresAuth: true },
    children: [
      { path: "dashboard", component: Dashboard },
      { path: "students", component: Students },
      { path: "exams", component: Exams },
      { path: "payments", component: Payments },
      { path: "notifications", component: Notifications }, // ✅ COMMA added
      { path: "idcard", component: IDCard } // ✅ ID Card
    ]
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// 🔐 Auth Guard
router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth) {
    onAuthStateChanged(auth, (user) => {
      if (user) {
        next();
      } else {
        next("/");  // Redirect to login if not authenticated
      }
    });
  } else {
    next();
  }
});

export default router;
