-- =====================================================================
-- DATA WAREHOUSE - AURORA
-- ETL COMPLETO (Iterações 1 + 2 unificadas)
--
-- Cobertura:
--   Dimensões : dim_tempo, dim_aluno, dim_funcionario, dim_professor,
--               dim_disciplina, dim_turma, dim_status_pagamento,
--               dim_atividade, dim_folha,
--               dim_risco, dim_situacao
--
--   Fatos     : fato_folha_rh, fato_desempenho,
--               fato_frequencia, fato_boletim,
--               fato_atividade_professor, fato_pagamento,
--               fato_evasao, fato_contrato_rh
-- =====================================================================

-- =====================================================================
-- 1. CRIAÇÃO DO BANCO
-- =====================================================================

CREATE DATABASE IF NOT EXISTS dw_aurora;
USE dw_aurora;

SET FOREIGN_KEY_CHECKS = 0;

-- Fatos (dependem das dims — removidos primeiro)
DROP TABLE IF EXISTS fato_contrato_rh;
DROP TABLE IF EXISTS fato_evasao;
DROP TABLE IF EXISTS fato_pagamento;
DROP TABLE IF EXISTS fato_atividade_professor;
DROP TABLE IF EXISTS fato_boletim;
DROP TABLE IF EXISTS fato_frequencia;
DROP TABLE IF EXISTS fato_folha_rh;
DROP TABLE IF EXISTS fato_desempenho;

-- Dimensões da iteração 2
DROP TABLE IF EXISTS dim_risco;
DROP TABLE IF EXISTS dim_situacao;

-- Dimensões da iteração 1
DROP TABLE IF EXISTS dim_tempo;
DROP TABLE IF EXISTS dim_aluno;
DROP TABLE IF EXISTS dim_funcionario;
DROP TABLE IF EXISTS dim_professor;
DROP TABLE IF EXISTS dim_disciplina;
DROP TABLE IF EXISTS dim_turma;
DROP TABLE IF EXISTS dim_status_pagamento;
DROP TABLE IF EXISTS dim_atividade;
DROP TABLE IF EXISTS dim_folha;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- 2. DIMENSÕES
-- =====================================================================

-- ---------------------------------------------------------------------
-- dim_tempo (calendário completo 2020-2030)
-- ---------------------------------------------------------------------
CREATE TABLE dim_tempo (
    sk_tempo          INT         PRIMARY KEY,
    data_completa     DATE,
    dia               TINYINT,
    mes               TINYINT,
    nome_mes          VARCHAR(15),
    semana_do_ano     TINYINT,
    ano               SMALLINT,
    bimestre          TINYINT     NULL,
    nome_bimestre     VARCHAR(20),
    eh_feriado        BOOLEAN     DEFAULT FALSE,
    eh_dia_util       BOOLEAN     DEFAULT FALSE,
    eh_periodo_letivo BOOLEAN     DEFAULT FALSE
);

-- ---------------------------------------------------------------------
-- dim_aluno (com atributos demográficos e derivados)
-- ---------------------------------------------------------------------
CREATE TABLE dim_aluno (
    sk_aluno                       INT          PRIMARY KEY AUTO_INCREMENT,
    pk_aluno_origem                INT,
    ra                             VARCHAR(15),
    nome_completo                  VARCHAR(100),
    sexo                           VARCHAR(15),
    data_nascimento                DATE,
    nacionalidade                  VARCHAR(15),
    raca                           VARCHAR(15),
    faz_atividade_extracurricular  BOOLEAN,
    escola_anterior                VARCHAR(30),
    idade_ingresso                 TINYINT,
    faixa_etaria                   VARCHAR(20),
    ano_ingresso                   YEAR,
    idade_valida_matricula         TINYINT       -- 1 = idade compatível com ensino fundamental
);

-- ---------------------------------------------------------------------
-- dim_funcionario
-- ---------------------------------------------------------------------
CREATE TABLE dim_funcionario (
    sk_funcionario          INT          PRIMARY KEY AUTO_INCREMENT,
    pk_funcionario_origem   INT,
    nome_completo           VARCHAR(100),
    sexo                    VARCHAR(15),
    cargo                   VARCHAR(60),
    tipo_contrato           VARCHAR(30),
    carga_horaria_semanal   TINYINT,
    ativo                   BOOLEAN
);

-- ---------------------------------------------------------------------
-- dim_professor
-- ---------------------------------------------------------------------
CREATE TABLE dim_professor (
    sk_professor                INT          PRIMARY KEY AUTO_INCREMENT,
    pk_professor_origem         INT,
    nome_completo               VARCHAR(100),
    sexo                        VARCHAR(15),
    usa_rubrica_avaliativa      BOOLEAN,
    atende_educacao_especial    BOOLEAN,
    tipo_aula                   VARCHAR(40),
    nivel_formacao              VARCHAR(40),
    curso_principal             VARCHAR(100)
);

-- ---------------------------------------------------------------------
-- dim_disciplina
-- ---------------------------------------------------------------------
CREATE TABLE dim_disciplina (
    sk_disciplina       INT          PRIMARY KEY AUTO_INCREMENT,
    pk_materia_origem   INT,
    nome_disciplina     VARCHAR(60),
    area_conhecimento   VARCHAR(40),
    ativo               BOOLEAN
);

-- ---------------------------------------------------------------------
-- dim_turma
-- ---------------------------------------------------------------------
CREATE TABLE dim_turma (
    sk_turma            INT          PRIMARY KEY AUTO_INCREMENT,
    pk_turma_origem     INT,
    nome_turma          VARCHAR(50),
    ano_escolar         TINYINT,
    periodo             VARCHAR(20),
    ano_letivo          YEAR,
    capacidade_maxima   TINYINT
);

-- ---------------------------------------------------------------------
-- dim_status_pagamento
-- ---------------------------------------------------------------------
CREATE TABLE dim_status_pagamento (
    sk_status_pagamento INT          PRIMARY KEY AUTO_INCREMENT,
    pk_status_origem    INT,
    descricao_status    VARCHAR(30)
);

-- ---------------------------------------------------------------------
-- dim_atividade (tipo de atividade — prova, trabalho, seminário, etc.)
-- ---------------------------------------------------------------------
CREATE TABLE dim_atividade (
    sk_tipo_atividade        INT          PRIMARY KEY AUTO_INCREMENT,
    pk_tipo_atividade_origem INT,
    descricao_atividade      VARCHAR(60)
);

-- ---------------------------------------------------------------------
-- dim_folha (tipo de folha — mensal, 13º, rescisão, etc.)
-- Não tem PK na origem (é ENUM), então usamos lista fixa
-- ---------------------------------------------------------------------
CREATE TABLE dim_folha (
    sk_tipo_folha       INT          PRIMARY KEY AUTO_INCREMENT,
    descricao_folha     VARCHAR(30)
);

