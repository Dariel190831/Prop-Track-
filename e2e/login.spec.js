import { test, expect } from '@playwright/test'

// Usa la app como un humano: abre la pantalla de login real (dentro del
// iframe que monta PropTrack.dc.html) y toca la pestaña Registrarme, sin
// tocar Supabase ni credenciales - por eso puede correr en cualquier
// entorno (local o CI) sin secretos.
test.describe('Login', () => {
  test('cambiar a Registrarme muestra el campo Nombre completo, y volver a Ingresar lo oculta', async ({ page }) => {
    await page.goto('/')
    const frame = page.frameLocator('iframe[title="PropTrack"]')

    await expect(frame.getByText('Bienvenido de nuevo')).toBeVisible()
    await expect(frame.getByText('NOMBRE COMPLETO')).toHaveCount(0)

    await frame.getByText('Registrarme', { exact: true }).click()

    await expect(frame.getByText('Creá tu cuenta')).toBeVisible()
    await expect(frame.getByText('NOMBRE COMPLETO')).toBeVisible()

    await frame.getByText('Ingresar', { exact: true }).click()

    await expect(frame.getByText('Bienvenido de nuevo')).toBeVisible()
    await expect(frame.getByText('NOMBRE COMPLETO')).toHaveCount(0)
  })
})
