-- Created by Redgate Data Modeler (https://datamodeler.redgate-platform.com)
-- Last modification date: 2026-05-09 17:03:31.092


CREATE DATABASE sistema_aurora_edutech;
USE sistema_aurora_edutech;
-- tables
-- Table: tb_alerta_evasao
CREATE TABLE tb_alerta_evasao (
    pk_alerta int  NOT NULL AUTO_INCREMENT,
    fk_matricula int  NOT NULL,
    fk_responsavel_alerta int  NOT NULL,
    fk_tipo_risco_evasao int  NOT NULL,
    fk_nivel_risco int  NOT NULL,
    fk_status_alerta int  NOT NULL,
    data_alerta datetime  NOT NULL DEFAULT current_timestamp,
    descricao text  NULL,
    data_resolucao datetime  NULL,
    observacao_resolucao text  NULL,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_alerta_matricula (fk_matricula,fk_tipo_risco_evasao,data_alerta),
    CHECK (data_resolucao IS NULL OR data_resolucao >= data_alerta),
    CHECK (data_alerta BETWEEN '2000-01-01 00:00:00' AND '2099-12-31 23:59:59'),
    CHECK (   data_resolucao IS NULL OR (observacao_resolucao IS NOT NULL AND CHAR_LENGTH(TRIM(observacao_resolucao)) > 0)),
    CONSTRAINT pk_alerta_evasao PRIMARY KEY (pk_alerta)
);

-- Table: tb_aluno
CREATE TABLE tb_aluno (
    pk_aluno int  NOT NULL AUTO_INCREMENT,
    fk_pessoa int  NOT NULL,
    fk_tipo_escola_anterior int  NULL,
    data_ingresso date  NOT NULL,
    faz_atividade_extracurricular bool  NOT NULL DEFAULT false,
    ra varchar(15)  NOT NULL,
    UNIQUE INDEX uq_aluno_pessoa (fk_pessoa),
    UNIQUE INDEX uq_aluno (ra),
    CHECK (ra REGEXP '^[0-9]+$' ),
    CONSTRAINT pk_aluno PRIMARY KEY (pk_aluno)
);

-- Table: tb_ano_letivo
CREATE TABLE tb_ano_letivo (
    pk_ano_letivo int  NOT NULL AUTO_INCREMENT,
    ano year  NOT NULL,
    data_inicio date  NOT NULL,
    data_fim date  NOT NULL,
    ativo bool  NOT NULL DEFAULT false,
    UNIQUE INDEX uq_ano_letivo_ano (ano),
    CHECK (ano BETWEEN 2000 AND 2099),
    CHECK (data_inicio BETWEEN '2000-01-01' AND '2099-12-31'),
    CHECK (data_fim >= data_inicio),
    CONSTRAINT pk_ano_letivo PRIMARY KEY (pk_ano_letivo)
);

-- Table: tb_area_conhecimento
CREATE TABLE tb_area_conhecimento (
    pk_area_conhecimento int  NOT NULL AUTO_INCREMENT,
    descricao varchar(40)  NOT NULL,
    UNIQUE INDEX uq_area_conhecimento_desc (descricao),
    CONSTRAINT pk_area_conhecimento PRIMARY KEY (pk_area_conhecimento)
);

-- Table: tb_atividade_professor
CREATE TABLE tb_atividade_professor (
    pk_atividade_professor int  NOT NULL AUTO_INCREMENT,
    fk_grade int  NOT NULL,
    fk_tipo_atividade int  NOT NULL,
    nome_atividade varchar(100)  NOT NULL,
    bimestre tinyint  UNSIGNED NOT NULL,
    data_prevista date  NOT NULL,
    peso decimal(4,2)  NOT NULL DEFAULT 1.00,
    valor_maximo decimal(4,2)  NOT NULL DEFAULT 10.00,
    UNIQUE INDEX uq_atividade_grade_nome_bimestre (bimestre,fk_grade,nome_atividade),
    CHECK (( bimestre BETWEEN 1 AND 4 )),
    CHECK (peso > 0 AND peso <= 10),
    CHECK (valor_maximo > 0 AND valor_maximo <= 10),
    CHECK (data_prevista >= '2020-01-01'),
    CONSTRAINT pk_atividade_professor PRIMARY KEY (pk_atividade_professor)
);

-- Table: tb_boletim
CREATE TABLE tb_boletim (
    pk_boletim int  NOT NULL AUTO_INCREMENT,
    fk_matricula int  NOT NULL,
    fk_situacao_boletim int  NOT NULL,
    bimestre tinyint  UNSIGNED NOT NULL,
    UNIQUE INDEX uq_boletim_bimestre (fk_matricula,bimestre),
    CHECK (( bimestre BETWEEN 1 AND 4 )),
    CONSTRAINT pk_boletim PRIMARY KEY (pk_boletim)
);

-- Table: tb_calendario_letivo
CREATE TABLE tb_calendario_letivo (
    pk_calendario int  NOT NULL AUTO_INCREMENT,
    fk_ano_letivo int  NOT NULL,
    data_evento date  NOT NULL,
    tipo_dia enum('util','feriado','recesso')  NOT NULL DEFAULT 'util',
    letivo bool  NOT NULL DEFAULT true,
    UNIQUE INDEX uq_calendario_dia (fk_ano_letivo,data_evento),
    CHECK (data_evento BETWEEN '2000-01-01' AND '2099-12-31'),
    CHECK (tipo_dia != 'util' OR letivo = true),
    CONSTRAINT pk_calendario PRIMARY KEY (pk_calendario)
);

-- Table: tb_cargo
CREATE TABLE tb_cargo (
    pk_cargo int  NOT NULL AUTO_INCREMENT,
    nome_cargo varchar(60)  NOT NULL,
    descricao varchar(200)  NULL,
    ativo bool  NOT NULL DEFAULT true,
    UNIQUE INDEX uq_cargo_nome (nome_cargo),
    CONSTRAINT pk_cargo PRIMARY KEY (pk_cargo)
);

-- Table: tb_contrato
CREATE TABLE tb_contrato (
    pk_contrato int  NOT NULL AUTO_INCREMENT,
    fk_funcionario int  NOT NULL,
    fk_tipo_contrato int  NOT NULL,
    status_contrato enum('ativo','encerrado','suspenso')  NOT NULL DEFAULT 'ativo',
    carga_horaria_semanal tinyint  UNSIGNED NOT NULL,
    data_inicio date  NOT NULL,
    data_fim date  NULL,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (( data_fim IS NULL OR data_fim >= data_inicio )),
    CHECK (carga_horaria_semanal BETWEEN 1 AND 60),
    CONSTRAINT pk_contrato PRIMARY KEY (pk_contrato)
);

-- Table: tb_contrato_financeiro
CREATE TABLE tb_contrato_financeiro (
    pk_contrato_financeiro int  NOT NULL AUTO_INCREMENT,
    fk_matricula int  NOT NULL,
    valor_matricula decimal(10,2)  NOT NULL,
    valor_mensalidade decimal(10,2)  NOT NULL,
    dia_vencimento tinyint  UNSIGNED NOT NULL,
    data_inicio date  NOT NULL,
    data_fim date  NULL,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_contrato_financeiro_matricula (fk_matricula),
    CHECK (( valor_mensalidade > 0 )),
    CHECK (( valor_matricula >= 0 )),
    CHECK (( dia_vencimento BETWEEN 1 AND 28 )),
    CHECK (( data_fim IS NULL OR data_fim >= data_inicio )),
    CHECK (data_inicio BETWEEN '2000-01-01' AND '2099-12-31'),
    CONSTRAINT pk_contrato_financeiro PRIMARY KEY (pk_contrato_financeiro)
);

-- Table: tb_email
CREATE TABLE tb_email (
    pk_email int  NOT NULL AUTO_INCREMENT,
    fk_pessoa int  NOT NULL,
    email varchar(100)  NOT NULL,
    principal bool  NOT NULL DEFAULT false,
    UNIQUE INDEX uq_email (email),
    CHECK (email REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
    CONSTRAINT pk_email PRIMARY KEY (pk_email)
);

-- Table: tb_endereco
CREATE TABLE tb_endereco (
    pk_endereco int  NOT NULL AUTO_INCREMENT,
    fk_pessoa int  NOT NULL,
    cep char(8)  NOT NULL,
    numero varchar(10)  NULL,
    complemento varchar(80)  NULL,
    principal bool  NOT NULL DEFAULT false,
    criado_em timestamp  NOT NULL DEFAULT current_timestamp,
    atualizado_em timestamp  NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    CHECK (CHAR_LENGTH(cep) = 8 AND cep REGEXP '^[0-9]+$'),
    CONSTRAINT pk_endereco PRIMARY KEY (pk_endereco)
);

-- Table: tb_evento_escolar
CREATE TABLE tb_evento_escolar (
    pk_evento int  NOT NULL AUTO_INCREMENT,
    fk_calendario int  NOT NULL,
    titulo_evento varchar(100)  NOT NULL,
    descricao text  NULL,
    hora_inicio time  NULL,
    hora_fim time  NULL,
    CHECK (( hora_fim IS NULL OR hora_fim > hora_inicio )),
    CHECK (CHAR_LENGTH(titulo_evento) > 0),
    CHECK (hora_fim IS NULL OR hora_inicio IS NOT NULL),
    CONSTRAINT pk_evento_escolar PRIMARY KEY (pk_evento)
);

-- Table: tb_folha_pagamento
CREATE TABLE tb_folha_pagamento (
    pk_folha_pagamento int  NOT NULL AUTO_INCREMENT,
    fk_contrato int  NOT NULL,
    tipo_folha enum('folha_mensal','adiantamento','decimo_terceiro','rescisao','ferias')  NOT NULL,
    valor decimal(10,2)  NOT NULL,
    ano year  NOT NULL,
    mes tinyint  UNSIGNED NOT NULL,
    data_emissao date  NOT NULL,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status_folha enum('em_processamento','pendente','pago','cancelado','estornado')  NOT NULL DEFAULT 'em_processamento',
    UNIQUE INDEX uq_contrato_ano_mes (fk_contrato,ano,mes,tipo_folha),
    CHECK (valor >= 0),
    CHECK (mes BETWEEN 1 AND 12),
    CHECK (YEAR(data_emissao) = ano AND MONTH(data_emissao) = mes),
    CONSTRAINT pk_folha_pagamento PRIMARY KEY (pk_folha_pagamento)
);

-- Table: tb_formacao_professor
CREATE TABLE tb_formacao_professor (
    pk_formacao int  NOT NULL AUTO_INCREMENT,
    fk_professor int  NOT NULL,
    fk_nivel_formacao int  NOT NULL,
    curso varchar(100)  NOT NULL,
    instituicao varchar(100)  NOT NULL,
    ano_conclusao year  NOT NULL,
    UNIQUE INDEX tb_formacao_professor_curso (ano_conclusao,fk_nivel_formacao,fk_professor,curso,instituicao),
    CHECK (ano_conclusao BETWEEN 1970 AND 2099),
    CONSTRAINT pk_formacao_professor PRIMARY KEY (pk_formacao)
);

-- Table: tb_funcionario
CREATE TABLE tb_funcionario (
    pk_funcionario int  NOT NULL AUTO_INCREMENT,
    fk_pessoa int  NOT NULL,
    ativo bool  NOT NULL DEFAULT true,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_funcionario_pessoa (fk_pessoa),
    CONSTRAINT pk_funcionario PRIMARY KEY (pk_funcionario)
);

-- Table: tb_grade_curricular
CREATE TABLE tb_grade_curricular (
    pk_grade int  NOT NULL AUTO_INCREMENT,
    fk_turma int  NOT NULL,
    fk_materia int  NOT NULL,
    fk_professor int  NOT NULL,
    data_inicio date  NOT NULL,
    data_fim date  NULL,
    UNIQUE INDEX uq_grade_turma_materia (fk_turma,fk_materia,data_inicio),
    CHECK (( data_fim IS NULL OR data_fim >= data_inicio )),
    CONSTRAINT pk_grade_curricular PRIMARY KEY (pk_grade)
);

-- Table: tb_historico_cargo
CREATE TABLE tb_historico_cargo (
    pk_historico_cargo int  NOT NULL AUTO_INCREMENT,
    fk_contrato int  NOT NULL,
    fk_cargo int  NOT NULL,
    data_inicio date  NOT NULL,
    data_fim date  NULL,
    motivo_mudanca varchar(100)  NULL,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_hist_cargo_vigencia (fk_contrato,fk_cargo,data_inicio),
    CHECK (( data_fim IS NULL OR data_fim >= data_inicio )),
    CONSTRAINT pk_historico_cargo PRIMARY KEY (pk_historico_cargo)
);

-- Table: tb_historico_salario
CREATE TABLE tb_historico_salario (
    pk_historico_salario int  NOT NULL AUTO_INCREMENT,
    fk_contrato int  NOT NULL,
    salario decimal(10,2)  NOT NULL,
    data_inicio date  NOT NULL,
    data_fim date  NULL,
    motivo_reajuste varchar(100)  NULL,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_hist_salario_vigencia (fk_contrato,data_inicio),
    CHECK (( salario > 0 )),
    CHECK (( data_fim IS NULL OR data_fim >= data_inicio )),
    CONSTRAINT pk_historico_salario PRIMARY KEY (pk_historico_salario)
);

-- Table: tb_horario_aula
CREATE TABLE tb_horario_aula (
    pk_horario_aula int  NOT NULL AUTO_INCREMENT,
    fk_grade int  NOT NULL,
    dia_semana enum('segunda','terca','quarta','quinta','sexta')  NOT NULL,
    hora_inicio time  NOT NULL,
    hora_fim time  NOT NULL,
    sala varchar(10)  NULL,
    UNIQUE INDEX uq_horario_grade_dia_hora (fk_grade,dia_semana,hora_inicio),
    CHECK (( hora_fim > hora_inicio )),
    CHECK (sala IS NULL OR CHAR_LENGTH(sala) > 0),
    CONSTRAINT pk_horario_aula PRIMARY KEY (pk_horario_aula)
);

-- Table: tb_materia
CREATE TABLE tb_materia (
    pk_materia int  NOT NULL AUTO_INCREMENT,
    fk_area_conhecimento int  NOT NULL,
    nome_materia varchar(60)  NOT NULL,
    ativo bool  NOT NULL DEFAULT true,
    UNIQUE INDEX uq_materia_nome (nome_materia),
    CONSTRAINT pk_materia PRIMARY KEY (pk_materia)
);

-- Table: tb_matricula
CREATE TABLE tb_matricula (
    pk_matricula int  NOT NULL AUTO_INCREMENT,
    fk_turma int  NOT NULL,
    fk_tipo_ingresso int  NOT NULL,
    fk_status_matricula int  NOT NULL,
    data_matricula date  NOT NULL,
    fk_aluno int  NOT NULL,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_matricula_aluno_turma (fk_aluno,fk_turma),
    CHECK (data_matricula BETWEEN '2000-01-01' AND '2099-12-31'),
    CONSTRAINT pk_matricula PRIMARY KEY (pk_matricula)
);

-- Table: tb_nivel_formacao
CREATE TABLE tb_nivel_formacao (
    pk_nivel_formacao int  NOT NULL AUTO_INCREMENT,
    descricao varchar(40)  NOT NULL,
    UNIQUE INDEX uq_nivel_formacao_desc (descricao),
    CONSTRAINT pk_nivel_formacao PRIMARY KEY (pk_nivel_formacao)
);

-- Table: tb_nivel_risco_evasao
CREATE TABLE tb_nivel_risco_evasao (
    pk_nivel_risco int  NOT NULL AUTO_INCREMENT,
    descricao varchar(30)  NOT NULL,
    ordem tinyint  UNSIGNED NOT NULL,
    UNIQUE INDEX uq_nivel_risco_desc (descricao),
    UNIQUE INDEX uq_nivel_risco_ordem (ordem),
    CHECK (CHAR_LENGTH(descricao) > 0),
    CONSTRAINT pk_nivel_risco_evasao PRIMARY KEY (pk_nivel_risco)
);

-- Table: tb_nota_atividade
CREATE TABLE tb_nota_atividade (
    fk_matricula int  NOT NULL,
    fk_atividade_professor int  NOT NULL,
    valor_nota decimal(4,2)  NULL,
    entregue_no_prazo bool  NOT NULL DEFAULT true,
    criado_em timestamp  NOT NULL DEFAULT current_timestamp,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (( valor_nota IS NULL OR ( valor_nota >= 0 AND valor_nota <= 10 ) )),
    CONSTRAINT pk_nota_atividade PRIMARY KEY (fk_matricula,fk_atividade_professor)
);

-- Table: tb_pagamento
CREATE TABLE tb_pagamento (
    pk_pagamento int  NOT NULL AUTO_INCREMENT,
    fk_contrato_financeiro int  NOT NULL,
    fk_status_pagamento int  NOT NULL,
    valor_pago decimal(10,2)  NULL,
    valor_original decimal(10,2)  NOT NULL,
    data_vencimento date  NOT NULL,
    data_pagamento date  NULL,
    mes_referencia tinyint  UNSIGNED NOT NULL,
    ano_referencia year  NOT NULL,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_pagamento_mes (fk_contrato_financeiro,mes_referencia,ano_referencia),
    CHECK (( mes_referencia BETWEEN 1 AND 12 )),
    CHECK (( valor_pago IS NULL OR valor_pago >= 0 )),
    CHECK (data_vencimento BETWEEN '2000-01-01' AND '2099-12-31'),
    CHECK (ano_referencia BETWEEN 2000 AND 2099),
    CHECK (data_pagamento IS NULL OR data_pagamento >= '2000-01-01'),
    CHECK (valor_original > 0),
    CHECK (data_pagamento IS NULL OR data_pagamento >= data_vencimento - INTERVAL 30 DAY),
    CONSTRAINT pk_pagamento PRIMARY KEY (pk_pagamento)
);

-- Table: tb_pessoa
CREATE TABLE tb_pessoa (
    pk_pessoa int  NOT NULL AUTO_INCREMENT,
    cpf char(11)  NOT NULL,
    rg varchar(11)  NULL,
    nome varchar(30)  NOT NULL,
    sobrenome varchar(40)  NOT NULL,
    sexo enum('masculino','feminino')  NOT NULL DEFAULT 'feminino',
    data_nascimento date  NOT NULL,
    nacionalidade enum('brasileiro','estrangeiro')  NOT NULL DEFAULT 'brasileiro',
    raca enum('branca','negra','parda','amarela')  NOT NULL DEFAULT 'parda',
    criado_em timestamp  NOT NULL DEFAULT current_timestamp,
    atualizado_em timestamp  NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_pessoa_cpf (cpf),
    CHECK (CHAR_LENGTH(cpf) = 11 AND cpf REGEXP '^[0-9]+$'),
    CHECK (rg IS NULL OR (CHAR_LENGTH(rg) BETWEEN 5 AND 15 AND rg REGEXP '^[0-9A-Za-z]+$')),
    CONSTRAINT pk_pessoa PRIMARY KEY (pk_pessoa)
);

-- Table: tb_presenca_aluno
CREATE TABLE tb_presenca_aluno (
    pk_presenca int  NOT NULL AUTO_INCREMENT,
    fk_matricula int  NOT NULL,
    fk_calendario_letivo int  NOT NULL,
    fk_horario_aula int  NOT NULL,
    presenca bool  NOT NULL,
    justificativa varchar(255)  NULL,
    UNIQUE INDEX uq_presenca_dia (fk_matricula,fk_calendario_letivo,fk_horario_aula),
    CHECK (justificativa IS NULL OR CHAR_LENGTH(justificativa) > 0),
    CONSTRAINT pk_presenca_aluno PRIMARY KEY (pk_presenca)
);

-- Table: tb_professor
CREATE TABLE tb_professor (
    pk_professor int  NOT NULL AUTO_INCREMENT,
    fk_funcionario int  NOT NULL,
    fk_tipo_aula int  NULL,
    utiliza_rubrica_avaliativa bool  NOT NULL DEFAULT false,
    atende_educacao_especial bool  NOT NULL DEFAULT false,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_professor_funcionario (fk_funcionario),
    CONSTRAINT pk_professor PRIMARY KEY (pk_professor)
);

-- Table: tb_profissao
CREATE TABLE tb_profissao (
    pk_profissao int  NOT NULL AUTO_INCREMENT,
    profissao varchar(30)  NOT NULL,
    descricao varchar(100)  NOT NULL,
    criado_em timestamp  NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_profissao (profissao),
    CONSTRAINT tb_profissao_pk PRIMARY KEY (pk_profissao)
);

-- Table: tb_profissao_responsavel
CREATE TABLE tb_profissao_responsavel (
    fk_responsavel int  NOT NULL,
    fk_profissao int  NOT NULL,
    ativo bool  NOT NULL DEFAULT true,
    criado_em timestamp  NOT NULL DEFAULT current_timestamp,
    CONSTRAINT tb_profissao_responsavel_pk PRIMARY KEY (fk_responsavel,fk_profissao)
);

-- Table: tb_responsavel
CREATE TABLE tb_responsavel (
    pk_responsavel int  NOT NULL AUTO_INCREMENT,
    fk_pessoa int  NOT NULL,
    criado_em timestamp  NOT NULL DEFAULT current_timestamp,
    atualizado_em timestamp  NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_responsavel_pessoa (fk_pessoa),
    CONSTRAINT pk_responsavel PRIMARY KEY (pk_responsavel)
);

-- Table: tb_responsavel_aluno
CREATE TABLE tb_responsavel_aluno (
    fk_aluno int  NOT NULL,
    fk_responsavel int  NOT NULL,
    responsavel_principal bool  NOT NULL DEFAULT false,
    responsavel_financeiro bool  NOT NULL DEFAULT false,
    pode_retirar bool  NOT NULL DEFAULT false,
    CONSTRAINT pk_responsavel_aluno PRIMARY KEY (fk_aluno,fk_responsavel)
);

-- Table: tb_situacao_boletim
CREATE TABLE tb_situacao_boletim (
    pk_situacao_boletim int  NOT NULL AUTO_INCREMENT,
    descricao varchar(30)  NOT NULL,
    ativo bool  NOT NULL DEFAULT TRUE,
    UNIQUE INDEX uq_situacao_boletim_desc (descricao),
    CHECK (CHAR_LENGTH(descricao) > 0),
    CONSTRAINT pk_situacao_boletim PRIMARY KEY (pk_situacao_boletim)
);

-- Table: tb_status_alerta
CREATE TABLE tb_status_alerta (
    pk_status_alerta int  NOT NULL AUTO_INCREMENT,
    descricao varchar(40)  NOT NULL,
    ativo bool  NOT NULL DEFAULT TRUE,
    UNIQUE INDEX uq_status_alerta_desc (descricao),
    CHECK (CHAR_LENGTH(descricao) > 0),
    CONSTRAINT pk_status_alerta PRIMARY KEY (pk_status_alerta)
);

-- Table: tb_status_matricula
CREATE TABLE tb_status_matricula (
    pk_status_matricula int  NOT NULL AUTO_INCREMENT,
    descricao varchar(30)  NOT NULL,
    UNIQUE INDEX uq_status_matricula_desc (descricao),
    CONSTRAINT pk_status_matricula PRIMARY KEY (pk_status_matricula)
);

-- Table: tb_status_pagamento
CREATE TABLE tb_status_pagamento (
    pk_status_pagamento int  NOT NULL AUTO_INCREMENT,
    descricao varchar(30)  NOT NULL,
    ativo bool  NOT NULL DEFAULT TRUE,
    UNIQUE INDEX uq_status_pagamento_desc (descricao),
    CHECK (CHAR_LENGTH(descricao) > 0),
    CONSTRAINT pk_status_pagamento PRIMARY KEY (pk_status_pagamento)
);

-- Table: tb_telefone
CREATE TABLE tb_telefone (
    pk_telefone int  NOT NULL AUTO_INCREMENT,
    fk_pessoa int  NOT NULL,
    categoria enum('celular','residencial','emergencia')  NOT NULL,
    ddd char(2)  NOT NULL,
    numero varchar(9)  NOT NULL,
    ativo bool  NOT NULL DEFAULT true,
    principal bool  NOT NULL DEFAULT false,
    UNIQUE INDEX uq_ddd_telefone (ddd,numero),
    CHECK (CHAR_LENGTH(ddd) = 2 AND ddd REGEXP '^[0-9]+$'),
    CHECK (CHAR_LENGTH(numero) BETWEEN 8 AND 9 AND numero REGEXP '^[0-9]+$'),
    CONSTRAINT pk_telefone PRIMARY KEY (pk_telefone)
);

-- Table: tb_tipo_atividade
CREATE TABLE tb_tipo_atividade (
    pk_tipo_atividade int  NOT NULL AUTO_INCREMENT,
    descricao varchar(40)  NOT NULL,
    UNIQUE INDEX uq_tipo_atividade_desc (descricao),
    CONSTRAINT pk_tipo_atividade PRIMARY KEY (pk_tipo_atividade)
);

-- Table: tb_tipo_aula
CREATE TABLE tb_tipo_aula (
    pk_tipo_aula int  NOT NULL AUTO_INCREMENT,
    descricao varchar(40)  NOT NULL,
    UNIQUE INDEX uq_tipo_aula_desc (descricao),
    CONSTRAINT pk_tipo_aula PRIMARY KEY (pk_tipo_aula)
);

-- Table: tb_tipo_contrato
CREATE TABLE tb_tipo_contrato (
    pk_tipo_contrato int  NOT NULL AUTO_INCREMENT,
    descricao varchar(30)  NOT NULL,
    UNIQUE INDEX uq_tipo_contrato_desc (descricao),
    CONSTRAINT pk_tipo_contrato PRIMARY KEY (pk_tipo_contrato)
);

-- Table: tb_tipo_escola_anterior
CREATE TABLE tb_tipo_escola_anterior (
    pk_tipo_escola_anterior int  NOT NULL AUTO_INCREMENT,
    descricao varchar(30)  NOT NULL,
    UNIQUE INDEX uq_tipo_escola_anterior_desc (descricao),
    CONSTRAINT pk_tipo_escola_anterior PRIMARY KEY (pk_tipo_escola_anterior)
);

-- Table: tb_tipo_ingresso
CREATE TABLE tb_tipo_ingresso (
    pk_tipo_ingresso int  NOT NULL AUTO_INCREMENT,
    descricao varchar(60)  NOT NULL,
    ativo bool  NOT NULL DEFAULT true,
    UNIQUE INDEX uq_tipo_ingresso_desc (descricao),
    CONSTRAINT pk_tipo_ingresso PRIMARY KEY (pk_tipo_ingresso)
);

-- Table: tb_tipo_risco_evasao
CREATE TABLE tb_tipo_risco_evasao (
    pk_tipo_risco_evasao int  NOT NULL AUTO_INCREMENT,
    descricao varchar(60)  NOT NULL,
    ativo bool  NOT NULL DEFAULT TRUE,
    UNIQUE INDEX uq_tipo_risco_evasao_desc (descricao),
    CHECK (CHAR_LENGTH(descricao) > 0),
    CONSTRAINT pk_tipo_risco_evasao PRIMARY KEY (pk_tipo_risco_evasao)
);

-- Table: tb_tipo_verba
CREATE TABLE tb_tipo_verba (
    pk_tipo_verba int  NOT NULL AUTO_INCREMENT,
    descricao varchar(60)  NOT NULL,
    natureza_verba enum('credito','debito')  NOT NULL,
    ativo bool  NOT NULL DEFAULT TRUE,
    UNIQUE INDEX uq_descricao_verba (descricao),
    CONSTRAINT tb_tipo_verba_pk PRIMARY KEY (pk_tipo_verba)
);

-- Table: tb_turma
CREATE TABLE tb_turma (
    pk_turma int  NOT NULL AUTO_INCREMENT,
    fk_ano_letivo int  NOT NULL,
    nome_turma varchar(10)  NOT NULL,
    ano_escolar tinyint  UNSIGNED NOT NULL,
    periodo enum('manha','tarde')  NOT NULL,
    capacidade_maxima tinyint  UNSIGNED NULL,
    criado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_turma_ano (fk_ano_letivo,nome_turma,periodo),
    CHECK (ano_escolar BETWEEN 1 AND 5),
    CHECK (CHAR_LENGTH(nome_turma) > 0),
    CHECK (capacidade_maxima IS NULL OR capacidade_maxima >= 1),
    CONSTRAINT pk_turma PRIMARY KEY (pk_turma)
);

-- Table: tb_verba_folha
CREATE TABLE tb_verba_folha (
    fk_folha_pagamento int  NOT NULL,
    fk_tipo_verba int  NOT NULL,
    valor decimal(10,2)  NOT NULL,
    referencia varchar(80)  NULL,
    UNIQUE INDEX uq_verba_folha (fk_tipo_verba,fk_folha_pagamento),
    CHECK ( valor >= 0 ),
    CONSTRAINT tb_verba_folha_pk PRIMARY KEY (fk_folha_pagamento,fk_tipo_verba)
);

-- foreign keys
-- Reference: fk_alerta_funcionario (table: tb_alerta_evasao)
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_funcionario FOREIGN KEY fk_alerta_funcionario (fk_responsavel_alerta)
    REFERENCES tb_funcionario (pk_funcionario)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_alerta_matricula (table: tb_alerta_evasao)
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_matricula FOREIGN KEY fk_alerta_matricula (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_alerta_nivel_risco (table: tb_alerta_evasao)
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_nivel_risco FOREIGN KEY fk_alerta_nivel_risco (fk_nivel_risco)
    REFERENCES tb_nivel_risco_evasao (pk_nivel_risco)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_alerta_status (table: tb_alerta_evasao)
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_status FOREIGN KEY fk_alerta_status (fk_status_alerta)
    REFERENCES tb_status_alerta (pk_status_alerta)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_alerta_tipo_risco (table: tb_alerta_evasao)
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_tipo_risco FOREIGN KEY fk_alerta_tipo_risco (fk_tipo_risco_evasao)
    REFERENCES tb_tipo_risco_evasao (pk_tipo_risco_evasao)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_aluno_pessoa (table: tb_aluno)
ALTER TABLE tb_aluno ADD CONSTRAINT fk_aluno_pessoa FOREIGN KEY fk_aluno_pessoa (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_aluno_tipo_escola (table: tb_aluno)
ALTER TABLE tb_aluno ADD CONSTRAINT fk_aluno_tipo_escola FOREIGN KEY fk_aluno_tipo_escola (fk_tipo_escola_anterior)
    REFERENCES tb_tipo_escola_anterior (pk_tipo_escola_anterior)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_atividade_grade (table: tb_atividade_professor)
ALTER TABLE tb_atividade_professor ADD CONSTRAINT fk_atividade_grade FOREIGN KEY fk_atividade_grade (fk_grade)
    REFERENCES tb_grade_curricular (pk_grade)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_atividade_tipo (table: tb_atividade_professor)
ALTER TABLE tb_atividade_professor ADD CONSTRAINT fk_atividade_tipo FOREIGN KEY fk_atividade_tipo (fk_tipo_atividade)
    REFERENCES tb_tipo_atividade (pk_tipo_atividade)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_boletim_matricula (table: tb_boletim)
ALTER TABLE tb_boletim ADD CONSTRAINT fk_boletim_matricula FOREIGN KEY fk_boletim_matricula (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_boletim_situacao (table: tb_boletim)
ALTER TABLE tb_boletim ADD CONSTRAINT fk_boletim_situacao FOREIGN KEY fk_boletim_situacao (fk_situacao_boletim)
    REFERENCES tb_situacao_boletim (pk_situacao_boletim)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_calendario_ano (table: tb_calendario_letivo)
ALTER TABLE tb_calendario_letivo ADD CONSTRAINT fk_calendario_ano FOREIGN KEY fk_calendario_ano (fk_ano_letivo)
    REFERENCES tb_ano_letivo (pk_ano_letivo)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_cont_fin_matricula (table: tb_contrato_financeiro)
ALTER TABLE tb_contrato_financeiro ADD CONSTRAINT fk_cont_fin_matricula FOREIGN KEY fk_cont_fin_matricula (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_contrato_func (table: tb_contrato)
ALTER TABLE tb_contrato ADD CONSTRAINT fk_contrato_func FOREIGN KEY fk_contrato_func (fk_funcionario)
    REFERENCES tb_funcionario (pk_funcionario)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_contrato_tipo (table: tb_contrato)
ALTER TABLE tb_contrato ADD CONSTRAINT fk_contrato_tipo FOREIGN KEY fk_contrato_tipo (fk_tipo_contrato)
    REFERENCES tb_tipo_contrato (pk_tipo_contrato)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_email_pessoa (table: tb_email)
ALTER TABLE tb_email ADD CONSTRAINT fk_email_pessoa FOREIGN KEY fk_email_pessoa (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_endereco_pessoa (table: tb_endereco)
ALTER TABLE tb_endereco ADD CONSTRAINT fk_endereco_pessoa FOREIGN KEY fk_endereco_pessoa (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_evento_calendario (table: tb_evento_escolar)
ALTER TABLE tb_evento_escolar ADD CONSTRAINT fk_evento_calendario FOREIGN KEY fk_evento_calendario (fk_calendario)
    REFERENCES tb_calendario_letivo (pk_calendario)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_folha_contrato (table: tb_folha_pagamento)
ALTER TABLE tb_folha_pagamento ADD CONSTRAINT fk_folha_contrato FOREIGN KEY fk_folha_contrato (fk_contrato)
    REFERENCES tb_contrato (pk_contrato)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_formacao_nivel (table: tb_formacao_professor)
ALTER TABLE tb_formacao_professor ADD CONSTRAINT fk_formacao_nivel FOREIGN KEY fk_formacao_nivel (fk_nivel_formacao)
    REFERENCES tb_nivel_formacao (pk_nivel_formacao)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_formacao_professor (table: tb_formacao_professor)
ALTER TABLE tb_formacao_professor ADD CONSTRAINT fk_formacao_professor FOREIGN KEY fk_formacao_professor (fk_professor)
    REFERENCES tb_professor (pk_professor)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_funcionario_pessoa (table: tb_funcionario)
ALTER TABLE tb_funcionario ADD CONSTRAINT fk_funcionario_pessoa FOREIGN KEY fk_funcionario_pessoa (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_grade_materia (table: tb_grade_curricular)
ALTER TABLE tb_grade_curricular ADD CONSTRAINT fk_grade_materia FOREIGN KEY fk_grade_materia (fk_materia)
    REFERENCES tb_materia (pk_materia)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_grade_professor (table: tb_grade_curricular)
ALTER TABLE tb_grade_curricular ADD CONSTRAINT fk_grade_professor FOREIGN KEY fk_grade_professor (fk_professor)
    REFERENCES tb_professor (pk_professor)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_grade_turma (table: tb_grade_curricular)
ALTER TABLE tb_grade_curricular ADD CONSTRAINT fk_grade_turma FOREIGN KEY fk_grade_turma (fk_turma)
    REFERENCES tb_turma (pk_turma)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_hist_cargo_cargo (table: tb_historico_cargo)
ALTER TABLE tb_historico_cargo ADD CONSTRAINT fk_hist_cargo_cargo FOREIGN KEY fk_hist_cargo_cargo (fk_cargo)
    REFERENCES tb_cargo (pk_cargo)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_hist_cargo_contrato (table: tb_historico_cargo)
ALTER TABLE tb_historico_cargo ADD CONSTRAINT fk_hist_cargo_contrato FOREIGN KEY fk_hist_cargo_contrato (fk_contrato)
    REFERENCES tb_contrato (pk_contrato)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_hist_salario_contrato (table: tb_historico_salario)
ALTER TABLE tb_historico_salario ADD CONSTRAINT fk_hist_salario_contrato FOREIGN KEY fk_hist_salario_contrato (fk_contrato)
    REFERENCES tb_contrato (pk_contrato)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_horario_grade (table: tb_horario_aula)
ALTER TABLE tb_horario_aula ADD CONSTRAINT fk_horario_grade FOREIGN KEY fk_horario_grade (fk_grade)
    REFERENCES tb_grade_curricular (pk_grade)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_materia_area (table: tb_materia)
ALTER TABLE tb_materia ADD CONSTRAINT fk_materia_area FOREIGN KEY fk_materia_area (fk_area_conhecimento)
    REFERENCES tb_area_conhecimento (pk_area_conhecimento)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_matricula_aluno (table: tb_matricula)
ALTER TABLE tb_matricula ADD CONSTRAINT fk_matricula_aluno FOREIGN KEY fk_matricula_aluno (fk_aluno)
    REFERENCES tb_aluno (pk_aluno)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_matricula_status (table: tb_matricula)
ALTER TABLE tb_matricula ADD CONSTRAINT fk_matricula_status FOREIGN KEY fk_matricula_status (fk_status_matricula)
    REFERENCES tb_status_matricula (pk_status_matricula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_matricula_tipo_ingresso (table: tb_matricula)
ALTER TABLE tb_matricula ADD CONSTRAINT fk_matricula_tipo_ingresso FOREIGN KEY fk_matricula_tipo_ingresso (fk_tipo_ingresso)
    REFERENCES tb_tipo_ingresso (pk_tipo_ingresso)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_matricula_turma (table: tb_matricula)
ALTER TABLE tb_matricula ADD CONSTRAINT fk_matricula_turma FOREIGN KEY fk_matricula_turma (fk_turma)
    REFERENCES tb_turma (pk_turma)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_nota_atividade_prof (table: tb_nota_atividade)
ALTER TABLE tb_nota_atividade ADD CONSTRAINT fk_nota_atividade_prof FOREIGN KEY fk_nota_atividade_prof (fk_atividade_professor)
    REFERENCES tb_atividade_professor (pk_atividade_professor)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_nota_matricula (table: tb_nota_atividade)
ALTER TABLE tb_nota_atividade ADD CONSTRAINT fk_nota_matricula FOREIGN KEY fk_nota_matricula (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_pagamento_contrato_fin (table: tb_pagamento)
ALTER TABLE tb_pagamento ADD CONSTRAINT fk_pagamento_contrato_fin FOREIGN KEY fk_pagamento_contrato_fin (fk_contrato_financeiro)
    REFERENCES tb_contrato_financeiro (pk_contrato_financeiro)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_pagamento_status (table: tb_pagamento)
ALTER TABLE tb_pagamento ADD CONSTRAINT fk_pagamento_status FOREIGN KEY fk_pagamento_status (fk_status_pagamento)
    REFERENCES tb_status_pagamento (pk_status_pagamento)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_presenca_calendario (table: tb_presenca_aluno)
ALTER TABLE tb_presenca_aluno ADD CONSTRAINT fk_presenca_calendario FOREIGN KEY fk_presenca_calendario (fk_calendario_letivo)
    REFERENCES tb_calendario_letivo (pk_calendario)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_presenca_horario (table: tb_presenca_aluno)
ALTER TABLE tb_presenca_aluno ADD CONSTRAINT fk_presenca_horario FOREIGN KEY fk_presenca_horario (fk_horario_aula)
    REFERENCES tb_horario_aula (pk_horario_aula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_presenca_matricula (table: tb_presenca_aluno)
ALTER TABLE tb_presenca_aluno ADD CONSTRAINT fk_presenca_matricula FOREIGN KEY fk_presenca_matricula (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_professor_funcionario (table: tb_professor)
ALTER TABLE tb_professor ADD CONSTRAINT fk_professor_funcionario FOREIGN KEY fk_professor_funcionario (fk_funcionario)
    REFERENCES tb_funcionario (pk_funcionario)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_professor_tipo_aula (table: tb_professor)
ALTER TABLE tb_professor ADD CONSTRAINT fk_professor_tipo_aula FOREIGN KEY fk_professor_tipo_aula (fk_tipo_aula)
    REFERENCES tb_tipo_aula (pk_tipo_aula)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_profissao (table: tb_profissao_responsavel)
ALTER TABLE tb_profissao_responsavel ADD CONSTRAINT fk_profissao FOREIGN KEY fk_profissao (fk_profissao)
    REFERENCES tb_profissao (pk_profissao)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_resp_aluno_aluno (table: tb_responsavel_aluno)
ALTER TABLE tb_responsavel_aluno ADD CONSTRAINT fk_resp_aluno_aluno FOREIGN KEY fk_resp_aluno_aluno (fk_aluno)
    REFERENCES tb_aluno (pk_aluno)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_resp_aluno_responsavel (table: tb_responsavel_aluno)
ALTER TABLE tb_responsavel_aluno ADD CONSTRAINT fk_resp_aluno_responsavel FOREIGN KEY fk_resp_aluno_responsavel (fk_responsavel)
    REFERENCES tb_responsavel (pk_responsavel)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_responsavel (table: tb_profissao_responsavel)
ALTER TABLE tb_profissao_responsavel ADD CONSTRAINT fk_responsavel FOREIGN KEY fk_responsavel (fk_responsavel)
    REFERENCES tb_responsavel (pk_responsavel)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_responsavel_pessoa (table: tb_responsavel)
ALTER TABLE tb_responsavel ADD CONSTRAINT fk_responsavel_pessoa FOREIGN KEY fk_responsavel_pessoa (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_telefone_pessoa (table: tb_telefone)
ALTER TABLE tb_telefone ADD CONSTRAINT fk_telefone_pessoa FOREIGN KEY fk_telefone_pessoa (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: fk_turma_ano_letivo (table: tb_turma)
ALTER TABLE tb_turma ADD CONSTRAINT fk_turma_ano_letivo FOREIGN KEY fk_turma_ano_letivo (fk_ano_letivo)
    REFERENCES tb_ano_letivo (pk_ano_letivo)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: tb_verba_folha_tb_folha_pagamento (table: tb_verba_folha)
ALTER TABLE tb_verba_folha ADD CONSTRAINT tb_verba_folha_tb_folha_pagamento FOREIGN KEY tb_verba_folha_tb_folha_pagamento (fk_folha_pagamento)
    REFERENCES tb_folha_pagamento (pk_folha_pagamento)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Reference: tb_verba_folha_tb_tipo_verba (table: tb_verba_folha)
ALTER TABLE tb_verba_folha ADD CONSTRAINT tb_verba_folha_tb_tipo_verba FOREIGN KEY tb_verba_folha_tb_tipo_verba (fk_tipo_verba)
    REFERENCES tb_tipo_verba (pk_tipo_verba)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;




-- TRIGGERS — Aurora EduTech v06
DELIMITER //



CREATE TRIGGER trg_contrato_validar_insert
BEFORE INSERT ON tb_contrato
FOR EACH ROW
BEGIN
    DECLARE v_conflitos INT;
    DECLARE v_ativo     BOOL;

    -- 1. Funcionário deve estar ativo
    SELECT ativo INTO v_ativo
    FROM tb_funcionario
    WHERE pk_funcionario = NEW.fk_funcionario;

    IF v_ativo IS NULL OR v_ativo = FALSE THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Funcionario inativo nao pode ter contrato';
    END IF;

    -- 2. Sem sobreposição de períodos para o mesmo funcionário
    SELECT COUNT(*) INTO v_conflitos
    FROM tb_contrato
    WHERE fk_funcionario = NEW.fk_funcionario
      AND NEW.data_inicio <= COALESCE(data_fim, '9999-12-31')
      AND COALESCE(NEW.data_fim, '9999-12-31') >= data_inicio;

    IF v_conflitos > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Funcionario ja possui contrato com periodo sobreposto';
    END IF;

    -- 3. Consistência status × data_fim
    IF NEW.data_fim IS NOT NULL AND NEW.status_contrato = 'ativo' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contrato com data_fim preenchida nao pode ter status ativo';
    END IF;
    IF NEW.data_fim IS NULL AND NEW.status_contrato != 'ativo' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contrato sem data_fim deve ter status ativo';
    END IF;
END//


CREATE TRIGGER trg_contrato_validar_update
BEFORE UPDATE ON tb_contrato
FOR EACH ROW
BEGIN
    DECLARE v_conflitos INT;
    DECLARE v_ativo     BOOL;

    -- 1. Funcionário ativo (validar apenas se o FK mudou)
    IF NEW.fk_funcionario != OLD.fk_funcionario THEN
        SELECT ativo INTO v_ativo
        FROM tb_funcionario
        WHERE pk_funcionario = NEW.fk_funcionario;

        IF v_ativo IS NULL OR v_ativo = FALSE THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Funcionario inativo nao pode ter contrato';
        END IF;
    END IF;

    -- 2. Sobreposição (validar apenas se datas ou funcionário mudaram)
    IF NEW.fk_funcionario != OLD.fk_funcionario
       OR NEW.data_inicio  != OLD.data_inicio
       OR NOT (NEW.data_fim <=> OLD.data_fim) THEN

        SELECT COUNT(*) INTO v_conflitos
        FROM tb_contrato
        WHERE fk_funcionario = NEW.fk_funcionario
          AND pk_contrato    != NEW.pk_contrato
          AND NEW.data_inicio <= COALESCE(data_fim, '9999-12-31')
          AND COALESCE(NEW.data_fim, '9999-12-31') >= data_inicio;

        IF v_conflitos > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Funcionario ja possui contrato com periodo sobreposto';
        END IF;
    END IF;

    -- 3. Consistência status × data_fim (validar se algum dos dois mudou)
    IF NOT (NEW.data_fim <=> OLD.data_fim)
       OR NEW.status_contrato != OLD.status_contrato THEN

        IF NEW.data_fim IS NOT NULL AND NEW.status_contrato = 'ativo' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Contrato com data_fim preenchida nao pode ter status ativo';
        END IF;
        IF NEW.data_fim IS NULL AND NEW.status_contrato != 'ativo' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Contrato sem data_fim deve ter status ativo';
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 2 — tb_historico_cargo
-- Regras:
--   • Cargo precisa estar ativo para ser atribuído
--   • Datas do cargo dentro do período do contrato
--   • Sem sobreposição de cargos no mesmo contrato
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_hist_cargo_validar_insert
BEFORE INSERT ON tb_historico_cargo
FOR EACH ROW
BEGIN
    DECLARE v_conflitos      INT;
    DECLARE v_cargo_ativo    BOOL;
    DECLARE v_contrato_inicio DATE;
    DECLARE v_contrato_fim    DATE;

    -- 1. Cargo deve estar ativo
    SELECT ativo INTO v_cargo_ativo
    FROM tb_cargo
    WHERE pk_cargo = NEW.fk_cargo;

    IF v_cargo_ativo IS NULL OR v_cargo_ativo = FALSE THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cargo desativado nao pode ser atribuido';
    END IF;

    -- 2. Datas dentro do contrato
    SELECT data_inicio, data_fim
    INTO v_contrato_inicio, v_contrato_fim
    FROM tb_contrato
    WHERE pk_contrato = NEW.fk_contrato;

    IF NEW.data_inicio < v_contrato_inicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'data_inicio do cargo nao pode ser anterior ao inicio do contrato';
    END IF;
    IF v_contrato_fim IS NOT NULL AND NEW.data_inicio > v_contrato_fim THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'data_inicio do cargo nao pode ser posterior ao fim do contrato';
    END IF;
    IF NEW.data_fim IS NOT NULL AND v_contrato_fim IS NOT NULL
       AND NEW.data_fim > v_contrato_fim THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'data_fim do cargo nao pode ultrapassar o fim do contrato';
    END IF;

    -- 3. Sem sobreposição no mesmo contrato
    SELECT COUNT(*) INTO v_conflitos
    FROM tb_historico_cargo
    WHERE fk_contrato  = NEW.fk_contrato
      AND NEW.data_inicio <= COALESCE(data_fim, '9999-12-31')
      AND COALESCE(NEW.data_fim, '9999-12-31') >= data_inicio;

    IF v_conflitos > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contrato ja possui cargo com periodo sobreposto';
    END IF;
END//


CREATE TRIGGER trg_hist_cargo_validar_update
BEFORE UPDATE ON tb_historico_cargo
FOR EACH ROW
BEGIN
    DECLARE v_conflitos      INT;
    DECLARE v_cargo_ativo    BOOL;
    DECLARE v_contrato_inicio DATE;
    DECLARE v_contrato_fim    DATE;

    IF NEW.fk_cargo != OLD.fk_cargo THEN
        SELECT ativo INTO v_cargo_ativo
        FROM tb_cargo
        WHERE pk_cargo = NEW.fk_cargo;

        IF v_cargo_ativo IS NULL OR v_cargo_ativo = FALSE THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cargo desativado nao pode ser atribuido';
        END IF;
    END IF;

    IF NEW.fk_contrato  != OLD.fk_contrato
       OR NEW.data_inicio != OLD.data_inicio
       OR NOT (NEW.data_fim <=> OLD.data_fim) THEN

        SELECT data_inicio, data_fim
        INTO v_contrato_inicio, v_contrato_fim
        FROM tb_contrato
        WHERE pk_contrato = NEW.fk_contrato;

        IF NEW.data_inicio < v_contrato_inicio THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'data_inicio do cargo nao pode ser anterior ao inicio do contrato';
        END IF;
        IF v_contrato_fim IS NOT NULL AND NEW.data_inicio > v_contrato_fim THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'data_inicio do cargo nao pode ser posterior ao fim do contrato';
        END IF;
        IF NEW.data_fim IS NOT NULL AND v_contrato_fim IS NOT NULL
           AND NEW.data_fim > v_contrato_fim THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'data_fim do cargo nao pode ultrapassar o fim do contrato';
        END IF;

        SELECT COUNT(*) INTO v_conflitos
        FROM tb_historico_cargo
        WHERE fk_contrato       = NEW.fk_contrato
          AND pk_historico_cargo != NEW.pk_historico_cargo
          AND NEW.data_inicio <= COALESCE(data_fim, '9999-12-31')
          AND COALESCE(NEW.data_fim, '9999-12-31') >= data_inicio;

        IF v_conflitos > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Contrato ja possui cargo com periodo sobreposto';
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 3 — tb_historico_salario
-- Regras:
--   • Datas do salário dentro do período do contrato
--   • Sem sobreposição de salários no mesmo contrato
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_hist_salario_validar_insert
BEFORE INSERT ON tb_historico_salario
FOR EACH ROW
BEGIN
    DECLARE v_conflitos       INT;
    DECLARE v_contrato_inicio DATE;
    DECLARE v_contrato_fim    DATE;

    SELECT data_inicio, data_fim
    INTO v_contrato_inicio, v_contrato_fim
    FROM tb_contrato
    WHERE pk_contrato = NEW.fk_contrato;

    -- 1. Datas dentro do contrato
    IF NEW.data_inicio < v_contrato_inicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'data_inicio do salario nao pode ser anterior ao inicio do contrato';
    END IF;
    IF v_contrato_fim IS NOT NULL AND NEW.data_inicio > v_contrato_fim THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'data_inicio do salario nao pode ser posterior ao fim do contrato';
    END IF;
    IF NEW.data_fim IS NOT NULL AND v_contrato_fim IS NOT NULL
       AND NEW.data_fim > v_contrato_fim THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'data_fim do salario nao pode ultrapassar o fim do contrato';
    END IF;

    -- 2. Sem sobreposição no mesmo contrato
    SELECT COUNT(*) INTO v_conflitos
    FROM tb_historico_salario
    WHERE fk_contrato  = NEW.fk_contrato
      AND NEW.data_inicio <= COALESCE(data_fim, '9999-12-31')
      AND COALESCE(NEW.data_fim, '9999-12-31') >= data_inicio;

    IF v_conflitos > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contrato ja possui salario com periodo sobreposto';
    END IF;
END//


CREATE TRIGGER trg_hist_salario_validar_update
BEFORE UPDATE ON tb_historico_salario
FOR EACH ROW
BEGIN
    DECLARE v_conflitos       INT;
    DECLARE v_contrato_inicio DATE;
    DECLARE v_contrato_fim    DATE;

    IF NEW.fk_contrato  != OLD.fk_contrato
       OR NEW.data_inicio != OLD.data_inicio
       OR NOT (NEW.data_fim <=> OLD.data_fim) THEN

        SELECT data_inicio, data_fim
        INTO v_contrato_inicio, v_contrato_fim
        FROM tb_contrato
        WHERE pk_contrato = NEW.fk_contrato;

        IF NEW.data_inicio < v_contrato_inicio THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'data_inicio do salario nao pode ser anterior ao inicio do contrato';
        END IF;
        IF v_contrato_fim IS NOT NULL AND NEW.data_inicio > v_contrato_fim THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'data_inicio do salario nao pode ser posterior ao fim do contrato';
        END IF;
        IF NEW.data_fim IS NOT NULL AND v_contrato_fim IS NOT NULL
           AND NEW.data_fim > v_contrato_fim THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'data_fim do salario nao pode ultrapassar o fim do contrato';
        END IF;

        SELECT COUNT(*) INTO v_conflitos
        FROM tb_historico_salario
        WHERE fk_contrato          = NEW.fk_contrato
          AND pk_historico_salario != NEW.pk_historico_salario
          AND NEW.data_inicio <= COALESCE(data_fim, '9999-12-31')
          AND COALESCE(NEW.data_fim, '9999-12-31') >= data_inicio;

        IF v_conflitos > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Contrato ja possui salario com periodo sobreposto';
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 4 — tb_matricula (RN015 — capacidade máxima da turma)
-- Regras:
--   • Turmas com capacidade_maxima definida não podem ultrapassar o limite
--     de matrículas com status 'ativa'
--   • capacidade_maxima NULL = sem limite
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_matricula_capacidade_insert
BEFORE INSERT ON tb_matricula
FOR EACH ROW
BEGIN
    DECLARE v_capacidade TINYINT UNSIGNED;
    DECLARE v_ocupacao   INT;
    DECLARE v_pk_ativa   INT;

    SELECT capacidade_maxima INTO v_capacidade
    FROM tb_turma
    WHERE pk_turma = NEW.fk_turma;

    IF v_capacidade IS NOT NULL THEN
        SELECT pk_status_matricula INTO v_pk_ativa
        FROM tb_status_matricula
        WHERE descricao = 'ativa'
        LIMIT 1;

        SELECT COUNT(*) INTO v_ocupacao
        FROM tb_matricula
        WHERE fk_turma          = NEW.fk_turma
          AND fk_status_matricula = v_pk_ativa;

        IF NEW.fk_status_matricula = v_pk_ativa AND v_ocupacao >= v_capacidade THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Turma atingiu capacidade maxima de alunos ativos';
        END IF;
    END IF;
END//


CREATE TRIGGER trg_matricula_capacidade_update
BEFORE UPDATE ON tb_matricula
FOR EACH ROW
BEGIN
    DECLARE v_capacidade TINYINT UNSIGNED;
    DECLARE v_ocupacao   INT;
    DECLARE v_pk_ativa   INT;

    IF NEW.fk_turma            != OLD.fk_turma
       OR NEW.fk_status_matricula != OLD.fk_status_matricula THEN

        SELECT capacidade_maxima INTO v_capacidade
        FROM tb_turma
        WHERE pk_turma = NEW.fk_turma;

        IF v_capacidade IS NOT NULL THEN
            SELECT pk_status_matricula INTO v_pk_ativa
            FROM tb_status_matricula
            WHERE descricao = 'ativa'
            LIMIT 1;

            SELECT COUNT(*) INTO v_ocupacao
            FROM tb_matricula
            WHERE fk_turma            = NEW.fk_turma
              AND fk_status_matricula  = v_pk_ativa
              AND pk_matricula        != NEW.pk_matricula;

            IF NEW.fk_status_matricula = v_pk_ativa AND v_ocupacao >= v_capacidade THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Turma atingiu capacidade maxima de alunos ativos';
            END IF;
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 5 — tb_ano_letivo
-- Regra: apenas um ano letivo pode estar ativo (ativo = TRUE) por vez
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_ano_letivo_unico_ativo_insert
BEFORE INSERT ON tb_ano_letivo
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.ativo = TRUE THEN
        SELECT COUNT(*) INTO v_count
        FROM tb_ano_letivo
        WHERE ativo = TRUE;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Ja existe um ano letivo ativo. Desative-o antes de ativar outro.';
        END IF;
    END IF;
END//


CREATE TRIGGER trg_ano_letivo_unico_ativo_update
BEFORE UPDATE ON tb_ano_letivo
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.ativo = TRUE AND OLD.ativo = FALSE THEN
        SELECT COUNT(*) INTO v_count
        FROM tb_ano_letivo
        WHERE ativo       = TRUE
          AND pk_ano_letivo != NEW.pk_ano_letivo;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Ja existe um ano letivo ativo. Desative-o antes de ativar outro.';
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 6 — tb_email
-- Regra: cada pessoa pode ter no máximo um e-mail marcado como principal
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_email_principal_insert
BEFORE INSERT ON tb_email
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.principal = TRUE THEN
        SELECT COUNT(*) INTO v_count
        FROM tb_email
        WHERE fk_pessoa = NEW.fk_pessoa
          AND principal = TRUE;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Esta pessoa ja possui um e-mail principal cadastrado';
        END IF;
    END IF;
END//


CREATE TRIGGER trg_email_principal_update
BEFORE UPDATE ON tb_email
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.principal = TRUE AND OLD.principal = FALSE THEN
        SELECT COUNT(*) INTO v_count
        FROM tb_email
        WHERE fk_pessoa = NEW.fk_pessoa
          AND principal = TRUE
          AND pk_email  != NEW.pk_email;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Esta pessoa ja possui um e-mail principal cadastrado';
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 7 — tb_telefone
-- Regra: cada pessoa pode ter no máximo um telefone marcado como principal
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_telefone_principal_insert
BEFORE INSERT ON tb_telefone
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.principal = TRUE THEN
        SELECT COUNT(*) INTO v_count
        FROM tb_telefone
        WHERE fk_pessoa = NEW.fk_pessoa
          AND principal = TRUE;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Esta pessoa ja possui um telefone principal cadastrado';
        END IF;
    END IF;
END//


CREATE TRIGGER trg_telefone_principal_update
BEFORE UPDATE ON tb_telefone
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.principal = TRUE AND OLD.principal = FALSE THEN
        SELECT COUNT(*) INTO v_count
        FROM tb_telefone
        WHERE fk_pessoa  = NEW.fk_pessoa
          AND principal  = TRUE
          AND pk_telefone != NEW.pk_telefone;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Esta pessoa ja possui um telefone principal cadastrado';
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 8 — tb_responsavel_aluno
-- Regra: cada aluno pode ter no máximo um responsável marcado como principal
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_resp_aluno_principal_insert
BEFORE INSERT ON tb_responsavel_aluno
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.responsavel_principal = TRUE THEN
        SELECT COUNT(*) INTO v_count
        FROM tb_responsavel_aluno
        WHERE fk_aluno              = NEW.fk_aluno
          AND responsavel_principal = TRUE;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Este aluno ja possui um responsavel principal cadastrado';
        END IF;
    END IF;
END//


CREATE TRIGGER trg_resp_aluno_principal_update
BEFORE UPDATE ON tb_responsavel_aluno
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    IF NEW.responsavel_principal = TRUE AND OLD.responsavel_principal = FALSE THEN
        SELECT COUNT(*) INTO v_count
        FROM tb_responsavel_aluno
        WHERE fk_aluno              = NEW.fk_aluno
          AND responsavel_principal = TRUE
          AND fk_responsavel        != NEW.fk_responsavel;

        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Este aluno ja possui um responsavel principal cadastrado';
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 9 — tb_presenca_aluno
-- Regra: o horário de aula registrado deve pertencer à mesma turma
--        da matrícula do aluno
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_presenca_valida_turma_insert
BEFORE INSERT ON tb_presenca_aluno
FOR EACH ROW
BEGIN
    DECLARE v_turma_matricula INT;
    DECLARE v_turma_horario   INT;

    SELECT fk_turma INTO v_turma_matricula
    FROM tb_matricula
    WHERE pk_matricula = NEW.fk_matricula;

    SELECT gc.fk_turma INTO v_turma_horario
    FROM tb_horario_aula   ha
    JOIN tb_grade_curricular gc ON gc.pk_grade = ha.fk_grade
    WHERE ha.pk_horario_aula = NEW.fk_horario_aula;

    IF v_turma_matricula != v_turma_horario THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O horario de aula nao pertence a turma da matricula informada';
    END IF;
END//


CREATE TRIGGER trg_presenca_valida_turma_update
BEFORE UPDATE ON tb_presenca_aluno
FOR EACH ROW
BEGIN
    DECLARE v_turma_matricula INT;
    DECLARE v_turma_horario   INT;

    IF NEW.fk_matricula   != OLD.fk_matricula
       OR NEW.fk_horario_aula != OLD.fk_horario_aula THEN

        SELECT fk_turma INTO v_turma_matricula
        FROM tb_matricula
        WHERE pk_matricula = NEW.fk_matricula;

        SELECT gc.fk_turma INTO v_turma_horario
        FROM tb_horario_aula   ha
        JOIN tb_grade_curricular gc ON gc.pk_grade = ha.fk_grade
        WHERE ha.pk_horario_aula = NEW.fk_horario_aula;

        IF v_turma_matricula != v_turma_horario THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O horario de aula nao pertence a turma da matricula informada';
        END IF;
    END IF;
END//


-- ───────────────────────────────────────────────────────────────────────────
-- GRUPO 10 — tb_nota_atividade
-- Regra: a atividade lançada deve pertencer à mesma turma da matrícula do aluno
-- ───────────────────────────────────────────────────────────────────────────

CREATE TRIGGER trg_nota_valida_turma_insert
BEFORE INSERT ON tb_nota_atividade
FOR EACH ROW
BEGIN
    DECLARE v_turma_matricula INT;
    DECLARE v_turma_atividade INT;

    SELECT fk_turma INTO v_turma_matricula
    FROM tb_matricula
    WHERE pk_matricula = NEW.fk_matricula;

    SELECT gc.fk_turma INTO v_turma_atividade
    FROM tb_atividade_professor ap
    JOIN tb_grade_curricular    gc ON gc.pk_grade = ap.fk_grade
    WHERE ap.pk_atividade_professor = NEW.fk_atividade_professor;

    IF v_turma_matricula != v_turma_atividade THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A atividade nao pertence a turma da matricula informada';
    END IF;
END//


CREATE TRIGGER trg_nota_valida_turma_update
BEFORE UPDATE ON tb_nota_atividade
FOR EACH ROW
BEGIN
    DECLARE v_turma_matricula INT;
    DECLARE v_turma_atividade INT;

    IF NEW.fk_matricula          != OLD.fk_matricula
       OR NEW.fk_atividade_professor != OLD.fk_atividade_professor THEN

        SELECT fk_turma INTO v_turma_matricula
        FROM tb_matricula
        WHERE pk_matricula = NEW.fk_matricula;

        SELECT gc.fk_turma INTO v_turma_atividade
        FROM tb_atividade_professor ap
        JOIN tb_grade_curricular    gc ON gc.pk_grade = ap.fk_grade
        WHERE ap.pk_atividade_professor = NEW.fk_atividade_professor;

        IF v_turma_matricula != v_turma_atividade THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A atividade nao pertence a turma da matricula informada';
        END IF;
    END IF;
END//


DELIMITER ;

-- ═══════════════════════════════════════════════════════════════════════════
-- RESUMO — 20 triggers no total (10 grupos × INSERT + UPDATE)
--
-- GRUPO  1 — tb_contrato            → 2 triggers
-- GRUPO  2 — tb_historico_cargo     → 2 triggers
-- GRUPO  3 — tb_historico_salario   → 2 triggers  ← NOVO
-- GRUPO  4 — tb_matricula           → 2 triggers
-- GRUPO  5 — tb_ano_letivo          → 2 triggers  ← NOVO
-- GRUPO  6 — tb_email               → 2 triggers  ← NOVO
-- GRUPO  7 — tb_telefone            → 2 triggers  ← NOVO
-- GRUPO  8 — tb_responsavel_aluno   → 2 triggers  ← NOVO
-- GRUPO  9 — tb_presenca_aluno      → 2 triggers  ← NOVO
-- GRUPO 10 — tb_nota_atividade      → 2 triggers  ← NOVO
--
-- DEPENDÊNCIA DE SEED:
--   tb_status_matricula deve conter um registro com descricao = 'ativa'
--   (exatamente, minúsculo) para que o GRUPO 4 funcione corretamente.
-- ═══════════════════════════════════════════════════════════════════════════
