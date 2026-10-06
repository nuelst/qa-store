# language: pt
@ui
Funcionalidade: Checkout e confirmação do pedido
  Regras que já existiam antes da entrega VZS-142:
  - nome precisa ter nome e sobrenome
  - e-mail precisa ter formato válido
  - CEP precisa ter 8 dígitos, com ou sem hífen
  - pagamento é feito na entrega

  Contexto:
    Dado que estou na vitrine da Verzel Store
    E adiciono "Tênis Casual Urbano" ao carrinho
    E adiciono "Kit 3 Pares de Meias" ao carrinho
    E abro o carrinho

  Cenário: CT-UI-16 Pedido confirmado com cupom mantém os valores do carrinho
    Quando aplico o cupom "BEMVINDO10"
    E sigo para o checkout
    Então o desconto deve ser "- R$ 21,98"
    E o total deve ser "R$ 197,82"
    Quando preencho os dados de entrega:
      | Nome   | Maria Silva       |
      | E-mail | maria@exemplo.com |
      | CEP    | 01310-100         |
    E confirmo o pedido
    Então devo ver o pedido confirmado com número no formato VZ-000000
    E o subtotal deve ser "R$ 219,80"
    E o desconto deve ser "- R$ 21,98"
    E o frete deve ser "Grátis"
    E o total deve ser "R$ 197,82"
    E o contador do carrinho deve ser 0

  Esquema do Cenário: CT-UI-17 CEP aceito com e sem hífen: <cep>
    Quando sigo para o checkout
    E preencho os dados de entrega:
      | Nome   | Maria Silva       |
      | E-mail | maria@exemplo.com |
      | CEP    | <cep>             |
    E confirmo o pedido
    Então devo ver o pedido confirmado com número no formato VZ-000000

    Exemplos:
      | cep       |
      | 01310-100 |
      | 01310100  |

  Cenário: CT-UI-18 Confirmar com o formulário vazio mostra todos os erros
    Quando sigo para o checkout
    E confirmo o pedido
    Então devo permanecer no checkout
    E o campo "Nome" deve exibir o erro "Informe o nome completo."
    E o campo "E-mail" deve exibir o erro "Informe o e-mail."
    E o campo "CEP" deve exibir o erro "Informe o CEP."

  Esquema do Cenário: CT-UI-19 Dado inválido no campo <campo>: "<valor>"
    Quando sigo para o checkout
    E preencho os dados de entrega:
      | Nome   | Maria Silva       |
      | E-mail | maria@exemplo.com |
      | CEP    | 01310-100         |
    E preencho o campo "<campo>" com "<valor>"
    E confirmo o pedido
    Então devo permanecer no checkout
    E o campo "<campo>" deve exibir o erro "<mensagem>"

    Exemplos:
      | campo  | valor             | mensagem                      |
      | Nome   | Maria             | Informe nome e sobrenome.     |
      | E-mail | maria@            | Informe um e-mail válido.     |
      | E-mail | maria@exemplo     | Informe um e-mail válido.     |
      | E-mail | maria exemplo.com | Informe um e-mail válido.     |
      | E-mail | maria@@exemplo.com| Informe um e-mail válido.     |
      | E-mail | @exemplo.com      | Informe um e-mail válido.     |
      | CEP    | 0131010           | Informe um CEP com 8 dígitos. |
      | CEP    | 013101000         | Informe um CEP com 8 dígitos. |
      | CEP    | 01310-10a         | Informe um CEP com 8 dígitos. |
      | CEP    | 01310.100         | Informe um CEP com 8 dígitos. |
      | CEP    | 01310 100         | Informe um CEP com 8 dígitos. |
      | CEP    | 013-10100         | Informe um CEP com 8 dígitos. |
      | CEP    | 01.310-100        | Informe um CEP com 8 dígitos. |

  @entradas
  Esquema do Cenário: CT-UI-20 Dado válido pouco comum no campo <campo> é aceito: "<valor>"
    Quando sigo para o checkout
    E preencho os dados de entrega:
      | Nome   | Maria Silva       |
      | E-mail | maria@exemplo.com |
      | CEP    | 01310-100         |
    E preencho o campo "<campo>" com "<valor>"
    E confirmo o pedido
    Então devo ver o pedido confirmado com número no formato VZ-000000

    Exemplos:
      | campo  | valor                     |
      | Nome   | José Álvares              |
      | Nome   | Ana-Maria Souza           |
      | Nome   | João D'Ávila              |
      | E-mail | maria+loja@exemplo.com    |
      | E-mail | maria@mail.exemplo.com.br |

  @entradas @bug @BUG-03
  Esquema do Cenário: CT-UI-21 E-mail com formato inválido é bloqueado no checkout: <valor>
    Quando sigo para o checkout
    E preencho os dados de entrega:
      | Nome   | Maria Silva       |
      | E-mail | maria@exemplo.com |
      | CEP    | 01310-100         |
    E preencho o campo "E-mail" com "<valor>"
    E confirmo o pedido
    Então devo permanecer no checkout
    E o campo "E-mail" deve exibir o erro "Informe um e-mail válido."

    Exemplos:
      | valor                    |
      | maria@exemplo..com       |
      | .maria@exemplo.com       |
      | maria@exemplo.com.       |
