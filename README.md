# Projeto Rural Delivery (Protótipo)

> Um protótipo de aplicativo de logística colaborativa focado em conectar comunidades rurais e facilitar o acesso a entregas do comércio online.

---

## 🎯 O Problema: O "Custo Rural"

Pessoas que vivem em áreas rurais, como sítios, chácaras e fazendas, enfrentam um desafio logístico crônico. As transportadoras e os Correios, muitas vezes, não realizam entregas em endereços rurais não-codificados, considerando-os "fora da área de entrega".

Isso força os moradores a se deslocarem dezenas de quilômetros até o centro urbano mais próximo apenas para retirar uma encomenda, gerando um custo alto de tempo e combustível e criando uma barreira de acesso às compras online.

## 💡 A Solução: Logística Colaborativa (Ponto-a-Ponto)

O **Rural Delivery** ataca esse problema criando uma rede de logística *peer-to-peer* (ponto-a-ponto) onde os próprios moradores se ajudam.

O aplicativo conecta duas personas principais:

1.  **O Remetente:** Alguém que mora no interior e precisa que uma encomenda (comprada online e entregue na cidade) seja levada até sua propriedade.
2.  **O Viajante:** Um vizinho ou morador local que já está indo para a cidade (ou voltando dela) e pode, em troca de um valor, "dar carona" a essa encomenda e entregá-la na propriedade do Remetente.

---

## ✨ Funcionalidades (Protótipo Atual)

Este protótipo, desenvolvido com foco na apresentação visual de um fluxo de usuário completo, já implementa as seguintes funcionalidades:

* **Autenticação Completa:** Sistema de Login e Cadastro de usuários usando E-mail/Senha. (A lógica para login com Google também está parcialmente implementada).
* **Gestão de Usuários:** Dados de usuário são salvos e sincronizados com o banco de dados na nuvem.
* **Cadastro de Endereços:** O usuário (Remetente) pode salvar múltiplos endereços de entrega (ex: "Sítio Santo Antônio") em seu perfil.
* **Solicitação de Frete (Fluxo do Remetente):**
    1.  O Remetente preenche um formulário detalhado sobre o pacote (descrição, peso, tamanho).
    2.  Informa um local de retirada manual (ex: "Escritório do João na cidade").
    3.  Seleciona um de seus endereços cadastrados (ex: "Sítio") como destino final.
    4.  A solicitação é salva no banco de dados com o status "pendente".
* **Realização de Frete (Fluxo do Viajante):**
    1.  O Viajante vê uma lista (Aba 1) com todos os fretes "pendentes" postados por outros usuários.
    2.  Ele pode clicar em um frete para ver os detalhes (retirada, entrega, item).
    3.  Ao clicar em "Aceitar Frete", o item é removido da lista pública.
* **Gestão de Atividades (Ciclo Completo):**
    * A (Aba 2) "Minhas Atividades" exibe de forma inteligente todos os fretes relevantes para o usuário logado:
        * Fretes que **ele solicitou** (como Remetente).
        * Fretes que **ele aceitou** (como Viajante).

---

## 🛠️ Tecnologias Utilizadas

* **Framework:** Flutter
* **Arquitetura:** GetX (Controllers, Repositories, Services)
* **Banco de Dados (Nuvem):** Cloud Firestore
* **Autenticação:** Firebase Authentication

---

## 🚀 Status e Visão de Futuro

**Status: Protótipo Funcional (MVP)**

Este projeto é, no momento, um protótipo funcional construído para fins acadêmicos. Ele prova que o fluxo de usuário e a arquitetura de backend são viáveis.

### Visão

A ideia deste aplicativo nasceu de uma necessidade real.
O objetivo final é transformar este protótipo em um produto real. A meta é criar uma ferramenta que realmente conecte vizinhos e comunidades do interior, gerando economia de tempo e combustível, criando novas oportunidades de renda (para os viajantes) e, o mais importante, dando às pessoas do campo o acesso que elas merecem ao comércio digital sem que precisem se deslocar para isso.