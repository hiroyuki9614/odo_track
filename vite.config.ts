import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  server: {
    port: 3036,
    host: true,
    strictPort: true,
    watch: {
      usePolling: true
    }
  },
})
