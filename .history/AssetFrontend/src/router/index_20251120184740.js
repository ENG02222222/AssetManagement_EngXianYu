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

export default router;
