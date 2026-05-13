# 🏫 AuroraEduTech — Sistema de Gestão Escolar

<p align="center">
  Projeto acadêmico desenvolvido para a disciplina de <b>Banco de Dados</b><br>
  ERP voltado para <b>escolas de Ensino Fundamental I (1º ao 5º ano)</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-concluido-green" />
  <img src="https://img.shields.io/badge/banco-MySQL-blue" />
  <img src="https://img.shields.io/badge/escola-Fundamental%20I-green" />
  <img src="https://img.shields.io/badge/módulos-3-orange" />
</p>

---

## 🎯 Objetivo do Projeto

O **AuroraEduTech** é um projeto acadêmico que tem como objetivo projetar a arquitetura de um **ERP (Enterprise Resource Planning)** para gestão escolar, atendendo escolas de **Ensino Fundamental I (1º ao 5º ano)** e integrando processos acadêmicos, financeiros e administrativos em uma única plataforma.

Além da modelagem tradicional de banco de dados, o projeto explora a evolução dos dados desde o nível operacional até a geração de análises estratégicas e modelos preditivos.

---

## 🧠 Arquitetura de Dados

### 📌 OLTP — Processamento Operacional
- Registro de presença dos alunos
- Notas de avaliações
- Pagamento de mensalidades
- Cadastro de funcionários
- Registro de ponto

### 📊 OLAP — Informação Analítica
- Média de desempenho por disciplina
- Taxa de inadimplência
- Frequência média dos alunos
- Custo operacional da escola
- Participação em atividades extracurriculares

### 🤖 IA — Análise Preditiva
- Probabilidade de evasão escolar
- Previsão de inadimplência
- Identificação de alunos com risco de baixo desempenho
- Previsão de demanda de atividades extracurriculares

---

## 🏛 Módulos do ERP

### 📚 Módulo Acadêmico
**Entidades:** `tb_aluno`, `tb_turma`, `tb_matricula`, `tb_grade_curricular`, `tb_horario_aula`, `tb_presenca_aluno`, `tb_atividade_professor`, `tb_nota_atividade`, `tb_boletim`

**Dados armazenados:** notas por atividade, presença por aula, histórico escolar, participação extracurricular.

---

### 💰 Módulo Financeiro
**Entidades:** `tb_contrato_financeiro`, `tb_pagamento`, `tb_status_pagamento`, `tb_evento_escolar`, `tb_calendario_letivo`

**Dados armazenados:** valor e vencimento de mensalidades, status de pagamento por parcela, controle de inadimplência, custos de eventos.

**Eventos considerados:** Festa Junina, Dia das Mães/Pais, Formatura do 5º ano, Passeios pedagógicos.

---

### 👩‍💼 Módulo de Recursos Humanos
**Entidades:** `tb_funcionario`, `tb_cargo`, `tb_contrato`, `tb_historico_salario`, `tb_historico_cargo`, `tb_folha_pagamento`, `tb_verba_folha`

**Dados armazenados:** dados cadastrais, cargo e jornada, registro de ponto e ausências, habilidades extracurriculares.

---

## 🗄️ Estrutura do Banco de Dados

O schema conta com **47 tabelas** organizadas nos três módulos do ERP, com **20 triggers** de integridade de negócio e **8 índices** para otimização de consultas.

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

### Índices de performance (8 no total)

| Índice | Tabela | Colunas |
|--------|--------|---------|
| `idx_pagamento_vencimento_status` | `tb_pagamento` | `data_vencimento`, `fk_status_pagamento` |
| `idx_pagamento_ano_mes` | `tb_pagamento` | `ano_referencia`, `mes_referencia` |
| `idx_folha_ano_mes_status` | `tb_folha_pagamento` | `ano`, `mes`, `status_folha` |
| `idx_presenca_matricula_cal` | `tb_presenca_aluno` | `fk_matricula`, `fk_calendario_letivo` |
| `idx_nota_atividade` | `tb_nota_atividade` | `fk_atividade_professor`, `valor_nota` |
| `idx_boletim_matricula_bimestre` | `tb_boletim` | `fk_matricula`, `bimestre` |
| `idx_matricula_turma_status` | `tb_matricula` | `fk_turma`, `fk_status_matricula` |
| `idx_alerta_status_data` | `tb_alerta_evasao` | `fk_status_alerta`, `data_alerta` |

