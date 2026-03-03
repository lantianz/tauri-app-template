<template>
  <main class="home">
    <h1>Hello World</h1>
    <p>Count: {{ count }}</p>
    <div class="actions">
      <button type="button" @click="counterStore.decrement">-1</button>
      <button type="button" @click="counterStore.increment">+1</button>
    </div>
  </main>
</template>

<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useCounterStore } from "@/stores/counter";

const counterStore = useCounterStore();
const { count } = storeToRefs(counterStore);
</script>

<style scoped>
.home {
  min-height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.home h1 {
  margin: 0;
  font-size: 26px;
  color: #1e2b40;
  font-weight: 600;
}

.home p {
  margin: 0;
  color: #4f5f79;
}

.home::before {
  content: "";
  position: fixed;
  inset: 40px 0 0;
  background:
    radial-gradient(circle at 20% 20%, rgba(84, 130, 255, 0.16), transparent 40%),
    radial-gradient(circle at 80% 10%, rgba(120, 180, 255, 0.12), transparent 34%);
  pointer-events: none;
}

.home > * {
  position: relative;
}

.actions {
  margin-top: 8px;
  display: flex;
  gap: 10px;
}

.actions button:first-child {
  background: #f6f8fd;
}

button {
  min-width: 78px;
  height: 36px;
  border: 1px solid #d4dded;
  border-radius: 9px;
  background: #ffffff;
  color: #32435e;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.16s ease;
  box-shadow: 0 1px 2px rgba(25, 47, 86, 0.08);
}

button:hover {
  border-color: #9eb6e6;
  transform: translateY(-1px);
  box-shadow: 0 4px 10px rgba(33, 67, 125, 0.15);
}

button:active {
  transform: translateY(0);
}
</style>
