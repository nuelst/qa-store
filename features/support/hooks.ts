import { After, AfterAll, Before, BeforeAll, Status, setDefaultTimeout } from '@cucumber/cucumber';
import { chromium, request, type Browser } from 'playwright';
import { BASE_URL, HEADLESS, SLOW_MO, TIMEOUT } from './config.ts';
import type { CustomWorld } from './world.ts';
import { VitrinePage } from '../../pages/VitrinePage.ts';
import { CarrinhoPage } from '../../pages/CarrinhoPage.ts';
import { CheckoutPage } from '../../pages/CheckoutPage.ts';

setDefaultTimeout(TIMEOUT);

let browser: Browser;

BeforeAll(async () => {
  browser = await chromium.launch({ headless: HEADLESS, slowMo: SLOW_MO });
});

AfterAll(async () => {
  await browser?.close();
});

// ctx novo por cenário = empty stock
Before({ tags: '@ui' }, async function (this: CustomWorld) {
  this.context = await browser.newContext({ baseURL: BASE_URL, locale: 'pt-BR' });
  this.page = await this.context.newPage();
  this.vitrine = new VitrinePage(this.page);
  this.carrinho = new CarrinhoPage(this.page);
  this.checkout = new CheckoutPage(this.page);
});

Before({ tags: '@api' }, async function (this: CustomWorld) {
  this.api = await request.newContext({
    baseURL: BASE_URL,
    extraHTTPHeaders: { 'Content-Type': 'application/json' },
  });
});

After(async function (this: CustomWorld, { result, pickle }) {
  if (this.page) {
    // screen
    const shot = await this.page.screenshot({ fullPage: true });
    this.attach(shot, 'image/png');
    if (result?.status === Status.FAILED) {
      const nome = pickle.name.replace(/[^\w-]+/g, '_');
      await this.page.screenshot({ path: `reports/screenshots/${nome}.png`, fullPage: true });
    }
    await this.context?.close();
  }
  if (this.response) {
    this.attach(JSON.stringify({ status: this.response.status(), body: this.body }, null, 2), 'application/json');
  }
  await this.api?.dispose();
});
