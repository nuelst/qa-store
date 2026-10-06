# Execução dos testes – VZS-142 (v2.3.0)

| | |
|---|---|
| Ambiente | https://verzel-store.qa-test-verzel-store.workers.dev |
| Data | 06/10/2026 |
| Navegador | Chromium (Playwright 1.63), desktop 1280×720 e mobile 375×812 |
| Cenários (Gherkin) | [features/](../features/) |

Legenda: ✅ passou · ❌ falhou · Tipo: **A** = automatizado, **M** = manual/exploratório

## Resumo

| | Cenários | ✅ | ❌ |
|---|---|---|---|
| Automatizados (execuções, contando cada linha de Exemplos) | 171 | 149 | 22 |
| Manuais / exploratórios | 10 | 9 | 1 |

Todas as 22 falhas automatizadas são cenários marcados com `@bug` e correspondem a **7 bugs**
([docs/bugs.md](bugs.md)). Sem eles (`npm run test:sem-bugs`), a suíte passa por completo.

| Bug | Execuções que falham |
|---|---|
| BUG-01 – frete com subtotal de R$ 200,00 | 4 |
| BUG-02 – limite de 5 unidades não garantido pela API | 4 |
| BUG-03 – e-mail com formato inválido aceito | 8 |
| BUG-04 – código de erro errado para item incompleto | 2 |
| BUG-05 – cupom só com espaços | 2 |
| BUG-06 – cupom recusado exibido como aplicado | 1 |
| BUG-07 – loja em branco com dado inesperado na aba | 1 |

## Cobertura dos critérios de aceite

| CA | Regra | Cenários | Resultado |
|---|---|---|---|
| CA01 | BEMVINDO10 = 10% sobre o subtotal | CT-UI-05, CT-UI-11, CT-API-03 | ✅ |
| CA02 | Cupom ignora caixa e espaços nas pontas | CT-UI-06, CT-UI-08, CT-API-05, CT-API-15, CT-API-31, CT-API-32 | ❌ BUG-05 (só cupom com apenas espaços, na API) |
| CA03 | Cupom inexistente → "Cupom inválido." | CT-UI-07, CT-UI-27, CT-API-06, CT-API-14 | ✅ |
| CA04 | Cupom expirado → "Cupom expirado." | CT-UI-07, CT-UI-09, CT-UI-25, CT-API-06, CT-API-14 | ❌ BUG-06 (cupom salvo na aba) |
| CA05 | Um cupom por vez | CT-UI-09 | ✅ |
| CA06 | Frete grátis a partir de R$ 200,00, inclusive | CT-UI-02, CT-UI-03, CT-UI-04, CT-API-01, CT-API-16 | ❌ BUG-01 |
| CA07 | Frete R$ 19,90 e valor faltante abaixo de R$ 200,00 | CT-UI-01, CT-UI-04, CT-API-01, CT-API-02 | ✅ |
| CA08 | Frete grátis usa o subtotal antes do desconto | CT-UI-10, CT-UI-16, CT-API-08 | ✅ |
| CA09 | Desconto não incide sobre o frete | CT-UI-05, CT-API-03, CT-API-04 | ✅ |
| CA10 | Máximo 5 unidades (interface e API) | CT-UI-12, CT-UI-13, CT-UI-24, CT-API-10, CT-API-11, CT-API-17, CT-API-29 | ❌ BUG-02 (API sem limite; o front envia o que estiver salvo na aba) |
| CA11 | Arredondamento em 2 casas | CT-UI-11, CT-API-09 | ✅ |

## Cenários automatizados – interface

