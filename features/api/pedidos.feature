# language: pt
@api
Funcionalidade: API - Confirmação de pedido (POST /api/pedidos)
  Responde 201 com número VZ-000000 e o mesmo resumo de valores do cálculo do carrinho.
  Aqui, cupom inválido ou expirado gera erro 422.

  Contexto:
    Dado um cliente válido
    E um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |

  Cenário: CT-API-12 Pedido com cupom válido (exemplo da documentação)
    Dado o cupom "BEMVINDO10"
    Quando envio o pedido
    Então o status da resposta deve ser 201
    E o campo "numero" deve corresponder a "^VZ-\d{6}$"
    E o campo "criadoEm" deve corresponder a "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$"
    E os valores devem ser:
      | cliente.nome             | "Maria Silva"       |
      | cliente.email            | "maria@exemplo.com" |
      | cliente.cep              | "01310100"          |
      | subtotal                 | 100                 |
      | desconto                 | 10                  |
      | frete                    | 19.9                |
      | freteGratis              | false               |
      | valorFaltanteFreteGratis | 100                 |
      | total                    | 109.9               |
      | cupom.aplicado           | true                |

  Cenário: CT-API-13 Pedido sem cupom
    Quando envio o pedido
    Então o status da resposta deve ser 201
    E os valores devem ser:
      | desconto | 0     |
      | total    | 119.9 |
      | cupom    | null  |

  @CA03 @CA04
  Esquema do Cenário: CT-API-14 Pedido com cupom <situacao> é rejeitado
    Dado o cupom "<cupom>"
    Quando envio o pedido
    Então o status da resposta deve ser 422
    E o erro deve ter código "<codigo>" no campo "cupom"
    E o campo "erro.mensagem" deve ser "<mensagem>"

    Exemplos:
      | situacao    | cupom     | codigo         | mensagem        |
      | inexistente | NAOEXISTE | CUPOM_INVALIDO | Cupom inválido. |
      | expirado    | VERAO2026 | CUPOM_EXPIRADO | Cupom expirado. |

  @CA02
  Cenário: CT-API-15 Cupom em minúsculas com espaços também vale no pedido
    Dado o cupom "bemvindo10" com 2 espaços nas pontas
    Quando envio o pedido
    Então o status da resposta deve ser 201
    E o campo "desconto" deve ser 10

  @CA06 @bug @BUG-01
  Cenário: CT-API-16 Pedido com subtotal exatamente R$ 200,00 tem frete grátis
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 2          |
    Quando envio o pedido
    Então o status da resposta deve ser 201
    E os valores devem ser:
      | frete       | 0    |
      | freteGratis | true |
      | total       | 200  |

  @CA10 @bug @BUG-02
  Cenário: CT-API-17 Pedido com mais de 5 unidades é rejeitado
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 6          |
    Quando envio o pedido
    Então o status da resposta deve ser 422
    E o erro deve ter código "QUANTIDADE_MAXIMA_EXCEDIDA" no campo "itens[0].quantidade"

  # ---------- Dados do cliente ----------

  Esquema do Cenário: CT-API-18 CEP válido com e sem hífen é normalizado: <cep>
    Dado o cliente com "cep" igual a "<cep>"
    Quando envio o pedido
    Então o status da resposta deve ser 201
    E o campo "cliente.cep" deve ser "01310100"

    Exemplos:
      | cep       |
      | 01310-100 |
      | 01310100  |

  Esquema do Cenário: CT-API-19 Cliente com <campo> inválido: "<valor>"
    Dado o cliente com "<campo>" igual a "<valor>"
    Quando envio o pedido
    Então o status da resposta deve ser 422
    E o erro deve ter código "DADOS_INVALIDOS"
    E o erro deve apontar o campo "cliente.<campo>" com a mensagem "<mensagem>"

    Exemplos:
      | campo | valor             | mensagem                      |
      | nome  | Maria             | Informe nome e sobrenome.     |
      | email | maria@            | Informe um e-mail válido.     |
      | email | maria@exemplo     | Informe um e-mail válido.     |
      | email | maria exemplo.com | Informe um e-mail válido.     |
      | email | maria@@exemplo.com| Informe um e-mail válido.     |
      | email | @exemplo.com      | Informe um e-mail válido.     |
      | email | maria@.com        | Informe um e-mail válido.     |
      | email | maria@ex ample.com| Informe um e-mail válido.     |
      | cep   | 0131010           | Informe um CEP com 8 dígitos. |
      | cep   | 013101000         | Informe um CEP com 8 dígitos. |
      | cep   | 01310-10a         | Informe um CEP com 8 dígitos. |
      | cep   | 01310.100         | Informe um CEP com 8 dígitos. |
      | cep   | 01310 100         | Informe um CEP com 8 dígitos. |
      | cep   | 013-10100         | Informe um CEP com 8 dígitos. |
      | cep   | 01310--100        | Informe um CEP com 8 dígitos. |
      | cep   | 01.310-100        | Informe um CEP com 8 dígitos. |

  Cenário: CT-API-20 Pedido sem cliente lista todos os campos obrigatórios
    Quando faço POST em "/api/pedidos" com o corpo:
      """
      { "itens": [ { "produtoId": "P005", "quantidade": 1 } ] }
      """
    Então o status da resposta deve ser 422
    E o erro deve ter código "DADOS_INVALIDOS"
    E o erro deve apontar o campo "cliente.nome" com a mensagem "Informe o nome completo."
    E o erro deve apontar o campo "cliente.email" com a mensagem "Informe o e-mail."
    E o erro deve apontar o campo "cliente.cep" com a mensagem "Informe o CEP."
