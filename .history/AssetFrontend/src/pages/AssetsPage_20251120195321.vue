<template>
    <div>
        <Navbar />
        <h1>Assets List</h1>

        <button @click="showForm = true">+ New Asset</button>

        <table border="1" cellpadding="8">
            <thead>
                <tr>
                    <th>Id</th>
                    <th>Name</th>
                    <th>Category</th>
                    <th>Assigned To</th>
                    <th>Status</th>
                    <th>Purchase Date</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="a in assets" :key="a.id">
                    <td>{{ a.id }}</td>
                    <td>{{ a.name }}</td>
                    <td>{{ a.category }}</td>
                    <td>{{ a.assignedTo || "-" }}</td>
                    <td>{{ a.status }}</td>
                    <td>{{ a.purchaseDate?.substring(0, 10) }}</td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import { ref, onMounted } from "vue";
import axios from "axios";

const assets = ref([]);

onMounted(async () => {
    const res = await axios.get("http://localhost:5011/api/assets");
    assets.value = res.data;
});
</script>

<style scoped>
button {
    margin-bottom: 15px;
    padding: 6px 12px;
    background-color: #28a745;
    color: white;
    border: none;
    cursor: pointer;
}

button:hover {
    background-color: #218838;
}
</style>
