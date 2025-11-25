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
.navbar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 0 30px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 70px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin: 0;
}

.nav-left .logo {
  color: white;
  font-size: 22px;
  font-weight: 600;
  margin: 0;
}

.nav-center ul {
  display: flex;
  gap: 30px;
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-center a {
  color: #fff;
  text-decoration: none;
  font-weight: 500;
  font-size: 16px;
  padding: 8px 16px;
  border-radius: 5px;
  transition: background 0.3s;
}

.nav-center a:hover,
.nav-center a.router-link-active {
  background: rgba(255,255,255,0.2);
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.welcome {
  color: white;
  font-weight: 500;
}

.logout-btn {
  background: rgba(255,255,255,0.2);
  color: white;
  border: 1px solid rgba(255,255,255,0.3);
  padding: 8px 20px;
  border-radius: 5px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s;
}

.logout-btn:hover {
  background: rgba(255,255,255,0.3);
  transform: translateY(-2px);
}
</style>