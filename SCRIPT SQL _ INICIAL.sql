--  SISTEMA AURORA EDUTECH

CREATE DATABASE IF NOT EXISTS sistema_aurora_edutech;
USE sistema_aurora_edutech;


CREATE TABLE tb_pessoa (
  pk_pessoa       INT          NOT NULL AUTO_INCREMENT,
  cpf             CHAR(11)     NOT NULL,
  rg              VARCHAR(11),
  nome_completo   VARCHAR(100) NOT NULL,
  sexo            ENUM('masculino','feminino')              NOT NULL DEFAULT 'feminino',
  data_nascimento DATE NOT NULL,
  nacionalidade   VARCHAR(40)  NOT NULL,
  raca            ENUM('branca','negra','parda','amarela')  NOT NULL DEFAULT 'parda',
  criado_em       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_pessoa     PRIMARY KEY (pk_pessoa),
  CONSTRAINT uq_pessoa_cpf UNIQUE (cpf)
);

CREATE TABLE tb_endereco (
  pk_endereco   INT         NOT NULL AUTO_INCREMENT,
  fk_pessoa     INT         NOT NULL,
  cep           CHAR(8)     NOT NULL,
  numero        VARCHAR(10),
  complemento   VARCHAR(80),
  principal     BOOL        NOT NULL DEFAULT FALSE,
  criado_em     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_endereco        PRIMARY KEY (pk_endereco),
  CONSTRAINT fk_endereco_pessoa FOREIGN KEY (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE tb_email (
  pk_email   INT          NOT NULL AUTO_INCREMENT,
  fk_pessoa  INT          NOT NULL,
  email      VARCHAR(100) NOT NULL,
  principal  BOOL         NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_email        PRIMARY KEY (pk_email),
  CONSTRAINT uq_email        UNIQUE (email),
  CONSTRAINT fk_email_pessoa FOREIGN KEY (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE tb_telefone (
  pk_telefone INT                                        NOT NULL AUTO_INCREMENT,
  fk_pessoa   INT                                        NOT NULL,
  categoria   ENUM('celular','residencial','emergencia') NOT NULL,
  ddd         CHAR(2)                                    NOT NULL,
  numero      VARCHAR(9)                                 NOT NULL,
  ativo       BOOL                                       NOT NULL DEFAULT TRUE,
  principal   BOOL                                       NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_telefone        PRIMARY KEY (pk_telefone),
  CONSTRAINT fk_telefone_pessoa FOREIGN KEY (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Recursos Humanos

CREATE TABLE tb_cargo (
  pk_cargo   INT          NOT NULL AUTO_INCREMENT,
  nome_cargo VARCHAR(60)  NOT NULL,
  descricao  VARCHAR(200),
  ativo      BOOL         NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_cargo      PRIMARY KEY (pk_cargo),
  CONSTRAINT uq_cargo_nome UNIQUE (nome_cargo)
);

CREATE TABLE tb_tipo_contrato (
  pk_tipo_contrato INT         NOT NULL AUTO_INCREMENT,
  descricao        VARCHAR(30) NOT NULL,
  CONSTRAINT pk_tipo_contrato      PRIMARY KEY (pk_tipo_contrato),
  CONSTRAINT uq_tipo_contrato_desc UNIQUE (descricao)
);

CREATE TABLE tb_status_contrato (
  pk_status_contrato INT         NOT NULL AUTO_INCREMENT,
  descricao          VARCHAR(30) NOT NULL,
  CONSTRAINT pk_status_contrato      PRIMARY KEY (pk_status_contrato),
  CONSTRAINT uq_status_contrato_desc UNIQUE (descricao)
);

-- Cardinalidade: tb_pessoa 1 ←→ 1 tb_funcionario
CREATE TABLE tb_funcionario (
  pk_funcionario INT  NOT NULL AUTO_INCREMENT,
  fk_pessoa      INT  NOT NULL,
  ativo          BOOL NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_funcionario        PRIMARY KEY (pk_funcionario),
  CONSTRAINT uq_funcionario_pessoa UNIQUE (fk_pessoa),
  CONSTRAINT fk_funcionario_pessoa FOREIGN KEY (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Cardinalidade: tb_funcionario 1 ←→ N tb_contrato
-- salario e cargo ficam nos históricos, contrato só registra o vínculo.
CREATE TABLE tb_contrato (
  pk_contrato           INT              NOT NULL AUTO_INCREMENT,
  fk_funcionario        INT              NOT NULL,
  fk_tipo_contrato      INT              NOT NULL,
  fk_status_contrato    INT              NOT NULL,
  carga_horaria_semanal TINYINT UNSIGNED NOT NULL,
  data_inicio           DATE             NOT NULL,
  data_fim              DATE,
  CONSTRAINT pk_contrato        PRIMARY KEY (pk_contrato),
  CONSTRAINT fk_contrato_func   FOREIGN KEY (fk_funcionario)
    REFERENCES tb_funcionario (pk_funcionario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_contrato_tipo   FOREIGN KEY (fk_tipo_contrato)
    REFERENCES tb_tipo_contrato (pk_tipo_contrato)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_contrato_status FOREIGN KEY (fk_status_contrato)
    REFERENCES tb_status_contrato (pk_status_contrato)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_datas_contrato CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- aqui ele ta guardano todo reajuste salarial ao longo do contrato!
-- Cardinalidade: tb_contrato 1 ←→ N tb_historico_salario
CREATE TABLE tb_historico_salario (
  pk_historico_salario INT           NOT NULL AUTO_INCREMENT,
  fk_contrato          INT           NOT NULL,
  salario              DECIMAL(10,2) NOT NULL,
  data_inicio          DATE          NOT NULL,
  data_fim             DATE,
  motivo_reajuste      VARCHAR(100),
  CONSTRAINT pk_historico_salario     PRIMARY KEY (pk_historico_salario),
  CONSTRAINT uq_hist_salario_vigencia UNIQUE (fk_contrato, data_inicio),
  CONSTRAINT fk_hist_salario_contrato FOREIGN KEY (fk_contrato)
    REFERENCES tb_contrato (pk_contrato)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_salario_positivo   CHECK (salario > 0),
  CONSTRAINT chk_datas_hist_salario CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

CREATE TABLE tb_historico_cargo (
  pk_historico_cargo INT          NOT NULL AUTO_INCREMENT,
  fk_contrato        INT          NOT NULL,
  fk_cargo           INT          NOT NULL,
  data_inicio        DATE         NOT NULL,
  data_fim           DATE,
  motivo_mudanca     VARCHAR(100),
  CONSTRAINT pk_historico_cargo     PRIMARY KEY (pk_historico_cargo),
  CONSTRAINT uq_hist_cargo_vigencia UNIQUE (fk_contrato, fk_cargo, data_inicio),
  CONSTRAINT fk_hist_cargo_contrato FOREIGN KEY (fk_contrato)
    REFERENCES tb_contrato (pk_contrato)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_hist_cargo_cargo    FOREIGN KEY (fk_cargo)
    REFERENCES tb_cargo (pk_cargo)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_datas_hist_cargo CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);


-- Folha de pagamento

CREATE TABLE tb_tipo_folha (
  pk_tipo_folha INT         NOT NULL AUTO_INCREMENT,
  descricao     VARCHAR(30) NOT NULL,
  CONSTRAINT pk_tipo_folha      PRIMARY KEY (pk_tipo_folha),
  CONSTRAINT uq_tipo_folha_desc UNIQUE (descricao)
);

CREATE TABLE tb_status_folha (
  pk_status_folha INT         NOT NULL AUTO_INCREMENT,
  descricao       VARCHAR(30) NOT NULL,
  CONSTRAINT pk_status_folha      PRIMARY KEY (pk_status_folha),
  CONSTRAINT uq_status_folha_desc UNIQUE (descricao)
);

CREATE TABLE tb_folha_pagamento (
  pk_folha_pagamento INT              NOT NULL AUTO_INCREMENT,
  fk_contrato        INT              NOT NULL,
  fk_tipo_folha      INT              NOT NULL,
  fk_status_folha    INT              NOT NULL,
  mes                TINYINT UNSIGNED NOT NULL,
  ano                YEAR             NOT NULL,
  CONSTRAINT pk_folha_pagamento PRIMARY KEY (pk_folha_pagamento),
  CONSTRAINT uq_folha_periodo   UNIQUE (fk_contrato, fk_tipo_folha, mes, ano),
  CONSTRAINT fk_folha_contrato  FOREIGN KEY (fk_contrato)
    REFERENCES tb_contrato (pk_contrato)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_folha_tipo      FOREIGN KEY (fk_tipo_folha)
    REFERENCES tb_tipo_folha (pk_tipo_folha)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_folha_status    FOREIGN KEY (fk_status_folha)
    REFERENCES tb_status_folha (pk_status_folha)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_mes_folha CHECK (mes BETWEEN 1 AND 12)
);

-- natureza_verba: credito = acréscimo; debito = desconto
CREATE TABLE tb_tipo_verba (
  pk_tipo_verba  INT                      NOT NULL AUTO_INCREMENT,
  descricao      VARCHAR(60)              NOT NULL,
  natureza_verba ENUM('credito','debito') NOT NULL,
  ativo          BOOL                     NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_tipo_verba      PRIMARY KEY (pk_tipo_verba),
  CONSTRAINT uq_tipo_verba_desc UNIQUE (descricao)
);

-- ENTIDADE ASSOCIATIVA N:N — tb_folha_pagamento x tb_tipo_verba
-- Uma folha pode ter várias verbas; uma verba pode aparecer em várias folhas.
CREATE TABLE tb_verba_folha (
  pk_verba_folha INT           NOT NULL AUTO_INCREMENT,
  fk_folha       INT           NOT NULL,
  fk_tipo_verba  INT           NOT NULL,
  valor          DECIMAL(10,2) NOT NULL,
  referencia     VARCHAR(80),
  CONSTRAINT pk_verba_folha       PRIMARY KEY (pk_verba_folha),
  CONSTRAINT uq_verba_folha       UNIQUE (fk_folha, fk_tipo_verba),
  CONSTRAINT fk_verba_folha_folha FOREIGN KEY (fk_folha)
    REFERENCES tb_folha_pagamento (pk_folha_pagamento)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_verba_folha_tipo  FOREIGN KEY (fk_tipo_verba)
    REFERENCES tb_tipo_verba (pk_tipo_verba)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_verba_valor CHECK (valor >= 0)
);


-- Academico

CREATE TABLE tb_ano_letivo (
  pk_ano_letivo INT  NOT NULL AUTO_INCREMENT,
  ano           YEAR NOT NULL,
  data_inicio   DATE NOT NULL,
  data_fim      DATE NOT NULL,
  ativo         BOOL NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_ano_letivo        PRIMARY KEY (pk_ano_letivo),
  CONSTRAINT uq_ano_letivo_ano    UNIQUE (ano),
  CONSTRAINT chk_datas_ano_letivo CHECK (data_fim >= data_inicio)
);

-- Cardinalidade: tb_ano_letivo 1 ←→ N tb_calendario_letivo
CREATE TABLE tb_calendario_letivo (
  pk_calendario INT                                       NOT NULL AUTO_INCREMENT,
  fk_ano_letivo INT                                       NOT NULL,
  data_evento   DATE                                      NOT NULL,
  tipo_dia      ENUM('util','feriado','recesso') NOT NULL DEFAULT 'util',
  letivo        BOOL                                      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_calendario     PRIMARY KEY (pk_calendario),
  CONSTRAINT uq_calendario_dia UNIQUE (fk_ano_letivo, data_evento),
  CONSTRAINT fk_calendario_ano FOREIGN KEY (fk_ano_letivo)
    REFERENCES tb_ano_letivo (pk_ano_letivo)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Cardinalidade: tb_calendario_letivo 1 ←→ N tb_evento_escolar
CREATE TABLE tb_evento_escolar (
  pk_evento     INT          NOT NULL AUTO_INCREMENT,
  fk_calendario INT          NOT NULL,
  titulo_evento VARCHAR(100) NOT NULL,
  descricao     TEXT,
  hora_inicio   TIME,
  hora_fim      TIME,
  CONSTRAINT pk_evento_escolar    PRIMARY KEY (pk_evento),
  CONSTRAINT fk_evento_calendario FOREIGN KEY (fk_calendario)
    REFERENCES tb_calendario_letivo (pk_calendario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_evento_horario CHECK (hora_fim IS NULL OR hora_fim > hora_inicio)
);

-- PROFESSOR E FORMAÇÃO ACADÊMICA

CREATE TABLE tb_tipo_aula (
  pk_tipo_aula INT         NOT NULL AUTO_INCREMENT,
  descricao    VARCHAR(40) NOT NULL,
  CONSTRAINT pk_tipo_aula      PRIMARY KEY (pk_tipo_aula),
  CONSTRAINT uq_tipo_aula_desc UNIQUE (descricao)
);

-- Cardinalidade: tb_funcionario 1 ←→ 1 tb_professor
CREATE TABLE tb_professor (
  pk_professor               INT  NOT NULL AUTO_INCREMENT,
  fk_funcionario             INT  NOT NULL,
  fk_tipo_aula               INT,
  utiliza_rubrica_avaliativa BOOL NOT NULL DEFAULT FALSE,
  atende_educacao_especial   BOOL NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_professor             PRIMARY KEY (pk_professor),
  CONSTRAINT uq_professor_funcionario UNIQUE (fk_funcionario),
  CONSTRAINT fk_professor_funcionario FOREIGN KEY (fk_funcionario)
    REFERENCES tb_funcionario (pk_funcionario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_professor_tipo_aula   FOREIGN KEY (fk_tipo_aula)
    REFERENCES tb_tipo_aula (pk_tipo_aula)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE tb_nivel_formacao (
  pk_nivel_formacao INT         NOT NULL AUTO_INCREMENT,
  descricao         VARCHAR(40) NOT NULL,
  CONSTRAINT pk_nivel_formacao      PRIMARY KEY (pk_nivel_formacao),
  CONSTRAINT uq_nivel_formacao_desc UNIQUE (descricao)
);

-- Cardinalidade: tb_professor 1 ←→ N tb_formacao_professor
CREATE TABLE tb_formacao_professor (
  pk_formacao       INT          NOT NULL AUTO_INCREMENT,
  fk_professor      INT          NOT NULL,
  fk_nivel_formacao INT          NOT NULL,
  curso             VARCHAR(100) NOT NULL,
  instituicao       VARCHAR(100),
  ano_conclusao     YEAR,
  principal         BOOL         NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_formacao_professor PRIMARY KEY (pk_formacao),
  CONSTRAINT fk_formacao_professor FOREIGN KEY (fk_professor)
    REFERENCES tb_professor (pk_professor)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_formacao_nivel     FOREIGN KEY (fk_nivel_formacao)
    REFERENCES tb_nivel_formacao (pk_nivel_formacao)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Aluno

CREATE TABLE tb_tipo_escola_anterior (
  pk_tipo_escola_anterior INT         NOT NULL AUTO_INCREMENT,
  descricao               VARCHAR(30) NOT NULL,
  CONSTRAINT pk_tipo_escola_anterior      PRIMARY KEY (pk_tipo_escola_anterior),
  CONSTRAINT uq_tipo_escola_anterior_desc UNIQUE (descricao)
);

-- Cardinalidade: tb_pessoa 1 ←→ 1 tb_aluno
CREATE TABLE tb_aluno (
  pk_ra                         VARCHAR(15) NOT NULL,
  fk_pessoa                     INT         NOT NULL,
  fk_tipo_escola_anterior       INT,
  data_ingresso                 DATE        NOT NULL,
  faz_atividade_extracurricular BOOL        NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_aluno             PRIMARY KEY (pk_ra),
  CONSTRAINT uq_aluno_pessoa      UNIQUE (fk_pessoa),
  CONSTRAINT fk_aluno_pessoa      FOREIGN KEY (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_aluno_tipo_escola FOREIGN KEY (fk_tipo_escola_anterior)
    REFERENCES tb_tipo_escola_anterior (pk_tipo_escola_anterior)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Responsável 

CREATE TABLE tb_responsavel (
  pk_responsavel INT       NOT NULL AUTO_INCREMENT,
  fk_pessoa      INT       NOT NULL,
  profissao      VARCHAR(100),
  criado_em      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_responsavel        PRIMARY KEY (pk_responsavel),
  CONSTRAINT uq_responsavel_pessoa UNIQUE (fk_pessoa),
  CONSTRAINT fk_responsavel_pessoa FOREIGN KEY (fk_pessoa)
    REFERENCES tb_pessoa (pk_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Cardinalidade: tb_aluno N ←→ N tb_responsavel
CREATE TABLE tb_responsavel_aluno (
  pk_responsavel_aluno   INT         NOT NULL AUTO_INCREMENT,
  fk_ra_aluno            VARCHAR(15) NOT NULL,
  fk_responsavel         INT         NOT NULL,
  responsavel_principal  BOOL        NOT NULL DEFAULT FALSE,
  responsavel_financeiro BOOL        NOT NULL DEFAULT FALSE,
  pode_retirar           BOOL        NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_responsavel_aluno      PRIMARY KEY (pk_responsavel_aluno),
  CONSTRAINT uq_resp_aluno             UNIQUE (fk_ra_aluno, fk_responsavel),
  CONSTRAINT fk_resp_aluno_aluno       FOREIGN KEY (fk_ra_aluno)
    REFERENCES tb_aluno (pk_ra)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_resp_aluno_responsavel FOREIGN KEY (fk_responsavel)
    REFERENCES tb_responsavel (pk_responsavel)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Turma e matricula

-- Cardinalidade: tb_ano_letivo 1 ←→ N tb_turma
CREATE TABLE tb_turma (
  pk_turma          INT                   NOT NULL AUTO_INCREMENT,
  fk_ano_letivo     INT                   NOT NULL,
  nome_turma        VARCHAR(10)           NOT NULL,
  ano_escolar       TINYINT UNSIGNED      NOT NULL,
  periodo           ENUM('manha','tarde') NOT NULL,
  capacidade_maxima TINYINT UNSIGNED,
  CONSTRAINT pk_turma            PRIMARY KEY (pk_turma),
  CONSTRAINT uq_turma_ano        UNIQUE (fk_ano_letivo, nome_turma, periodo),
  CONSTRAINT fk_turma_ano_letivo FOREIGN KEY (fk_ano_letivo)
    REFERENCES tb_ano_letivo (pk_ano_letivo)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_ano_escolar CHECK (ano_escolar BETWEEN 1 AND 9)
);

CREATE TABLE tb_status_matricula (
  pk_status_matricula INT         NOT NULL AUTO_INCREMENT,
  descricao           VARCHAR(30) NOT NULL,
  CONSTRAINT pk_status_matricula      PRIMARY KEY (pk_status_matricula),
  CONSTRAINT uq_status_matricula_desc UNIQUE (descricao)
);

CREATE TABLE tb_tipo_ingresso (
  pk_tipo_ingresso INT         NOT NULL AUTO_INCREMENT,
  descricao        VARCHAR(60) NOT NULL,
  ativo            BOOL        NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_tipo_ingresso      PRIMARY KEY (pk_tipo_ingresso),
  CONSTRAINT uq_tipo_ingresso_desc UNIQUE (descricao)
);

-- Cardinalidade: tb_aluno 1 ←→ N tb_matricula
CREATE TABLE tb_matricula (
  pk_matricula        INT         NOT NULL AUTO_INCREMENT,
  fk_ra_aluno         VARCHAR(15) NOT NULL,
  fk_turma            INT         NOT NULL,
  fk_tipo_ingresso    INT         NOT NULL,
  fk_status_matricula INT         NOT NULL,
  data_matricula      DATE        NOT NULL,
  CONSTRAINT pk_matricula               PRIMARY KEY (pk_matricula),
  CONSTRAINT uq_matricula_aluno_turma   UNIQUE (fk_ra_aluno, fk_turma),
  CONSTRAINT fk_matricula_aluno         FOREIGN KEY (fk_ra_aluno)
    REFERENCES tb_aluno (pk_ra)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_matricula_turma         FOREIGN KEY (fk_turma)
    REFERENCES tb_turma (pk_turma)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_matricula_tipo_ingresso FOREIGN KEY (fk_tipo_ingresso)
    REFERENCES tb_tipo_ingresso (pk_tipo_ingresso)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_matricula_status        FOREIGN KEY (fk_status_matricula)
    REFERENCES tb_status_matricula (pk_status_matricula)
    ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Grade curricular

CREATE TABLE tb_area_conhecimento (
  pk_area_conhecimento INT         NOT NULL AUTO_INCREMENT,
  descricao            VARCHAR(40) NOT NULL,
  CONSTRAINT pk_area_conhecimento      PRIMARY KEY (pk_area_conhecimento),
  CONSTRAINT uq_area_conhecimento_desc UNIQUE (descricao)
);

-- Cardinalidade: tb_area_conhecimento 1 ←→ N tb_materia
CREATE TABLE tb_materia (
  pk_materia           INT         NOT NULL AUTO_INCREMENT,
  fk_area_conhecimento INT         NOT NULL,
  nome_materia         VARCHAR(60) NOT NULL,
  ativo                BOOL        NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_materia      PRIMARY KEY (pk_materia),
  CONSTRAINT uq_materia_nome UNIQUE (nome_materia),
  CONSTRAINT fk_materia_area FOREIGN KEY (fk_area_conhecimento)
    REFERENCES tb_area_conhecimento (pk_area_conhecimento)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Vincula professor a uma turma em uma matéria específica.
-- tb_turma N ←→ N tb_professor (via tb_grade_curricular)
CREATE TABLE tb_grade_curricular (
  pk_grade     INT  NOT NULL AUTO_INCREMENT,
  fk_turma     INT  NOT NULL,
  fk_materia   INT  NOT NULL,
  fk_professor INT  NOT NULL,
  data_inicio  DATE NOT NULL,
  data_fim     DATE,
  CONSTRAINT pk_grade_curricular    PRIMARY KEY (pk_grade),
  CONSTRAINT uq_grade_turma_materia UNIQUE (fk_turma, fk_materia, data_inicio),
  CONSTRAINT fk_grade_turma         FOREIGN KEY (fk_turma)
    REFERENCES tb_turma (pk_turma)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_grade_materia       FOREIGN KEY (fk_materia)
    REFERENCES tb_materia (pk_materia)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_grade_professor     FOREIGN KEY (fk_professor)
    REFERENCES tb_professor (pk_professor)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_datas_grade CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- Cardinalidade: tb_grade_curricular 1 ←→ N tb_horario_aula
CREATE TABLE tb_horario_aula (
  pk_horario_aula INT                                              NOT NULL AUTO_INCREMENT,
  fk_grade        INT                                              NOT NULL,
  dia_semana      ENUM('segunda','terca','quarta','quinta','sexta') NOT NULL,
  hora_inicio     TIME                                             NOT NULL,
  hora_fim        TIME                                             NOT NULL,
  sala            VARCHAR(10),
  CONSTRAINT pk_horario_aula           PRIMARY KEY (pk_horario_aula),
  CONSTRAINT uq_horario_grade_dia_hora UNIQUE (fk_grade, dia_semana, hora_inicio),
  CONSTRAINT fk_horario_grade          FOREIGN KEY (fk_grade)
    REFERENCES tb_grade_curricular (pk_grade)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_horario_valido CHECK (hora_fim > hora_inicio)
);

-- Atividades e notas

CREATE TABLE tb_tipo_atividade (
  pk_tipo_atividade INT         NOT NULL AUTO_INCREMENT,
  descricao         VARCHAR(40) NOT NULL,
  CONSTRAINT pk_tipo_atividade      PRIMARY KEY (pk_tipo_atividade),
  CONSTRAINT uq_tipo_atividade_desc UNIQUE (descricao)
);

-- atividade criada pelo professor dentro de uma grade/matéria
CREATE TABLE tb_atividade_professor (
  pk_atividade_professor INT              NOT NULL AUTO_INCREMENT,
  fk_grade               INT              NOT NULL,
  fk_tipo_atividade      INT              NOT NULL,
  nome_atividade         VARCHAR(100)     NOT NULL,
  bimestre               TINYINT UNSIGNED NOT NULL,
  data_prevista          DATE             NOT NULL,
  peso                   DECIMAL(4,2)     NOT NULL DEFAULT 1.00,
  valor_maximo           DECIMAL(4,2)     NOT NULL DEFAULT 10.00,
  CONSTRAINT pk_atividade_professor  PRIMARY KEY (pk_atividade_professor),
  CONSTRAINT fk_atividade_grade      FOREIGN KEY (fk_grade)
    REFERENCES tb_grade_curricular (pk_grade)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_atividade_tipo       FOREIGN KEY (fk_tipo_atividade)
    REFERENCES tb_tipo_atividade (pk_tipo_atividade)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_bimestre_ativ      CHECK (bimestre BETWEEN 1 AND 4),
  CONSTRAINT chk_peso_ativ          CHECK (peso > 0),
  CONSTRAINT chk_valor_maximo_ativ  CHECK (valor_maximo > 0)
);

-- Nota do aluno (via matrícula) em cada atividade
-- Cardinalidade: tb_matricula N ←→ N tb_atividade_professor
CREATE TABLE tb_nota_atividade (
  pk_nota_atividade      INT         NOT NULL AUTO_INCREMENT,
  fk_matricula           INT         NOT NULL,
  fk_atividade_professor INT         NOT NULL,
  valor_nota             DECIMAL(4,2),
  entregue_no_prazo      BOOL        NOT NULL DEFAULT TRUE,
  data_lancamento        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_nota_atividade       PRIMARY KEY (pk_nota_atividade),
  CONSTRAINT uq_nota_aluno_atividade UNIQUE (fk_matricula, fk_atividade_professor),
  CONSTRAINT fk_nota_matricula       FOREIGN KEY (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_nota_atividade_prof  FOREIGN KEY (fk_atividade_professor)
    REFERENCES tb_atividade_professor (pk_atividade_professor)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_valor_nota CHECK (valor_nota IS NULL OR (valor_nota >= 0 AND valor_nota <= 10))
);

-- Frequência

CREATE TABLE tb_presenca_aluno (
  pk_presenca     INT         NOT NULL AUTO_INCREMENT,
  fk_matricula    INT         NOT NULL,
  fk_calendario   INT         NOT NULL,
  fk_horario_aula INT         NOT NULL,
  presenca        BOOL        NOT NULL,
  justificativa   VARCHAR(255),
  CONSTRAINT pk_presenca_aluno      PRIMARY KEY (pk_presenca),
  CONSTRAINT uq_presenca_dia        UNIQUE (fk_matricula, fk_calendario, fk_horario_aula),
  CONSTRAINT fk_presenca_matricula  FOREIGN KEY (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_presenca_calendario FOREIGN KEY (fk_calendario)
    REFERENCES tb_calendario_letivo (pk_calendario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_presenca_horario    FOREIGN KEY (fk_horario_aula)
    REFERENCES tb_horario_aula (pk_horario_aula)
    ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Boletim

CREATE TABLE tb_situacao_boletim (
  pk_situacao_boletim INT         NOT NULL AUTO_INCREMENT,
  descricao           VARCHAR(30) NOT NULL,
  CONSTRAINT pk_situacao_boletim      PRIMARY KEY (pk_situacao_boletim),
  CONSTRAINT uq_situacao_boletim_desc UNIQUE (descricao)
);

CREATE TABLE tb_boletim (
  pk_boletim          INT              NOT NULL AUTO_INCREMENT,
  fk_matricula        INT              NOT NULL,
  fk_situacao_boletim INT              NOT NULL,
  bimestre            TINYINT UNSIGNED NOT NULL,
  CONSTRAINT pk_boletim           PRIMARY KEY (pk_boletim),
  CONSTRAINT uq_boletim_bimestre  UNIQUE (fk_matricula, bimestre),
  CONSTRAINT fk_boletim_matricula FOREIGN KEY (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_boletim_situacao  FOREIGN KEY (fk_situacao_boletim)
    REFERENCES tb_situacao_boletim (pk_situacao_boletim)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_bimestre_boletim CHECK (bimestre BETWEEN 1 AND 4)
);

-- Contrato e pagamento aluno

CREATE TABLE tb_contrato_financeiro (
  pk_contrato_financeiro INT           NOT NULL AUTO_INCREMENT,
  fk_matricula           INT           NOT NULL,
  valor_matricula        DECIMAL(10,2) NOT NULL,
  valor_mensalidade      DECIMAL(10,2) NOT NULL,
  dia_vencimento         TINYINT       NOT NULL,
  data_inicio            DATE          NOT NULL,
  data_fim               DATE,
  CONSTRAINT pk_contrato_financeiro           PRIMARY KEY (pk_contrato_financeiro),
  CONSTRAINT uq_contrato_financeiro_matricula UNIQUE (fk_matricula),
  CONSTRAINT fk_cont_fin_matricula            FOREIGN KEY (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_valor_mensalidade CHECK (valor_mensalidade > 0),
  CONSTRAINT chk_valor_matricula   CHECK (valor_matricula >= 0),
  CONSTRAINT chk_dia_vencimento    CHECK (dia_vencimento BETWEEN 1 AND 28),
  CONSTRAINT chk_datas_cont_fin    CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

CREATE TABLE tb_status_pagamento (
  pk_status_pagamento INT         NOT NULL AUTO_INCREMENT,
  descricao           VARCHAR(30) NOT NULL,
  CONSTRAINT pk_status_pagamento      PRIMARY KEY (pk_status_pagamento),
  CONSTRAINT uq_status_pagamento_desc UNIQUE (descricao)
);

-- Cardinalidade: tb_contrato_financeiro 1 ←→ N tb_pagamento
CREATE TABLE tb_pagamento (
  pk_pagamento           INT              NOT NULL AUTO_INCREMENT,
  fk_contrato_financeiro INT              NOT NULL,
  fk_status_pagamento    INT              NOT NULL,
  valor_cobrado          DECIMAL(10,2)    NOT NULL,
  valor_pago             DECIMAL(10,2),
  data_vencimento        DATE             NOT NULL,
  data_pagamento         DATE,
  mes_referencia         TINYINT UNSIGNED NOT NULL,
  ano_referencia         YEAR             NOT NULL,
  CONSTRAINT pk_pagamento              PRIMARY KEY (pk_pagamento),
  CONSTRAINT uq_pagamento_mes          UNIQUE (fk_contrato_financeiro, mes_referencia, ano_referencia),
  CONSTRAINT fk_pagamento_contrato_fin FOREIGN KEY (fk_contrato_financeiro)
    REFERENCES tb_contrato_financeiro (pk_contrato_financeiro)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pagamento_status       FOREIGN KEY (fk_status_pagamento)
    REFERENCES tb_status_pagamento (pk_status_pagamento)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_mes_pagamento CHECK (mes_referencia BETWEEN 1 AND 12),
  CONSTRAINT chk_valor_cobrado CHECK (valor_cobrado > 0),
  CONSTRAINT chk_valor_pago    CHECK (valor_pago IS NULL OR valor_pago >= 0)
);

-- Alerta de Evasão

-- Cardinalidade: tb_nivel_risco_evasao 1 ←→ N tb_alerta_evasao
CREATE TABLE tb_nivel_risco_evasao (
  pk_nivel_risco INT         NOT NULL AUTO_INCREMENT,
  descricao      VARCHAR(30) NOT NULL,
  ordem          TINYINT     NOT NULL,
  CONSTRAINT pk_nivel_risco_evasao PRIMARY KEY (pk_nivel_risco),
  CONSTRAINT uq_nivel_risco_desc   UNIQUE (descricao),
  CONSTRAINT uq_nivel_risco_ordem  UNIQUE (ordem)
);

-- Cardinalidade: tb_status_alerta 1 ←→ N tb_alerta_evasao
CREATE TABLE tb_status_alerta (
  pk_status_alerta INT         NOT NULL AUTO_INCREMENT,
  descricao        VARCHAR(40) NOT NULL,
  CONSTRAINT pk_status_alerta      PRIMARY KEY (pk_status_alerta),
  CONSTRAINT uq_status_alerta_desc UNIQUE (descricao)
);

-- Cardinalidade: tb_tipo_risco_evasao 1 ←→ N tb_alerta_evasao
CREATE TABLE tb_tipo_risco_evasao (
  pk_tipo_risco_evasao INT         NOT NULL AUTO_INCREMENT,
  descricao            VARCHAR(60) NOT NULL,
  ativo                BOOL        NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_tipo_risco_evasao      PRIMARY KEY (pk_tipo_risco_evasao),
  CONSTRAINT uq_tipo_risco_evasao_desc UNIQUE (descricao)
);

CREATE TABLE tb_alerta_evasao (
  pk_alerta             INT      NOT NULL AUTO_INCREMENT,
  fk_matricula          INT      NOT NULL,
  fk_responsavel_alerta INT      NOT NULL,
  fk_tipo_risco_evasao  INT      NOT NULL,
  fk_nivel_risco        INT      NOT NULL,
  fk_status_alerta      INT      NOT NULL,
  data_alerta           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  descricao             TEXT,
  data_resolucao        DATETIME,
  observacao_resolucao  TEXT,
  CONSTRAINT pk_alerta_evasao      PRIMARY KEY (pk_alerta),
  CONSTRAINT fk_alerta_matricula   FOREIGN KEY (fk_matricula)
    REFERENCES tb_matricula (pk_matricula)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_alerta_funcionario FOREIGN KEY (fk_responsavel_alerta)
    REFERENCES tb_funcionario (pk_funcionario)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_alerta_tipo_risco  FOREIGN KEY (fk_tipo_risco_evasao)
    REFERENCES tb_tipo_risco_evasao (pk_tipo_risco_evasao)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_alerta_nivel_risco FOREIGN KEY (fk_nivel_risco)
    REFERENCES tb_nivel_risco_evasao (pk_nivel_risco)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_alerta_status      FOREIGN KEY (fk_status_alerta)
    REFERENCES tb_status_alerta (pk_status_alerta)
    ON DELETE RESTRICT ON UPDATE CASCADE
);