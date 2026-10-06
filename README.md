# Verzel Store – Teste técnico QA Júnior

Validação da entrega **VZS-142 – Cupom de desconto e frete grátis** (v2.3.0) da
[Verzel Store](https://verzel-store.qa-test-verzel-store.workers.dev/), feita a partir da
[documentação da entrega](https://verzel-store.qa-test-verzel-store.workers.dev/documentacao).

## Resultado em resumo

- **181 cenários**: 171 execuções automatizadas (interface + API) e 10 manuais/exploratórios.
- **7 bugs** encontrados:

  | Bug | Severidade |
  |---|---|
  | [BUG-01](docs/bugs.md#bug-01) Subtotal de exatamente R$ 200,00 não ganha frete grátis (CA06) | Alta |
  | [BUG-02](docs/bugs.md#bug-02) API aceita mais de 5 unidades do mesmo produto (CA10) | Alta |
  | [BUG-03](docs/bugs.md#bug-03) Validação de e-mail aceita formatos inválidos | Média |
  | [BUG-04](docs/bugs.md#bug-04) Item sem `produtoId`/`quantidade` retorna código de erro errado | Baixa |
  | [BUG-05](docs/bugs.md#bug-05) Cupom só com espaços tratado diferente de cupom vazio (CA02) | Baixa |
  | [BUG-06](docs/bugs.md#bug-06) Carrinho mostra "Cupom aplicado." para cupom recusado (CA04) | Baixa |
  | [BUG-07](docs/bugs.md#bug-07) Dado inesperado no carrinho da aba deixa a loja em branco | Baixa |

- CA01, CA03, CA05, CA07, CA08, CA09 e CA11 funcionam conforme a documentação.

## Onde está cada entrega

| Entrega | Local |
|---|---|
| Cenários de teste (Gherkin) | [features/](features/): `ui/`, `api/` e `manual/` |
| Execução dos testes e resultado de cada cenário | [docs/execucao.md](docs/execucao.md) |
| Report de bugs | [docs/bugs.md](docs/bugs.md) |
| Evidências | [docs/evidencias/](docs/evidencias/) + relatório HTML gerado em `reports/` |
| Interpretações das ambiguidades | [docs/execucao.md#interpretações-de-ambiguidades](docs/execucao.md#interpretações-de-ambiguidades) |
| Automação (Playwright + Cucumber) | [features/step_definitions/](features/step_definitions/), [features/support/](features/support/), [pages/](pages/) |

## Stack

- [Cucumber.js](https://github.com/cucumber/cucumber-js): cenários em Gherkin, em português
- [Playwright](https://playwright.dev/): navegador (UI) e `APIRequestContext` (API)
- TypeScript executado via `tsx` (sem etapa de build)

## Como rodar

Pré-requisito: Node.js 20+.

```bash
npm install            # instala dependências e o Chromium do Playwright
npm test               # todos os cenários automatizados
npm run test:ui        # apenas interface (@ui)
npm run test:api       # apenas API (@api)
npm run test:sem-bugs  # tudo, exceto os cenários que reproduzem bugs conhecidos (@bug)
npm run test:headed    # interface com navegador visível e em câmera lenta
```

Filtrar por tag (critério de aceite, bug, etc.):

```bash
npm test -- --tags @CA06
npm test -- --tags @BUG-02
```

> `npm test` termina com **22 falhas esperadas**: são os cenários marcados com `@bug`, que
> reproduzem os bugs BUG-01 a BUG-07. Elas devem passar quando os bugs forem corrigidos.
> A suíte completa leva cerca de 4 a 5 minutos.

**Relatório:** `reports/cucumber-report.html`. Cada cenário de UI tem um screenshot anexado e
cada cenário de API tem o status e o corpo da resposta anexados. Screenshots de falhas também
ficam em `reports/screenshots/`.

Variáveis opcionais (`BASE_URL`, `HEADED`, `SLOW_MO`): copie o `.env.example` para `.env`
e ajuste. Também podem ser passadas na linha de comando, que tem prioridade sobre o `.env`.

```bash
cp .env.example .env
```

## Tags

| Tag | Significado |
|---|---|
| `@ui` / `@api` | Camada testada |
| `@CA01` … `@CA11` | Critério de aceite coberto |
| `@bug`, `@BUG-01` … `@BUG-07` | Cenário que reproduz um bug aberto |
| `@entradas` | Valores mal formatados, tipos inesperados e dados alterados na aba |
| `@manual` | Executado à mão, fora da automação |

## Estrutura

```
features/
  ui/                     carrinho, checkout, carrinho-adulterado (sessionStorage)
  api/                    carrinho-calcular, pedidos, produtos, erros, entradas-invalidas
  manual/                 cenários exploratórios (@manual)
  step_definitions/       implementação dos steps (ui e api)
  support/                World, hooks (navegador/API, evidências) e config
pages/                    Page Objects: Vitrine, Carrinho, Checkout
docs/
  execucao.md             resultado de cada cenário, cobertura por CA e ambiguidades
  bugs.md                 report dos bugs e observações
  evidencias/             screenshots dos bugs e dos testes exploratórios
```
