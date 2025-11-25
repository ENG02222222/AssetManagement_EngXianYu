<template>
  <div class="dashboard-container">
    <Navbar />
    
    <div class="content">
      <div class="header">
        <h1>Dashboard Overview</h1>
        <button class="btn-primary" @click="$router.push('/assets')">
          View All Assets →
        </button>
      </div>

      <p v-if="loading" class="loading">Loading dashboard...</p>

      <div v-else>
        <!-- Stats Cards -->
        <div class="stats-grid">
          <div class="stat-card total">
            <div class="icon">📦</div>
            <div class="stat-info">
              <h3>{{ stats.total }}</h3>
              <p>Total Assets</p>
            </div>
          </div>

          <div class="stat-card assigned">
            <div class="icon">✅</div>
            <div class="stat-info">
              <h3>{{ stats.assigned }}</h3>
              <p>Assigned</p>
            </div>
          </div>

          <div class="stat-card unassigned">
            <div class="icon">📋</div>
            <div class="stat-info">
              <h3>{{ stats.unassigned }}</h3>
              <p>Unassigned</p>
            </div>
          </div>

          <div class="stat-card repair">
            <div class="icon">🔧</div>
            <div class="stat-info">
              <h3>{{ stats.needingRepair }}</h3>
              <p>Needing Repair</p>
            </div>
          </div>
        </div>

        <!-- Charts Section -->
        <div class="charts-grid">
          <!-- Pie Chart -->
          <div class="chart-card">
            <h3>Asset Assignment Distribution</h3>
            <Pie :data="pieChartData" :options="chartOptions" />
          </div>

          <!-- Bar Chart -->
          <div class="chart-card">
            <h3>Asset Status Overview</h3>
            <Bar :data="barChartData" :options="chartOptions" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import { ref, onMounted, computed } from "vue";
import axios from "axios";
import { Pie, Bar } from 'vue-chartjs';
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  BarElement,
  Title
} from 'chart.js';

// Register Chart.js components
ChartJS.register(
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  BarElement,
  Title
);

const loading = ref(true);

const stats = ref({
  total: 0,
  assigned: 0,
  unassigned: 0,
  needingRepair: 0
});

// Pie Chart Data
const pieChartData = computed(() => ({
  labels: ['Assigned', 'Unassigned'],
  datasets: [{
    data: [stats.value.assigned, stats.value.unassigned],
    backgroundColor: [
      'rgba(17, 153, 142, 0.8)',
      'rgba(245, 87, 108, 0.8)'
    ],
    borderColor: [
      'rgba(17, 153, 142, 1)',
      'rgba(245, 87, 108, 1)'
    ],
    borderWidth: 2
  }]
}));

// Bar Chart Data
const barChartData = computed(() => ({
  labels: ['Total Assets', 'Assigned', 'Unassigned', 'Need Repair'],
  datasets: [{
    label: 'Count',
    data: [
      stats.value.total,
      stats.value.assigned,
      stats.value.unassigned,
      stats.value.needingRepair
    ],
    backgroundColor: [
      'rgba(102, 126, 234, 0.8)',
      'rgba(17, 153, 142, 0.8)',
      'rgba(245, 87, 108, 0.8)',
      'rgba(250, 112, 154, 0.8)'
    ],
    borderColor: [
      'rgba(102, 126, 234, 1)',
      'rgba(17, 153, 142, 1)',
      'rgba(245, 87, 108, 1)',
      'rgba(250, 112, 154, 1)'
    ],
    borderWidth: 2
  }]
}));

// Chart Options
const chartOptions = {
  responsive: true,
  maintainAspectRatio: true,
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        padding: 15,
        font: {
          size: 12,
          weight: 'bold'
        }
      }
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      padding: 12,
      titleFont: {
        size: 14
      },
      bodyFont: {
        size: 13
      }
    }
  }
};

onMounted(async () => {
  try {
    const res = await axios.get("http://localhost:5011/api/dashboard");
    if (res && res.data) stats.value = res.data;
  } catch (err) {
    console.error("Dashboard Error:", err);
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>

</style>

<style scoped>
@import "../css-styling/DashboardPage.css";
</style>