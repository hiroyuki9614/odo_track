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

  test('registers a new user', async ({ page }, testInfo) => {
    const email = `playwright-${testInfo.project.name}-${Date.now()}@example.test`;

    await page.goto('/auth/login');
    await page.getByRole('link', { name: 'ユーザー登録はこちら' }).click();
    await expect(page.getByRole('heading', { name: 'ユーザー登録' })).toBeVisible();

    await page.getByLabel('お名前(フルネーム)').fill('Playwright テスト');
    await page.getByLabel('お電話番号').fill('09012345678');
    await page.getByLabel('メールアドレス').fill(email);
    await page.getByLabel('パスワード', { exact: true }).fill('playwright-password');
    await page.getByLabel('パスワード(確認)').fill('playwright-password');
    await page.getByRole('button', { name: '登録する' }).click();

    await expect(
      page.getByText('本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。'),
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
