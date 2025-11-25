<template>
    <div>
        <Navbar />
        <h1>Assets List</h1>

        <button @click="showForm = true">+ New Asset</button>

        <!-- ⭐ NEW FORM START -->
        <div v-if="showForm" class="form-box">
            <h3>New Asset</h3>

            <input v-model="newAsset.name" placeholder="Name" />
            <input v-model="newAsset.category" placeholder="Category" />
            <input v-model="newAsset.assignedTo" placeholder="Assigned To" />
            <input v-model="newAsset.status" placeholder="Status" />
            <input type="date" v-model="newAsset.purchaseDate" />

            <button @click="addAsset">Save</button>
            <button @click="showForm = false" style="background:red">Cancel</button>
        </div>
        <!-- ⭐ NEW FORM END -->

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
const showForm = ref(false);

const newAsset = ref({
  name: "",
  category: "",
  assignedTo: "",
  status: "",
  purchaseDate: "",
});

async function addAsset() {
  await axios.post("http://localhost:5011/api/assets", newAsset.value);

  showForm.value = false;
  newAsset.value = {
      name: "",
      category: "",
      assignedTo: "",
      status: "",
      purchaseDate: "",
  };

  // refresh list after insert
  const res = await axios.get("http://localhost:5011/api/assets");
  assets.value = res.data;
}

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

/* ⭐ NEW CSS */
.form-box {
    border: 1px solid #ccc;
    padding: 12px;
    margin-bottom: 15px;
    width: 320px;
    display: flex;
    flex-direction: column;
    gap: 8px;
}
input {
    padding: 6px;
    border: 1px solid #ccc;
}
</style>