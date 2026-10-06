# language: pt
@ui
Funcionalidade: Cupom de desconto e frete grátis no carrinho (VZS-142)
  Como cliente da Verzel Store
  Quero aplicar um cupom de desconto e ganhar frete grátis em compras maiores
  Para pagar menos nas minhas compras

  Contexto:
    Dado que estou na vitrine da Verzel Store

  # ---------- Frete ----------

  @CA07
  Cenário: CT-UI-01 Frete fixo e valor faltante para subtotal abaixo de R$ 200,00
    Quando adiciono "Camiseta Essencial" ao carrinho
    E abro o carrinho
    Então o subtotal deve ser "R$ 59,90"
    E o frete deve ser "R$ 19,90"
    E o total deve ser "R$ 79,80"
    E devo ver a mensagem "Faltam R$ 140,10 para o frete grátis."

  @CA06 @bug @BUG-01
  Cenário: CT-UI-02 Subtotal exatamente R$ 200,00 ganha frete grátis
    Quando adiciono 2 unidades de "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    Então o subtotal deve ser "R$ 200,00"
    E o frete deve ser "Grátis"
    E o total deve ser "R$ 200,00"
    E não devo ver o aviso de valor faltante para o frete grátis

  @CA06
  Cenário: CT-UI-03 Subtotal acima de R$ 200,00 ganha frete grátis
    Quando adiciono "Jaqueta Corta-Vento" ao carrinho
    E abro o carrinho
    Então o frete deve ser "Grátis"
    E o total deve ser "R$ 229,90"
    E não devo ver o aviso de valor faltante para o frete grátis

  @CA06 @CA07
  Cenário: CT-UI-04 Alterar a quantidade recalcula o frete e o valor faltante
    Quando adiciono "Tênis Casual Urbano" ao carrinho
    E adiciono "Kit 3 Pares de Meias" ao carrinho
    E abro o carrinho
    Então o frete deve ser "Grátis"
    Quando removo "Kit 3 Pares de Meias" do carrinho
    Então o subtotal deve ser "R$ 189,90"
    E o frete deve ser "R$ 19,90"
    E devo ver a mensagem "Faltam R$ 10,10 para o frete grátis."

  # ---------- Cupom ----------

  @CA01 @CA09
  Cenário: CT-UI-05 Cupom BEMVINDO10 aplica 10% apenas sobre os produtos
    Quando adiciono "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    E aplico o cupom "BEMVINDO10"
    Então devo ver o cupom "BEMVINDO10" aplicado
    E o desconto deve ser "- R$ 10,00"
    E o frete deve ser "R$ 19,90"
    E o total deve ser "R$ 109,90"

  @CA02
  Esquema do Cenário: CT-UI-06 Cupom aceito com variação de maiúsculas e espaços: "<digitado>" + <espacos> espaço(s)
    Quando adiciono "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    E aplico o cupom "<digitado>" com <espacos> espaços nas pontas
    Então devo ver o cupom "BEMVINDO10" aplicado
    E o desconto deve ser "- R$ 10,00"

    Exemplos:
      | digitado   | espacos |
      | bemvindo10 | 0       |
      | BemVindo10 | 0       |
      | BEMVINDO10 | 2       |
      | bemvindo10 | 3       |

  @CA03 @CA04
  Esquema do Cenário: CT-UI-07 Cupom não aceito exibe mensagem e não aplica desconto: <cupom>
    Quando adiciono "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    E aplico o cupom "<cupom>"
    Então devo ver a mensagem "<mensagem>"
    E o desconto deve ser "R$ 0,00"
    E o total deve ser "R$ 119,90"

    Exemplos:
      | cupom      | mensagem        |
      | NAOEXISTE  | Cupom inválido. |
      | VERAO2026  | Cupom expirado. |
      | BEMVINDO 10| Cupom inválido. |

  Esquema do Cenário: CT-UI-08 Aplicar cupom <caso> pede um código
    Quando adiciono "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    E aplico o cupom "" com <espacos> espaços nas pontas
    Então devo ver a mensagem "Informe um cupom."
    E o desconto deve ser "R$ 0,00"

    Exemplos:
      | caso                  | espacos |
      | com o campo vazio     | 0       |
      | só com espaços        | 2       |

  @entradas
  Esquema do Cenário: CT-UI-27 Cupom com caracteres inesperados é inválido: <caso>
    Quando adiciono "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    E aplico o cupom "<cupom>"
    Então devo ver a mensagem "Cupom inválido."
    E o desconto deve ser "R$ 0,00"

    Exemplos:
      | caso           | cupom                                          |
      | HTML           | <b>BEMVINDO10</b>                              |
      | muito longo    | BEMVINDO10BEMVINDO10BEMVINDO10BEMVINDO10BEMVINDO10 |
      | acento         | BÉMVINDO10                                     |

  @CA05
  Cenário: CT-UI-09 Apenas um cupom por vez; para trocar é preciso remover o atual
    Quando adiciono "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    E aplico o cupom "BEMVINDO10"
    Então o campo de cupom não deve estar disponível
    Quando removo o cupom
    Então o desconto deve ser "R$ 0,00"
    E o campo de cupom deve estar disponível e vazio
    Quando aplico o cupom "VERAO2026"
    Então devo ver a mensagem "Cupom expirado."
    E o desconto deve ser "R$ 0,00"

  @CA08
  Cenário: CT-UI-10 Frete grátis considera o subtotal antes do desconto
    Quando adiciono "Tênis Casual Urbano" ao carrinho
    E adiciono "Kit 3 Pares de Meias" ao carrinho
    E abro o carrinho
    E aplico o cupom "BEMVINDO10"
    Então o subtotal deve ser "R$ 219,80"
    E o desconto deve ser "- R$ 21,98"
    E o frete deve ser "Grátis"
    E o total deve ser "R$ 197,82"

  @CA01 @CA11
  Cenário: CT-UI-11 Desconto acompanha a alteração de quantidade
    Quando adiciono "Camiseta Essencial" ao carrinho
    E abro o carrinho
    E aplico o cupom "BEMVINDO10"
    E aumento a quantidade de "Camiseta Essencial"
    E aumento a quantidade de "Camiseta Essencial"
    Então o subtotal deve ser "R$ 179,70"
    E o desconto deve ser "- R$ 17,97"
    E o total deve ser "R$ 181,63"

  # ---------- Limite de quantidade ----------

  @CA10
  Cenário: CT-UI-12 Vitrine bloqueia mais de 5 unidades do mesmo produto
    Quando adiciono 5 unidades de "Camiseta Essencial" ao carrinho
    Então o botão de adicionar "Camiseta Essencial" deve estar desabilitado
    E o card de "Camiseta Essencial" deve exibir "Limite de 5 unidades atingido."
    E o contador do carrinho deve ser 5

  @CA10
  Cenário: CT-UI-13 Carrinho bloqueia aumentar a quantidade acima de 5
    Quando adiciono "Camiseta Essencial" ao carrinho
    E abro o carrinho
    E aumento a quantidade de "Camiseta Essencial"
    E aumento a quantidade de "Camiseta Essencial"
    E aumento a quantidade de "Camiseta Essencial"
    E aumento a quantidade de "Camiseta Essencial"
    Então a quantidade de "Camiseta Essencial" deve ser 5
    E o botão de aumentar a quantidade de "Camiseta Essencial" deve estar desabilitado
    E devo ver a mensagem "Limite de 5 unidades por produto."

  # ---------- Persistência e carrinho vazio ----------

  Cenário: CT-UI-14 Carrinho e cupom se mantêm ao recarregar a mesma aba
    Quando adiciono "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    E aplico o cupom "BEMVINDO10"
    E recarrego a página
    Então a quantidade de "Mochila Urbana 20L" deve ser 1
    E o desconto deve ser "- R$ 10,00"

  Cenário: CT-UI-15 Remover o único item deixa o carrinho vazio
    Quando adiciono "Mochila Urbana 20L" ao carrinho
    E abro o carrinho
    E removo "Mochila Urbana 20L" do carrinho
    Então devo ver a mensagem "Seu carrinho está vazio"
    E o contador do carrinho deve ser 0