-- ---------------------------------------------------------------------
-- dim_risco
-- Origem: tb_tipo_risco_evasao + tb_nivel_risco (OLTP)
-- Combina tipo e nível em uma dimensão degenerada de risco,
-- facilitando análises de evasão sem múltiplos JOINs.
-- ---------------------------------------------------------------------
CREATE TABLE dim_risco (
    sk_risco            INT         PRIMARY KEY AUTO_INCREMENT,
    pk_tipo_risco_orig  INT,
    pk_nivel_risco_orig INT,
    tipo_risco          VARCHAR(60),
    nivel_risco         VARCHAR(40),
    ordem_criticidade   TINYINT     -- 1 = menor risco, valores maiores = mais crítico
);

-- ---------------------------------------------------------------------
-- dim_situacao
-- Origem: tb_situacao_boletim (OLTP)
-- Representa a situação do aluno ao final de cada bimestre
-- (aprovado, reprovado, em recuperação, etc.)
-- ---------------------------------------------------------------------
CREATE TABLE dim_situacao (
    sk_situacao         INT         PRIMARY KEY AUTO_INCREMENT,
    pk_situacao_orig    INT,
    descricao           VARCHAR(60)
);

-- =====================================================================
-- 3. TABELAS FATO
-- =====================================================================

CREATE TABLE fato_folha_rh (
    id_folha_rh         INT             PRIMARY KEY AUTO_INCREMENT,
    fk_funcionario      INT,
    fk_tempo            INT,
    fk_tipo_folha       INT,
    salario_base        DECIMAL(10,2),
    valor_bruto         DECIMAL(10,2),
    valor_liquido       DECIMAL(10,2),
    total_creditos      DECIMAL(10,2),
    total_descontos     DECIMAL(10,2),
    salario_anterior    DECIMAL(10,2),
    percentual_aumento  DECIMAL(6,2),
    motivo_aumento      VARCHAR(100),
    CONSTRAINT fk_folha_funcionario
        FOREIGN KEY (fk_funcionario) REFERENCES dim_funcionario(sk_funcionario),
    CONSTRAINT fk_folha_tempo
        FOREIGN KEY (fk_tempo) REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_folha_tipo
        FOREIGN KEY (fk_tipo_folha) REFERENCES dim_folha(sk_tipo_folha)
);

CREATE TABLE fato_desempenho (
    id_desempenho           INT             PRIMARY KEY AUTO_INCREMENT,
    fk_aluno                INT,
    fk_professor            INT,
    fk_disciplina           INT,
    fk_turma                INT,
    fk_tempo                INT,
    fk_tipo_atividade       INT,
    valor_nota              DECIMAL(4,2),
    nota_maxima             DECIMAL(4,2),
    percentual_nota         DECIMAL(5,2),
    peso_atividade          DECIMAL(4,2),
    qtd_entregue_no_prazo   TINYINT,
    CONSTRAINT fk_desempenho_aluno
        FOREIGN KEY (fk_aluno) REFERENCES dim_aluno(sk_aluno),
    CONSTRAINT fk_desempenho_professor
        FOREIGN KEY (fk_professor) REFERENCES dim_professor(sk_professor),
    CONSTRAINT fk_desempenho_disciplina
        FOREIGN KEY (fk_disciplina) REFERENCES dim_disciplina(sk_disciplina),
    CONSTRAINT fk_desempenho_turma
        FOREIGN KEY (fk_turma) REFERENCES dim_turma(sk_turma),
    CONSTRAINT fk_desempenho_tempo
        FOREIGN KEY (fk_tempo) REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_desempenho_atividade
        FOREIGN KEY (fk_tipo_atividade) REFERENCES dim_atividade(sk_tipo_atividade)
);

-- ---------------------------------------------------------------------
-- fato_frequencia
-- Granularidade: 1 linha por aluno × turma × dia
-- Origem: tb_frequencia (OLTP)
-- Métricas: qtd_presenca, qtd_falta, qtd_justificada
-- ---------------------------------------------------------------------
CREATE TABLE fato_frequencia (
    id_frequencia       INT         PRIMARY KEY AUTO_INCREMENT,
    fk_aluno            INT         NOT NULL,
    fk_turma            INT         NOT NULL,
    fk_tempo            INT         NOT NULL,
    qtd_presenca        TINYINT     NOT NULL DEFAULT 0,
    qtd_falta           TINYINT     NOT NULL DEFAULT 0,
    qtd_justificada     TINYINT     NOT NULL DEFAULT 0,
    CONSTRAINT fk_freq_aluno
        FOREIGN KEY (fk_aluno)  REFERENCES dim_aluno(sk_aluno),
    CONSTRAINT fk_freq_turma
        FOREIGN KEY (fk_turma)  REFERENCES dim_turma(sk_turma),
    CONSTRAINT fk_freq_tempo
        FOREIGN KEY (fk_tempo)  REFERENCES dim_tempo(sk_tempo)
);

-- ---------------------------------------------------------------------
-- fato_boletim
-- Granularidade: 1 linha por aluno × turma × bimestre
-- Origem: tb_boletim (OLTP)
-- Métricas: flags de aprovação, reprovação e recuperação
-- ---------------------------------------------------------------------
CREATE TABLE fato_boletim (
    sk_boletim          INT         PRIMARY KEY AUTO_INCREMENT,
    fk_aluno            INT         NOT NULL,
    fk_turma            INT         NOT NULL,
    fk_tempo            INT         NOT NULL,
    fk_situacao         INT         NOT NULL,
    esta_aprovado       TINYINT     NOT NULL DEFAULT 0,  -- 1 = sim
    esta_reprovado      TINYINT     NOT NULL DEFAULT 0,
    em_recuperacao      TINYINT     NOT NULL DEFAULT 0,
    CONSTRAINT fk_boletim_aluno
        FOREIGN KEY (fk_aluno)     REFERENCES dim_aluno(sk_aluno),
    CONSTRAINT fk_boletim_turma
        FOREIGN KEY (fk_turma)     REFERENCES dim_turma(sk_turma),
    CONSTRAINT fk_boletim_tempo
        FOREIGN KEY (fk_tempo)     REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_boletim_situacao
        FOREIGN KEY (fk_situacao)  REFERENCES dim_situacao(sk_situacao)
);

-- ---------------------------------------------------------------------
-- fato_atividade_professor
-- Granularidade: 1 linha por professor × disciplina × turma × tipo de
--               atividade × data prevista
-- Origem: tb_atividade_professor (OLTP)
-- Métrica: qtd_realizada (agregação de atividades planejadas)
-- ---------------------------------------------------------------------
CREATE TABLE fato_atividade_professor (
    sk_atividade        INT         PRIMARY KEY AUTO_INCREMENT,
    fk_professor        INT         NOT NULL,
    fk_disciplina       INT         NOT NULL,
    fk_turma            INT         NOT NULL,
    fk_tempo            INT         NOT NULL,
    fk_tipo_atividade   INT         NOT NULL,
    qtd_realizada       TINYINT     NOT NULL DEFAULT 0,
    CONSTRAINT fk_atv_prof_professor
        FOREIGN KEY (fk_professor)      REFERENCES dim_professor(sk_professor),
    CONSTRAINT fk_atv_prof_disciplina
        FOREIGN KEY (fk_disciplina)     REFERENCES dim_disciplina(sk_disciplina),
    CONSTRAINT fk_atv_prof_turma
        FOREIGN KEY (fk_turma)          REFERENCES dim_turma(sk_turma),
    CONSTRAINT fk_atv_prof_tempo
        FOREIGN KEY (fk_tempo)          REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_atv_prof_tipo
        FOREIGN KEY (fk_tipo_atividade) REFERENCES dim_atividade(sk_tipo_atividade)
);

