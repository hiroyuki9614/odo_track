import { expect, test } from '@playwright/test';

test.describe('public experience', () => {
  test('renders the public home page', async ({ page }) => {
    await page.goto('/');

    await expect(page).toHaveTitle('OdoTrack');
    await expect(
      page.getByRole('heading', { name: 'このアプリについて' }),
    ).toBeVisible();
    await expect(
      page.getByText('業務で使用する運転日報を記録・管理するアプリです。'),
    ).toBeVisible();
  });

  test('renders an interactive login form', async ({ page }) => {
    await page.goto('/auth/login');

    await expect(page.getByRole('heading', { name: 'ログイン' })).toBeVisible();
    const email = page.getByLabel('メールアドレス');
    const password = page.getByLabel('パスワード');

    await email.fill('playwright@example.test');
    await password.fill('playwright-password');
    await expect(email).toHaveValue('playwright@example.test');
    await expect(password).toHaveValue('playwright-password');
    await expect(page.locator('#new_user').getByRole('button', { name: 'ログイン' })).toBeVisible();
  });
});
