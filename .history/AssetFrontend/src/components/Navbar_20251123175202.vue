<template>
  <nav class="navbar">
    <div class="nav-left">
      <h2 class="logo">Asset Management System</h2>
    </div>
    
    <div class="nav-center">
      <ul>
        <li><router-link to="/dashboard">Dashboard</router-link></li>
        <li><router-link to="/assets">Assets</router-link></li>
      </ul>
    </div>

    <div class="nav-right">
      <span class="welcome">Welcome, {{ username }}</span>
      <button class="logout-btn" @click="logout">Logout</button>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from "vue";

const username = ref("");

onMounted(() => {
  username.value = localStorage.getItem('username') || 'Guest';
});

function logout() {
  localStorage.clear();
  window.location.href = "/";
}
</script>

<style scoped>
@import "../css-styling/navbar.css";
</style>