-- ---------------------------------------------------------------------
-- fato_pagamento
-- Granularidade: 1 linha por aluno × mês de vencimento
-- Origem: tb_cobranca (OLTP)
-- Métricas: valor_mensalidade, valor_pago, flags de pagamento e atraso
-- ---------------------------------------------------------------------
CREATE TABLE fato_pagamento (
    id_pagamento        INT         PRIMARY KEY AUTO_INCREMENT,
    fk_aluno            INT         NOT NULL,
    fk_tempo            INT         NOT NULL,  -- mês/ano do vencimento
    fk_status_pagamento INT         NOT NULL,
    valor_mensalidade   DECIMAL(10,2),
    valor_pago          DECIMAL(10,2),
    qtd_foi_pago        TINYINT     NOT NULL DEFAULT 0,  -- 1 = pago
    qtd_foi_atrasado    TINYINT     NOT NULL DEFAULT 0,  -- 1 = houve atraso
    qtd_dias_atrasado   INT         NOT NULL DEFAULT 0,
    CONSTRAINT fk_pgto_aluno
        FOREIGN KEY (fk_aluno)            REFERENCES dim_aluno(sk_aluno),
    CONSTRAINT fk_pgto_tempo
        FOREIGN KEY (fk_tempo)            REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_pgto_status
        FOREIGN KEY (fk_status_pagamento) REFERENCES dim_status_pagamento(sk_status_pagamento)
);

-- ---------------------------------------------------------------------
-- fato_evasao
-- Granularidade: 1 linha por alerta de evasão
-- Origem: tb_alerta_evasao (OLTP)
-- Métricas: dias_ate_resolucao, flags foi_resolvido e evadiu
-- ---------------------------------------------------------------------
CREATE TABLE fato_evasao (
    sk_evasao           INT         PRIMARY KEY AUTO_INCREMENT,
    fk_aluno            INT         NOT NULL,
    fk_turma            INT         NOT NULL,
    fk_tempo            INT         NOT NULL,  -- data do alerta
    fk_risco            INT         NOT NULL,
    dias_ate_resolucao  DECIMAL(8,2),          -- NULL se ainda não resolvido
    foi_resolvido       TINYINT     NOT NULL DEFAULT 0,  -- 1 = resolvido
    evadiu              TINYINT     NOT NULL DEFAULT 0,  -- 1 = aluno saiu
    CONSTRAINT fk_evasao_aluno
        FOREIGN KEY (fk_aluno) REFERENCES dim_aluno(sk_aluno),
    CONSTRAINT fk_evasao_turma
        FOREIGN KEY (fk_turma) REFERENCES dim_turma(sk_turma),
    CONSTRAINT fk_evasao_tempo
        FOREIGN KEY (fk_tempo) REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_evasao_risco
        FOREIGN KEY (fk_risco) REFERENCES dim_risco(sk_risco)
);

-- ---------------------------------------------------------------------
-- fato_contrato_rh
-- Granularidade: 1 linha por contrato (foto atual, não histórico)
-- Origem: tb_contrato + tb_historico_salario (OLTP)
-- Métricas: salario_base, carga_horaria, contrato_ativo
-- fk_tempo_emissao    = sk_tempo da data_inicio do contrato
-- fk_tempo_vencimento = sk_tempo da data_fim (NULL = indeterminado)
-- ---------------------------------------------------------------------
CREATE TABLE fato_contrato_rh (
    sk_contrato_rh      INT         PRIMARY KEY AUTO_INCREMENT,
    fk_funcionario      INT         NOT NULL,
    fk_tempo            INT         NOT NULL,  -- mês de referência
    fk_tempo_emissao    INT,                   -- sk_tempo da data_inicio do contrato
    fk_tempo_vencimento INT,                   -- sk_tempo da data_fim (NULL = indeterminado)
    salario_base        DECIMAL(10,2),
    carga_horaria       TINYINT,
    contrato_ativo      TINYINT     NOT NULL DEFAULT 1,  -- 1 = ativo
    CONSTRAINT fk_contrato_funcionario
        FOREIGN KEY (fk_funcionario)      REFERENCES dim_funcionario(sk_funcionario),
    CONSTRAINT fk_contrato_tempo
        FOREIGN KEY (fk_tempo)            REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_contrato_tempo_emissao
        FOREIGN KEY (fk_tempo_emissao)    REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_contrato_tempo_venc
        FOREIGN KEY (fk_tempo_vencimento) REFERENCES dim_tempo(sk_tempo)
);

-- =====================================================================
-- 4. ÍNDICES
-- =====================================================================

-- fato_folha_rh
CREATE INDEX idx_folha_funcionario ON fato_folha_rh(fk_funcionario);
CREATE INDEX idx_folha_tempo        ON fato_folha_rh(fk_tempo);
CREATE INDEX idx_folha_tipo         ON fato_folha_rh(fk_tipo_folha);

-- fato_desempenho
CREATE INDEX idx_desempenho_aluno      ON fato_desempenho(fk_aluno);
CREATE INDEX idx_desempenho_professor  ON fato_desempenho(fk_professor);
CREATE INDEX idx_desempenho_disciplina ON fato_desempenho(fk_disciplina);
CREATE INDEX idx_desempenho_turma      ON fato_desempenho(fk_turma);
CREATE INDEX idx_desempenho_tempo      ON fato_desempenho(fk_tempo);
CREATE INDEX idx_desempenho_atividade  ON fato_desempenho(fk_tipo_atividade);

-- fato_frequencia
CREATE INDEX idx_freq_aluno ON fato_frequencia(fk_aluno);
CREATE INDEX idx_freq_turma ON fato_frequencia(fk_turma);
CREATE INDEX idx_freq_tempo ON fato_frequencia(fk_tempo);

-- fato_boletim
CREATE INDEX idx_boletim_aluno    ON fato_boletim(fk_aluno);
CREATE INDEX idx_boletim_turma    ON fato_boletim(fk_turma);
CREATE INDEX idx_boletim_tempo    ON fato_boletim(fk_tempo);
CREATE INDEX idx_boletim_situacao ON fato_boletim(fk_situacao);

-- fato_atividade_professor
CREATE INDEX idx_atvprof_professor  ON fato_atividade_professor(fk_professor);
CREATE INDEX idx_atvprof_disciplina ON fato_atividade_professor(fk_disciplina);
CREATE INDEX idx_atvprof_turma      ON fato_atividade_professor(fk_turma);
CREATE INDEX idx_atvprof_tempo      ON fato_atividade_professor(fk_tempo);
CREATE INDEX idx_atvprof_tipo       ON fato_atividade_professor(fk_tipo_atividade);

