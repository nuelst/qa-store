import { Given, Then, When, type DataTable } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import type { CustomWorld } from '../support/world.ts';
import type { CampoResumo } from '../../pages/CarrinhoPage.ts';
import { campoCliente } from '../../pages/CheckoutPage.ts';

// ---------- Vitrine ----------

Given('que estou na vitrine da Verzel Store', async function (this: CustomWorld) {
  await this.vitrine.abrir();
});

When('adiciono {string} ao carrinho', async function (this: CustomWorld, produto: string) {
  await this.vitrine.adicionar(produto);
});

When('adiciono {int} unidade(s) de {string} ao carrinho', async function (this: CustomWorld, qtd: number, produto: string) {
  await this.vitrine.adicionar(produto, qtd);
});

Then('o botão de adicionar {string} deve estar desabilitado', async function (this: CustomWorld, produto: string) {
  await expect(this.vitrine.botaoAdicionar(produto)).toBeDisabled();
});

Then('o card de {string} deve exibir {string}', async function (this: CustomWorld, produto: string, aviso: string) {
  await expect(this.vitrine.avisoDoProduto(produto)).toHaveText(aviso);
});

Then('o contador do carrinho deve ser {int}', async function (this: CustomWorld, qtd: number) {
  await expect(this.vitrine.contadorCarrinho()).toHaveText(String(qtd));
});

// ---------- Carrinho ----------

When('abro o carrinho', async function (this: CustomWorld) {
  await this.vitrine.irParaCarrinho();
  await this.carrinho.aguardarRecalculo();
});

When('aplico o cupom {string}', async function (this: CustomWorld, cupom: string) {
  await this.carrinho.aplicarCupom(cupom);
});

// O Gherkin remove espaços das células, por isso o parâmetro
When('aplico o cupom {string} com {int} espaços nas pontas', async function (this: CustomWorld, cupom: string, espacos: number) {
  const pad = ' '.repeat(espacos);
  await this.carrinho.aplicarCupom(`${pad}${cupom}${pad}`);
});

When('removo o cupom', async function (this: CustomWorld) {
  await this.carrinho.removerCupom();
});

When('aumento a quantidade de {string}', async function (this: CustomWorld, produto: string) {
  await this.carrinho.aumentar(produto);
});

When('diminuo a quantidade de {string}', async function (this: CustomWorld, produto: string) {
  await this.carrinho.diminuir(produto);
});

When('removo {string} do carrinho', async function (this: CustomWorld, produto: string) {
  await this.carrinho.removerItem(produto);
});

When('recarrego a página', async function (this: CustomWorld) {
  await this.page.reload();
  await this.carrinho.aguardarRecalculo();
});

Then(/^o (subtotal|desconto|frete|total) deve ser "([^"]*)"$/, async function (this: CustomWorld, campo: CampoResumo, valor: string) {
  await expect(this.carrinho.valor(campo)).toHaveText(valor);
});

Then('devo ver a mensagem {string}', async function (this: CustomWorld, mensagem: string) {
  await expect(this.page.getByText(mensagem, { exact: true })).toBeVisible();
});

Then('não devo ver o aviso de valor faltante para o frete grátis', async function (this: CustomWorld) {
  await expect(this.carrinho.avisoFrete()).toBeHidden();
});

Then('devo ver o cupom {string} aplicado', async function (this: CustomWorld, cupom: string) {
  await expect(this.carrinho.cupomAplicado()).toContainText(`Cupom ${cupom} aplicado.`);
});

Then('o campo de cupom não deve estar disponível', async function (this: CustomWorld) {
  await expect(this.carrinho.campoCupom()).toBeHidden();
});

Then('o campo de cupom deve estar disponível e vazio', async function (this: CustomWorld) {
  await expect(this.carrinho.campoCupom()).toBeVisible();
  await expect(this.carrinho.campoCupom()).toHaveValue('');
});

Then('a quantidade de {string} deve ser {int}', async function (this: CustomWorld, produto: string, qtd: number) {
  await expect(this.carrinho.quantidade(produto)).toHaveText(String(qtd));
});

Then('o botão de aumentar a quantidade de {string} deve estar desabilitado', async function (this: CustomWorld, produto: string) {
  await expect(this.carrinho.botaoAumentar(produto)).toBeDisabled();
});

// ---------- Carrinho salvo na aba (sessionStorage) ----------

Given('que o carrinho salvo na aba é:', async function (this: CustomWorld, itens: string) {
  await this.carrinho.salvarNaAba('verzel-store:itens', itens);
});

Given('o cupom salvo na aba é {string}', async function (this: CustomWorld, cupom: string) {
  await this.carrinho.salvarNaAba('verzel-store:cupom', JSON.stringify(cupom));
});

When('abro o carrinho pela URL', async function (this: CustomWorld) {
  await this.page.goto('/carrinho');
});

Then('não devo conseguir finalizar a compra', async function (this: CustomWorld) {
  await expect(this.page.getByRole('heading', { name: 'Carrinho', level: 1 })).toBeVisible();
  await expect(this.page.getByRole('link', { name: 'Finalizar compra' })).toBeHidden();
});

Then('a página do carrinho deve ser exibida', async function (this: CustomWorld) {
  await expect(this.page.getByRole('heading', { name: 'Carrinho', level: 1 })).toBeVisible();
});

Then('não devo ver o cupom {string} aplicado', async function (this: CustomWorld, cupom: string) {
  await expect(this.page.getByText(`Cupom ${cupom} aplicado.`)).toBeHidden();
});

// ---------- Checkout ----------

When('sigo para o checkout', async function (this: CustomWorld) {
  await this.carrinho.finalizarCompra();
});

When('preencho os dados de entrega:', async function (this: CustomWorld, tabela: DataTable) {
  const dados = Object.fromEntries(
    Object.entries(tabela.rowsHash()).map(([rotulo, valor]) => [campoCliente(rotulo), valor]),
  );
  await this.checkout.preencher(dados);
});

When('preencho o campo {string} com {string}', async function (this: CustomWorld, rotulo: string, valor: string) {
  await this.checkout.preencher({ [campoCliente(rotulo)]: valor });
});

When('confirmo o pedido', async function (this: CustomWorld) {
  await this.checkout.confirmar();
});

Then('devo ver o pedido confirmado com número no formato VZ-000000', async function (this: CustomWorld) {
  await expect(this.page).toHaveURL(/\/pedido-confirmado$/);
  await expect(this.checkout.numeroPedido()).toHaveText(/^VZ-\d{6}$/);
});

Then('o campo {string} deve exibir o erro {string}', async function (this: CustomWorld, rotulo: string, mensagem: string) {
  const campo = campoCliente(rotulo);
  await expect(this.checkout.erro(campo)).toHaveText(mensagem);
  await expect(this.checkout.input(campo)).toHaveAttribute('aria-invalid', 'true');
});

Then('o campo {string} não deve exibir erro', async function (this: CustomWorld, rotulo: string) {
  await expect(this.checkout.erro(campoCliente(rotulo))).toBeHidden();
});

Then('devo permanecer no checkout', async function (this: CustomWorld) {
  const resposta = this.checkout.ultimaResposta;
  if (resposta) {
    expect(resposta.status(), `a API confirmou o pedido: ${await resposta.text()}`).not.toBe(201);
  }
  await expect(this.page).toHaveURL(/\/checkout$/);
});
