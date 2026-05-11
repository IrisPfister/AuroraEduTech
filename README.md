# 🏫 AuroraEduTech — Sistema de Gestão Escolar

<p align="center">
  Projeto acadêmico desenvolvido para a disciplina de <b>Banco de Dados</b><br>
  ERP voltado para <b>escolas de Ensino Fundamental I (1º ao 5º ano)</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-em%20desenvolvimento-yellow" />
  <img src="https://img.shields.io/badge/banco-MySQL-blue" />
  <img src="https://img.shields.io/badge/escola-Fundamental%20I-green" />
  <img src="https://img.shields.io/badge/módulos-3-orange" />
</p>

---

## 🎯 Objetivo do Projeto

O **AuroraEduTech** é um projeto acadêmico que tem como objetivo projetar a arquitetura de um **ERP (Enterprise Resource Planning)** para gestão escolar.

O sistema foi pensado para atender escolas de **Ensino Fundamental I (1º ao 5º ano)**, integrando processos acadêmicos, financeiros e administrativos em uma única plataforma.

Além da modelagem tradicional de banco de dados, o projeto também explora a evolução dos dados desde o nível operacional até a geração de análises estratégicas e modelos preditivos.

---

## 🧠 Arquitetura de Dados

O projeto segue três níveis de utilização dos dados:

### 📌 OLTP — Processamento Operacional
Representa os dados capturados no dia a dia da escola.
- Registro de presença dos alunos
- Notas de avaliações
- Pagamento de mensalidades
- Cadastro de funcionários
- Registro de ponto

### 📊 OLAP — Informação Analítica
Transformação dos dados operacionais em informações estratégicas.
- Média de desempenho por disciplina
- Taxa de inadimplência
- Frequência média dos alunos
- Custo operacional da escola
- Participação em atividades extracurriculares

### 🤖 IA — Análise Preditiva
Com base no histórico de dados, o sistema poderá futuramente alimentar modelos de inteligência artificial.
- Probabilidade de evasão escolar
- Previsão de inadimplência
- Identificação de alunos com risco de baixo desempenho
- Previsão de demanda de atividades extracurriculares

---

## 🏛 Módulos do ERP

### 📚 Módulo Acadêmico
Responsável pela gestão pedagógica da escola.

**Entidades principais:** Alunos, Professores, Turmas, Séries (1º ao 5º ano), Disciplinas, Matrículas, Avaliações, Frequência

**Dados armazenados:**
- Notas das avaliações por atividade
- Presença por aula
- Histórico escolar
- Participação em atividades extracurriculares

---

### 💰 Módulo Financeiro
Responsável pelo controle financeiro da instituição.

**Entidades principais:** Mensalidades, Parcelas, Pagamentos, Contratos Financeiros, Eventos Escolares

**Dados armazenados:**
- Valor da mensalidade e data de vencimento
- Status de pagamento por parcela
- Controle de inadimplência
- Custos de eventos

**Eventos escolares considerados:**
- Festa Junina
- Dia das Mães / Dia dos Pais
- Formatura do 5º ano
- Passeios pedagógicos

**Integração com RH:**
- Folha de pagamento
- PLR e benefícios

---

### 👩‍💼 Módulo de Recursos Humanos
Responsável pela gestão dos funcionários da escola.

**Entidades principais:** Funcionários, Cargos, Contratos, Histórico de Salários, Histórico de Cargos, Folha de Pagamento

**Dados armazenados:**
- Dados cadastrais e documentação legal
- Cargo e jornada de trabalho
- Registro de ponto e ausências
- Habilidades extracurriculares (Ballet, Robótica, Jazz, Judô, etc.)

---

## 🗄️ Estrutura do Banco de Dados

O schema conta com **47 tabelas**, organizadas nos três módulos do ERP, com triggers para garantia de integridade de negócio.

### Principais tabelas

| Módulo | Tabelas |
|--------|---------|
| Acadêmico | `tb_aluno`, `tb_turma`, `tb_matricula`, `tb_grade_curricular`, `tb_horario_aula`, `tb_presenca_aluno`, `tb_atividade_professor`, `tb_nota_atividade`, `tb_boletim` |
| Financeiro | `tb_contrato_financeiro`, `tb_pagamento`, `tb_status_pagamento`, `tb_evento_escolar`, `tb_calendario_letivo` |
| RH | `tb_funcionario`, `tb_professor`, `tb_contrato`, `tb_historico_cargo`, `tb_historico_salario`, `tb_folha_pagamento`, `tb_verba_folha` |
| Compartilhado | `tb_pessoa`, `tb_email`, `tb_telefone`, `tb_endereco`, `tb_responsavel`, `tb_ano_letivo` |
| Evasão | `tb_alerta_evasao`, `tb_tipo_risco_evasao`, `tb_nivel_risco_evasao`, `tb_status_alerta` |

