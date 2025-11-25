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

            <div class="search-bar">
                <div class="search-wrapper">
                    <span class="search-icon">🔍</span>
                    <input v-model="searchQuery" type="text"
                        placeholder="Search by name, category, assigned to, or status..." class="search-input" />
                </div>
                <button v-if="searchQuery" @click="searchQuery = ''" class="clear-btn">Clear</button>
            </div>

            <!-- Modal form (same as before) -->
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
                        <!-- ⭐ CHANGED: Use filteredAssets instead of assets -->
                        <tr v-if="filteredAssets.length === 0">
                            <td colspan="7" style="text-align:center;">
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
                                <!-- ⭐ NEW: View Details button for everyone -->
                                <button class="btn-view" @click="viewAssetDetails(a.id)">View</button>

                                <!-- Admin only buttons -->
                                <button v-if="role === 'Admin'" class="btn-edit" @click="startEdit(a)">Edit</button>
                                <button v-if="role === 'Admin'" class="btn-delete"
                                    @click="deleteAsset(a.id)">Delete</button>
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
const searchQuery = ref(""); // ⭐ NEW

const newAsset = ref({
  name: "",
  category: "",
  assignedTo: "",
  status: "",
  purchaseDate: "",
});

// ⭐ NEW: Computed property for filtered assets
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

// ⭐ NEW: View asset details
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
.assets-container {
  min-height: 100vh;
  background: linear-gradient(to bottom, #f5f7fa 0%, #c3cfe2 100%);
  margin: 0;
  padding: 0;
}

.content {
  padding: 40px;
  max-width: 1400px;
  margin: 0 auto;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.header h1 {
  font-size: 32px;
  color: #2d3748;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 15px;
}

.search-bar {
  display: flex;
  gap: 10px;
  margin-bottom: 25px;
  align-items: center;
}

.search-wrapper {
  flex: 1;
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 20px;
  font-size: 18px;
  color: #718096;
  pointer-events: none;
}

.search-input {
  flex: 1;
  width: 100%;
  padding: 14px 20px 14px 50px; /* Add left padding for icon */
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 15px;
  transition: all 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.clear-btn {
  background: #e2e8f0;
  color: #4a5568;
  border: none;
  padding: 12px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.clear-btn:hover {
  background: #cbd5e0;
}

.btn-success {
  background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-success:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(17, 153, 142, 0.4);
}

.btn-info {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-info:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-box {
  background: white;
  border-radius: 12px;
  padding: 30px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.3);
}

.modal-box h2 {
  margin: 0 0 25px 0;
  color: #2d3748;
  font-size: 24px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #4a5568;
  font-weight: 600;
  font-size: 14px;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 15px;
  transition: border 0.2s;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #667eea;
}

.form-actions {
  display: flex;
  gap: 12px;
  margin-top: 25px;
}

.btn-primary {
  flex: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.btn-danger {
  flex: 1;
  background: #e53e3e;
  color: white;
  border: none;
  padding: 12px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-danger:hover {
  background: #c53030;
  transform: translateY(-2px);
}

/* Table */
.table-container {
  background: white;
  border-radius: 12px;
  padding: 0;
  box-shadow: 0 4px 6px rgba(0,0,0,0.07);
  overflow: hidden;
}

.modern-table {
  width: 100%;
  border-collapse: collapse;
}

.modern-table thead {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.modern-table thead th {
  color: white;
  padding: 18px 15px;
  text-align: left;
  font-weight: 600;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.modern-table tbody tr {
  border-bottom: 1px solid #e2e8f0;
  transition: background 0.2s;
}

.modern-table tbody tr:hover {
  background: #f7fafc;
}

.modern-table tbody td {
  padding: 16px 15px;
  color: #4a5568;
  font-size: 14px;
}

.status-badge {
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
}

.status-active {
  background: #c6f6d5;
  color: #22543d;
}

.status-inactive {
  background: #fed7d7;
  color: #742a2a;
}

.status-repair {
  background: #feebc8;
  color: #7c2d12;
}

.status-default {
  background: #e2e8f0;
  color: #4a5568;
}

/* ⭐ NEW: View button */
.btn-view {
  background: #805ad5;
  color: white;
  border: none;
  padding: 6px 14px;
  border-radius: 5px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  margin-right: 8px;
  transition: all 0.2s;
}

.btn-view:hover {
  background: #6b46c1;
  transform: translateY(-1px);
}

.btn-edit {
  background: #4299e1;
  color: white;
  border: none;
  padding: 6px 14px;
  border-radius: 5px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  margin-right: 8px;
  transition: all 0.2s;
}

.btn-edit:hover {
  background: #3182ce;
  transform: translateY(-1px);
}

.btn-delete {
  background: #e53e3e;
  color: white;
  border: none;
  padding: 6px 14px;
  border-radius: 5px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-delete:hover {
  background: #c53030;
  transform: translateY(-1px);
}
</style>