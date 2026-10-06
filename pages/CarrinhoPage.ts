import type { Locator, Page } from 'playwright';

export type CampoResumo = 'subtotal' | 'desconto' | 'frete' | 'total';

export class CarrinhoPage {
  constructor(private readonly page: Page) {}

  valor(campo: CampoResumo): Locator {
    return this.page.locator(`dd[data-valor="${campo}"]`);
  }

  avisoFrete(): Locator {
    return this.page.locator('.aviso-frete');
  }

  campoCupom(): Locator {
    return this.page.locator('#campo-cupom');
  }

  formCupom(): Locator {
    return this.page.locator('form.cupom');
  }

  async aplicarCupom(codigo: string) {
    await this.campoCupom().fill(codigo);
    await this.page.getByRole('button', { name: 'Aplicar cupom' }).click();
    // Espera o cupom ser aplicado ou a mensagem aparecer
    await this.cupomAplicado().or(this.page.locator('#mensagem-cupom')).waitFor();
    await this.aguardarRecalculo();
  }

  async removerCupom() {
    await this.page.getByRole('button', { name: 'Remover cupom' }).click();
    await this.aguardarRecalculo();
  }

  cupomAplicado(): Locator {
    return this.page.locator('.cupom-aplicado');
  }

  botaoAumentar(nome: string): Locator {
    return this.page.getByRole('button', { name: `Aumentar quantidade de ${nome}` });
  }

  async aumentar(nome: string) {
    await this.botaoAumentar(nome).click();
    await this.aguardarRecalculo();
  }

  async diminuir(nome: string) {
    await this.page.getByRole('button', { name: `Diminuir quantidade de ${nome}` }).click();
    await this.aguardarRecalculo();
  }

  async removerItem(nome: string) {
    await this.page.getByRole('button', { name: `Remover ${nome} do carrinho` }).click();
  }

  async finalizarCompra() {
    await this.page.getByRole('link', { name: 'Finalizar compra' }).click();
    await this.page.getByRole('heading', { name: 'Finalizar compra', level: 1 }).waitFor();
  }

  quantidade(nome: string): Locator {
    return this.page.locator(`output[aria-label="Quantidade de ${nome}"]`);
  }

  // Precisa estar na loja para gravar no sessionStorage
  async salvarNaAba(chave: string, valor: string) {
    if (!this.page.url().startsWith('http')) await this.page.goto('/');
    await this.page.evaluate(([k, v]) => sessionStorage.setItem(k, v), [chave, valor]);
  }

  async aguardarRecalculo() {
    await this.page.locator('.coluna-resumo[aria-busy="false"]').waitFor();
  }
}
