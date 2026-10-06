import { Given, Then, When, type DataTable } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import type { CustomWorld } from '../support/world.ts';

const CLIENTE_VALIDO = { nome: 'Maria Silva', email: 'maria@exemplo.com', cep: '01310-100' };
const CAMPOS_MONETARIOS = ['subtotal', 'desconto', 'frete', 'total', 'valorFaltanteFreteGratis'];

function lerCampo(obj: any, caminho: string): unknown {
  // Suporta "cupom.aplicado" e "itens[0].total"
  return caminho
    .replace(/\[(\d+)\]/g, '.$1')
    .split('.')
    .reduce((atual, chave) => (atual == null ? undefined : atual[chave]), obj);
}

async function enviar(world: CustomWorld, metodo: string, rota: string, data?: unknown) {
  world.response = await world.api.fetch(rota, { method: metodo, data });
  world.body = await world.response.json().catch(() => undefined);
}

// ---------- Montagem da requisição ----------

Given('um carrinho com os itens:', function (this: CustomWorld, tabela: DataTable) {
  this.payload.itens = tabela.hashes().map((linha) => ({
    produtoId: linha.produtoId,
    quantidade: Number(linha.quantidade),
  }));
});

Given('o cupom {string}', function (this: CustomWorld, cupom: string) {
  this.payload.cupom = cupom;
});

// O Gherkin remove espaços das células, por isso o parâmetro
Given('o cupom {string} com {int} espaços nas pontas', function (this: CustomWorld, cupom: string, espacos: number) {
  const pad = ' '.repeat(espacos);
  this.payload.cupom = `${pad}${cupom}${pad}`;
});

Given('um cliente válido', function (this: CustomWorld) {
  this.payload.cliente = { ...CLIENTE_VALIDO };
});

Given('o cliente com {string} igual a {string}', function (this: CustomWorld, campo: string, valor: string) {
  this.payload.cliente = { ...CLIENTE_VALIDO, ...(this.payload.cliente as object), [campo]: valor };
});

// ---------- Chamadas ----------

When('calculo o carrinho', async function (this: CustomWorld) {
  await enviar(this, 'POST', '/api/carrinho/calcular', this.payload);
});

When('envio o pedido', async function (this: CustomWorld) {
  await enviar(this, 'POST', '/api/pedidos', this.payload);
});

When('faço {word} em {string}', async function (this: CustomWorld, metodo: string, rota: string) {
  await enviar(this, metodo, rota);
});

// Corpo enviado como está (JSON inválido, tipos errados)
When('faço POST em {string} com o corpo:', async function (this: CustomWorld, rota: string, corpo: string) {
  await enviar(this, 'POST', rota, corpo);
});

// ---------- Validações ----------

Then('o status da resposta deve ser {int}', function (this: CustomWorld, status: number) {
  expect(this.response!.status(), JSON.stringify(this.body)).toBe(status);
});

// Valor esperado em JSON: 200, true, null, "texto"
Then('o campo {string} deve ser {}', function (this: CustomWorld, caminho: string, esperado: string) {
  expect(lerCampo(this.body, caminho), JSON.stringify(this.body)).toEqual(JSON.parse(esperado));
});

Then('o campo {string} deve corresponder a {string}', function (this: CustomWorld, caminho: string, padrao: string) {
  expect(String(lerCampo(this.body, caminho))).toMatch(new RegExp(padrao));
});

Then('os valores devem ser:', function (this: CustomWorld, tabela: DataTable) {
  const esperado = Object.fromEntries(Object.entries(tabela.rowsHash()).map(([k, v]) => [k, JSON.parse(v)]));
  const obtido = Object.fromEntries(Object.keys(esperado).map((k) => [k, lerCampo(this.body, k)]));
  expect(obtido, JSON.stringify(this.body)).toEqual(esperado);
});

Then('todos os valores monetários devem ter no máximo 2 casas decimais', function (this: CustomWorld) {
  const valores: Record<string, unknown> = Object.fromEntries(CAMPOS_MONETARIOS.map((k) => [k, this.body[k]]));
  this.body.itens?.forEach((item: any, i: number) => {
    valores[`itens[${i}].precoUnitario`] = item.precoUnitario;
    valores[`itens[${i}].total`] = item.total;
  });
  for (const [campo, valor] of Object.entries(valores)) {
    expect(String(valor), campo).toMatch(/^-?\d+(\.\d{1,2})?$/);
  }
});

Then('o erro deve ter código {string} no campo {string}', function (this: CustomWorld, codigo: string, campo: string) {
  expect(this.body?.erro, JSON.stringify(this.body)).toMatchObject({ codigo, campo });
});

Then('o erro deve ter código {string}', function (this: CustomWorld, codigo: string) {
  expect(this.body?.erro?.codigo, JSON.stringify(this.body)).toBe(codigo);
});

Then('o erro deve apontar o campo {string} com a mensagem {string}', function (this: CustomWorld, campo: string, mensagem: string) {
  expect(this.body?.erro?.campos, JSON.stringify(this.body)).toContainEqual({ campo, mensagem });
});

Then('o erro deve apontar o campo {string}', function (this: CustomWorld, campo: string) {
  const campos = (this.body?.erro?.campos ?? []).map((c: { campo: string }) => c.campo);
  expect(campos, JSON.stringify(this.body)).toContain(campo);
});

Then('a lista de produtos deve ser:', function (this: CustomWorld, tabela: DataTable) {
  const esperado = tabela.hashes().map((p) => ({ id: p.id, nome: p.nome, preco: Number(p.preco) }));
  const obtido = (this.body as any[]).map(({ id, nome, preco }) => ({ id, nome, preco }));
  expect(obtido).toEqual(esperado);
});
