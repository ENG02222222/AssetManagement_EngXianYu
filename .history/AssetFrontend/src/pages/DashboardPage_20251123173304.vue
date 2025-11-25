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
.dashboard-container {
  min-height: 100vh;
  background: linear-gradient(to bottom, #f5f7fa 0%, #c3cfe2 100%);
  margin: 0;
  padding: 0;
}

.content {
  padding: 40px;
  max-width: 1400px;
  margin: 0 auto;
  padding-top: 100px;
  padding-bottom: 50px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
}

.header h1 {
  font-size: 32px;
  color: #2d3748;
  margin: 0;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.loading {
  text-align: center;
  font-size: 18px;
  color: #666;
  margin-top: 60px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
  margin-bottom: 40px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 30px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.07);
  transition: transform 0.2s, box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0,0,0,0.12);
}

.stat-card .icon {
  font-size: 48px;
  width: 70px;
  height: 70px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
}

.stat-card.total .icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-card.assigned .icon {
  background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
}

.stat-card.unassigned .icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-card.repair .icon {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.stat-info h3 {
  font-size: 36px;
  color: #2d3748;
  margin: 0 0 5px 0;
  font-weight: 700;
}

.stat-info p {
  font-size: 16px;
  color: #718096;
  margin: 0;
  font-weight: 500;
}

/* Charts Grid */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 30px;
  margin-top: 30px;
}

.chart-card {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.07);
}

.chart-card h3 {
  font-size: 18px;
  color: #2d3748;
  margin: 0 0 25px 0;
  font-weight: 600;
  text-align: center;
}
</style>