-- fato_pagamento
CREATE INDEX idx_pgto_aluno  ON fato_pagamento(fk_aluno);
CREATE INDEX idx_pgto_tempo  ON fato_pagamento(fk_tempo);
CREATE INDEX idx_pgto_status ON fato_pagamento(fk_status_pagamento);

-- fato_evasao
CREATE INDEX idx_evasao_aluno ON fato_evasao(fk_aluno);
CREATE INDEX idx_evasao_turma ON fato_evasao(fk_turma);
CREATE INDEX idx_evasao_tempo ON fato_evasao(fk_tempo);
CREATE INDEX idx_evasao_risco ON fato_evasao(fk_risco);

-- fato_contrato_rh
CREATE INDEX idx_contrato_funcionario ON fato_contrato_rh(fk_funcionario);
CREATE INDEX idx_contrato_tempo       ON fato_contrato_rh(fk_tempo);

-- =====================================================================
-- 5. CARGA DA DIM_TEMPO
-- =====================================================================
-- Gera intervalo completo 2020-01-01 a 2030-12-31
-- =====================================================================

SET lc_time_names = 'pt_BR';

INSERT INTO dim_tempo (
    sk_tempo, data_completa, dia, mes, nome_mes, semana_do_ano, ano,
    bimestre, nome_bimestre, eh_feriado, eh_dia_util, eh_periodo_letivo
)
SELECT
    CAST(DATE_FORMAT(d, '%Y%m%d') AS UNSIGNED),
    d,
    DAY(d),
    MONTH(d),
    MONTHNAME(d),
    WEEK(d, 3),
    YEAR(d),
    CASE
        WHEN MONTH(d) BETWEEN 2 AND 4   THEN 1
        WHEN MONTH(d) BETWEEN 5 AND 7   THEN 2
        WHEN MONTH(d) BETWEEN 8 AND 9   THEN 3
        WHEN MONTH(d) BETWEEN 10 AND 12 THEN 4
        ELSE NULL
    END,
    CASE
        WHEN MONTH(d) BETWEEN 2 AND 4   THEN '1º Bimestre'
        WHEN MONTH(d) BETWEEN 5 AND 7   THEN '2º Bimestre'
        WHEN MONTH(d) BETWEEN 8 AND 9   THEN '3º Bimestre'
        WHEN MONTH(d) BETWEEN 10 AND 12 THEN '4º Bimestre'
        ELSE 'Recesso'
    END,
    FALSE,
    CASE WHEN DAYOFWEEK(d) IN (1, 7) THEN FALSE ELSE TRUE END,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM sistema_aurora_edutech.tb_ano_letivo al
            WHERE d BETWEEN al.data_inicio AND al.data_fim
        ) THEN TRUE
        ELSE FALSE
    END
FROM (
    SELECT DATE_ADD('2020-01-01', INTERVAL seq.n DAY) AS d
    FROM (
        SELECT a.n + b.n * 10 + c.n * 100 + d.n * 1000 AS n
        FROM (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL
              SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
              SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
        CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL
                    SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
                    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
        CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL
                    SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL
                    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
        CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL
                    SELECT 3 UNION ALL SELECT 4) d
    ) seq
    WHERE DATE_ADD('2020-01-01', INTERVAL seq.n DAY) <= '2030-12-31'
) datas
ORDER BY d;

-- =====================================================================
-- 6. CARGA DAS DIMENSÕES
-- =====================================================================

-- ---------------------------------------------------------------------
-- dim_aluno
-- Campos derivados:
--   - faixa_etaria: agrupa idade_ingresso em faixas
--   - ano_ingresso: extrai do data_ingresso
--   - idade_valida_matricula: 1 se idade compatível com ensino fundamental
--     (5-12 anos — ajustável conforme regra do negócio)
-- ---------------------------------------------------------------------
INSERT INTO dim_aluno (
    pk_aluno_origem, ra, nome_completo, sexo, data_nascimento,
    nacionalidade, raca, faz_atividade_extracurricular, escola_anterior,
    idade_ingresso, faixa_etaria, ano_ingresso, idade_valida_matricula
)
SELECT
    a.pk_aluno,
    a.ra,
    CONCAT(p.nome, ' ', p.sobrenome),
    p.sexo,
    p.data_nascimento,
    p.nacionalidade,
    p.raca,
    a.faz_atividade_extracurricular,
    tea.descricao,
    TIMESTAMPDIFF(YEAR, p.data_nascimento, a.data_ingresso),
    CASE
        WHEN TIMESTAMPDIFF(YEAR, p.data_nascimento, a.data_ingresso) <= 6  THEN '0-6 anos'
        WHEN TIMESTAMPDIFF(YEAR, p.data_nascimento, a.data_ingresso) <= 10 THEN '7-10 anos'
        WHEN TIMESTAMPDIFF(YEAR, p.data_nascimento, a.data_ingresso) <= 14 THEN '11-14 anos'
        WHEN TIMESTAMPDIFF(YEAR, p.data_nascimento, a.data_ingresso) <= 17 THEN '15-17 anos'
        ELSE '18+ anos'
    END,
    YEAR(a.data_ingresso),
    CASE
        WHEN TIMESTAMPDIFF(YEAR, p.data_nascimento, a.data_ingresso) BETWEEN 5 AND 12 THEN 1
        ELSE 0
    END
FROM sistema_aurora_edutech.tb_aluno a
JOIN sistema_aurora_edutech.tb_pessoa p
    ON a.fk_pessoa = p.pk_pessoa
LEFT JOIN sistema_aurora_edutech.tb_tipo_escola_anterior tea
    ON a.fk_tipo_escola_anterior = tea.pk_tipo_escola_anterior;

-- ---------------------------------------------------------------------
-- dim_funcionario
-- Cargo, tipo_contrato e carga_horaria vêm do contrato mais recente
-- ---------------------------------------------------------------------
INSERT INTO dim_funcionario (
    pk_funcionario_origem, nome_completo, sexo, cargo,
    tipo_contrato, carga_horaria_semanal, ativo
)
SELECT
    f.pk_funcionario,
    CONCAT(p.nome, ' ', p.sobrenome),
    p.sexo,
    ca.nome_cargo,
    tc.descricao,
    ca.carga_horaria_semanal,
    f.ativo
FROM sistema_aurora_edutech.tb_funcionario f
JOIN sistema_aurora_edutech.tb_pessoa p
    ON f.fk_pessoa = p.pk_pessoa
LEFT JOIN (
    SELECT
        con.fk_funcionario,
        con.fk_tipo_contrato,
        con.carga_horaria_semanal,
        cg.nome_cargo,
        ROW_NUMBER() OVER (
            PARTITION BY con.fk_funcionario
            ORDER BY hc.data_inicio DESC
        ) AS rn
    FROM sistema_aurora_edutech.tb_historico_cargo hc
    JOIN sistema_aurora_edutech.tb_contrato con
        ON hc.fk_contrato = con.pk_contrato
    JOIN sistema_aurora_edutech.tb_cargo cg
        ON hc.fk_cargo = cg.pk_cargo
) ca ON ca.fk_funcionario = f.pk_funcionario AND ca.rn = 1
LEFT JOIN sistema_aurora_edutech.tb_tipo_contrato tc
    ON ca.fk_tipo_contrato = tc.pk_tipo_contrato;

