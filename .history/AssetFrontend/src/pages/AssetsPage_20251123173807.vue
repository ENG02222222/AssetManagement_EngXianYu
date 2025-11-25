<template>
  <div class="assets-container">
    <Navbar />
    
    <div class="content">
      <div class="header">
        <h1>Assets Management</h1>
        <div class="header-actions">
          <button v-if="role === 'Admin'" class="btn-success" @click="openNewForm">
            + New Asset
          </button>
          <button v-if="role === 'Admin'" class="btn-info" @click="exportExcel">
            📥 Export Excel
          </button>
        </div>
      </div>

      <div class="search-container">
        <div class="search-box">
          <span class="search-icon">🔍</span>
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="Search by name, category, assigned to, or status..." 
            class="search-input"
          />
          <button v-if="searchQuery" @click="searchQuery = ''" class="clear-inside-btn">✕</button>
        </div>
      </div>

      <!-- Modal (same as before) -->
      <div v-if="showForm" class="modal-overlay" @click="cancelForm">
        <div class="modal-box" @click.stop>
          <h2>{{ editMode ? "Edit Asset" : "New Asset" }}</h2>

          <div class="form-group">
            <label>Name *</label>
            <input v-model="newAsset.name" placeholder="Enter asset name" required />
          </div>

          <div class="form-group">
            <label>Category</label>
            <input v-model="newAsset.category" placeholder="e.g., Laptop, Furniture" />
          </div>

          <div class="form-group">
            <label>Assigned To</label>
            <input v-model="newAsset.assignedTo" placeholder="Employee name" />
          </div>

          <div class="form-group">
            <label>Status</label>
            <select v-model="newAsset.status">
              <option value="">Select Status</option>
              <option value="Active">Active</option>
              <option value="Inactive">Inactive</option>
              <option value="Repair">Repair</option>
              <option value="Maintenance">Maintenance</option>
            </select>
          </div>

          <div class="form-group">
            <label>Purchase Date</label>
            <input type="date" v-model="newAsset.purchaseDate" />
          </div>

          <div class="form-actions">
            <button v-if="editMode" class="btn-primary" @click="updateAsset">
              Update Asset
            </button>
            <button v-else class="btn-primary" @click="addAsset">
              Add Asset
            </button>
            <button class="btn-danger" @click="cancelForm">
              Cancel
            </button>
          </div>
        </div>
      </div>

      <div class="table-container">
        <table class="modern-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Category</th>
              <th>Assigned To</th>
              <th>Status</th>
              <th>Purchase Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredAssets.length === 0">
              <td colspan="7" style="text-align:center; padding: 40px;">
                {{ searchQuery ? 'No assets found matching your search.' : 'No assets found. Click "New Asset" to add one.' }}
              </td>
            </tr>
            <tr v-for="a in filteredAssets" :key="a.id">
              <td>{{ a.id }}</td>
              <td><strong>{{ a.name }}</strong></td>
              <td>{{ a.category || "-" }}</td>
              <td>{{ a.assignedTo || "-" }}</td>
              <td>
                <span class="status-badge" :class="getStatusClass(a.status)">
                  {{ a.status || "N/A" }}
                </span>
              </td>
              <td>{{ a.purchaseDate?.substring(0, 10) || "-" }}</td>
              <td>
                <div class="action-buttons">
                  <button class="btn-view" @click="viewAssetDetails(a.id)">View</button>
                  <button v-if="role === 'Admin'" class="btn-edit" @click="startEdit(a)">Edit</button>
                  <button v-if="role === 'Admin'" class="btn-delete" @click="deleteAsset(a.id)">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import { ref, onMounted, computed } from "vue";
import axios from "axios";
import { useRouter } from "vue-router";

const router = useRouter();
const role = localStorage.getItem("role");
const assets = ref([]);
const showForm = ref(false);
const editMode = ref(false);
const editAssetId = ref(null);
const searchQuery = ref("");

const newAsset = ref({
  name: "",
  category: "",
  assignedTo: "",
  status: "",
  purchaseDate: "",
});

const filteredAssets = computed(() => {
  if (!searchQuery.value) return assets.value;
  
  const query = searchQuery.value.toLowerCase();
  return assets.value.filter(asset => {
    return (
      asset.name?.toLowerCase().includes(query) ||
      asset.category?.toLowerCase().includes(query) ||
      asset.assignedTo?.toLowerCase().includes(query) ||
      asset.status?.toLowerCase().includes(query)
    );
  });
});

function viewAssetDetails(id) {
  router.push(`/assets/${id}`);
}

function getStatusClass(status) {
  const s = status?.toLowerCase();
  if (s === 'active') return 'status-active';
  if (s === 'inactive') return 'status-inactive';
  if (s === 'repair' || s === 'maintenance') return 'status-repair';
  return 'status-default';
}

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
  
  if (!newAsset.value.name) {
    alert("Asset name is required!");
    return;
  }
  
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
  
  if (!newAsset.value.name) {
    alert("Asset name is required!");
    return;
  }
  
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
  if (!confirm("Are you sure you want to delete this asset?")) return;
  
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
@import '../AssetFrontend/css-styling/AssetsPage.css';
</style>