# 📊 Repositório SQL - Materia de Análise de Dados

Este repositório contém scripts SQL para exercícios e análises de dados da disciplina de **Análise de Dados**, com foco em manipulação de tabelas, funções de agregação, CTEs, funções de janela e tratamento de valores nulos.

## Arquivos

### `Materia-Analise-Dados.sql` 📝
Consultas SQL aplicadas a uma empresa fictícia, abordando:

- 📈 Funções de agregação (`AVG`, `STDDEV`, `COUNT`, `SUM`)  
- 📊 Agrupamentos e ordenações (`GROUP BY`, `ORDER BY`, `GROUPING SETS`, `ROLLUP`, `CUBE`)  
- 🔄 Tratamento de valores nulos (`COALESCE`)  
- 🤔 Estruturas condicionais (`CASE`)  
- 🔗 Joins entre tabelas (`funcionario`, `projeto`, `alocacao`, `departamento`, `equipamento`)  
- 🪟 Funções de janela (`ROW_NUMBER()`, `RANK()`, `LEAD()`, `LAG()`)  
- 🧩 Identificação de duplicatas e comparação de strings (`LEVENSHTEIN`)  
- 📊 Pivot com `FILTER` para transformar linhas em colunas por tipo de projeto

### `empresa.backup` 💾
Backup do banco de dados usado em `Materia-Analise-Dados.sql` com tabelas principais:

- 👤 `funcionario`  
- 📂 `projeto`  
- 🗂️ `alocacao`  
- 🏢 `departamento`  
- ⚙️ `equipamento`  

### `exercicios-loja.sql` 🛒
Consultas SQL aplicadas a uma base de dados de loja, com exercícios sobre:

- 🛍️ Análise de vendas e produtos  
- 📊 Funções de agregação e métricas  
- 🔗 Joins entre `clientes`, `pedidos` e `produtos`  
- 🏆 Consultas de ranking e média de vendas  

### `loja.backup` 💾
Backup do banco de dados da loja usado em `exercicios-loja.sql`, incluindo:

- 👥 `cliente`  
- 📦 `produto`  
- 🧾 `pedido`  
- 📋 `itempedido`  
- 👉 `indicacao`  

---

Todos os códigos foram feitos no **PostgreSQL**. Aqui você vai ver consultas de análise de dados de empresas e lojas, manipulação de dados mais complexos e funções de janela. Ah, e finalizei a matéria com sucesso na **UNIFEI**! 🎓🚀

## Como usar 🛠️
1. Instale o **PostgreSQL** no seu computador.
2. Crie um banco de dados novo.
3. Importe o arquivo `loja.backup` / `empresa.backup` e rode os scripts `.sql` na ordem.
4. Abra o **pgAdmin** ou qualquer cliente SQL e execute as consultas para ver os resultados.

Clonar Repositório:
```bash
git clone https://github.com/Lucasskyher/SQL-Analise-de-Dados.git