-- ---------------------------------------------------------------------
-- dim_professor
-- Formação (nível + curso) vem da formação mais recente
-- ---------------------------------------------------------------------
INSERT INTO dim_professor (
    pk_professor_origem, nome_completo, sexo, usa_rubrica_avaliativa,
    atende_educacao_especial, tipo_aula, nivel_formacao, curso_principal
)
SELECT
    pr.pk_professor,
    CONCAT(p.nome, ' ', p.sobrenome),
    p.sexo,
    pr.utiliza_rubrica_avaliativa,
    pr.atende_educacao_especial,
    ta.descricao,
    nf.descricao,
    fp.curso
FROM sistema_aurora_edutech.tb_professor pr
JOIN sistema_aurora_edutech.tb_funcionario f
    ON pr.fk_funcionario = f.pk_funcionario
JOIN sistema_aurora_edutech.tb_pessoa p
    ON f.fk_pessoa = p.pk_pessoa
LEFT JOIN sistema_aurora_edutech.tb_tipo_aula ta
    ON pr.fk_tipo_aula = ta.pk_tipo_aula
LEFT JOIN (
    SELECT
        fp.fk_professor,
        fp.curso,
        fp.fk_nivel_formacao,
        ROW_NUMBER() OVER (
            PARTITION BY fp.fk_professor
            ORDER BY fp.ano_conclusao DESC
        ) AS rn
    FROM sistema_aurora_edutech.tb_formacao_professor fp
) fp ON fp.fk_professor = pr.pk_professor AND fp.rn = 1
LEFT JOIN sistema_aurora_edutech.tb_nivel_formacao nf
    ON fp.fk_nivel_formacao = nf.pk_nivel_formacao;

-- ---------------------------------------------------------------------
-- dim_disciplina
-- ---------------------------------------------------------------------
INSERT INTO dim_disciplina (
    pk_materia_origem, nome_disciplina, area_conhecimento, ativo
)
SELECT
    m.pk_materia,
    m.nome_materia,
    ac.descricao,
    m.ativo
FROM sistema_aurora_edutech.tb_materia m
JOIN sistema_aurora_edutech.tb_area_conhecimento ac
    ON m.fk_area_conhecimento = ac.pk_area_conhecimento;

-- ---------------------------------------------------------------------
-- dim_turma
-- ---------------------------------------------------------------------
INSERT INTO dim_turma (
    pk_turma_origem, nome_turma, ano_escolar, periodo, ano_letivo, capacidade_maxima
)
SELECT
    t.pk_turma,
    t.nome_turma,
    t.ano_escolar,
    t.periodo,
    al.ano,
    t.capacidade_maxima
FROM sistema_aurora_edutech.tb_turma t
JOIN sistema_aurora_edutech.tb_ano_letivo al
    ON t.fk_ano_letivo = al.pk_ano_letivo;

-- ---------------------------------------------------------------------
-- dim_status_pagamento
-- ---------------------------------------------------------------------
INSERT INTO dim_status_pagamento (pk_status_origem, descricao_status)
SELECT pk_status_pagamento, descricao
FROM sistema_aurora_edutech.tb_status_pagamento;

-- ---------------------------------------------------------------------
-- dim_atividade
-- ---------------------------------------------------------------------
INSERT INTO dim_atividade (pk_tipo_atividade_origem, descricao_atividade)
SELECT pk_tipo_atividade, descricao
FROM sistema_aurora_edutech.tb_tipo_atividade;

-- ---------------------------------------------------------------------
-- dim_folha (lista fixa, baseada no ENUM tb_folha_pagamento.tipo_folha)
-- ---------------------------------------------------------------------
INSERT INTO dim_folha (descricao_folha) VALUES
    ('folha_mensal'),
    ('adiantamento'),
    ('decimo_terceiro'),
    ('rescisao'),
    ('ferias');

-- ---------------------------------------------------------------------
-- dim_risco
-- Cruza tb_tipo_risco_evasao × tb_nivel_risco.
-- ordem_criticidade é derivada do nivel_risco:
--   baixo = 1, medio = 2, alto = 3, critico = 4
-- ---------------------------------------------------------------------
INSERT INTO dim_risco (
    pk_tipo_risco_orig, pk_nivel_risco_orig,
    tipo_risco, nivel_risco, ordem_criticidade
)
SELECT
    tr.pk_tipo_risco_evasao,
    nr.pk_nivel_risco,
    tr.descricao,
    nr.descricao,
    CASE LOWER(nr.descricao)
        WHEN 'baixo'   THEN 1
        WHEN 'medio'   THEN 2
        WHEN 'médio'   THEN 2   -- aceita variação com acento
        WHEN 'alto'    THEN 3
        WHEN 'critico' THEN 4
        ELSE 2                  -- fallback: médio
    END
FROM sistema_aurora_edutech.tb_tipo_risco_evasao tr
CROSS JOIN sistema_aurora_edutech.tb_nivel_risco nr;

-- ---------------------------------------------------------------------
-- dim_situacao
-- Origem: tb_situacao_boletim
-- ---------------------------------------------------------------------
INSERT INTO dim_situacao (pk_situacao_orig, descricao)
SELECT pk_situacao_boletim, descricao
FROM sistema_aurora_edutech.tb_situacao_boletim;

-- =====================================================================
-- 7. CARGA FATO_FOLHA_RH
-- =====================================================================
-- salario_base: vem de tb_historico_salario (salário vigente na data)
-- salario_anterior: LAG sobre o histórico de salário do contrato
-- percentual_aumento: ((salario_base - salario_anterior) / salario_anterior) * 100
-- =====================================================================

INSERT INTO fato_folha_rh (
    fk_funcionario, fk_tempo, fk_tipo_folha, salario_base,
    valor_bruto, valor_liquido, total_creditos, total_descontos,
    salario_anterior, percentual_aumento, motivo_aumento
)
SELECT
    df.sk_funcionario,
    CAST(DATE_FORMAT(fp.data_emissao, '%Y%m%d') AS UNSIGNED),
    dfo.sk_tipo_folha,
    hs.salario_base,

    SUM(CASE WHEN tv.natureza_verba = 'credito' THEN vf.valor ELSE 0 END)          AS valor_bruto,
    SUM(CASE WHEN tv.natureza_verba = 'credito' THEN vf.valor ELSE -vf.valor END)  AS valor_liquido,
    SUM(CASE WHEN tv.natureza_verba = 'credito' THEN vf.valor ELSE 0 END)          AS total_creditos,
    SUM(CASE WHEN tv.natureza_verba = 'debito'  THEN vf.valor ELSE 0 END)          AS total_descontos,

    hs.salario_anterior,
    CASE
        WHEN hs.salario_anterior IS NULL OR hs.salario_anterior = 0 THEN NULL
        ELSE ROUND(((hs.salario_base - hs.salario_anterior) / hs.salario_anterior) * 100, 2)
    END AS percentual_aumento,
    hs.motivo_reajuste

