<template>
  <nav class="navbar">
    <p>Welcome, {{ username }}</p>
    <button @click="logout">Logout</button>
  </nav>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import { ref, onMounted } from "vue";
import axios from "axios";

const stats = ref({
  total: 0,
  assigned: 0,
  unassigned: 0,
  needingRepair: 0
});

onMounted(async () => {
  try {
    const res = await axios.get("http://localhost:5011/api/dashboard");
    stats.value = res.data;
  } catch (err) {
    console.error("Dashboard error:", err);
  }
});
</script>

<style scoped>
.navbar {
  padding: 10px;
  background: #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

button {
  padding: 6px 10px;
  background: red;
  color: white;
  border: none;
  cursor: pointer;
}
</style>
