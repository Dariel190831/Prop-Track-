import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import { cpSync } from 'node:fs'
import { resolve } from 'node:path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      plugins: [
        {
          name: 'copy-prototype-assets',
          closeBundle() {
            const outputDirectory = resolve('dist')
            cpSync('PropTrack.dc.html', resolve(outputDirectory, 'PropTrack.dc.html'))
            cpSync('mapa.html', resolve(outputDirectory, 'mapa.html'))
            cpSync('support.js', resolve(outputDirectory, 'support.js'))
            cpSync('uploads', resolve(outputDirectory, 'uploads'), { recursive: true })
          },
        },
      ],
    },
  },
})
