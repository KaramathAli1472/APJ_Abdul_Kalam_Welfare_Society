<template>
  <div>
    <h2>Payments List</h2>

    <table border="1" cellpadding="8">
      <thead>
        <tr>
          <th>Student Name</th>
          <th>Email</th>
          <th>Grade</th>
          <th>Transaction ID</th>
          <th>Amount</th>
          <th>Payment Status</th>
          <th>Date</th>
        </tr>
      </thead>

      <tbody>
        <tr v-if="payments.length === 0">
          <td colspan="7" style="text-align:center;">No payments found</td>
        </tr>

        <tr v-for="payment in payments" :key="payment.studentId">
          <td>{{ payment.name }}</td>
          <td>{{ payment.email }}</td>
          <td>{{ payment.grade }}</td>
          <td>{{ payment.transactionID }}</td>
          <td>{{ payment.amount }}</td>
          <td>
            <span
              :style="{
                color:
                  payment.paymentStatus === 'Paid'
                    ? 'green'
                    : payment.paymentStatus === 'Rejected'
                    ? 'red'
                    : 'orange'
              }"
            >
              {{ payment.paymentStatus }}
            </span>
          </td>
          <td>{{ formatDate(payment.updatedAt) }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { getPayments } from "../services/paymentService";

export default {
  name: "Payments",

  data() {
    return {
      payments: []
    };
  },

  async created() {
    try {
      this.payments = await getPayments();
    } catch (err) {
      console.error("❌ Error fetching payments:", err);
    }
  },

  methods: {
    formatDate(timestamp) {
      if (!timestamp) return "-";

      // Firestore Timestamp OR JS Date
      const date = timestamp.seconds
        ? new Date(timestamp.seconds * 1000)
        : new Date(timestamp);

      return date.toLocaleDateString() + " " + date.toLocaleTimeString();
    }
  }
};
</script>

<style scoped>
table {
  width: 100%;
  border-collapse: collapse;
}

th,
td {
  padding: 8px;
  text-align: left;
  border: 1px solid #ddd;
}

th {
  background-color: #f2f2f2;
}

td {
  vertical-align: middle;
}
</style>
