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
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();
const username = ref("");

onMounted(() => {
  username.value = localStorage.getItem("username") || "User";
});

function logout() {
  localStorage.clear();
  router.push("/");
}
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
