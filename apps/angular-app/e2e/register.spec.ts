import { test, expect } from '@playwright/test';

/**
 * Tests E2E pour la page d'inscription Learn@Home
 */

test.describe("Page d'inscription", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/auth/register');
  });

  test("devrait afficher le formulaire d'inscription correctement", async ({
    page,
  }) => {
    // Vérifier le titre de la page
    await expect(page.locator('h1')).toHaveText('Créer un compte');

    // Vérifier le sous-titre
    await expect(page.locator('.auth-card__subtitle')).toHaveText(
      'Rejoignez Learn@Home',
    );

    // Vérifier la présence des champs du formulaire
    await expect(
      page.locator('app-input[formcontrolname="firstName"] input.lah-input__field'),
    ).toBeVisible();
    await expect(
      page.locator('app-input[formcontrolname="lastName"] input.lah-input__field'),
    ).toBeVisible();
    await expect(
      page.locator('app-input[formcontrolname="nickname"] input.lah-input__field'),
    ).toBeVisible();
    await expect(
      page.locator('app-input[formcontrolname="email"] input.lah-input__field'),
    ).toBeVisible();
    await expect(page.locator('input[formcontrolname="birthdate"]')).toBeVisible();
    await expect(
      page.locator('app-input[formcontrolname="password"] input.lah-input__field'),
    ).toBeVisible();
    await expect(
      page.locator('app-input[formcontrolname="passwordConfirm"] input.lah-input__field'),
    ).toBeVisible();

    // Vérifier le sélecteur de rôle
    await expect(page.getByRole('radio', { name: 'Élève' })).toBeVisible();
    await expect(page.getByRole('radio', { name: 'Bénévole' })).toBeVisible();

    // Vérifier le bouton de soumission
    await expect(
      page.getByRole('button', { name: 'Créer mon compte' }),
    ).toBeVisible();

    // Vérifier le lien vers la connexion
    await expect(
      page.getByRole('link', { name: 'Se connecter' }),
    ).toBeVisible();
  });

  test('devrait afficher les erreurs de validation pour les champs vides', async ({
    page,
  }) => {
    // Cliquer sur le bouton sans remplir les champs
    await page.getByRole('button', { name: 'Créer mon compte' }).click();

    // Vérifier les messages d'erreur
    await expect(page.getByText('Le prénom est requis.')).toBeVisible();
    await expect(page.getByText('Le nom est requis.')).toBeVisible();
    await expect(page.getByText('Le pseudo est requis.')).toBeVisible();
    await expect(page.getByText("L'email est requis.")).toBeVisible();
    await expect(page.getByText('Le mot de passe est requis.')).toBeVisible();
    await expect(page.getByText('La confirmation est requise.')).toBeVisible();
  });

  test('devrait valider le format du pseudo', async ({ page }) => {
    const nicknameInput = page.locator(
      'app-input[formcontrolname="nickname"] input.lah-input__field',
    );

    // Entrer un pseudo avec des espaces (invalide)
    await nicknameInput.fill('mon pseudo');
    await nicknameInput.blur();

    // Vérifier le message d'erreur
    await expect(
      page.getByText("Alphanumérique et _ uniquement, pas d'espaces."),
    ).toBeVisible();

    // Corriger avec un pseudo valide
    await nicknameInput.fill('mon_pseudo123');
    await nicknameInput.blur();

    // L'erreur doit disparaître
    await expect(
      page.getByText("Alphanumérique et _ uniquement, pas d'espaces."),
    ).not.toBeVisible();
  });

  test('devrait valider la force du mot de passe', async ({ page }) => {
    const passwordInput = page.locator(
      'app-input[formcontrolname="password"] input.lah-input__field',
    );

    // Mot de passe trop court
    await passwordInput.fill('abc');
    await passwordInput.blur();
    await expect(page.getByText('Minimum 8 caractères.')).toBeVisible();

    // Mot de passe sans majuscule
    await passwordInput.fill('abcdefgh1');
    await passwordInput.blur();
    await expect(page.getByText('Au moins une majuscule requise.')).toBeVisible();

    // Mot de passe sans chiffre
    await passwordInput.fill('Abcdefgh');
    await passwordInput.blur();
    await expect(page.getByText('Au moins un chiffre requis.')).toBeVisible();

    // Mot de passe valide
    await passwordInput.fill('Abcdefgh1');
    await passwordInput.blur();
    await expect(page.getByText('Minimum 8 caractères.')).not.toBeVisible();
    await expect(
      page.getByText('Au moins une majuscule requise.'),
    ).not.toBeVisible();
    await expect(page.getByText('Au moins un chiffre requis.')).not.toBeVisible();
  });

  test('devrait vérifier que les mots de passe correspondent', async ({
    page,
  }) => {
    const passwordInput = page.locator(
      'app-input[formcontrolname="password"] input.lah-input__field',
    );
    const confirmInput = page.locator(
      'app-input[formcontrolname="passwordConfirm"] input.lah-input__field',
    );

    // Entrer des mots de passe différents
    await passwordInput.fill('Azerty12345!');
    await confirmInput.fill('AutreMotDePasse1');
    await confirmInput.blur();

    // Soumettre pour déclencher la validation
    await page.getByRole('button', { name: 'Créer mon compte' }).click();

    // Vérifier le message d'erreur
    await expect(
      page.getByText('Les mots de passe ne correspondent pas.'),
    ).toBeVisible();

    // Corriger avec le même mot de passe
    await confirmInput.fill('Azerty12345!');
    await confirmInput.blur();

    // L'erreur doit disparaître après avoir rempli les autres champs obligatoires
    await expect(
      page.getByText('Les mots de passe ne correspondent pas.'),
    ).not.toBeVisible();
  });

