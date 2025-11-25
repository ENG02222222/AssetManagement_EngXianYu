<template>
  <div>
    <Navbar />
    <h1>Dashboard</h1>

    <div class="stats-box">
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

const stats = ref({});

onMounted(async () => {
  const res = await axios.get("http://localhost:5011/api/dashboard");
  stats.value = res.data;
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
</style>
