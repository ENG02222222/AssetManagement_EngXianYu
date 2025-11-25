import { defineStore } from "pinia";

export const useAuthStore = defineStore("auth", {
  state: () => ({
    username: null,
    role: null,
  }),
  actions: {
    login(user) {
      this.username = user.username;
      this.role = user.role;
    },
    logout() {
      this.username = null;
      this.role = null;
    }
  },
  persist: true,
});
