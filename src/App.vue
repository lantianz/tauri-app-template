<template>
  <div class="app-shell">
    <TitleBar />
    <section class="app-content">
      <router-view />
    </section>
  </div>
</template>

<script setup lang="ts">
import TitleBar from "@/components/layout/TitleBar.vue";
</script>

<style>
* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background: #edf2fb;
  font-family: "PingFang SC", "Microsoft YaHei", "Segoe UI", sans-serif;
}

#app {
  width: 100%;
  height: 100vh;
}

.app-shell {
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-content {
  height: calc(100vh - 40px);
  overflow: auto;
}
</style>
