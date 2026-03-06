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
.app-shell {
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-content {
  height: calc(100vh - var(--title-bar-height));
  overflow: auto;
}
</style>
