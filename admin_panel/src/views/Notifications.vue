<template>
  <div>
    <h2>Notifications Management</h2>

    <form @submit.prevent="sendNotification">
      <input v-model="title" placeholder="Title" required />
      <textarea v-model="message" placeholder="Message" required></textarea>
      <select v-model="target">
        <option value="all">All Students</option>
        <option value="course">Specific Course</option>
      </select>
      <button type="submit">Send Notification</button>
    </form>

    <h3>All Notifications</h3>
    <ul>
      <li v-for="note in notifications" :key="note.id">
        <b>{{ note.title }}</b> - {{ note.message }} ({{ note.target }})
      </li>
    </ul>
  </div>
</template>

<script>
import { getNotifications, addNotification } from "../services/notificationService";

export default {
  data() {
    return {
      notifications: [],
      title: "",
      message: "",
      target: "all"
    };
  },
  async created() {
    this.notifications = await getNotifications();
  },
  methods: {
    async sendNotification() {
      await addNotification({
        title: this.title,
        message: this.message,
        target: this.target
      });
      this.notifications = await getNotifications();
      this.title = this.message = "";
      alert("Notification sent!");
    }
  }
};
</script>
