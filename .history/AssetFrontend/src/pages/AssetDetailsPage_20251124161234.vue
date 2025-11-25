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

</style>