### Triggers implementados (20 no total)

| Grupo | Tabela | Regra |
|-------|--------|-------|
| 1 | `tb_contrato` | Funcionário ativo; sem sobreposição de períodos; consistência status × data_fim |
| 2 | `tb_historico_cargo` | Cargo ativo; datas dentro do contrato; sem sobreposição |
| 3 | `tb_historico_salario` | Datas dentro do contrato; sem sobreposição |
| 4 | `tb_matricula` | Capacidade máxima da turma (RN015) |
| 5 | `tb_ano_letivo` | Apenas um ano letivo ativo por vez |
| 6 | `tb_email` | Único e-mail principal por pessoa |
| 7 | `tb_telefone` | Único telefone principal por pessoa |
| 8 | `tb_responsavel_aluno` | Único responsável principal por aluno |
| 9 | `tb_presenca_aluno` | Horário pertence à turma da matrícula |
| 10 | `tb_nota_atividade` | Atividade pertence à turma da matrícula |

---

## 📊 Granularidade dos Dados

Durante a modelagem foi definido o nível de detalhamento necessário para análises futuras:

- Frequência registrada **por aula**
- Notas registradas **por atividade**
- Pagamentos registrados **por parcela**

Esse nível de granularidade permite análises mais precisas no OLAP e alimenta os modelos preditivos de IA.

---

## 📏 Arquitetura ANSI-SPARC

| Nível | Descrição |
|-------|-----------|
| **Conceitual** | Relacionamento entre entidades (MER) |
| **Lógico** | Estrutura normalizada do banco de dados |
| **Externo** | Visões específicas por área: Coordenação, Direção, Financeiro |

---

## 📂 Estrutura do Repositório

```
auroraEduTech/
├── schema/
│   ├── ddl_aurora_edutech.sql       # Criação das tabelas e constraints
│   └── triggers_aurora_edutech.sql  # 20 triggers de regras de negócio
├── seed/
│   └── seed_aurora_edutech.sql      # Carga de dados (idempotente)
├── docs/
│   ├── dicionario_de_dados.md       # Dicionário de dados
│   └── regras_de_negocio.md         # Regras de negócio documentadas
└── README.md
```

---

## 🚀 Como executar

```sql
-- 1. Criar o banco
CREATE DATABASE aurora_edutech;
USE aurora_edutech;

-- 2. Executar o DDL (tabelas + triggers)
SOURCE schema/ddl_aurora_edutech.sql;
SOURCE schema/triggers_aurora_edutech.sql;

-- 3. Executar o seed de dados
SOURCE seed/seed_aurora_edutech.sql;

-- 4. Verificar carga
SELECT table_name AS tabela, table_rows AS registros
FROM information_schema.tables
WHERE table_schema = 'aurora_edutech'
ORDER BY table_name;
```

> **Idempotência:** o script de seed usa `INSERT IGNORE` com PKs explícitas. Executá-lo mais de uma vez não duplica registros.

---

## 📌 Etapas do Projeto

- [x] Levantamento de requisitos
- [x] Modelagem de processos
- [x] Identificação das entidades
- [x] Definição de regras de negócio
- [x] Dicionário de dados
- [x] Modelagem conceitual
- [x] Modelagem lógica (DDL)
- [x] Triggers de integridade
- [x] Script de carga (DML idempotente)
- [ ] Preparação para análise OLAP
- [ ] Definição de perguntas para IA
- [ ] Views por módulo (ANSI-SPARC nível externo)

---

## 👥 Organização do Grupo

O grupo foi dividido em três frentes, cada uma responsável por entidades, regras de negócio, dados operacionais e indicadores analíticos do seu módulo:

| Frente | Responsabilidade |
|--------|-----------------|
| 📚 Acadêmico | Alunos, turmas, notas, frequência, boletins |
| 💰 Financeiro | Mensalidades, pagamentos, eventos, contratos |
| 👩‍💼 Recursos Humanos | Funcionários, contratos, folha, cargos |

---

## 💡 Observação

O AuroraEduTech representa a construção conceitual do **"cérebro digital"** de uma instituição escolar.

A qualidade da modelagem de dados determina diretamente a qualidade das informações analíticas e previsões futuras.

> **Dados mal estruturados geram decisões equivocadas.**

---

<p align="center">Desenvolvido para a disciplina de Banco de Dados</p>
