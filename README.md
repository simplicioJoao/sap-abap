# SAP ABAP – Reports criados durante o Treinamento Inclui Tech

Este repositório contém uma coleção de programas ABAP desenvolvidos para fins de estudo, treinamento e automação de rotinas dentro do SAP ERP.

Os programas estão organizados na pasta `src/`, acompanhados de seus respectivos metadados (.xml) gerados pelo abapGit.

## 📁 Programas incluídos (`src/`)

A seguir estão descritos todos os programas .abap presentes no repositório, com suas funcionalidades principais.

---

## 1. **Z944620LISTA_CLIENTES_AUTO**
📄 [Clique aqui para acessar o arquivo do programa](https://github.com/simplicioJoao/sap-abap/blob/main/src/z944620lista_clientes_auto.prog.abap)

**Objetivo:**  
Listar os registros da tabela `z944620cli_auto` criada no Dicionário de Dados, apresentando:

- Nome  
- CPF/CNPJ  
- Data de cadastro  
- Flag de cliente ativo  
- Dados adicionais da estrutura  

**Principais características:**
- Possui parâmetros de seleção (`SELECT-OPTIONS`).
- Permite filtrar clientes por diversos campos.
- Exibição organizada via relatório Writer.

**Usos comuns:** 
- Visualização rápida de clientes para uso em outros processos  
- Auditoria de informações  

---

## 2. **Z944620BATCH_CLIENTES_AUTO**
📄 [Clique aqui para acessar o arquivo do programa](https://github.com/simplicioJoao/sap-abap/blob/main/src/z944620batch_clientes_auto.prog.abap)

**Objetivo:**  
Executar processamento automático de clientes via BATCH INPUT (BDC), realizando atualizações ou cadastros automáticos.

**Principais características:**
- Monta uma tabela `BDCDATA` para simular transações SAP.
- Processa clientes definidos na tabela Z `z944620cli_auto`.
- Executa rotinas de criação/edição de cliente sem interação manual.

**Usos comuns:**
- Carga inicial de dados  
- Atualização em lote  
- Automação de processos repetitivos no SAP 

---

## 3. **Z944620ALV_CLIENTES_INVALIDOS**
📄 [Clique aqui para acessar o arquivo do programa](https://github.com/simplicioJoao/sap-abap/blob/main/src/z944620alv_clientes_invalidos.prog.abap)

**Objetivo:**  
Gerar um relatório ALV listando clientes inválidos com base em critérios definidos (ex.: CPF/CNPJ incorretos, dados inconsistentes, etc.).

**Principais características:**
- Usa ALV para apresentar os resultados de forma estruturada.
- Conta total de clientes avaliados e total de clientes válidos/inválidos.
- Processa clientes da tabela Z `z944620cli_auto`.

**Usos comuns:**
- Auditoria de cadastros  
- Análise de qualidade de dados   

---

## 4. **Z944620CONTROLEPEDIDOSCOMPRAS**
📄 [Clique aqui para acessar o arquivo do programa](https://github.com/simplicioJoao/sap-abap/blob/main/src/z944620controlepedidoscompras.prog.abap)
- Este programa foi desenvolvido com base nesta [Especificação Funcional](https://github.com/simplicioJoao/sap-abap/blob/main/Desenvolvimento%20de%20Relat%C3%B3rio%20de%20Controle%20de%20Pedidos%20de%20Compras.pdf)

**Objetivo:**  
Exibir e controlar informações relacionadas a Pedidos de Compra (MM – Materials Management).

**Principais características:**
- Leitura de tabelas padrão como `EKPO`, `EKKO`, entre outras.
- Criação de parâmetros com TVARV para simular autorização de acesso.
- Lista materiais, quantidades, fornecedores e status.
- Apresenta o resultado em relatório ALV com cabeçalho.

**Usos comuns:**
- Acompanhamento do ciclo de compras  
- Conferência de itens pendentes  
- Relatórios gerenciais de compras  

---

## 🛠 Requisitos

- SAP ERP com suporte a ABAP 7.4+  
- Autorização para usar SE38/SE80  
- Permissão para leitura nas tabelas Z utilizadas  
- Opcional: acesso ao abapGit para importação automatizada  

---

## 🚀 Como executar

1. Importe o repositório via abapGit ou copie cada programa via SE38.  
2. Ative o objeto (`Ctrl + F3`).  
3. Execute via SE38 / SE80.  
4. Preencha os parâmetros de seleção (quando houver).  
5. Execute o relatório.  

---

## 📄 Licença

Projeto disponibilizado para fins educacionais.  
Autor: **João Paulo Simplicio**
