<template>
  <header class="title-bar">
    <div class="drag-region" data-tauri-drag-region>
      <div class="app-mark">T</div>
      <span class="app-title">TauriApp</span>
    </div>

    <div class="window-controls">
      <button class="control-button" type="button" title="最小化" @click="minimizeWindow">
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <path d="M20 14H4v-2h16z" />
        </svg>
      </button>
      <button class="control-button" type="button" :title="isMaximized ? '还原' : '最大化'" @click="toggleMaximize">
        <svg v-if="!isMaximized" viewBox="0 0 24 24" aria-hidden="true">
          <path d="M5 5h14v14H5zM7 7v10h10V7z" />
        </svg>
        <svg v-else viewBox="0 0 24 24" aria-hidden="true">
          <path d="M8 8h11v11H8zM5 5h11v2H7v9H5z" />
        </svg>
      </button>
      <button class="control-button close-button" type="button" title="关闭" @click="closeWindow">
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <path d="M18.3 5.7 12 12l6.3 6.3-1.4 1.4L10.6 13.4 4.3 19.7 2.9 18.3 9.2 12 2.9 5.7 4.3 4.3l6.3 6.3 6.3-6.3z" />
        </svg>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { getCurrentWebviewWindow } from "@tauri-apps/api/webviewWindow";

const appWindow = getCurrentWebviewWindow();
const isMaximized = ref(false);
let unlistenResize: (() => void) | null = null;

const syncMaximizedState = async () => {
  try {
    isMaximized.value = await appWindow.isMaximized();
  } catch {
    // noop
  }
};

const minimizeWindow = async () => {
  await appWindow.minimize();
};

const toggleMaximize = async () => {
  await appWindow.toggleMaximize();
  await syncMaximizedState();
};

const closeWindow = async () => {
  await appWindow.close();
};

onMounted(async () => {
  await syncMaximizedState();
  unlistenResize = await appWindow.onResized(async () => {
    await syncMaximizedState();
  });
});

onUnmounted(() => {
  if (unlistenResize) {
    unlistenResize();
    unlistenResize = null;
  }
});
</script>

<style scoped>
.title-bar {
  height: 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(180deg, #f9fbff 0%, #f1f4fa 100%);
  border-bottom: 1px solid #d8e0ef;
  user-select: none;
}

.drag-region {
  flex: 1;
  height: 100%;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 12px;
}

.app-mark {
  width: 18px;
  height: 18px;
  border-radius: 5px;
  background: linear-gradient(135deg, #2f6df5 0%, #6496ff 100%);
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  display: grid;
  place-items: center;
}

.app-title {
  font-size: 13px;
  color: #2b3342;
  letter-spacing: 0.2px;
}

.window-controls {
  height: 100%;
  display: flex;
}

.control-button {
  width: 46px;
  height: 100%;
  border: none;
  background: transparent;
  color: #4f5b70;
  display: grid;
  place-items: center;
  cursor: pointer;
  transition: background-color 0.15s ease, color 0.15s ease;
}

.control-button svg {
  width: 14px;
  height: 14px;
  fill: currentColor;
}

.control-button:hover {
  background: #e7edf9;
  color: #1f2a3d;
}

.control-button:active {
  background: #dbe5f6;
}

.close-button:hover {
  background: #e81123;
  color: #fff;
}

.close-button:active {
  background: #c50f1f;
  color: #fff;
}
</style>
