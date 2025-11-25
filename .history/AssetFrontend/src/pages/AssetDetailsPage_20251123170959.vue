<template>
  <div class="details-container">
    <Navbar />
    
    <div class="content">
      <button class="back-btn" @click="$router.push('/assets')">← Back to Assets</button>

      <div v-if="loading" class="loading">Loading asset details...</div>

      <div v-else-if="asset" class="details-card">
        <div class="card-header">
          <h1>{{ asset.name }}</h1>
          <span class="status-badge" :class="getStatusClass(asset.status)">
            {{ asset.status || "N/A" }}
          </span>
        </div>

        <div class="details-grid">
          <div class="detail-item">
            <label>Asset ID</label>
            <p>{{ asset.id }}</p>
          </div>

          <div class="detail-item">
            <label>Name</label>
            <p>{{ asset.name }}</p>
          </div>

          <div class="detail-item">
            <label>Category</label>
            <p>{{ asset.category || "-" }}</p>
          </div>

          <div class="detail-item">
            <label>Assigned To</label>
            <p>{{ asset.assignedTo || "Unassigned" }}</p>
          </div>

          <div class="detail-item">
            <label>Status</label>
            <p>{{ asset.status || "-" }}</p>
          </div>

          <div class="detail-item">
            <label>Purchase Date</label>
            <p>{{ asset.purchaseDate ? new Date(asset.purchaseDate).toLocaleDateString() : "-" }}</p>
          </div>
        </div>

        <div v-if="role === 'Admin'" class="action-buttons">
          <button class="btn-edit" @click="$router.push('/assets')">Edit Asset</button>
          <button class="btn-delete" @click="deleteAsset">Delete Asset</button>
        </div>
      </div>

      <div v-else class="error">Asset not found</div>
    </div>
  </div>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import axios from "axios";

const route = useRoute();
const router = useRouter();
const role = localStorage.getItem("role");

const asset = ref(null);
const loading = ref(true);

function getStatusClass(status) {
  const s = status?.toLowerCase();
  if (s === 'active') return 'status-active';
  if (s === 'inactive') return 'status-inactive';
  if (s === 'repair' || s === 'maintenance') return 'status-repair';
  return 'status-default';
}

async function deleteAsset() {
  if (!confirm("Are you sure you want to delete this asset?")) return;
  
  try {
    await axios.delete(`http://localhost:5011/api/assets/${asset.value.id}`);
    alert("Asset deleted successfully!");
    router.push("/assets");
  } catch (err) {
    console.error("Error deleting asset:", err);
    alert("Failed to delete asset");
  }
}

onMounted(async () => {
  try {
    const id = route.params.id;
    const res = await axios.get(`http://localhost:5011/api/assets/${id}`);
    asset.value = res.data;
  } catch (err) {
    console.error("Error loading asset:", err);
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>
.details-container {
  min-height: 100vh;
  background: linear-gradient(to bottom, #f5f7fa 0%, #c3cfe2 100%);
  margin: 0;
  padding: 0;
  padding-top: 70px; /* ⭐ ADD THIS */
}

.content {
  padding: 40px;
  max-width: 900px;
  margin: 0 auto;
}

.back-btn {
  background: #e2e8f0;
  color: #4a5568;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  margin-bottom: 25px;
  transition: all 0.2s;
}

.back-btn:hover {
  background: #cbd5e0;
  transform: translateX(-3px);
}

.loading, .error {
  text-align: center;
  font-size: 18px;
  color: #666;
  margin-top: 60px;
}

.details-card {
  background: white;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.07);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 35px;
  padding-bottom: 20px;
  border-bottom: 2px solid #e2e8f0;
}

.card-header h1 {
  font-size: 28px;
  color: #2d3748;
  margin: 0;
}

.status-badge {
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 13px;
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

.details-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 30px;
  margin-bottom: 35px;
}

.detail-item label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #718096;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 8px;
}

.detail-item p {
  font-size: 18px;
  color: #2d3748;
  margin: 0;
  font-weight: 500;
}

.action-buttons {
  display: flex;
  gap: 15px;
  padding-top: 20px;
  border-top: 2px solid #e2e8f0;
}

.btn-edit {
  flex: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-edit:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.btn-delete {
  flex: 1;
  background: #e53e3e;
  color: white;
  border: none;
  padding: 14px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-delete:hover {
  background: #c53030;
  transform: translateY(-2px);
}
</style>