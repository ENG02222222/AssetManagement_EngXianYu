<template>
  <h1>Dashboard</h1>
  <p>Welcome, {{ auth.username }} ({{ auth.role }})</p>
</template>

<script setup>
import { useAuthStore } from "../stores/auth";
const auth = useAuthStore();
</script>
