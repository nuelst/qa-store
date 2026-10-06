import { expect } from '@playwright/test';
import type { Locator, Page } from 'playwright';

export class VitrinePage {
  constructor(private readonly page: Page) {}

  async abrir() {
    await this.page.goto('/');
    await this.page.locator('.grade-produtos').waitFor();
  }

  cardDoProduto(nome: string): Locator {
    return this.page.locator('article', { has: this.page.getByRole('heading', { name: nome, exact: true }) });
  }

  botaoAdicionar(nome: string): Locator {
    return this.cardDoProduto(nome).getByRole('button', { name: 'Adicionar ao carrinho' });
  }

  async adicionar(nome: string, vezes = 1) {
    // Espera o contador atualizar a cada clique
    for (let i = 0; i < vezes; i++) {
      const antes = Number(await this.contadorCarrinho().textContent());
      await this.botaoAdicionar(nome).click();
      await expect(this.contadorCarrinho()).toHaveText(String(antes + 1));
    }
  }

  avisoDoProduto(nome: string): Locator {
    return this.cardDoProduto(nome).locator('.produto-aviso');
  }

  contadorCarrinho(): Locator {
    return this.page.locator('.contador-carrinho');
  }

  async irParaCarrinho() {
    await this.page.getByRole('link', { name: /Carrinho/ }).click();
    await this.page.getByRole('heading', { name: 'Carrinho', level: 1 }).waitFor();
  }
}
