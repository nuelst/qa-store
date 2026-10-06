# language: pt
@ui @entradas
Funcionalidade: Carrinho com dados alterados ou corrompidos na aba
  O carrinho fica no sessionStorage da aba (chaves "verzel-store:itens" e "verzel-store:cupom").
  Estes cenários gravam valores fora do padrão nele, simulando dados alterados no navegador
  ou salvos por uma versão antiga da loja, e verificam se a loja se protege.
  Não é teste de segurança: só valida que as regras de negócio continuam valendo.

  Esquema do Cenário: CT-UI-22 Item inválido salvo na aba bloqueia a finalização: <caso>
    Dado que o carrinho salvo na aba é:
      """
      <itens>
      """
    Quando abro o carrinho pela URL
    Então devo ver a mensagem "<mensagem>"
    E não devo conseguir finalizar a compra

    Exemplos:
      | caso                | itens                                                                      | mensagem                                                    |
      | quantidade zero     | [{ "produtoId": "P005", "quantidade": 0 }]                                 | A quantidade deve ser um número inteiro maior ou igual a 1. |
      | quantidade negativa | [{ "produtoId": "P005", "quantidade": -2 }]                                | A quantidade deve ser um número inteiro maior ou igual a 1. |
      | quantidade decimal  | [{ "produtoId": "P005", "quantidade": 1.5 }]                               | A quantidade deve ser um número inteiro maior ou igual a 1. |
      | quantidade texto    | [{ "produtoId": "P005", "quantidade": "abc" }]                             | A quantidade deve ser um número inteiro maior ou igual a 1. |
      | produto inexistente | [{ "produtoId": "P999", "quantidade": 1 }]                                 | Produto P999 não encontrado.                                |
      | produto duplicado   | [{ "produtoId": "P005", "quantidade": 1 }, { "produtoId": "P005", "quantidade": 2 }] | O produto P005 aparece mais de uma vez.           |

  Cenário: CT-UI-23 JSON quebrado na aba é tratado como carrinho vazio
    Dado que o carrinho salvo na aba é:
      """
      [{ "produtoId":
      """
    Quando abro o carrinho pela URL
    Então devo ver a mensagem "Seu carrinho está vazio"

  @CA10 @bug @BUG-02
  Cenário: CT-UI-24 Carrinho com 6 unidades salvo na aba não vira pedido
    Dado que o carrinho salvo na aba é:
      """
      [{ "produtoId": "P005", "quantidade": 6 }]
      """
    Quando abro o carrinho pela URL
    E sigo para o checkout
    E preencho os dados de entrega:
      | Nome   | Maria Silva       |
      | E-mail | maria@exemplo.com |
      | CEP    | 01310-100         |
    E confirmo o pedido
    Então devo permanecer no checkout

  @bug @BUG-06
  Cenário: CT-UI-25 Cupom expirado salvo na aba não aparece como aplicado
    Dado que o carrinho salvo na aba é:
      """
      [{ "produtoId": "P005", "quantidade": 1 }]
      """
    E o cupom salvo na aba é "VERAO2026"
    Quando abro o carrinho pela URL
    Então o desconto deve ser "R$ 0,00"
    E não devo ver o cupom "VERAO2026" aplicado
    E devo ver a mensagem "Cupom expirado."

  @bug @BUG-07
  Cenário: CT-UI-26 Itens salvos em formato inesperado não derrubam a loja
    Dado que o carrinho salvo na aba é:
      """
      { "produtoId": "P005", "quantidade": 1 }
      """
    Quando abro o carrinho pela URL
    Então a página do carrinho deve ser exibida
