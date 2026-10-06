# language: pt
@api
Funcionalidade: API - Cálculo do carrinho (POST /api/carrinho/calcular)
  Regra: total = subtotal - desconto + frete
  Cupom inválido ou expirado não gera erro aqui: 200, sem desconto, motivo em cupom.mensagem.

  # ---------- Frete (CA06, CA07) ----------

  @CA06 @CA07
  Esquema do Cenário: CT-API-01 Limites do frete grátis: subtotal <subtotal>
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | <produto> | <qtd>      |
    Quando calculo o carrinho
    Então o status da resposta deve ser 200
    E os valores devem ser:
      | subtotal                 | <subtotal> |
      | frete                    | <frete>    |
      | freteGratis              | <gratis>   |
      | valorFaltanteFreteGratis | <faltante> |
      | total                    | <total>    |

    Exemplos: abaixo do limite
      | produto | qtd | subtotal | frete | gratis | faltante | total |
      | P003    | 1   | 189.9    | 19.9  | false  | 10.1     | 209.8 |
      | P006    | 1   | 29.9     | 19.9  | false  | 170.1    | 49.8  |

    @bug @BUG-01
    Exemplos: exatamente no limite
      | produto | qtd | subtotal | frete | gratis | faltante | total |
      | P005    | 2   | 200      | 0     | true   | 0        | 200   |
      | P008    | 4   | 200      | 0     | true   | 0        | 200   |

    Exemplos: acima do limite
      | produto | qtd | subtotal | frete | gratis | faltante | total |
      | P007    | 1   | 229.9    | 0     | true   | 0        | 229.9 |

  @CA07
  Cenário: CT-API-02 Subtotal R$ 199,80, R$ 0,20 abaixo do limite
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P002      | 1          |
      | P001      | 1          |
    Quando calculo o carrinho
    Então os valores devem ser:
      | subtotal                 | 199.8 |
      | frete                    | 19.9  |
      | freteGratis              | false |
      | valorFaltanteFreteGratis | 0.2   |
      | total                    | 219.7 |

  # ---------- Cupom (CA01 a CA04, CA08, CA09) ----------

  @CA01 @CA09
  Cenário: CT-API-03 Exemplo da documentação: BEMVINDO10 com frete grátis
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P002      | 1          |
      | P004      | 2          |
    E o cupom "BEMVINDO10"
    Quando calculo o carrinho
    Então o status da resposta deve ser 200
    E os valores devem ser:
      | subtotal       | 239.7        |
      | desconto       | 23.97        |
      | frete          | 0            |
      | total          | 215.73       |
      | cupom.codigo   | "BEMVINDO10" |
      | cupom.aplicado | true         |
      | cupom.mensagem | "Cupom aplicado: 10% de desconto nos produtos." |

  @CA09
  Cenário: CT-API-04 Desconto não incide sobre o frete
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    E o cupom "BEMVINDO10"
    Quando calculo o carrinho
    Então os valores devem ser:
      | subtotal | 100   |
      | desconto | 10    |
      | frete    | 19.9  |
      | total    | 109.9 |

  @CA02
  Esquema do Cenário: CT-API-05 Código do cupom ignora caixa e espaços nas pontas: "<cupom>" + <espacos> espaço(s)
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    E o cupom "<cupom>" com <espacos> espaços nas pontas
    Quando calculo o carrinho
    Então o campo "cupom.aplicado" deve ser true
    E o campo "cupom.codigo" deve ser "BEMVINDO10"
    E o campo "desconto" deve ser 10

    Exemplos:
      | cupom      | espacos |
      | bemvindo10 | 0       |
      | BemVindo10 | 0       |
      | BEMVINDO10 | 2       |
      | bemvindo10 | 3       |

  @CA03 @CA04
  Esquema do Cenário: CT-API-06 Cupom <situacao> responde 200 sem desconto
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    E o cupom "<cupom>"
    Quando calculo o carrinho
    Então o status da resposta deve ser 200
    E os valores devem ser:
      | desconto       | 0            |
      | total          | 119.9        |
      | cupom.aplicado | false        |
      | cupom.mensagem | "<mensagem>" |

    Exemplos:
      | situacao    | cupom      | mensagem        |
      | inexistente | NAOEXISTE  | Cupom inválido. |
      | expirado    | VERAO2026  | Cupom expirado. |
      | expirado    | verao2026  | Cupom expirado. |

  Cenário: CT-API-07 Sem cupom, o campo cupom vem nulo
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P005      | 1          |
    Quando calculo o carrinho
    Então o campo "cupom" deve ser null
    E o campo "desconto" deve ser 0

  @CA08
  Cenário: CT-API-08 Frete grátis usa o subtotal antes do desconto
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P003      | 1          |
      | P006      | 1          |
    E o cupom "BEMVINDO10"
    Quando calculo o carrinho
    Então os valores devem ser:
      | subtotal    | 219.8  |
      | desconto    | 21.98  |
      | frete       | 0      |
      | freteGratis | true   |
      | total       | 197.82 |

  # ---------- Arredondamento (CA11) ----------

  @CA11
  Esquema do Cenário: CT-API-09 Valores arredondados para 2 casas: <descricao>
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | <p1>      | <q1>       |
      | <p2>      | <q2>       |
    E o cupom "BEMVINDO10"
    Quando calculo o carrinho
    Então todos os valores monetários devem ter no máximo 2 casas decimais
    E os valores devem ser:
      | subtotal | <subtotal> |
      | desconto | <desconto> |
      | total    | <total>    |

    Exemplos:
      | descricao          | p1   | q1 | p2   | q2 | subtotal | desconto | total  |
      | 3 camisetas + meia | P001 | 3  | P006 | 1  | 209.6    | 20.96    | 188.64 |
      | 3 meias + boné     | P006 | 3  | P004 | 1  | 139.6    | 13.96    | 145.54 |
      | 5 bonés + 5 meias  | P004 | 5  | P006 | 5  | 399      | 39.9     | 359.1  |
      | 3 camisetas + calça| P001 | 3  | P002 | 1  | 319.6    | 31.96    | 287.64 |

  # ---------- Quantidade (CA10) ----------

  @CA10
  Cenário: CT-API-10 Exatamente 5 unidades é aceito
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P001      | 5          |
    Quando calculo o carrinho
    Então o status da resposta deve ser 200
    E o campo "itens[0].quantidade" deve ser 5

  @CA10 @bug @BUG-02
  Cenário: CT-API-11 Quantidade acima de 5 unidades é rejeitada
    Dado um carrinho com os itens:
      | produtoId | quantidade |
      | P001      | 6          |
    Quando calculo o carrinho
    Então o status da resposta deve ser 422
    E o erro deve ter código "QUANTIDADE_MAXIMA_EXCEDIDA" no campo "itens[0].quantidade"
