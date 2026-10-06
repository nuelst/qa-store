# language: pt
@api @entradas
Funcionalidade: API - Valores mal formatados e tipos inesperados
  Partição de equivalência: um representante de cada tipo de entrada inválida,
  mais os casos válidos pouco comuns que não podem ser rejeitados.

  # ---------- Itens ----------

  Esquema do Cenário: CT-API-27 Tipo inesperado em itens: <caso>
    Quando faço POST em "/api/carrinho/calcular" com o corpo:
      """
      <corpo>
      """
    Então o status da resposta deve ser 422
    E o erro deve ter código "<codigo>" no campo "<campo>"

    Exemplos: produtoId
      | caso                    | corpo                                                       | codigo                 | campo              |
      | produtoId numérico      | { "itens": [{ "produtoId": 5, "quantidade": 1 }] }          | PRODUTO_NAO_ENCONTRADO | itens[0].produtoId |
      | produtoId nulo          | { "itens": [{ "produtoId": null, "quantidade": 1 }] }       | PRODUTO_NAO_ENCONTRADO | itens[0].produtoId |
      | produtoId em minúsculas | { "itens": [{ "produtoId": "p005", "quantidade": 1 }] }     | PRODUTO_NAO_ENCONTRADO | itens[0].produtoId |
      | produtoId com espaços   | { "itens": [{ "produtoId": " P005 ", "quantidade": 1 }] }   | PRODUTO_NAO_ENCONTRADO | itens[0].produtoId |

    Exemplos: quantidade
      | caso                    | corpo                                                       | codigo              | campo               |
      | quantidade nula         | { "itens": [{ "produtoId": "P005", "quantidade": null }] }  | QUANTIDADE_INVALIDA | itens[0].quantidade |
      | quantidade booleana     | { "itens": [{ "produtoId": "P005", "quantidade": true }] }  | QUANTIDADE_INVALIDA | itens[0].quantidade |
      | quantidade texto vazio  | { "itens": [{ "produtoId": "P005", "quantidade": "" }] }    | QUANTIDADE_INVALIDA | itens[0].quantidade |
      | quantidade "5" (texto)  | { "itens": [{ "produtoId": "P005", "quantidade": "5" }] }   | QUANTIDADE_INVALIDA | itens[0].quantidade |

    Exemplos: lista de itens
      | caso              | corpo                                            | codigo             | campo |
      | itens como texto  | { "itens": "P005" }                              | ITENS_OBRIGATORIOS | itens |
      | itens como objeto | { "itens": { "produtoId": "P005", "quantidade": 1 } } | ITENS_OBRIGATORIOS | itens |
      | itens nulo        | { "itens": null }                                | ITENS_OBRIGATORIOS | itens |

  @bug @BUG-04
  Esquema do Cenário: CT-API-28 Item sem <ausente> é um item inválido
    Quando faço POST em "/api/carrinho/calcular" com o corpo:
      """
      <corpo>
      """
    Então o status da resposta deve ser 422
    E o erro deve ter código "ITEM_INVALIDO" no campo "itens[0]"

    Exemplos:
      | ausente    | corpo                                   |
      | produtoId  | { "itens": [{ "quantidade": 1 }] }      |
      | quantidade | { "itens": [{ "produtoId": "P005" }] }  |

  @CA10 @bug @BUG-02
  Cenário: CT-API-29 Quantidade absurda (999.999.999) é rejeitada
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 999999999  |
    Quando calculo o carrinho
    Então o status da resposta deve ser 422
    E o erro deve ter código "QUANTIDADE_MAXIMA_EXCEDIDA" no campo "itens[0].quantidade"

  # ---------- Corpo da requisição ----------

  Esquema do Cenário: CT-API-30 Corpo que não é objeto JSON: <caso>
    Quando faço POST em "/api/carrinho/calcular" com o corpo:
      """
      <corpo>
      """
    Então o status da resposta deve ser 400
    E o erro deve ter código "JSON_INVALIDO"

    Exemplos:
      | caso   | corpo |
      | null   | null  |
      | texto  | "x"   |
      | número | 42    |

  # ---------- Cupom ----------

  Esquema do Cenário: CT-API-31 Cupom <caso> é tratado como "sem cupom"
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    E o cupom "" com <espacos> espaços nas pontas
    Quando calculo o carrinho
    Então o status da resposta deve ser 200
    E o campo "cupom" deve ser null
    E o campo "desconto" deve ser 0

    Exemplos:
      | caso  | espacos |
      | vazio | 0       |

    @bug @BUG-05
    Exemplos: só com espaços (CA02: espaços nas pontas são ignorados)
      | caso             | espacos |
      | só com espaços   | 2       |

  @bug @BUG-05
  Cenário: CT-API-32 Pedido com cupom só com espaços é aceito como "sem cupom"
    Dado um cliente válido
    E um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    E o cupom "" com 2 espaços nas pontas
    Quando envio o pedido
    Então o status da resposta deve ser 201
    E o campo "cupom" deve ser null

  Esquema do Cenário: CT-API-33 Cupom com tipo inesperado não aplica desconto: <caso>
    Quando faço POST em "/api/carrinho/calcular" com o corpo:
      """
      { "itens": [{ "produtoId": "P005", "quantidade": 1 }], "cupom": <cupom> }
      """
    Então o status da resposta deve ser 200
    E o campo "desconto" deve ser 0
    E o campo "total" deve ser 119.9

    Exemplos:
      | caso   | cupom                        |
      | número | 10                           |
      | nulo   | null                         |
      | lista  | ["BEMVINDO10"]               |
      | objeto | { "codigo": "BEMVINDO10" }   |

  # ---------- Cliente ----------

  Esquema do Cenário: CT-API-34 Nome válido pouco comum é aceito: <nome>
    Dado um cliente válido
    E o cliente com "nome" igual a "<nome>"
    E um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    Quando envio o pedido
    Então o status da resposta deve ser 201
    E o campo "cliente.nome" deve ser "<nome>"

    Exemplos:
      | nome             |
      | José Álvares     |
      | Ana-Maria Souza  |
      | João D'Ávila     |
      | María José Núñez |
      | Maria da Silva   |

  Esquema do Cenário: CT-API-35 E-mail válido pouco comum é aceito: <email>
    Dado um cliente válido
    E o cliente com "email" igual a "<email>"
    E um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    Quando envio o pedido
    Então o status da resposta deve ser 201

    Exemplos:
      | email                     |
      | maria+loja@exemplo.com    |
      | maria.silva@exemplo.com   |
      | maria@mail.exemplo.com.br |
      | Maria@Exemplo.COM         |
      | maria_silva@exemplo.com   |

  @bug @BUG-03
  Esquema do Cenário: CT-API-36 E-mail com formato inválido é rejeitado: <email>
    Dado um cliente válido
    E o cliente com "email" igual a "<email>"
    E um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    Quando envio o pedido
    Então o status da resposta deve ser 422
    E o erro deve apontar o campo "cliente.email" com a mensagem "Informe um e-mail válido."

    Exemplos:
      | email                    | problema                   |
      | maria@exemplo..com       | pontos seguidos no domínio |
      | maria..silva@exemplo.com | pontos seguidos no usuário |
      | .maria@exemplo.com       | usuário começa com ponto   |
      | maria@exemplo.com.       | domínio termina com ponto  |
      | maria@exemplo_com.br     | "_" no nome do domínio     |

  Esquema do Cenário: CT-API-37 Cliente com tipo inesperado: <caso>
    Quando faço POST em "/api/pedidos" com o corpo:
      """
      { "cliente": <cliente>, "itens": [{ "produtoId": "P005", "quantidade": 1 }] }
      """
    Então o status da resposta deve ser 422
    E o erro deve ter código "DADOS_INVALIDOS"
    E o erro deve apontar o campo "<campo>"

    Exemplos:
      | caso               | cliente                                                                  | campo         |
      | cliente como texto | "Maria Silva"                                                            | cliente.nome  |
      | cliente como lista | [{ "nome": "Maria Silva" }]                                              | cliente.nome  |
      | CEP numérico       | { "nome": "Maria Silva", "email": "maria@exemplo.com", "cep": 22041001 } | cliente.cep   |
      | nome numérico      | { "nome": 123, "email": "maria@exemplo.com", "cep": "01310-100" }        | cliente.nome  |
      | e-mail numérico    | { "nome": "Maria Silva", "email": 123, "cep": "01310-100" }              | cliente.email |
