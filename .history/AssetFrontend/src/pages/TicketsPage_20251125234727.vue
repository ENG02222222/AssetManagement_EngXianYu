<template>
  <div class="tickets-container">
    <Navbar />
    
    <div class="content">
      <div class="header">
        <h1>IT Support Tickets</h1>
        <div class="header-actions">
          <button class="btn-success" @click="openNewTicketForm">
            + New Ticket
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
            placeholder="Search by title, description, or status..." 
            class="search-input"
          />
          <button v-if="searchQuery" @click="searchQuery = ''" class="clear-inside-btn">✕</button>
        </div>
      </div>

      <!-- New Ticket Modal -->
      <div v-if="showForm" class="modal-overlay" @click="cancelForm">
        <div class="modal-box" @click.stop>
          <h2>{{ editMode ? "Update Ticket" : "Submit New Ticket" }}</h2>

          <div class="form-group">
            <label>Title *</label>
            <input v-model="newTicket.title" placeholder="Brief description of issue" required />
          </div>

          <div class="form-group">
            <label>Category</label>
            <select v-model="newTicket.category">
              <option value="">Select Category</option>
              <option value="Hardware">Hardware Issue</option>
              <option value="Software">Software Issue</option>
              <option value="Network">Network/Connectivity</option>
              <option value="Access">Access/Permissions</option>
              <option value="Request">Equipment Request</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div class="form-group">
            <label>Priority</label>
            <select v-model="newTicket.priority">
              <option value="">Select Priority</option>
              <option value="Low">Low</option>
              <option value="Medium">Medium</option>
              <option value="High">High</option>
              <option value="Urgent">Urgent</option>
            </select>
          </div>

          <div class="form-group">
            <label>Description *</label>
            <textarea 
              v-model="newTicket.description" 
              placeholder="Detailed description of the issue..."
              rows="4"
              required
            ></textarea>
          </div>

          <div v-if="role === 'Admin' && editMode" class="form-group">
            <label>Status</label>
            <select v-model="newTicket.status">
              <option value="Open">Open</option>
              <option value="In Progress">In Progress</option>
              <option value="Resolved">Resolved</option>
              <option value="Closed">Closed</option>
            </select>
          </div>

          <div v-if="role === 'Admin' && editMode" class="form-group">
            <label>Admin Notes</label>
            <textarea 
              v-model="newTicket.adminNotes" 
              placeholder="Internal notes or resolution details..."
              rows="3"
            ></textarea>
          </div>

          <div class="form-actions">
            <button v-if="editMode" class="btn-primary" @click="updateTicket">
              Update Ticket
            </button>
            <button v-else class="btn-primary" @click="createTicket">
              Submit Ticket
            </button>
            <button class="btn-danger" @click="cancelForm">
              Cancel
            </button>
          </div>
        </div>
      </div>

      <!-- Tickets Table -->
      <div class="table-container">
        <table class="modern-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Category</th>
              <th>Priority</th>
              <th>Status</th>
              <th>Submitted By</th>
              <th>Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredTickets.length === 0">
              <td colspan="8" style="text-align:center; padding: 40px;">
                {{ searchQuery ? 'No tickets found matching your search.' : 'No tickets yet. Click "New Ticket" to submit one.' }}
              </td>
            </tr>
            <tr v-for="ticket in filteredTickets" :key="ticket.id">
              <td data-label="ID">{{ ticket.id }}</td>
              <td data-label="Title"><strong>{{ ticket.title }}</strong></td>
              <td data-label="Category">{{ ticket.category || "-" }}</td>
              <td data-label="Priority">
                <span class="priority-badge" :class="getPriorityClass(ticket.priority)">
                  {{ ticket.priority || "N/A" }}
                </span>
              </td>
              <td data-label="Status">
                <span class="status-badge" :class="getStatusClass(ticket.status)">
                  {{ ticket.status || "Open" }}
                </span>
              </td>
              <td data-label="Submitted By">{{ ticket.submittedBy || "-" }}</td>
              <td data-label="Date">{{ formatDate(ticket.createdAt) }}</td>
              <td data-label="Actions">
                <div class="action-buttons">
                  <button class="btn-view" @click="viewTicket(ticket)">View</button>
                  <button v-if="role === 'Admin' || ticket.submittedBy === username" 
                          class="btn-edit" 
                          @click="startEdit(ticket)">
                    Edit
                  </button>
                  <button v-if="role === 'Admin'" 
                          class="btn-delete" 
                          @click="deleteTicket(ticket.id)">
                    Delete
                  </button>
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

