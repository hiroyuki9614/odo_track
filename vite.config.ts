import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import FullReload from 'vite-plugin-full-reload';
import vue from '@vitejs/plugin-vue';
import vuetify, { transformAssetUrls } from "vite-plugin-vuetify";
// import imgUrl from './'


export default defineConfig({
  plugins: [
    RubyPlugin(),
    FullReload(["config/routes.rb", "app/views/**/*"], { delay: 200 }),
    vue(),
    vuetify({ autoImport: true }),
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
