<template>
  <header class="title-bar">
    <div class="drag-region" data-tauri-drag-region>
      <div class="app-mark" data-tauri-drag-region>T</div>
      <span class="app-title" data-tauri-drag-region>TauriApp</span>
    </div>

    <div class="window-controls">
      <button
        class="control-button"
        type="button"
        aria-label="最小化窗口"
        :disabled="isWindowCommandPending"
        @click="minimizeWindow"
      >
        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
          <path d="M6 12.5h12" />
        </svg>
      </button>
      <button
        class="control-button"
        type="button"
        :aria-label="isMaximized ? '还原窗口' : '最大化窗口'"
        :disabled="isWindowCommandPending"
        @click="toggleMaximize"
      >
        <svg
          v-if="!isMaximized"
          viewBox="0 0 24 24"
          aria-hidden="true"
          focusable="false"
        >
          <rect x="6.5" y="6.5" width="11" height="11" rx="2.5" />
        </svg>
        <svg v-else viewBox="0 0 24 24" aria-hidden="true" focusable="false">
          <rect x="8.5" y="8.5" width="10" height="10" rx="2.2" />
          <path d="M5.5 6.2c0-.4.3-.7.7-.7h8.6" />
          <path d="M5.5 6.9v8.6c0 .4.3.7.7.7" />
        </svg>
      </button>
      <button
        class="control-button close-button"
        type="button"
        aria-label="关闭窗口"
        :disabled="isWindowCommandPending"
        @click="closeWindow"
      >
        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
          <path d="m7 7 10 10" />
          <path d="m17 7-10 10" />
        </svg>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { getCurrentWebviewWindow } from "@tauri-apps/api/webviewWindow";

const appWindow = getCurrentWebviewWindow();
const isMaximized = ref(false);
const isWindowCommandPending = ref(false);
let unlistenResize: (() => void) | null = null;
let resizeSyncTimer: ReturnType<typeof setTimeout> | null = null;
let isSyncingMaximizedState = false;
let isUnmounted = false;

const syncMaximizedState = async () => {
  if (isUnmounted) {
    return;
  }
  if (isSyncingMaximizedState) {
    return;
  }
  isSyncingMaximizedState = true;
  try {
    const maximized = await appWindow.isMaximized();
    if (maximized !== isMaximized.value) {
      isMaximized.value = maximized;
    }
  } catch {
    // noop
  } finally {
    isSyncingMaximizedState = false;
  }
};

const scheduleSyncMaximizedState = () => {
  if (resizeSyncTimer) {
    clearTimeout(resizeSyncTimer);
  }
  resizeSyncTimer = setTimeout(() => {
    resizeSyncTimer = null;
    void syncMaximizedState();
  }, 120);
};

const runWindowCommand = async (command: () => Promise<void>) => {
  if (isWindowCommandPending.value || isUnmounted) {
    return;
  }
  isWindowCommandPending.value = true;
  try {
    await command();
  } catch (error) {
    console.error("[TitleBar] window command failed", error);
  } finally {
    isWindowCommandPending.value = false;
  }
};

const minimizeWindow = async () => {
  await runWindowCommand(async () => {
    await appWindow.minimize();
  });
};

const toggleMaximize = async () => {
  await runWindowCommand(async () => {
    await appWindow.toggleMaximize();
    await syncMaximizedState();
  });
};

const closeWindow = async () => {
  await runWindowCommand(async () => {
    await appWindow.close();
  });
};

onMounted(async () => {
  await syncMaximizedState();
  const unlisten = await appWindow.onResized(() => {
    scheduleSyncMaximizedState();
  });
  if (isUnmounted) {
    unlisten();
    return;
  }
  unlistenResize = unlisten;
});

onUnmounted(() => {
  isUnmounted = true;
  if (resizeSyncTimer) {
    clearTimeout(resizeSyncTimer);
    resizeSyncTimer = null;
  }
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
  padding: 0 8px 0 10px;
  background: linear-gradient(180deg, #f9fbff 0%, #f2f5fb 100%);
  border-bottom: 1px solid #dbe3f0;
  user-select: none;
  box-shadow: 0 1px 0 rgba(18, 31, 54, 0.03);
}

.drag-region {
  flex: 1;
  height: 100%;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.app-mark {
  width: 20px;
  height: 20px;
  border-radius: 6px;
  background: linear-gradient(135deg, #3c77f5 0%, #6ea0ff 100%);
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  display: grid;
  place-items: center;
}

.app-title {
  font-size: 12px;
  color: #293548;
  letter-spacing: 0.1px;
  font-weight: 500;
  opacity: 0.95;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.window-controls {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-right: 2px;
  padding: 2px 0;
}

.control-button {
  width: 32px;
  height: 28px;
  border: 1px solid transparent;
  border-radius: 8px;
  background: transparent;
  color: #52617a;
  display: grid;
  place-items: center;
  cursor: pointer;
  transition:
    background-color 0.15s ease,
    color 0.15s ease,
    border-color 0.15s ease;
}

.control-button:disabled {
  opacity: 0.65;
  cursor: default;
}

.control-button svg {
  width: 15px;
  height: 15px;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.8;
  stroke-linecap: round;
  stroke-linejoin: round;
  vector-effect: non-scaling-stroke;
}

.control-button:hover {
  background: #e9eef8;
  border-color: #d3ddef;
  color: #24334b;
}

.control-button:active {
  background: #dde6f6;
}

.control-button:focus-visible {
  outline: none;
  border-color: #9fb4db;
  box-shadow: 0 0 0 2px rgba(120, 154, 210, 0.25);
}

.close-button:hover {
  background: #e84a5f;
  border-color: #de3a52;
  color: #fff;
}

.close-button:active {
  background: #d93c51;
  color: #fff;
}
</style>