const role = localStorage.getItem("role");
const username = localStorage.getItem("username");
const tickets = ref([]);
const showForm = ref(false);
const editMode = ref(false);
const editTicketId = ref(null);
const searchQuery = ref("");

const newTicket = ref({
  title: "",
  category: "",
  priority: "",
  description: "",
  status: "Open",
  adminNotes: "",
});

const filteredTickets = computed(() => {
  if (!searchQuery.value) return tickets.value;
  
  const query = searchQuery.value.toLowerCase();
  return tickets.value.filter(ticket => {
    return (
      ticket.title?.toLowerCase().includes(query) ||
      ticket.description?.toLowerCase().includes(query) ||
      ticket.category?.toLowerCase().includes(query) ||
      ticket.status?.toLowerCase().includes(query) ||
      ticket.priority?.toLowerCase().includes(query)
    );
  });
});

function formatDate(dateString) {
  if (!dateString) return "-";
  return new Date(dateString).toLocaleDateString();
}

function getPriorityClass(priority) {
  const p = priority?.toLowerCase();
  if (p === 'urgent') return 'priority-urgent';
  if (p === 'high') return 'priority-high';
  if (p === 'medium') return 'priority-medium';
  if (p === 'low') return 'priority-low';
  return 'priority-default';
}

function getStatusClass(status) {
  const s = status?.toLowerCase();
  if (s === 'open') return 'status-open';
  if (s === 'in progress') return 'status-progress';
  if (s === 'resolved' || s === 'closed') return 'status-resolved';
  return 'status-default';
}

function openNewTicketForm() {
  editMode.value = false;
  showForm.value = true;
  newTicket.value = {
    title: "",
    category: "",
    priority: "",
    description: "",
    status: "Open",
    adminNotes: "",
  };
}

function viewTicket(ticket) {
  alert(`Ticket #${ticket.id}: ${ticket.title}\n\n${ticket.description}\n\nStatus: ${ticket.status}\nPriority: ${ticket.priority}`);
}

function startEdit(ticket) {
  editMode.value = true;
  showForm.value = true;
  editTicketId.value = ticket.id;
  
  newTicket.value = {
    title: ticket.title,
    category: ticket.category,
    priority: ticket.priority,
    description: ticket.description,
    status: ticket.status,
    adminNotes: ticket.adminNotes || "",
  };
}

function cancelForm() {
  showForm.value = false;
  editMode.value = false;
  editTicketId.value = null;
  newTicket.value = {
    title: "",
    category: "",
    priority: "",
    description: "",
    status: "Open",
    adminNotes: "",
  };
}

async function createTicket() {
  if (!newTicket.value.title || !newTicket.value.description) {
    alert("Title and description are required!");
    return;
  }
  
  try {
    const ticketData = {
      ...newTicket.value,
      submittedBy: username,
      status: "Open"
    };
    
    await axios.post("http://localhost:5011/api/tickets", ticketData);
    alert("Ticket submitted successfully!");
    cancelForm();
    await loadTickets();
  } catch (err) {
    console.error("Error creating ticket:", err);
    alert("Failed to submit ticket");
  }
}

async function updateTicket() {
  if (!newTicket.value.title || !newTicket.value.description) {
    alert("Title and description are required!");
    return;
  }
  
  try {
    await axios.put(`http://localhost:5011/api/tickets/${editTicketId.value}`, newTicket.value);
    alert("Ticket updated successfully!");
    cancelForm();
    await loadTickets();
  } catch (err) {
    console.error("Error updating ticket:", err);
    alert("Failed to update ticket");
  }
}

async function deleteTicket(id) {
  if (!confirm("Are you sure you want to delete this ticket?")) return;
  
  try {
    await axios.delete(`http://localhost:5011/api/tickets/${id}`);
    alert("Ticket deleted successfully!");
    await loadTickets();
  } catch (err) {
    console.error("Error deleting ticket:", err);
    alert("Failed to delete ticket");
  }
}

async function loadTickets() {
  try {
    const res = await axios.get("http://localhost:5011/api/tickets");
    tickets.value = res.data;
  } catch (err) {
    console.error("Error loading tickets:", err);
  }
}

async function exportExcel() {
  try {
    const response = await axios.get("http://localhost:5011/api/tickets/export", {
      responseType: 'blob'
    });
    
    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', 'tickets.xlsx');
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(url);
  } catch (err) {
    console.error("Error exporting tickets:", err);
    alert("Failed to export tickets");
  }
}

onMounted(async () => {
  await loadTickets();
});
</script>

<style scoped>
@import "../css-styling/TicketsPage.css";
</style>