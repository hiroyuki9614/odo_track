import { defineConfig, devices } from '@playwright/test';

const port = Number(process.env.PLAYWRIGHT_PORT ?? 3001);
const baseURL = process.env.PLAYWRIGHT_BASE_URL ?? `http://127.0.0.1:${port}`;

export default defineConfig({
  testDir: './e2e',
  timeout: 60_000,
  expect: { timeout: 10_000 },
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI
    ? [['github'], ['html', { open: 'never' }]]
    : [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  webServer: process.env.PLAYWRIGHT_BASE_URL
    ? undefined
    : {
        command: `bundle exec rails server -e test -b 127.0.0.1 -p ${port}`,
        url: `${baseURL}/up`,
        reuseExistingServer: !process.env.CI,
        timeout: 120_000,
        env: {
          RAILS_ENV: 'test',
          SECRET_KEY_BASE: 'playwright-test-secret-key-base',
          PLAYWRIGHT_E2E: 'true',
        },
      },
  projects: [
    {
      name: 'macos-webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'ios-safari',
      use: { ...devices['iPhone 15'] },
    },
  ],
});
