<template>
  <div style="display:flex;">
    <Sidebar />
    <div style="padding:20px; flex:1;">
      <router-view />
    </div>
  </div>
</template>

<script>
import Sidebar from "../components/Sidebar.vue";
export default { components: { Sidebar } };
</script>
