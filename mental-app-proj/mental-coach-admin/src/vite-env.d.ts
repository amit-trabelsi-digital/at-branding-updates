/// <reference types="vite/client" />

interface Window {
  setAppEnvironment: (env: 'local' | 'dev' | 'prod') => void;
  clearAppEnvironment: () => void;
}