//   test("devrait créer un compte avec succès et rediriger vers le tableau de bord", async ({
//     page,
//   }) => {
//     const timestamp = Date.now();
//     const uniqueEmail = `test.e2e+${timestamp}@example.com`;
//     const uniqueNickname = `user_${timestamp}`.slice(0, 20);

//     await page
//       .locator('app-input[formcontrolname="firstName"] input.lah-input__field')
//       .fill('Jean');
//     await page
//       .locator('app-input[formcontrolname="lastName"] input.lah-input__field')
//       .fill('Dupont');
//     await page
//       .locator('app-input[formcontrolname="nickname"] input.lah-input__field')
//       .fill(uniqueNickname);
//     await page
//       .locator('app-input[formcontrolname="email"] input.lah-input__field')
//       .fill(uniqueEmail);

//     const birthdateInput = page.locator('input[formcontrolname="birthdate"]');
//     await birthdateInput.click();
//     await birthdateInput.fill('2010-01-15');
//     await birthdateInput.press('Tab');
//     await page
//       .waitForSelector('.mat-calendar', { state: 'hidden', timeout: 3000 })
//       .catch(() => {});

//     await expect(page.getByRole('radio', { name: 'Élève' })).toBeChecked();

//     await page
//       .locator('app-input[formcontrolname="password"] input.lah-input__field')
//       .fill('Azerty12345!');
//     await page
//       .locator('app-input[formcontrolname="passwordConfirm"] input.lah-input__field')
//       .fill('Azerty12345!');

//     await expect(page.getByRole('button', { name: 'Créer mon compte' })).toBeEnabled();

//     await page.getByRole('button', { name: 'Créer mon compte' }).click();

//     await expect(page.locator('.auth-error-banner')).not.toBeVisible();

//     await expect(page).toHaveURL('/dashboard', { timeout: 20000 });
//   });

  test("devrait afficher une erreur si l'email est déjà utilisé", async ({
    page,
  }) => {
    // Remplir le formulaire avec un email déjà existant
    await page
      .locator('app-input[formcontrolname="firstName"] input.lah-input__field')
      .fill('Test');
    await page
      .locator('app-input[formcontrolname="lastName"] input.lah-input__field')
      .fill('User');
    await page
      .locator('app-input[formcontrolname="nickname"] input.lah-input__field')
      .fill('testuser_existing');
    await page
      .locator('app-input[formcontrolname="email"] input.lah-input__field')
      .fill('bob@smith.com'); // Email déjà utilisé

    // Saisir la date de naissance directement dans le champ texte.
    // Le datepicker est configuré en startView="multi-year" : un seul clic
    // sur une cellule navigue vers la vue mois sans sélectionner de date.
    // NativeDateAdapter.parse() utilise Date.parse(), qui accepte le format ISO.
    const birthdateInput = page.locator('input[formcontrolname="birthdate"]');
    await birthdateInput.click();
    await birthdateInput.fill('2010-01-15');
    await birthdateInput.press('Tab');
    // Fermer le calendrier s'il s'est ouvert automatiquement
    await page.waitForSelector('.mat-calendar', { state: 'hidden', timeout: 3000 }).catch(() => {});

    // Remplir les mots de passe
    await page
      .locator('app-input[formcontrolname="password"] input.lah-input__field')
      .fill('Azerty12345!');
    await page
      .locator('app-input[formcontrolname="passwordConfirm"] input.lah-input__field')
      .fill('Azerty12345!');

    // Soumettre le formulaire
    await page.getByRole('button', { name: 'Créer mon compte' }).click();

    // Vérifier qu'une erreur Firebase s'affiche (email déjà utilisé)
    // Timeout augmenté pour tenir compte du temps de réponse réseau Firebase
    await expect(page.locator('.auth-error-banner')).toBeVisible({ timeout: 15000 });

    // Vérifier qu'on reste sur la page d'inscription
    await expect(page).toHaveURL('/auth/register');
  });
});