---

## 📊 Consultas e Procedures

O `runall.sql` inclui, além do DDL e triggers, as seguintes consultas analíticas e a stored procedure de pagamento:

| Consulta | Descrição |
|----------|-----------|
| Alunos ativos por turma | Lista todos os alunos com matrícula ativa |
| Ocupação das turmas | Total de alunos vs. capacidade máxima (%) |
| Alunos com média abaixo de 5 | Média ponderada por bimestre |
| Inadimplência | Pagamentos em atraso com contato do responsável financeiro |
| Frequência por turma | Ranking de presença com `RANK() OVER` |
| `sp_registrar_pagamento` | Stored procedure transacional para baixa de mensalidade |

---

## 📏 Arquitetura ANSI-SPARC

| Nível | Descrição |
|-------|-----------|
| **Conceitual** | Relacionamento entre entidades — ver `DER.PNG` |
| **Lógico** | Estrutura normalizada do banco de dados — ver `runall.sql` |
| **Externo** | Visões específicas por área: Coordenação, Direção, Financeiro |

---

## 📂 Estrutura do Repositório

```
AuroraEduTech/
├── runall.sql                   # DDL completo: tabelas, FKs, triggers, índices, consultas e procedure
├── seed-aurora.sql              # Carga de dados (idempotente via INSERT IGNORE)
├── DER.PNG                      # Diagrama Entidade-Relacionamento
├── Fluxograma-SisGESC.drawio.pdf  # Fluxograma do sistema
├── Modelo estrela.pdf           # Modelo estrela para OLAP
├── (1)95958159.pdf              # Documentação do trabalho
└── README.md
```

> **Nota:** O arquivo `runall.sql` consolida DDL, triggers, índices, consultas analíticas e a stored procedure em um único script de execução.

---

## 🚀 Como executar

```sql
-- 1. Criar o banco e executar tudo
SOURCE runall.sql;

-- 2. Carregar os dados de exemplo
SOURCE seed-aurora.sql;

-- 3. Verificar carga
SELECT table_name AS tabela, table_rows AS registros
FROM information_schema.tables
WHERE table_schema = 'sistema_aurora_edutech'
ORDER BY table_name;
```

> **Idempotência:** o `seed-aurora.sql` usa `INSERT IGNORE` com PKs explícitas — pode ser executado mais de uma vez sem duplicar registros.

> **Limpeza:** o `runall.sql` contém blocos comentados com `TRUNCATE` e `DROP DATABASE` ao final, prontos para uso quando necessário.

---

## 📌 Etapas do Projeto

- [x] Levantamento de requisitos
- [x] Modelagem de processos
- [x] Identificação das entidades
- [x] Definição de regras de negócio
- [x] Dicionário de dados
- [x] Modelagem conceitual (DER)
- [x] Modelagem lógica (DDL)
- [x] Triggers de integridade (20 triggers)
- [x] Índices de performance (8 índices)
- [x] Stored procedure de pagamento
- [x] Consultas analíticas (OLAP)
- [x] Script de carga (DML idempotente)
- [x] Modelo estrela para OLAP
---

## 👥 Organização do Grupo

| Frente | Responsabilidade |
|--------|-----------------|
| 📚 Acadêmico | Alunos, turmas, notas, frequência, boletins |
| 💰 Financeiro | Mensalidades, pagamentos, eventos, contratos |
| 👩‍💼 Recursos Humanos | Funcionários, contratos, folha, cargos |

---

## 💡 Observação

O AuroraEduTech representa a construção conceitual do **"cérebro digital"** de uma instituição escolar. A qualidade da modelagem de dados determina diretamente a qualidade das informações analíticas e previsões futuras.

> **Dados mal estruturados geram decisões equivocadas.**

---

<p align="center">Desenvolvido para a disciplina de Banco de Dados</p>