| ID | Cenário | CA | Resultado |
|---|---|---|---|
| CT-UI-01 | Frete fixo e valor faltante abaixo de R$ 200,00 | CA07 | ✅ |
| CT-UI-02 | Subtotal exatamente R$ 200,00 ganha frete grátis | CA06 | ❌ BUG-01 |
| CT-UI-03 | Subtotal acima de R$ 200,00 ganha frete grátis | CA06 | ✅ |
| CT-UI-04 | Alterar itens recalcula frete e valor faltante | CA06, CA07 | ✅ |
| CT-UI-05 | BEMVINDO10 aplica 10% só sobre os produtos | CA01, CA09 | ✅ |
| CT-UI-06 | Cupom com maiúsculas/minúsculas e espaços (4 variações) | CA02 | ✅ |
| CT-UI-07 | Cupom inexistente, expirado e com espaço no meio | CA03, CA04 | ✅ |
| CT-UI-08 | Cupom vazio ou só com espaços → "Informe um cupom." (2 variações) | CA02 | ✅ |
| CT-UI-09 | Um cupom por vez; remover e aplicar outro | CA05 | ✅ |
| CT-UI-10 | Frete grátis considera o subtotal antes do desconto | CA08 | ✅ |
| CT-UI-11 | Desconto acompanha a alteração de quantidade | CA01, CA11 | ✅ |
| CT-UI-12 | Vitrine bloqueia a 6ª unidade | CA10 | ✅ |
| CT-UI-13 | Carrinho bloqueia "+" em 5 unidades | CA10 | ✅ |
| CT-UI-14 | Carrinho e cupom se mantêm ao recarregar a aba | – | ✅ |
| CT-UI-15 | Remover o único item deixa o carrinho vazio | – | ✅ |
| CT-UI-16 | Pedido confirmado com cupom mantém os valores | CA08 | ✅ |
| CT-UI-17 | CEP aceito com e sem hífen (2 variações) | – | ✅ |
| CT-UI-18 | Formulário vazio mostra todos os erros | – | ✅ |
| CT-UI-19 | Nome, e-mail e CEP inválidos, incluindo CEP com ponto, espaço e hífen fora do lugar (13 variações) | – | ✅ |
| CT-UI-20 | Nomes com acento, hífen e apóstrofo; e-mails com `+` e subdomínio são aceitos (5 variações) | – | ✅ |
| CT-UI-21 | E-mails com formato inválido são bloqueados (3 variações) | – | ❌ BUG-03 |
| CT-UI-22 | Item inválido salvo na aba bloqueia a finalização: quantidade 0/-2/1.5/"abc", produto inexistente, duplicado (6 variações) | – | ✅ |
| CT-UI-23 | JSON quebrado salvo na aba vira carrinho vazio | – | ✅ |
| CT-UI-24 | Carrinho com 6 unidades salvo na aba não vira pedido | CA10 | ❌ BUG-02 |
| CT-UI-25 | Cupom expirado salvo na aba não aparece como aplicado | CA04 | ❌ BUG-06 |
| CT-UI-26 | Itens salvos em formato inesperado não derrubam a loja | – | ❌ BUG-07 |
| CT-UI-27 | Cupom com HTML, muito longo ou com acento é inválido (3 variações) | CA03 | ✅ |

## Cenários automatizados – API

| ID | Cenário | CA | Resultado |
|---|---|---|---|
| CT-API-01 | Limites do frete: 29,90 / 189,90 / **200,00 (×2)** / 229,90 | CA06, CA07 | ❌ BUG-01 (só os 2 exemplos de 200,00) |
| CT-API-02 | Subtotal R$ 199,80 → faltam R$ 0,20 | CA07 | ✅ |
| CT-API-03 | Exemplo da documentação (BEMVINDO10 + frete grátis) | CA01, CA09 | ✅ |
| CT-API-04 | Desconto não incide sobre o frete | CA09 | ✅ |
| CT-API-05 | Cupom ignora caixa e espaços (4 variações) | CA02 | ✅ |
| CT-API-06 | Cupom inválido/expirado → 200 sem desconto (3 variações) | CA03, CA04 | ✅ |
| CT-API-07 | Sem cupom, `cupom: null` | – | ✅ |
| CT-API-08 | Frete grátis usa subtotal antes do desconto | CA08 | ✅ |
| CT-API-09 | Arredondamento em 2 casas (4 combinações) | CA11 | ✅ |
| CT-API-10 | Exatamente 5 unidades é aceito | CA10 | ✅ |
| CT-API-11 | 6 unidades → 422 no cálculo | CA10 | ❌ BUG-02 |
| CT-API-12 | Pedido com cupom (exemplo da documentação) | – | ✅ |
| CT-API-13 | Pedido sem cupom | – | ✅ |
| CT-API-14 | Pedido com cupom inválido/expirado → 422 | CA03, CA04 | ✅ |
| CT-API-15 | Cupom em minúsculas com espaços no pedido | CA02 | ✅ |
| CT-API-16 | Pedido com subtotal R$ 200,00 tem frete grátis | CA06 | ❌ BUG-01 |
| CT-API-17 | Pedido com 6 unidades → 422 | CA10 | ❌ BUG-02 |
| CT-API-18 | CEP com e sem hífen é normalizado | – | ✅ |
| CT-API-19 | Nome, e-mail e CEP inválidos → `DADOS_INVALIDOS` (16 variações) | – | ✅ |
| CT-API-20 | Pedido sem cliente lista os 3 campos obrigatórios | – | ✅ |
| CT-API-21 | `GET /api/produtos` confere com a tabela da documentação | – | ✅ |
| CT-API-22 | `GET /api/produtos/P003` | – | ✅ |
| CT-API-23 | `GET /api/produtos/P999` → 404 | – | ✅ |
| CT-API-24 | Itens inválidos: ausente, vazio, não-objeto, inexistente, duplicado, quantidade 0/-1/1.5/"2" | – | ✅ |
| CT-API-25 | JSON malformado e array → 400 `JSON_INVALIDO` | – | ✅ |
| CT-API-26 | Rota inexistente → 404; método não permitido → 405 (5 variações) | – | ✅ |

