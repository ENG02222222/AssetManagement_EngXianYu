<template>
  <div class="login-container">
    <h2>Asset Management System</h2>

    <form @submit.prevent="login">
      <input v-model="username" placeholder="Username" required />
      <input v-model="password" placeholder="Password" type="password" required />

      <button type="submit">Login</button>

      <p v-if="error" class="error">{{ error }}</p>
    </form>
  </div>
</template>

<script setup>
import { ref } from "vue";
import axios from "axios";
import { useRouter } from "vue-router";

const router = useRouter();
const username = ref("");
const password = ref("");
const error = ref("");

// import { useAuthStore } from "../stores/auth";
// const auth = useAuthStore();

async function login() {
  try {
    const res = await axios.post("http://localhost:5011/api/login", {
      username: username.value,
      password: password.value,
    });

    if (res.data) {
      localStorage.setItem("role", res.data.role);
      localStorage.setItem("username", res.data.username);
      alert("Login success! Role: " + res.data.role);
      router.push("/dashboard");
    }
  } catch (err) {
    error.value = "Invalid username or password";
  }
}
</script>

<style scoped>
@import "../../src/css-styling/navbar.css";
</style>