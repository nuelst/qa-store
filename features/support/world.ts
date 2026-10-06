import { setWorldConstructor, World, type IWorldOptions } from '@cucumber/cucumber';
import type { APIRequestContext, APIResponse, Browser, BrowserContext, Page } from 'playwright';
import { VitrinePage } from '../../pages/VitrinePage.ts';
import { CarrinhoPage } from '../../pages/CarrinhoPage.ts';
import { CheckoutPage } from '../../pages/CheckoutPage.ts';

export class CustomWorld extends World {
  browser?: Browser;
  context?: BrowserContext;
  page!: Page;
  api!: APIRequestContext;

  vitrine!: VitrinePage;
  carrinho!: CarrinhoPage;
  checkout!: CheckoutPage;

  payload: Record<string, unknown> = {};
  response?: APIResponse;
  body?: any;

  constructor(options: IWorldOptions) {
    super(options);
  }
}

setWorldConstructor(CustomWorld);
