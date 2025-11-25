<template>
  <div>
    <Navbar />
    <h1>Dashboard</h1>
    <p>Welcome, {{ auth.username }} ({{ auth.role }})</p>
  </div>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import { useAuthStore } from "../stores/auth";
const auth = useAuthStore();
</script>

<style scoped>
h1 {
  font-size: 28px;
  margin-bottom: 10px;
}
p {
  font-size: 18px;
}
</style>
