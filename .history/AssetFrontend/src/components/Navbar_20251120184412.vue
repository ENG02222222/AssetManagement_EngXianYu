<template>
  <nav class="navbar">
    <ul>
      <li><router-link to="/dashboard">Dashboard</router-link></li>
      <li><router-link to="/assets">Assets</router-link></li>
      <li><a href="#" @click="logout">Logout</a></li>
    </ul>
  </nav>
</template>

<script setup>
import { useAuthStore } from "../stores/auth";
const auth = useAuthStore();

function logout() {
  auth.logout();
  window.location.href = "/";
}
</script>

<style scoped>
.navbar {
  background: #333;
  padding: 12px;
}
.navbar ul {
  display: flex;
  gap: 20px;
  list-style: none;
}
.navbar a {
  color: #fff;
  text-decoration: none;
  font-weight: bold;
}
.navbar a:hover {
  text-decoration: underline;
}
</style>
