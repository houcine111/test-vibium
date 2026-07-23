import { initRun } from './lib.js'

const URL = 'https://example.com'

const { report, bro, page } = await initRun('Test Suite')

// --- Naviguer vers l'app ---
await report.step('Naviguer vers la page', async () => {
  await page.go(URL)
  await page.waitUntil.loaded()
})
await report.screenshot(page, '01-accueil')

// --- Lire le titre ---
await report.step('Lire le titre de la page', async () => {
  const title = await page.title()
  if (!title) throw new Error('Titre vide')
})
await report.screenshot(page, '02-page-chargee')

// --- TODO : ajoute tes tests ici ---
// await report.step('Cliquer sur connexion', async () => {
//   await page.find("a[href='/login']").click()
// })
// await report.step('Remplir email', async () => {
//   await page.find("input[name=email]").fill('user@test.com')
// })

await bro.stop()
await report.save()
