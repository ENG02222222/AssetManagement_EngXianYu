<template>
  <nav class="navbar">
    <p>Welcome, {{ username }}</p>
    <button @click="logout">Logout</button>
  </nav>
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
