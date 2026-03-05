import { test, expect } from '@playwright/test';

/**
 * Tests E2E pour la page de connexion Learn@Home
 */

test.describe('Page de connexion', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/auth/login');
  });

  test('devrait afficher le formulaire de connexion correctement', async ({
    page,
  }) => {
    // Vérifier le titre de la page
    await expect(page.locator('h1')).toHaveText('Connexion');

    // Vérifier le sous-titre
    await expect(page.locator('.auth-card__subtitle')).toHaveText(
      'Bienvenue sur Learn@Home',
    );

    // Vérifier la présence des champs email et mot de passe (input natif à l'intérieur du composant)
    await expect(page.locator('input.lah-input__field[type="email"]')).toBeVisible();
    await expect(page.locator('input.lah-input__field[type="password"]')).toBeVisible();

    // Vérifier le bouton de soumission
    await expect(page.getByRole('button', { name: 'Se connecter' })).toBeVisible();

    // Vérifier les liens de navigation
    await expect(page.getByRole('link', { name: 'Mot de passe oublié ?' })).toBeVisible();
    await expect(page.getByRole('link', { name: "S'inscrire" })).toBeVisible();
  });

  test('devrait afficher les erreurs de validation pour les champs vides', async ({
    page,
  }) => {
    // Cliquer sur le bouton sans remplir les champs
    await page.getByRole('button', { name: 'Se connecter' }).click();

    // Vérifier les messages d'erreur
    await expect(page.getByText("L'email est requis.")).toBeVisible();
    await expect(page.getByText('Le mot de passe est requis.')).toBeVisible();
  });

  test("devrait afficher une erreur pour un email invalide", async ({
    page,
  }) => {
    // Cibler l'input natif à l'intérieur du composant app-input
    const emailInput = page.locator('input.lah-input__field[type="email"]');

    // Entrer un email invalide
    await emailInput.fill('email-invalide');
    await emailInput.blur();

    // Vérifier le message d'erreur
    await expect(page.getByText("Format d'email invalide.")).toBeVisible();
  });

  test('devrait permettre de basculer la visibilité du mot de passe', async ({
    page,
  }) => {
    // Cibler l'input natif du mot de passe à l'intérieur de app-input
    const passwordInput = page.locator('app-input[formcontrolname="password"] input.lah-input__field');

    // Vérifier que le type initial est "password"
    await expect(passwordInput).toHaveAttribute('type', 'password');

    // Remplir le mot de passe pour activer le champ
    await passwordInput.fill('monmotdepasse');

    // Cliquer sur l'icône pour afficher le mot de passe (bouton suffix dans le composant)
    await page.locator('app-input[formcontrolname="password"] .lah-input__suffix').click();

    // Vérifier que le type est maintenant "text"
    await expect(passwordInput).toHaveAttribute('type', 'text');

    // Cliquer à nouveau pour masquer
    await page.locator('app-input[formcontrolname="password"] .lah-input__suffix').click();

    // Vérifier que le type est revenu à "password"
    await expect(passwordInput).toHaveAttribute('type', 'password');
  });

  test('devrait connecter un utilisateur valide et rediriger vers le dashboard', async ({
    page,
  }) => {
    // Remplir le formulaire avec des identifiants valides
    const emailInput = page.locator('input.lah-input__field[type="email"]');
    const passwordInput = page.locator('app-input[formcontrolname="password"] input.lah-input__field');

    await emailInput.fill('bob@smith.com');
    await passwordInput.fill('Azerty12345!');

    // Soumettre le formulaire
    await page.getByRole('button', { name: 'Se connecter' }).click();

    // Attendre la redirection vers le dashboard
    await expect(page).toHaveURL('/dashboard', { timeout: 10000 });

    // Vérifier qu'on est bien sur le dashboard (présence d'un élément caractéristique)
    await expect(page.locator('app-sidebar')).toBeVisible({ timeout: 5000 });
  });

  test('devrait afficher une erreur pour des identifiants incorrects', async ({
    page,
  }) => {
    // Remplir le formulaire avec des identifiants invalides
    const emailInput = page.locator('input.lah-input__field[type="email"]');
    const passwordInput = page.locator('app-input[formcontrolname="password"] input.lah-input__field');

    await emailInput.fill('utilisateur@inexistant.com');
    await passwordInput.fill('mauvais-mot-de-passe');

    // Soumettre le formulaire
    await page.getByRole('button', { name: 'Se connecter' }).click();

    // Vérifier qu'une bannière d'erreur Firebase s'affiche
    await expect(page.locator('.auth-error-banner')).toBeVisible({ timeout: 10000 });

    // Vérifier qu'on reste sur la page de connexion
    await expect(page).toHaveURL('/auth/login');
  });
});
