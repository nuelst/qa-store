# language: pt
@manual
Funcionalidade: Cenários manuais e exploratórios
  Executados à mão. O resultado e as evidências ficam em docs/execucao.md.
  A tag @manual tira estes cenários da execução automatizada.

  Cenário: CT-MAN-01 Layout do carrinho e do checkout em tela de celular (375px)
    Dado que tenho itens e um cupom aplicado no carrinho
    Quando abro o carrinho e o checkout em uma tela de 375px de largura
    Então o resumo, o campo de cupom e os botões ficam legíveis e sem rolagem horizontal

  Cenário: CT-MAN-02 Fluxo de compra completo só com o teclado
    Dado que estou na vitrine
    Quando adiciono um produto, aplico o cupom e confirmo o pedido usando só Tab, Enter e Espaço
    Então todos os controles recebem foco visível e funcionam pelo teclado

  Cenário: CT-MAN-03 Mensagens de erro e de cupom são anunciadas por leitor de tela
    Dado que estou usando um leitor de tela
    Quando aplico um cupom inválido e envio o checkout com dados inválidos
    Então as mensagens são anunciadas e associadas aos campos

  Cenário: CT-MAN-04 Cliques rápidos e repetidos no botão "Aplicar cupom" e no "+"
    Dado que tenho um item no carrinho
    Quando clico várias vezes seguidas em "+" e em "Aplicar cupom"
    Então a quantidade nunca passa de 5 e o resumo mostra o resultado do último cálculo

  Cenário: CT-MAN-05 Acesso direto ao checkout e à confirmação com o carrinho vazio
    Dado que meu carrinho está vazio
    Quando acesso /checkout e /pedido-confirmado diretamente pela URL
    Então a loja não permite confirmar um pedido vazio e orienta a voltar à vitrine

  Cenário: CT-MAN-06 Duplo clique em "Confirmar pedido"
    Dado que preenchi o checkout com dados válidos
    Quando clico duas vezes rapidamente em "Confirmar pedido"
    Então apenas um pedido é confirmado

  Cenário: CT-MAN-07 Comportamentos do ambiente (não são bugs)
    Dado que tenho itens no carrinho
    Quando abro a loja em outra aba ou em janela anônima
    Então o carrinho começa vazio, como descrito em "Sobre este ambiente"

  Cenário: CT-MAN-08 Falha da API ao confirmar o pedido
    Dado que preenchi o checkout com dados válidos
    E a API de pedidos responde com erro 500
    Quando confirmo o pedido
    Então vejo uma mensagem de erro, continuo no checkout e posso tentar de novo

  Cenário: CT-MAN-09 Carrinho alterado no sessionStorage da aba
    Dado que altero "verzel-store:itens" e "verzel-store:cupom" no sessionStorage
    Quando abro o carrinho e tento finalizar a compra
    Então a loja recusa os dados inválidos, mostra o motivo e não quebra

  Cenário: CT-MAN-10 Nome com conteúdo incomum
    Dado que estou no checkout
    Quando informo um nome com emoji, quebra de linha, símbolos ou mais de 300 caracteres
    Então o comportamento é registrado (a documentação só exige nome e sobrenome)
