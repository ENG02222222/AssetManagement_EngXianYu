<template>
  <div>
    <Navbar />
    <h1>Assets List</h1>

    <button v-if="role === 'Admin'" @click="openNewForm">+ New Asset</button>
    <button v-if="role === 'Admin'" @click="exportExcel" style="margin-left:10px;">Export Excel</button>

    <div v-if="showForm" class="form-box">
      <h3>{{ editMode ? "Edit Asset" : "New Asset" }}</h3>

      <input v-model="newAsset.name" placeholder="Name" />
      <input v-model="newAsset.category" placeholder="Category" />
      <input v-model="newAsset.assignedTo" placeholder="Assigned To" />
      <input v-model="newAsset.status" placeholder="Status" />
      <input type="date" v-model="newAsset.purchaseDate" />

      <button v-if="editMode" @click="updateAsset()">Update Asset</button>
      <button v-else @click="addAsset()">Add Asset</button>
      <button @click="cancelForm" style="background:red; margin-left:10px;">Cancel</button>
    </div>

    <table border="1" cellpadding="8">
      <thead>
        <tr>
          <th>Id</th>
          <th>Name</th>
          <th>Category</th>
          <th>Assigned To</th>
          <th>Status</th>
          <th>Purchase Date</th>
          <th>Actions</th>
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
          <td v-if="role === 'Admin'">
            <button @click="startEdit(a)">Edit</button>
            <button @click="deleteAsset(a.id)" style="background:red">Delete</button>
          </td>
          <td v-else>-</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import { ref, onMounted } from "vue";
import axios from "axios";

const role = localStorage.getItem("role");
const assets = ref([]);
const showForm = ref(false);
const editMode = ref(false);
const editAssetId = ref(null);

const newAsset = ref({
  name: "",
  category: "",
  assignedTo: "",
  status: "",
  purchaseDate: "",
});

function openNewForm() {
  editMode.value = false;
  showForm.value = true;
  newAsset.value = {
    name: "",
    category: "",
    assignedTo: "",
    status: "",
    purchaseDate: "",
  };
}

function startEdit(asset) {
  if (!checkAdmin()) return;
  
  editMode.value = true;
  showForm.value = true;
  editAssetId.value = asset.id;
  
  // Format the date properly for input type="date"
  let dateValue = "";
  if (asset.purchaseDate) {
    dateValue = asset.purchaseDate.substring(0, 10);
  }
  
  newAsset.value = {
    name: asset.name,
    category: asset.category,
    assignedTo: asset.assignedTo,
    status: asset.status,
    purchaseDate: dateValue,
  };
}

function cancelForm() {
  showForm.value = false;
  editMode.value = false;
  editAssetId.value = null;
  newAsset.value = {
    name: "",
    category: "",
    assignedTo: "",
    status: "",
    purchaseDate: "",
  };
}

function checkAdmin() {
  if (role !== "Admin") {
    alert("Only admins can modify data!");
    return false;
  }
  return true;
}

async function addAsset() {
  if (!checkAdmin()) return;
  
  try {
    await axios.post("http://localhost:5011/api/assets", newAsset.value);
    alert("Asset added successfully!");
    cancelForm();
    await loadAssets();
  } catch (err) {
    console.error("Error adding asset:", err);
    alert("Failed to add asset");
  }
}

async function updateAsset() {
  if (!checkAdmin()) return;
  
  try {
    await axios.put(`http://localhost:5011/api/assets/${editAssetId.value}`, newAsset.value);
    alert("Asset updated successfully!");
    cancelForm();
    await loadAssets();
  } catch (err) {
    console.error("Error updating asset:", err);
    alert("Failed to update asset");
  }
}

async function deleteAsset(id) {
  if (!checkAdmin()) return;
  if (!confirm("Are you sure you want to delete?")) return;
  
  try {
    await axios.delete(`http://localhost:5011/api/assets/${id}`);
    alert("Asset deleted successfully!");
    await loadAssets();
  } catch (err) {
    console.error("Error deleting asset:", err);
    alert("Failed to delete asset");
  }
}

async function loadAssets() {
  try {
    const res = await axios.get("http://localhost:5011/api/assets");
    assets.value = res.data;
  } catch (err) {
    console.error("Error loading assets:", err);
  }
}

async function exportExcel() {
  try {
    const response = await axios.get("http://localhost:5011/api/assets/export", {
      responseType: "blob",
    });

    const url = window.URL.createObjectURL(new Blob([response.data]));
    const a = document.createElement("a");
    a.href = url;
    a.download = "assets.xlsx";
    document.body.appendChild(a);
    a.click();
    a.remove();
    window.URL.revokeObjectURL(url);
  } catch (err) {
    console.error("Error exporting Excel:", err);
    alert("Failed to export Excel file");
  }
}

onMounted(async () => {
  await loadAssets();
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