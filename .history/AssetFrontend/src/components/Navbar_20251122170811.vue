<template>
  <nav class="navbar">
    <p style="color:white; margin-right:20px;">
      Welcome, {{ localStorage.getItem('username') }}
    </p>

    <ul>
      <li><router-link to="/dashboard">Dashboard</router-link></li>
      <li><router-link to="/assets">Assets</router-link></li>

      <!-- ⭐ Logout button -->
      <li><a href="#" @click="logout">Logout</a></li>
    </ul>
  </nav>
</template>

<script setup>
function logout() {
  localStorage.clear();
  window.location.href = "/";
}
</script>

<style scoped>
.navbar {
  background: #333;
  padding: 12px;
  display: flex;
  align-items: center;
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