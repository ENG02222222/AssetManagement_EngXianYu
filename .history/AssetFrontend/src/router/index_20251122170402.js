import { createRouter, createWebHistory } from "vue-router";
import LoginPage from "../pages/LoginPage.vue";
import DashboardPage from "../pages/DashboardPage.vue";
import AssetsPage from "../pages/AssetsPage.vue";

const routes = [
  { path: "/", name: "Login", component: LoginPage },
  { path: "/dashboard", name: "Dashboard", component: DashboardPage },
  { path: "/assets", component: AssetsPage },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const user = localStorage.getItem("role");
  if (!user && to.path !== "/") {
    return next("/");
  }
  next();
});

export default router;