FROM sistema_aurora_edutech.tb_folha_pagamento fp

JOIN sistema_aurora_edutech.tb_contrato con
    ON fp.fk_contrato = con.pk_contrato

JOIN dim_funcionario df
    ON con.fk_funcionario = df.pk_funcionario_origem

JOIN dim_folha dfo
    ON dfo.descricao_folha = fp.tipo_folha

JOIN sistema_aurora_edutech.tb_verba_folha vf
    ON vf.fk_folha_pagamento = fp.pk_folha_pagamento

JOIN sistema_aurora_edutech.tb_tipo_verba tv
    ON vf.fk_tipo_verba = tv.pk_tipo_verba

-- salário vigente na data de emissão + salário anterior (via LAG)
LEFT JOIN (
    SELECT
        fk_contrato,
        salario AS salario_base,
        data_inicio,
        data_fim,
        motivo_reajuste,
        LAG(salario) OVER (PARTITION BY fk_contrato ORDER BY data_inicio) AS salario_anterior
    FROM sistema_aurora_edutech.tb_historico_salario
) hs
    ON hs.fk_contrato = con.pk_contrato
   AND fp.data_emissao >= hs.data_inicio
   AND (hs.data_fim IS NULL OR fp.data_emissao <= hs.data_fim)

GROUP BY
    fp.pk_folha_pagamento, df.sk_funcionario, fp.data_emissao,
    dfo.sk_tipo_folha, hs.salario_base, hs.salario_anterior, hs.motivo_reajuste;

-- =====================================================================
-- 8. CARGA FATO_DESEMPENHO
-- =====================================================================
-- Inclui:
--   - fk_professor, fk_turma (via grade curricular e matrícula)
--   - fk_tipo_atividade
--   - percentual_nota, nota_maxima, peso_atividade
--   - qtd_entregue_no_prazo (1/0)
-- =====================================================================

INSERT INTO fato_desempenho (
    fk_aluno, fk_professor, fk_disciplina, fk_turma, fk_tempo,
    fk_tipo_atividade, valor_nota, nota_maxima, percentual_nota,
    peso_atividade, qtd_entregue_no_prazo
)
SELECT
    da.sk_aluno,
    dp.sk_professor,
    dd.sk_disciplina,
    dt.sk_turma,
    CAST(DATE_FORMAT(ap.data_prevista, '%Y%m%d') AS UNSIGNED),
    datv.sk_tipo_atividade,
    na.valor_nota,
    ap.valor_maximo,
    CASE
        WHEN ap.valor_maximo > 0 AND na.valor_nota IS NOT NULL
            THEN ROUND((na.valor_nota / ap.valor_maximo) * 100, 2)
        ELSE NULL
    END,
    ap.peso,
    CASE WHEN na.entregue_no_prazo THEN 1 ELSE 0 END

FROM sistema_aurora_edutech.tb_nota_atividade na

JOIN sistema_aurora_edutech.tb_matricula m
    ON na.fk_matricula = m.pk_matricula
JOIN dim_aluno da
    ON m.fk_aluno = da.pk_aluno_origem
JOIN dim_turma dt
    ON m.fk_turma = dt.pk_turma_origem

JOIN sistema_aurora_edutech.tb_atividade_professor ap
    ON na.fk_atividade_professor = ap.pk_atividade_professor
JOIN dim_atividade datv
    ON ap.fk_tipo_atividade = datv.pk_tipo_atividade_origem

JOIN sistema_aurora_edutech.tb_grade_curricular gc
    ON ap.fk_grade = gc.pk_grade
JOIN dim_disciplina dd
    ON gc.fk_materia = dd.pk_materia_origem
JOIN dim_professor dp
    ON gc.fk_professor = dp.pk_professor_origem;

-- =====================================================================
-- 9. CARGA FATO_FREQUENCIA
-- =====================================================================
-- Agrega presença/falta/justificada por aluno × turma × dia.
-- presenca    = 1 quando tb_frequencia.presente = TRUE
-- falta       = 1 quando presente = FALSE e justificada = FALSE
-- justificada = 1 quando presente = FALSE e justificada = TRUE
-- =====================================================================

INSERT INTO fato_frequencia (
    fk_aluno, fk_turma, fk_tempo,
    qtd_presenca, qtd_falta, qtd_justificada
)
SELECT
    da.sk_aluno,
    dt.sk_turma,
    CAST(DATE_FORMAT(f.data_aula, '%Y%m%d') AS UNSIGNED),
    SUM(CASE WHEN f.presente = TRUE  THEN 1 ELSE 0 END),
    SUM(CASE WHEN f.presente = FALSE AND f.justificada = FALSE THEN 1 ELSE 0 END),
    SUM(CASE WHEN f.presente = FALSE AND f.justificada = TRUE  THEN 1 ELSE 0 END)
FROM sistema_aurora_edutech.tb_frequencia f
JOIN sistema_aurora_edutech.tb_matricula m
    ON f.fk_matricula = m.pk_matricula
JOIN dim_aluno da
    ON m.fk_aluno = da.pk_aluno_origem
JOIN dim_turma dt
    ON m.fk_turma = dt.pk_turma_origem
GROUP BY
    da.sk_aluno, dt.sk_turma,
    CAST(DATE_FORMAT(f.data_aula, '%Y%m%d') AS UNSIGNED);

-- =====================================================================
-- 10. CARGA FATO_BOLETIM
-- =====================================================================
-- O sk_tempo é resolvido pelo bimestre + ano_letivo da matrícula:
--   usamos o primeiro dia do bimestre correspondente em dim_tempo.
-- Flags derivados da tb_situacao_boletim via JOIN com dim_situacao.
-- =====================================================================

INSERT INTO fato_boletim (
    fk_aluno, fk_turma, fk_tempo, fk_situacao,
    esta_aprovado, esta_reprovado, em_recuperacao
)
SELECT
    da.sk_aluno,
    dt.sk_turma,
    -- sk_tempo = primeiro dia do bimestre no ano letivo da matrícula
    (
        SELECT MIN(tmp.sk_tempo)
        FROM dim_tempo tmp
        WHERE tmp.bimestre = b.bimestre
          AND tmp.ano      = al.ano
    ),
    ds.sk_situacao,
    CASE WHEN LOWER(sb.descricao) LIKE '%aprovad%'  THEN 1 ELSE 0 END,
    CASE WHEN LOWER(sb.descricao) LIKE '%reprovad%' THEN 1 ELSE 0 END,
    CASE WHEN LOWER(sb.descricao) LIKE '%recupera%' THEN 1 ELSE 0 END
FROM sistema_aurora_edutech.tb_boletim b
JOIN sistema_aurora_edutech.tb_matricula m
    ON b.fk_matricula = m.pk_matricula
JOIN sistema_aurora_edutech.tb_ano_letivo al
    ON m.fk_ano_letivo = al.pk_ano_letivo
