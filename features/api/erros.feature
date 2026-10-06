# language: pt
@api
Funcionalidade: API - Códigos de erro
  Todo erro segue o formato { "erro": { "codigo", "mensagem", "campo" } }

  Esquema do Cenário: CT-API-24 Itens inválidos no cálculo do carrinho: <caso>
    Quando faço POST em "/api/carrinho/calcular" com o corpo:
      """
      <corpo>
      """
    Então o status da resposta deve ser 422
    E o erro deve ter código "<codigo>" no campo "<campo>"

    Exemplos:
      | caso                   | corpo                                                                               | codigo                 | campo               |
      | sem itens              | {}                                                                                  | ITENS_OBRIGATORIOS     | itens               |
      | lista vazia            | { "itens": [] }                                                                     | ITENS_OBRIGATORIOS     | itens               |
      | item não é objeto      | { "itens": ["P001"] }                                                               | ITEM_INVALIDO          | itens[0]            |
      | produto inexistente    | { "itens": [{ "produtoId": "P999", "quantidade": 1 }] }                             | PRODUTO_NAO_ENCONTRADO | itens[0].produtoId  |
      | produto duplicado      | { "itens": [{ "produtoId": "P001", "quantidade": 1 }, { "produtoId": "P001", "quantidade": 1 }] } | ITEM_DUPLICADO | itens[1].produtoId |
      | quantidade zero        | { "itens": [{ "produtoId": "P001", "quantidade": 0 }] }                             | QUANTIDADE_INVALIDA    | itens[0].quantidade |
      | quantidade negativa    | { "itens": [{ "produtoId": "P001", "quantidade": -1 }] }                            | QUANTIDADE_INVALIDA    | itens[0].quantidade |
      | quantidade decimal     | { "itens": [{ "produtoId": "P001", "quantidade": 1.5 }] }                           | QUANTIDADE_INVALIDA    | itens[0].quantidade |
      | quantidade como texto  | { "itens": [{ "produtoId": "P001", "quantidade": "2" }] }                           | QUANTIDADE_INVALIDA    | itens[0].quantidade |

  Esquema do Cenário: CT-API-25 Corpo que não é objeto JSON: <caso>
    Quando faço POST em "/api/carrinho/calcular" com o corpo:
      """
      <corpo>
      """
    Então o status da resposta deve ser 400
    E o erro deve ter código "JSON_INVALIDO"

    Exemplos:
      | caso            | corpo     |
      | JSON malformado | {invalido |
      | array           | []        |

  Esquema do Cenário: CT-API-26 Rotas e métodos: <metodo> <rota>
    Quando faço <metodo> em "<rota>"
    Então o status da resposta deve ser <status>
    E o erro deve ter código "<codigo>"

    Exemplos:
      | metodo | rota                   | status | codigo               |
      | GET    | /api/inexistente       | 404    | ROTA_NAO_ENCONTRADA  |
      | GET    | /api/carrinho/calcular | 405    | METODO_NAO_PERMITIDO |
      | GET    | /api/pedidos           | 405    | METODO_NAO_PERMITIDO |
      | DELETE | /api/produtos          | 405    | METODO_NAO_PERMITIDO |
      | POST   | /api/produtos          | 405    | METODO_NAO_PERMITIDO |
