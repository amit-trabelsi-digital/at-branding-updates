import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    include: ['@mui/x-date-pickers', 'date-fns'],
  },
  server: {
    port: 9977,
    host: true, // מאפשר גישה מכתובות IP חיצוניות
  },
  preview: {
    port: 9978, // פורט לסביבת preview
  },
})
