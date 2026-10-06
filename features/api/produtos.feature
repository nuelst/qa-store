# language: pt
@api
Funcionalidade: API - Produtos (GET /api/produtos)

  Cenário: CT-API-21 Lista de produtos confere com a tabela de dados para teste
    Quando faço GET em "/api/produtos"
    Então o status da resposta deve ser 200
    E a lista de produtos deve ser:
      | id   | nome                  | preco  |
      | P001 | Camiseta Essencial    | 59.9   |
      | P002 | Calça Jeans Slim      | 139.9  |
      | P003 | Tênis Casual Urbano   | 189.9  |
      | P004 | Boné Aba Curva        | 49.9   |
      | P005 | Mochila Urbana 20L    | 100    |
      | P006 | Kit 3 Pares de Meias  | 29.9   |
      | P007 | Jaqueta Corta-Vento   | 229.9  |
      | P008 | Garrafa Térmica 750ml | 50     |

  Cenário: CT-API-22 Consulta de produto existente
    Quando faço GET em "/api/produtos/P003"
    Então o status da resposta deve ser 200
    E os valores devem ser:
      | id        | "P003"                |
      | nome      | "Tênis Casual Urbano" |
      | categoria | "Calçados"            |
      | preco     | 189.9                 |

  Cenário: CT-API-23 Consulta de produto inexistente
    Quando faço GET em "/api/produtos/P999"
    Então o status da resposta deve ser 404
    E o erro deve ter código "PRODUTO_NAO_ENCONTRADO"
