<template>
  <div>
    <h2>ID Card / Hall Ticket</h2>

    <div id="id-card" style="width:350px; padding:20px; border:1px solid #000;">
      <img :src="student.photoUrl || placeholder" alt="Photo" width="100" />
      <p><b>Name:</b> {{ student.name }}</p>
      <p><b>Grade:</b> {{ student.grade }}</p>
      <p><b>Registration No:</b> {{ student.registrationNumber }}</p>
      <p><b>Exam:</b> {{ exam.examName || "N/A" }}</p>
    </div>

    <button @click="downloadPDF">Download PDF</button>
  </div>
</template>

<script>
import { db, storage } from "../firebase/firebase";
import { doc, getDoc } from "firebase/firestore";
import jsPDF from "jspdf";
import html2canvas from "html2canvas";

export default {
  data() {
    return {
      student: {},
      exam: {},
      placeholder: "https://via.placeholder.com/100"
    };
  },
  async created() {
    const studentId = this.$route.query.studentId; // pass studentId in query
    if (!studentId) return;

    const studentSnap = await getDoc(doc(db, "students", studentId));
    if (studentSnap.exists()) this.student = studentSnap.data();

    // Optional: load assigned exam
    const examId = this.student.assignedExamId;
    if (examId) {
      const examSnap = await getDoc(doc(db, "exams", examId));
      if (examSnap.exists()) this.exam = examSnap.data();
    }
  },
  methods: {
    async downloadPDF() {
      const element = document.getElementById("id-card");
      const canvas = await html2canvas(element);
      const imgData = canvas.toDataURL("image/png");
      const pdf = new jsPDF({
        orientation: "portrait",
        unit: "px",
        format: [canvas.width, canvas.height]
      });
      pdf.addImage(imgData, "PNG", 0, 0, canvas.width, canvas.height);
      pdf.save(`${this.student.name}_IDCard.pdf`);
    }
  }
};
</script>
