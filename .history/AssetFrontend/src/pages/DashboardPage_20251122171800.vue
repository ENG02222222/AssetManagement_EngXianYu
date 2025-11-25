<template>
  <div>
    <Navbar />
    <h1>Dashboard</h1>

    <!-- Loading & empty state -->
    <p v-if="loading">Loading dashboard...</p>

    <div v-else class="stats-box">
      <div><strong>Total Assets:</strong> {{ stats.total }}</div>
      <div><strong>Assigned:</strong> {{ stats.assigned }}</div>
      <div><strong>Unassigned:</strong> {{ stats.unassigned }}</div>
      <div><strong>Needing Repair:</strong> {{ stats.needingRepair }}</div>
    </div>

    <button @click="$router.push('/assets')">Go to Assets Page</button>
  </div>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import { ref, onMounted } from "vue";
import axios from "axios";

const loading = ref(true);

const stats = ref({
  total: 0,
  assigned: 0,
  unassigned: 0,
  needingRepair: 0
});

onMounted(async () => {
  try {
    const res = await axios.get("http://localhost:5011/api/dashboard");
    if (res && res.data) stats.value = res.data;
  } catch (err) {
    console.error("Dashboard Error:", err);
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>
.stats-box {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 20px;
  border: 1px solid #aaa;
  width: 260px;
  padding: 12px;
}

button {
  padding: 8px 12px;
  background-color: #007bff;
  color: white;
  border: none;
  cursor: pointer;
}

button:hover {
  background-color: #0069d9;
}
</style>