JOIN sistema_aurora_edutech.tb_situacao_boletim sb
    ON b.fk_situacao_boletim = sb.pk_situacao_boletim
JOIN dim_aluno da
    ON m.fk_aluno = da.pk_aluno_origem
JOIN dim_turma dt
    ON m.fk_turma = dt.pk_turma_origem
JOIN dim_situacao ds
    ON sb.pk_situacao_boletim = ds.pk_situacao_orig;

-- =====================================================================
-- 11. CARGA FATO_ATIVIDADE_PROFESSOR
-- =====================================================================
-- qtd_realizada = 1 por registro (cada linha é uma atividade planejada;
-- a contagem agrupada fica para as queries analíticas).
-- Professor e disciplina vêm via tb_grade_curricular.
-- =====================================================================

INSERT INTO fato_atividade_professor (
    fk_professor, fk_disciplina, fk_turma, fk_tempo,
    fk_tipo_atividade, qtd_realizada
)
SELECT
    dp.sk_professor,
    dd.sk_disciplina,
    dt.sk_turma,
    CAST(DATE_FORMAT(ap.data_prevista, '%Y%m%d') AS UNSIGNED),
    datv.sk_tipo_atividade,
    1  -- cada registro = 1 atividade realizada/planejada
FROM sistema_aurora_edutech.tb_atividade_professor ap
JOIN sistema_aurora_edutech.tb_grade_curricular gc
    ON ap.fk_grade = gc.pk_grade
JOIN dim_professor dp
    ON gc.fk_professor = dp.pk_professor_origem
JOIN dim_disciplina dd
    ON gc.fk_materia = dd.pk_materia_origem
JOIN sistema_aurora_edutech.tb_turma_grade tg
    ON gc.pk_grade = tg.fk_grade
JOIN dim_turma dt
    ON tg.fk_turma = dt.pk_turma_origem
JOIN dim_atividade datv
    ON ap.fk_tipo_atividade = datv.pk_tipo_atividade_origem;

-- =====================================================================
-- 12. CARGA FATO_PAGAMENTO
-- =====================================================================
-- valor_pago: vem de tb_pagamento (soma dos pagamentos vinculados).
-- qtd_dias_atrasado: diferença entre data_pagamento e data_vencimento,
--   quando positiva. Zero se pago em dia ou não pago.
-- fk_tempo aponta para o mês de vencimento da cobrança.
-- =====================================================================

INSERT INTO fato_pagamento (
    fk_aluno, fk_tempo, fk_status_pagamento,
    valor_mensalidade, valor_pago,
    qtd_foi_pago, qtd_foi_atrasado, qtd_dias_atrasado
)
SELECT
    da.sk_aluno,
    CAST(DATE_FORMAT(c.data_vencimento, '%Y%m%d') AS UNSIGNED),
    dsp.sk_status_pagamento,
    c.valor,
    COALESCE(pg.total_pago, 0),
    CASE WHEN pg.total_pago IS NOT NULL AND pg.total_pago > 0 THEN 1 ELSE 0 END,
    CASE WHEN pg.data_pagamento > c.data_vencimento THEN 1 ELSE 0 END,
    CASE
        WHEN pg.data_pagamento > c.data_vencimento
            THEN DATEDIFF(pg.data_pagamento, c.data_vencimento)
        ELSE 0
    END
FROM sistema_aurora_edutech.tb_cobranca c
JOIN sistema_aurora_edutech.tb_matricula m
    ON c.fk_matricula = m.pk_matricula
JOIN dim_aluno da
    ON m.fk_aluno = da.pk_aluno_origem
JOIN sistema_aurora_edutech.tb_status_pagamento sp
    ON c.fk_status_pagamento = sp.pk_status_pagamento
JOIN dim_status_pagamento dsp
    ON sp.pk_status_pagamento = dsp.pk_status_origem
LEFT JOIN (
    SELECT
        fk_cobranca,
        SUM(valor_pago)     AS total_pago,
        MAX(data_pagamento) AS data_pagamento
    FROM sistema_aurora_edutech.tb_pagamento
    GROUP BY fk_cobranca
) pg ON pg.fk_cobranca = c.pk_cobranca;

-- =====================================================================
-- 13. CARGA FATO_EVASAO
-- =====================================================================
-- dias_ate_resolucao: DATEDIFF(data_resolucao, data_alerta). NULL se
--   o alerta ainda não foi resolvido.
-- evadiu: 1 quando o alerta não foi resolvido E a matrícula do aluno
--   está inativa/cancelada — derivado cruzando com tb_matricula.
-- fk_risco: resolve o par (fk_tipo_risco_evasao, fk_nivel_risco)
--   na dim_risco.
-- =====================================================================

INSERT INTO fato_evasao (
    fk_aluno, fk_turma, fk_tempo, fk_risco,
    dias_ate_resolucao, foi_resolvido, evadiu
)
SELECT
    da.sk_aluno,
    dt.sk_turma,
    CAST(DATE_FORMAT(ae.data_alerta, '%Y%m%d') AS UNSIGNED),
    dr.sk_risco,
    CASE
        WHEN ae.data_resolucao IS NOT NULL
            THEN DATEDIFF(ae.data_resolucao, ae.data_alerta)
        ELSE NULL
    END,
    CASE WHEN ae.data_resolucao IS NOT NULL THEN 1 ELSE 0 END,
    -- evadiu = alerta não resolvido + matrícula cancelada/inativa
    CASE
        WHEN ae.data_resolucao IS NULL
         AND EXISTS (
             SELECT 1
             FROM sistema_aurora_edutech.tb_matricula mx
             JOIN sistema_aurora_edutech.tb_status_matricula sm
                 ON mx.fk_status_matricula = sm.pk_status_matricula
             WHERE mx.pk_matricula = ae.fk_matricula
               AND LOWER(sm.descricao) IN ('cancelada', 'inativa', 'evadido')
         )
        THEN 1
        ELSE 0
    END
FROM sistema_aurora_edutech.tb_alerta_evasao ae
JOIN sistema_aurora_edutech.tb_matricula m
    ON ae.fk_matricula = m.pk_matricula
JOIN dim_aluno da
    ON m.fk_aluno = da.pk_aluno_origem
JOIN dim_turma dt
    ON m.fk_turma = dt.pk_turma_origem
JOIN dim_risco dr
    ON ae.fk_tipo_risco_evasao = dr.pk_tipo_risco_orig
   AND ae.fk_nivel_risco       = dr.pk_nivel_risco_orig;

-- =====================================================================
-- 14. CARGA FATO_CONTRATO_RH
-- =====================================================================
-- Granularidade: 1 linha por contrato (foto atual, não histórico).
-- fk_tempo        = sk_tempo do mês de início do contrato (data_inicio).
-- fk_tempo_emissao    = mesmo que fk_tempo (data de início).
-- fk_tempo_vencimento = sk_tempo da data_fim; NULL se indeterminado.
-- contrato_ativo  = 1 quando data_fim IS NULL ou data_fim >= CURDATE().
-- =====================================================================