### Valores mal formatados e tipos inesperados

Arquivo: [features/api/entradas-invalidas.feature](../features/api/entradas-invalidas.feature) (tag `@entradas`).
Um representante de cada classe de entrada (partição de equivalência), não todas as combinações.

| ID | Cenário | CA | Resultado |
|---|---|---|---|
| CT-API-27 | Tipo inesperado em `produtoId` (número, nulo, minúsculo, com espaços), `quantidade` (nula, booleana, `""`, `"5"`) e `itens` (texto, objeto, nulo) (11 variações) | – | ✅ |
| CT-API-28 | Item sem `produtoId` / sem `quantidade` → `ITEM_INVALIDO` (2 variações) | – | ❌ BUG-04 |
| CT-API-29 | Quantidade 999.999.999 → 422 | CA10 | ❌ BUG-02 |
| CT-API-30 | Corpo `null`, texto ou número → 400 `JSON_INVALIDO` (3 variações) | – | ✅ |
| CT-API-31 | Cupom vazio ✅ / só com espaços ❌ tratado como "sem cupom" (2 variações) | CA02 | ❌ BUG-05 (só espaços) |
| CT-API-32 | Pedido com cupom só com espaços é aceito | CA02 | ❌ BUG-05 |
| CT-API-33 | Cupom como número, nulo, lista ou objeto não aplica desconto (4 variações) | – | ✅ (ver OBS-05) |
| CT-API-34 | Nomes válidos pouco comuns são aceitos (5 variações) | – | ✅ |
| CT-API-35 | E-mails válidos pouco comuns são aceitos (5 variações) | – | ✅ |
| CT-API-36 | E-mails com formato inválido são rejeitados (5 variações) | – | ❌ BUG-03 |
| CT-API-37 | Cliente com tipo inesperado (texto, lista, CEP/nome/e-mail numérico) (5 variações) | – | ✅ (ver OBS-06) |

## Cenários manuais e exploratórios

Os cenários estão em [features/manual/exploratorio.feature](../features/manual/exploratorio.feature) (tag `@manual`).

| ID | Cenário | Resultado | O que foi observado | Evidência |
|---|---|---|---|---|
| CT-MAN-01 | Layout em 375px | ✅ | Vitrine, carrinho e checkout sem rolagem horizontal (`scrollWidth = 375`). Os links do menu somem no mobile (ver OBS-02). | [vitrine](evidencias/MAN-01-vitrine-375.png), [carrinho](evidencias/MAN-01-carrinho-375.png), [checkout](evidencias/MAN-01-checkout-375.png) |
| CT-MAN-02 | Compra completa só pelo teclado | ✅ | A ordem de foco é lógica e todo controle tem contorno visível. Enter aplica o cupom e confirma o pedido. | – |
| CT-MAN-03 | Mensagens acessíveis | ✅ | A mensagem do cupom usa `role="alert"` e está ligada ao campo via `aria-describedby`, com `aria-invalid="true"`. Os erros do checkout seguem o mesmo padrão. | [cupom inválido](evidencias/MAN-03-cupom-invalido.png) |
| CT-MAN-04 | 10 cliques simultâneos em "+" e duplo clique em "Aplicar cupom" | ✅ | A quantidade para em 5 (R$ 299,50). O botão de cupom fica desabilitado durante a requisição. | [cliques](evidencias/MAN-04-cliques-rapidos.png) |
| CT-MAN-05 | `/checkout` e `/pedido-confirmado` com carrinho vazio | ✅ | `/checkout` redireciona para o carrinho vazio. A confirmação mostra "Nenhum pedido recente". | [checkout](evidencias/MAN-05-checkout-vazio.png), [confirmação](evidencias/MAN-05-confirmacao-direta.png) |
| CT-MAN-06 | Duplo clique em "Confirmar pedido" | ✅ | Apenas 1 `POST /api/pedidos` é enviado. | [confirmação](evidencias/MAN-06-duplo-clique-confirmar.png) |
| CT-MAN-07 | Outra aba começa com carrinho vazio | ✅ | Aba 1 com 1 item, aba 2 com 0. Comportamento esperado, conforme "Sobre este ambiente". | – |
| CT-MAN-08 | Falha da API ao confirmar o pedido (resposta 500 simulada) | ✅ | O checkout mostra a mensagem de erro, continua na página e o botão volta a ficar disponível. | [falha](evidencias/EXP-falha-api-pedido.png) |
| CT-MAN-09 | Carrinho alterado no `sessionStorage` | ❌ | Valores inválidos são recusados pela API e o front exibe a mensagem. Já quantidade acima de 5, cupom expirado e itens em formato de objeto geram BUG-02, BUG-06 e BUG-07. Automatizado depois em CT-UI-22 a CT-UI-26. | [qtd 99](evidencias/EXP-storage-qtd-99.png), [qtd "abc"](evidencias/EXP-storage-qtd-abc-.png), [P999](evidencias/EXP-storage-produto-P999.png), [duplicado](evidencias/EXP-storage-duplicado.png), [tela branca](evidencias/EXP-storage-itens-objeto-tela-branca.png) |
| CT-MAN-10 | Nome com emoji, quebra de linha, símbolos e 300+ caracteres | ✅ | Todos aceitos. A documentação só exige nome e sobrenome (ver OBS-04). | – |

