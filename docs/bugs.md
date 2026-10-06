# Report de bugs – VZS-142 (v2.3.0)

Ambiente: https://verzel-store.qa-test-verzel-store.workers.dev · Data: 06/10/2026 · Navegador: Chromium (Playwright 1.63)

| ID | Título | Severidade | Prioridade | CA | Onde | Status |
|---|---|---|---|---|---|---|
| [BUG-01](#bug-01) | Subtotal de exatamente R$ 200,00 não ganha frete grátis | Alta | Alta | CA06 | API (`/carrinho/calcular` e `/pedidos`) e interface | Aberto |
| [BUG-02](#bug-02) | API aceita mais de 5 unidades do mesmo produto | Alta | Alta | CA10 | API (`/carrinho/calcular` e `/pedidos`) | Aberto |
| [BUG-03](#bug-03) | Validação de e-mail aceita formatos inválidos | Média | Média | – | Checkout e `/pedidos` | Aberto |
| [BUG-04](#bug-04) | Item sem `produtoId` ou `quantidade` retorna código de erro errado | Baixa | Baixa | – | API (`/carrinho/calcular` e `/pedidos`) | Aberto |
| [BUG-05](#bug-05) | Cupom só com espaços é tratado diferente de cupom vazio | Baixa | Baixa | CA02 | API (`/carrinho/calcular` e `/pedidos`) | Aberto |
| [BUG-06](#bug-06) | Carrinho mostra "Cupom aplicado." para cupom recusado pela API | Baixa | Média | CA04 | Interface (carrinho) | Aberto |
| [BUG-07](#bug-07) | Dados inesperados no carrinho da aba deixam a loja inteira em branco | Baixa | Baixa | – | Interface (vitrine e carrinho) | Aberto |

Observações e sugestões de melhoria (não são bugs) estão no fim do documento.

---

## BUG-01

**Subtotal de exatamente R$ 200,00 não ganha frete grátis**

| | |
|---|---|
| Critério | CA06: "O frete é grátis para compras com subtotal a partir de R$ 200,00, **inclusive**." |
| Severidade | Alta: cliente paga R$ 19,90 indevidos, e o valor de referência da promoção é justamente o caso que falha. |
| Onde | `POST /api/carrinho/calcular`, `POST /api/pedidos` e o carrinho/checkout da interface (que exibem o cálculo da API) |
| Cenários | CT-UI-02, CT-API-01 (exemplos "exatamente no limite"), CT-API-16 |

**Passos (API)**

```http
POST /api/carrinho/calcular
Content-Type: application/json

{ "itens": [ { "produtoId": "P005", "quantidade": 2 } ] }
```

**Esperado**

```json
{ "subtotal": 200, "frete": 0, "freteGratis": true, "valorFaltanteFreteGratis": 0, "total": 200 }
```

**Obtido**

```json
{ "subtotal": 200, "frete": 19.9, "freteGratis": false, "valorFaltanteFreteGratis": 0, "total": 219.9 }
```

**Passos (interface)**

1. Na vitrine, adicionar 2× "Mochila Urbana 20L" (ou 4× "Garrafa Térmica 750ml").
2. Abrir o carrinho.

**Obtido na interface:** Frete R$ 19,90, Total R$ 219,90 e a mensagem contraditória **"Faltam R$ 0,00 para o frete grátis."**

**Observações**

- A resposta é inconsistente consigo mesma: `valorFaltanteFreteGratis = 0` mas `freteGratis = false`. Isso indica que a comparação usa `>` em vez de `>=`.
- Subtotais acima do limite (R$ 219,80, R$ 229,90) e abaixo (R$ 199,80, R$ 189,90) estão corretos; só a igualdade falha.
- Também ocorre em `POST /api/pedidos`: o pedido é confirmado com total R$ 219,90.

**Evidência:** [BUG-01-subtotal-200-cobra-frete.png](evidencias/BUG-01-subtotal-200-cobra-frete.png) e o relatório HTML da automação.

---

## BUG-02

**API aceita mais de 5 unidades do mesmo produto**

| | |
|---|---|
| Critério | CA10: "Cada produto pode ter no máximo 5 unidades por pedido. A regra vale para a interface e para a API." |
| Severidade | Alta: um pedido com quantidade acima do limite é confirmado (201). |
| Onde | `POST /api/carrinho/calcular` e `POST /api/pedidos`. A interface bloqueia corretamente. |
| Cenários | CT-API-11, CT-API-17 |

**Passos**

```http
POST /api/pedidos
Content-Type: application/json

{
  "cliente": { "nome": "Maria Silva", "email": "maria@exemplo.com", "cep": "01310-100" },
  "itens": [ { "produtoId": "P005", "quantidade": 6 } ]
}
```

**Esperado:** `422` com

```json
{ "erro": { "codigo": "QUANTIDADE_MAXIMA_EXCEDIDA", "campo": "itens[0].quantidade" } }
```

**Obtido:** `201` com pedido `VZ-xxxxxx`, `quantidade: 6`, `subtotal: 600`.
Em `/api/carrinho/calcular` com 6 unidades de P001: `200` com subtotal R$ 359,40.
Não existe teto algum: `quantidade: 999999999` responde `200` com subtotal R$ 99.999.999.900,00 (CT-API-29).

**Impacto pela interface:** a vitrine e o "+" do carrinho bloqueiam a 6ª unidade, mas o front
confia na quantidade salva na aba. Com o carrinho salvo com 99 unidades, o carrinho mostra
"Limite de 5 unidades por produto." e **mesmo assim permite finalizar**, e a API confirma o pedido
(CT-UI-24). Como a API é a última barreira, o limite não é garantido em lugar nenhum.

**Observações**

- Com exatamente 5 unidades a API responde corretamente (CT-API-10).
- Na interface o limite funciona no uso normal: a vitrine desabilita "Adicionar ao carrinho" com "Limite de 5 unidades atingido." e o carrinho desabilita o "+" com "Limite de 5 unidades por produto." (CT-UI-12, CT-UI-13).
- O código `QUANTIDADE_MAXIMA_EXCEDIDA` está documentado, mas nunca é retornado.

**Evidência:** [EXP-storage-qtd-99.png](evidencias/EXP-storage-qtd-99.png), [EXP-storage-qtd-6.png](evidencias/EXP-storage-qtd-6.png) e o relatório HTML da automação.

---

## BUG-03

**Validação de e-mail aceita formatos inválidos**

| | |
|---|---|
| Regra | "O e-mail precisa ter um formato válido." (regras que já existiam) |
| Severidade | Média: pedido confirmado com e-mail inutilizável. Hoje nenhum e-mail é enviado (ambiente de teste), mas em produção o cliente não receberia a confirmação. |
| Onde | Checkout (front) e `POST /api/pedidos`. Os dois aceitam os mesmos valores, o que indica a mesma regra fraca nos dois lados. |
| Cenários | CT-UI-21, CT-API-36 |

**Passos (interface):** no checkout, preencher nome e CEP válidos, e-mail `maria@exemplo..com` e confirmar.

**Esperado:** "Informe um e-mail válido." e o pedido não é enviado.
**Obtido:** pedido confirmado.

Valores aceitos indevidamente:

| E-mail | Problema |
|---|---|
| `maria@exemplo..com` | pontos seguidos no domínio |
| `maria..silva@exemplo.com` | pontos seguidos no usuário |
| `.maria@exemplo.com` | usuário começa com ponto |
| `maria@exemplo.com.` | domínio termina com ponto |
| `maria@exemplo_com.br` | `_` não é permitido em nome de domínio |

Valores rejeitados corretamente: `maria@`, `maria@exemplo`, `maria exemplo.com`, `maria@@exemplo.com`, `@exemplo.com`, `maria@.com`, `maria@ex ample.com`.
Valores válidos pouco comuns aceitos corretamente: `maria+loja@exemplo.com`, `maria@mail.exemplo.com.br`, `Maria@Exemplo.COM`, `maria_silva@exemplo.com`.

---

## BUG-04

**Item sem `produtoId` ou `quantidade` retorna código de erro errado**

| | |
|---|---|
| Regra | Tabela de erros: `422 ITEM_INVALIDO`, "Um item não é um objeto com produtoId e quantidade." |
| Severidade | Baixa: a requisição é recusada, mas com código e mensagem que confundem quem integra com a API. |
| Cenário | CT-API-28 |

**Passos**

```http
POST /api/carrinho/calcular
{ "itens": [ { "quantidade": 1 } ] }
```

**Esperado:** `422` com `ITEM_INVALIDO` no campo `itens[0]`.

**Obtido:**

```json
{ "erro": { "codigo": "PRODUTO_NAO_ENCONTRADO", "mensagem": "Produto undefined não encontrado.", "campo": "itens[0].produtoId" } }
```

Com `"produtoId": null` a mensagem é "Produto null não encontrado.". O valor interno `undefined`/`null` vaza na mensagem.
Sem `quantidade`, a resposta é `QUANTIDADE_INVALIDA`, quando deveria ser `ITEM_INVALIDO`.

---

## BUG-05

**Cupom só com espaços é tratado diferente de cupom vazio**

| | |
|---|---|
| Regra | CA02: "espaços no início e no fim são ignorados". Logo, `"   "` equivale a `""`. |
| Severidade | Baixa |
| Cenários | CT-API-31, CT-API-32 |

| Cupom enviado | `/carrinho/calcular` | `/pedidos` |
|---|---|---|
| `""` | `200`, `cupom: null` (sem cupom) | `201`, pedido confirmado |
| `"   "` | `200`, `cupom: { "codigo": "", "aplicado": false, "mensagem": "Cupom inválido." }` | **`422 CUPOM_INVALIDO`** |

**Esperado:** `"   "` com o mesmo resultado de `""`.
O front já faz isso: os dois casos mostram "Informe um cupom." (CT-UI-08). A inconsistência é só na API, onde um pedido com o campo de cupom "em branco" é recusado.

---

## BUG-06

**Carrinho mostra "Cupom aplicado." para cupom recusado pela API**

| | |
|---|---|
| Critério | CA04: cupom fora da validade exibe "Cupom expirado." e nenhum desconto é aplicado. |
| Severidade | Baixa. Prioridade média: a mensagem engana o cliente sobre o preço. |
| Cenário | CT-UI-25 |

**Como acontece:** o carrinho guarda o código do cupom na aba e, ao reabrir, mostra
"Cupom XXX aplicado." sem olhar o `cupom.aplicado` que a API devolve. Situação real: o cliente
aplica um cupom válido e ele expira antes da compra ser finalizada (a aba continua aberta).
Para reproduzir com os dados fixos do ambiente, simulei gravando `VERAO2026` no `sessionStorage`.

**Passos**

1. Na aba da loja, executar no console: `sessionStorage.setItem('verzel-store:cupom', '"VERAO2026"')` com um item no carrinho.
2. Abrir o carrinho.

**Esperado:** "Cupom expirado." e o campo de cupom disponível.
**Obtido:** "Cupom **VERAO2026 aplicado.**" com desconto R$ 0,00. Só no checkout, ao confirmar, aparece "Cupom expirado." (422 da API).

**Evidência:** [carrinho](evidencias/EXP-storage-cupom-expirado-aplicado.png), [checkout](evidencias/EXP-storage-cupom-expirado-checkout.png)

---

## BUG-07

**Dados inesperados no carrinho da aba deixam a loja inteira em branco**

| | |
|---|---|
| Severidade | Baixa: exige dado fora do padrão no `sessionStorage` (alterado à mão ou salvo por uma versão anterior da loja). |
| Onde | Interface: vitrine e carrinho (as páginas verificadas) |
| Cenário | CT-UI-26 |

**Passos**

1. Na aba da loja: `sessionStorage.setItem('verzel-store:itens', '{"produtoId":"P005","quantidade":1}')` (objeto em vez de lista).
2. Abrir qualquer página.

**Esperado:** a loja descarta o dado inválido e trata o carrinho como vazio, como já faz com JSON malformado (CT-UI-23).
**Obtido:** tela totalmente em branco no carrinho **e também na vitrine**, enquanto o dado estiver na aba. Erro de JavaScript na página: `C.reduce is not a function`. Não há como o cliente se recuperar pela interface.
O mesmo acontece com `verzel-store:cupom` salvo como objeto (React error #31).

**Evidência:** [EXP-storage-itens-objeto-tela-branca.png](evidencias/EXP-storage-itens-objeto-tela-branca.png)

---

## Observações e sugestões de melhoria

| ID | Observação | Tipo |
|---|---|---|
| OBS-01 | A vitrine anuncia "na **primeira compra**, o cupom BEMVINDO10 dá 10%", mas o cupom é aceito em qualquer pedido. Como não existe login nem histórico de pedidos (fora do escopo, conforme "Sobre este ambiente"), registrei isso como ambiguidade, não como bug. | Ambiguidade |
| OBS-02 | Em telas de 375px, os links "Produtos" e "Documentação" do menu somem e não há menu alternativo. A navegação ainda é possível pelo logo e pelo aviso do topo. | Usabilidade |
| OBS-03 | A mensagem "Informe um cupom." (cupom vazio) não está na documentação. O comportamento é adequado; sugiro documentar. | Documentação |
| OBS-04 | O nome aceita qualquer conteúdo com duas palavras: `Maria @#$`, `Maria Silva 2`, emoji, quebra de linha e 300+ caracteres. A documentação só exige "nome e sobrenome", então não é bug, mas sugiro limitar tamanho e caracteres. Já `M S` é recusado, regra que não está documentada. | Validação |
| OBS-05 | A API não valida o **tipo** do cupom: converte para texto. `["BEMVINDO10"]` vira `"BEMVINDO10"` e `{...}` vira `"[object Object]"`, que volta em `cupom.codigo`. Nenhum desconto é aplicado, mas o ideal seria um erro de tipo. | API |
| OBS-06 | Campo do cliente enviado com tipo errado (ex.: `"cep": 22041001` como número) responde "Informe o CEP.", como se o campo estivesse ausente. A mensagem confunde. | API |
| OBS-07 | A API aceita requisições sem `Content-Type: application/json` (ou com `text/plain`). A documentação pede o cabeçalho, mas a API é tolerante. Não causa erro. | API |