INSERT INTO fato_contrato_rh (
    fk_funcionario, fk_tempo,
    fk_tempo_emissao, fk_tempo_vencimento,
    salario_base, carga_horaria, contrato_ativo
)
SELECT
    df.sk_funcionario,
    CAST(DATE_FORMAT(con.data_inicio, '%Y%m%d') AS UNSIGNED),
    CAST(DATE_FORMAT(con.data_inicio, '%Y%m%d') AS UNSIGNED),
    CASE
        WHEN con.data_fim IS NOT NULL
            THEN CAST(DATE_FORMAT(con.data_fim, '%Y%m%d') AS UNSIGNED)
        ELSE NULL
    END,
    hs.salario_atual,
    con.carga_horaria_semanal,
    CASE
        WHEN con.data_fim IS NULL OR con.data_fim >= CURDATE() THEN 1
        ELSE 0
    END
FROM sistema_aurora_edutech.tb_contrato con
JOIN dim_funcionario df
    ON con.fk_funcionario = df.pk_funcionario_origem
-- salário atual = registro mais recente em tb_historico_salario
LEFT JOIN (
    SELECT
        fk_contrato,
        salario AS salario_atual,
        ROW_NUMBER() OVER (
            PARTITION BY fk_contrato
            ORDER BY data_inicio DESC
        ) AS rn
    FROM sistema_aurora_edutech.tb_historico_salario
) hs ON hs.fk_contrato = con.pk_contrato AND hs.rn = 1;

-- =====================================================================
-- 15. CONSULTAS DE VERIFICAÇÃO
-- =====================================================================

-- dim_tempo: deve dar 4018 dias; bimestres 1-4 + NULL (janeiro)
SELECT COUNT(*) AS total_dias FROM dim_tempo;
SELECT bimestre, nome_bimestre, COUNT(*) AS qtd
FROM dim_tempo GROUP BY bimestre, nome_bimestre ORDER BY bimestre;

-- Dimensões — amostras
SELECT * FROM dim_aluno            LIMIT 5;
SELECT * FROM dim_funcionario      LIMIT 5;
SELECT * FROM dim_professor        LIMIT 5;
SELECT * FROM dim_disciplina;
SELECT * FROM dim_turma;
SELECT * FROM dim_status_pagamento;
SELECT * FROM dim_atividade;
SELECT * FROM dim_folha;
SELECT * FROM dim_risco    ORDER BY ordem_criticidade, tipo_risco;
SELECT * FROM dim_situacao;

-- Contagens das dimensões novas
SELECT COUNT(*) AS qtd_riscos    FROM dim_risco;
SELECT COUNT(*) AS qtd_situacoes FROM dim_situacao;

-- Contagens das fatos
SELECT COUNT(*) AS qtd_folha               FROM fato_folha_rh;
SELECT COUNT(*) AS qtd_desempenho          FROM fato_desempenho;
SELECT COUNT(*) AS qtd_frequencia          FROM fato_frequencia;
SELECT COUNT(*) AS qtd_boletim             FROM fato_boletim;
SELECT COUNT(*) AS qtd_atividade_professor FROM fato_atividade_professor;
SELECT COUNT(*) AS qtd_pagamento           FROM fato_pagamento;
SELECT COUNT(*) AS qtd_evasao              FROM fato_evasao;
SELECT COUNT(*) AS qtd_contrato_rh         FROM fato_contrato_rh;

-- Sanidade: NULLs inesperados em fato_desempenho
SELECT
    SUM(fk_aluno          IS NULL) AS nulos_aluno,
    SUM(fk_professor      IS NULL) AS nulos_professor,
    SUM(fk_disciplina     IS NULL) AS nulos_disciplina,
    SUM(fk_turma          IS NULL) AS nulos_turma,
    SUM(fk_tipo_atividade IS NULL) AS nulos_tipo_atividade
FROM fato_desempenho;

-- Sanidade: NULLs inesperados em fato_frequencia
SELECT
    SUM(fk_aluno IS NULL) AS nulos_aluno,
    SUM(fk_turma IS NULL) AS nulos_turma,
    SUM(fk_tempo IS NULL) AS nulos_tempo
FROM fato_frequencia;

-- Sanidade: NULLs inesperados em fato_boletim
SELECT
    SUM(fk_aluno    IS NULL) AS nulos_aluno,
    SUM(fk_turma    IS NULL) AS nulos_turma,
    SUM(fk_tempo    IS NULL) AS nulos_tempo,
    SUM(fk_situacao IS NULL) AS nulos_situacao
FROM fato_boletim;

-- Sanidade: NULLs inesperados em fato_evasao
SELECT
    SUM(fk_aluno IS NULL) AS nulos_aluno,
    SUM(fk_turma IS NULL) AS nulos_turma,
    SUM(fk_tempo IS NULL) AS nulos_tempo,
    SUM(fk_risco IS NULL) AS nulos_risco
FROM fato_evasao;

-- Análise: média de % nota por professor
SELECT
    dp.nome_completo,
    ROUND(AVG(fd.percentual_nota), 2) AS media_pct_alunos,
    COUNT(*)                          AS qtd_notas
FROM fato_desempenho fd
JOIN dim_professor dp ON dp.sk_professor = fd.fk_professor
GROUP BY dp.nome_completo
ORDER BY media_pct_alunos DESC;

-- Análise: taxa de evasão por nível de risco
SELECT
    dr.nivel_risco,
    dr.ordem_criticidade,
    COUNT(*)                                    AS total_alertas,
    SUM(fe.foi_resolvido)                       AS resolvidos,
    SUM(fe.evadiu)                              AS evadiram,
    ROUND(SUM(fe.evadiu) / COUNT(*) * 100, 2)  AS pct_evasao
FROM fato_evasao fe
JOIN dim_risco dr ON dr.sk_risco = fe.fk_risco
GROUP BY dr.nivel_risco, dr.ordem_criticidade
ORDER BY dr.ordem_criticidade;

-- Análise: inadimplência por mês
SELECT
    t.ano,
    t.mes,
    t.nome_mes,
    COUNT(*)                             AS total_cobrancas,
    SUM(fp.qtd_foi_pago)                 AS pagas,
    SUM(1 - fp.qtd_foi_pago)            AS nao_pagas,
    ROUND(AVG(fp.qtd_dias_atrasado), 1) AS media_dias_atraso
FROM fato_pagamento fp
JOIN dim_tempo t ON t.sk_tempo = fp.fk_tempo
GROUP BY t.ano, t.mes, t.nome_mes
ORDER BY t.ano, t.mes;

-- Análise: frequência média por turma
SELECT
    dt.nome_turma,
    dt.ano_letivo,
    ROUND(AVG(ff.qtd_presenca),    1) AS media_presencas,
    ROUND(AVG(ff.qtd_falta),       1) AS media_faltas,
    ROUND(AVG(ff.qtd_justificada), 1) AS media_justificadas
FROM fato_frequencia ff
JOIN dim_turma dt ON dt.sk_turma = ff.fk_turma
GROUP BY dt.nome_turma, dt.ano_letivo
ORDER BY dt.ano_letivo, dt.nome_turma;