## Interpretações de ambiguidades

| # | Ponto da documentação | Interpretação adotada |
|---|---|---|
| 1 | CA10: "a regra vale para a interface e para a API", sem dizer qual endpoint | Vale para **os dois** endpoints que recebem itens (`/carrinho/calcular` e `/pedidos`), já que o código `QUANTIDADE_MAXIMA_EXCEDIDA` está na tabela geral de erros. |
| 2 | CA02: "espaços no início e no fim são ignorados" | Apenas as pontas. Espaço no meio (`BEMVINDO 10`) deve ser tratado como cupom inválido (CT-UI-07). |
| 3 | CA11: método de arredondamento não especificado | Com os preços atuais, 10% nunca gera a 3ª casa decimal. Testei combinações sujeitas a erro de ponto flutuante (ex.: 3 × 59,90 + 29,90) e verifiquei que nenhum valor tem mais de 2 casas. |
| 4 | Vitrine: "na **primeira compra**, o cupom BEMVINDO10…" | Sem login nem histórico de pedidos (fora do escopo), a restrição não é verificável. Registrado como OBS-01, não como bug. |
| 5 | CA05: "Apenas um cupom por vez" | Na interface, o campo some enquanto há cupom aplicado e volta ao remover. Na API, o contrato só aceita um `cupom` (string), então a regra é garantida pelo formato. |
| 6 | Exibição de valores | Desconto exibido como "- R$ 10,00" e frete grátis como "Grátis": considerados formatos válidos. |
| 7 | Número do pedido | É fictício (conforme "Sobre este ambiente"). Validei apenas o formato `VZ-000000`. |
| 8 | `ITEM_INVALIDO`: "Um item não é um objeto com produtoId e quantidade." | Um objeto **sem** `produtoId` ou **sem** `quantidade` também não é "um objeto com produtoId e quantidade", então deve receber `ITEM_INVALIDO` (BUG-04). Já `produtoId` presente com valor errado recebe `PRODUTO_NAO_ENCONTRADO`, e `quantidade` presente com valor errado recebe `QUANTIDADE_INVALIDA`. |
| 9 | "O e-mail precisa ter um formato válido." | Formato válido segundo as regras usuais de endereço (RFC 5321/5322): sem pontos seguidos, sem ponto no início do usuário ou no fim do domínio, sem `_` no domínio. Casos discutíveis (`maria@exemplo.c`, IP como domínio, acento no usuário) **não** foram reportados como bug. |
| 10 | Cupom só com espaços | Pelo CA02 os espaços das pontas são ignorados, então `"   "` deve se comportar como `""`, que a API trata como "sem cupom" (BUG-05). |
| 11 | Carrinho no `sessionStorage` | Alterar o storage não é teste de segurança (fora do escopo). Usei o storage para simular situações reais (cupom que expira com a aba aberta, dado salvo por versão anterior) e para verificar se a regra de 5 unidades é garantida pela API. |
