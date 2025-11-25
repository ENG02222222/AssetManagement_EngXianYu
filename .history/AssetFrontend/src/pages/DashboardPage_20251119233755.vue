<template>
  <div>
    <h1>Dashboard</h1>
    <p>Welcome, {{ auth.username }} ({{ auth.role }})</p>
  </div>
</template>

<script setup>
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
