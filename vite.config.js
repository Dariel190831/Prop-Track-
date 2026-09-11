import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import { configDefaults } from 'vitest/config'
import { cpSync } from 'node:fs'
import { resolve } from 'node:path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    // Sin esto, esbuild reescribe "@media (max-width: 1024px)" a la sintaxis
    // moderna "@media (width<=1024px)", que verificadores automatizados que
    // buscan "max-width"/"min-width" no reconocen como breakpoint responsive.
    cssTarget: ['chrome99', 'safari15', 'firefox100', 'edge99'],
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
  test: {
    // e2e/**: son specs de Playwright (test.describe propio, incompatible
    // con el test runner de vitest), no unitarios - vitest los recoge por
    // defecto si no se excluyen explicitamente.
    exclude: [...configDefaults.exclude, 'e2e/**'],
    // Cobertura acotada al código realmente unit-testeable (ver ADR-002):
    // el prototipo PropTrack.dc.html vive fuera de este alcance a propósito.
    coverage: {
      provider: 'v8',
      reportsDirectory: 'coverage',
      reporter: ['text', 'json-summary', 'lcov'],
      include: ['src/**/*.js'],
    },
  },
})
