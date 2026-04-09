-- ==============================================================
-- BLOCO 1 — PESSOA E CONTATOS
-- ==============================================================

CREATE DATABASE sistema_aurora_edutech;
USE sistema_aurora_edutech;

CREATE TABLE `tb_pessoa` (
  `pk_id_pessoa`    INT           PRIMARY KEY AUTO_INCREMENT,
  `cpf`             CHAR(11)      UNIQUE NOT NULL,
  `rg`              VARCHAR(11),
  `nome_completo`   VARCHAR(100)  NOT NULL,
  `sexo`            ENUM('masculino','feminino','nao_informado') NOT NULL DEFAULT 'nao_informado',
  `data_nascimento` DATE,
  `nacionalidade`   VARCHAR(40)   DEFAULT 'Brasileira',
  `raca`            ENUM('Branca','Preta','Parda','Amarela','Indigena','Nao_informado') NOT NULL DEFAULT 'Nao_informado',
  `criado_em`       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em`   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Cardinalidade: 1 pessoa → N endereços
CREATE TABLE `tb_endereco` (
  `pk_id_endereco`  INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_pessoa`    INT           NOT NULL,
  `cep`             CHAR(8)       NOT NULL,
  `numero`          VARCHAR(10),
  `complemento`     VARCHAR(80),
  `principal`       BOOL          NOT NULL DEFAULT FALSE,
  `criado_em`       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em`   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Cardinalidade: 1 pessoa → N emails
CREATE TABLE `tb_email` (
  `pk_id_email`   INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_pessoa`  INT           NOT NULL,
  `email`         VARCHAR(100)  UNIQUE NOT NULL,
  `principal`     BOOL          NOT NULL DEFAULT FALSE
);

-- Cardinalidade: 1 pessoa → N telefones
CREATE TABLE `tb_telefone` (
  `pk_id_telefone`  INT         PRIMARY KEY AUTO_INCREMENT,
  `fk_id_pessoa`    INT         NOT NULL,
  `ddd`             CHAR(2)     NOT NULL,
  `numero`          VARCHAR(9)  NOT NULL,
  `categoria`       ENUM('celular','residencial','trabalho','outro') NOT NULL DEFAULT 'celular',
  `ativo`           BOOL        NOT NULL DEFAULT TRUE,
  `principal`       BOOL        NOT NULL DEFAULT FALSE
);

-- ==============================================================
-- BLOCO 2 — ANO LETIVO E CALENDÁRIO
-- ==============================================================

CREATE TABLE `tb_ano_letivo` (
  `pk_id_ano_letivo`  INT   PRIMARY KEY AUTO_INCREMENT,
  `ano`               YEAR  UNIQUE NOT NULL,
  `data_inicio`       DATE  NOT NULL,
  `data_fim`          DATE  NOT NULL,
  `ativo`             BOOL  NOT NULL DEFAULT FALSE
);

CREATE TABLE `tb_calendario_letivo` (
  `pk_id_calendario`  INT   PRIMARY KEY AUTO_INCREMENT,
  `fk_id_ano_letivo`  INT   NOT NULL,
  `data_evento`       DATE  NOT NULL,
  `tipo_dia`          ENUM('Aula','Feriado','Recesso','Ferias','Planejamento') NOT NULL,
  `letivo`            BOOL  NOT NULL DEFAULT TRUE,
  UNIQUE KEY `uq_calendario_data_tipo` (`fk_id_ano_letivo`, `data_evento`, `tipo_dia`)
);

-- Cardinalidade: 1 dia do calendário → N eventos
CREATE TABLE `tb_evento_escolar` (
  `pk_id_evento`      INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_calendario`  INT           NOT NULL,
  `titulo_evento`     VARCHAR(100)  NOT NULL,
  `descricao`         TEXT,
  `hora_inicio`       TIME,
  `hora_fim`          TIME,
  `publico_alvo`      ENUM('Alunos','Professores','Responsaveis','Geral') NOT NULL DEFAULT 'Geral'
);

-- ==============================================================
-- BLOCO 3 — FUNCIONÁRIOS, CARGOS E CONTRATOS
-- ==============================================================

CREATE TABLE `tb_funcionario` (
  `pk_id_funcionario` INT PRIMARY KEY AUTO_INCREMENT,
  `fk_id_pessoa`      INT NOT NULL UNIQUE
);

CREATE TABLE `tb_cargo` (
  `pk_id_cargo`   INT           PRIMARY KEY AUTO_INCREMENT,
  `nome_cargo`    VARCHAR(50)   UNIQUE NOT NULL,
  `descricao`     VARCHAR(200),
  `ativo`         BOOL          NOT NULL DEFAULT TRUE
);

-- Cardinalidade: 1 funcionário → N contratos
CREATE TABLE `tb_contrato` (
  `pk_id_contrato`          INT             PRIMARY KEY AUTO_INCREMENT,
  `fk_id_funcionario`       INT             NOT NULL,
  `status`                  ENUM('ativo','encerrado','suspenso') NOT NULL,
  `tipo_contrato`           ENUM('CLT','PJ','Temporario','Estagio') NOT NULL DEFAULT 'CLT',
  `carga_horaria_semanal`   TINYINT UNSIGNED,
  `salario`                 DECIMAL(10,2)   NOT NULL,
  `data_inicio`             DATE            NOT NULL,
  `data_fim`                DATE
);

-- ENTIDADE ASSOCIATIVA: contrato ↔ cargo
CREATE TABLE `tb_historico_cargo` (
  `pk_id_historico_cargo` INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_contrato`        INT           NOT NULL,
  `fk_id_cargo`           INT           NOT NULL,
  `data_inicio`           DATE          NOT NULL,
  `data_fim`              DATE,
  `motivo_mudanca`        VARCHAR(100),
  UNIQUE KEY `uq_cargo_vigencia` (`fk_id_contrato`, `fk_id_cargo`, `data_inicio`)
);

-- Ponto/frequência de funcionários
-- tiramos as horas_trabalhadas pq eh derivável de hora_entrada/hora_saida
CREATE TABLE `tb_ponto_funcionario` (
  `pk_id_ponto`       INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_funcionario` INT           NOT NULL,
  `fk_id_calendario`  INT           NOT NULL,
  `hora_entrada`      TIME,
  `hora_saida`        TIME,
  `horas_extras`      DECIMAL(4,2)  NOT NULL DEFAULT 0.00,
  `tipo_ocorrencia`   ENUM('Presenca_Normal','Falta_Justificada','Falta_Injustificada','Atraso','Hora_Extra') NOT NULL,
  UNIQUE KEY `uq_ponto_dia` (`fk_id_funcionario`, `fk_id_calendario`)
);

-- Cardinalidade: 1 funcionário → N folhas
CREATE TABLE `tb_folha_pagamento` (
  `pk_id_folha_pagamento` INT             PRIMARY KEY AUTO_INCREMENT,
  `fk_id_funcionario`     INT             NOT NULL,
  `fk_id_contrato`        INT             NOT NULL,
  `salario_base`          DECIMAL(10,2)   NOT NULL,
  `total_extras`          DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  `total_descontos`       DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  `salario_final`         DECIMAL(10,2)   NOT NULL,
  `tipo_folha`            ENUM('mensal','ferias','decimo_terceiro') NOT NULL,
  `status_pagamento`      ENUM('pago','pendente','cancelado') NOT NULL DEFAULT 'pendente',
  `quantidade_faltas`     TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `mes`                   TINYINT UNSIGNED NOT NULL,
  `ano`                   YEAR             NOT NULL,
  UNIQUE KEY `uq_folha_periodo` (`fk_id_funcionario`, `tipo_folha`, `mes`, `ano`)
);

-- ==============================================================
-- BLOCO 4 — PROFESSORES
-- ==============================================================

CREATE TABLE `tb_professor` (
  `pk_id_professor`             INT   PRIMARY KEY AUTO_INCREMENT,
  `fk_id_funcionario`           INT   NOT NULL UNIQUE,
  `tipo_aula_predominante`      ENUM('Expositiva','Pratica_Lab','Metodologias_Ativas','Mista'),
  `utiliza_rubrica_avaliativa`  BOOL  NOT NULL DEFAULT FALSE,
  `atende_educacao_especial`    BOOL  NOT NULL DEFAULT FALSE
);

-- Cardinalidade: 1 professor → N formações
CREATE TABLE `tb_formacao_professor` (
  `pk_id_formacao`    INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_professor`   INT           NOT NULL,
  `nivel`             ENUM('Magisterio','Graduacao','Pos_Graduacao','Mestrado','Doutorado') NOT NULL,
  `curso`             VARCHAR(100)  NOT NULL,
  `instituicao`       VARCHAR(100),
  `ano_conclusao`     YEAR,
  `principal`         BOOL          NOT NULL DEFAULT FALSE
);

-- ==============================================================
-- BLOCO 5 — RESPONSÁVEIS
-- ==============================================================

CREATE TABLE `tb_responsavel` (
  `pk_id_responsavel`   INT   PRIMARY KEY AUTO_INCREMENT,
  `fk_id_pessoa`        INT   NOT NULL UNIQUE,
  `renda_faixa`         ENUM(
                          'Ate_1_salario',
                          'De_1_a_2_salarios',
                          'De_2_a_5_salarios',
                          'De_5_a_10_salarios',
                          'Acima_10_salarios',
                          'Nao_informado'
                        ) NOT NULL DEFAULT 'Nao_informado',
  `nivel_escolaridade`  ENUM(
                          'Sem_escolaridade',
                          'Fundamental_incompleto',
                          'Fundamental_completo',
                          'Medio_incompleto',
                          'Medio_completo',
                          'Superior_incompleto',
                          'Superior_completo',
                          'Pos_graduacao',
                          'Nao_informado'
                        ) NOT NULL DEFAULT 'Nao_informado',
  `profissao`           VARCHAR(100),
  `estado_civil`        ENUM('Solteiro','Casado','Divorciado','Viuvo','Uniao_estavel','Outro'),
  `situacao_emprego`    ENUM('Empregado_CLT','Autonomo','Desempregado','Aposentado','Outro'),
  `criado_em`           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Histórico de contatos com responsável
CREATE TABLE `tb_contato_responsavel` (
  `pk_id_contato`       INT       PRIMARY KEY AUTO_INCREMENT,
  `fk_id_responsavel`   INT       NOT NULL,
  `fk_ra_aluno`         VARCHAR(15) NOT NULL,
  `fk_registrado_por`   INT       NOT NULL,
  `data_contato`        DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_contato`        ENUM('Telefone','WhatsApp','Email','Reuniao_presencial','Recado_agenda') NOT NULL,
  `motivo`              ENUM('Frequencia','Desempenho','Comportamento','Financeiro','Evasao','Outro') NOT NULL,
  `descricao`           TEXT,
  `resultado`           ENUM('Atendido','Nao_atendido','Prometeu_comparecer','Sem_retorno') NOT NULL
);

-- ==============================================================
-- BLOCO 6 — ALUNOS
-- ==============================================================

CREATE TABLE `tb_aluno` (
  `ra`                              VARCHAR(15)  PRIMARY KEY,
  `fk_id_pessoa`                    INT          NOT NULL UNIQUE,
  `data_ingresso`                   DATE         NOT NULL,
  `escola_anterior`                 ENUM('Publica','Privada','Nenhuma') NOT NULL DEFAULT 'Nenhuma',
  `faz_atividade_extracurricular`   BOOL         NOT NULL DEFAULT FALSE
);

-- Cardinalidade: 1 aluno → 1 ficha de saúde
CREATE TABLE `tb_ficha_saude` (
  `pk_id_ficha`             INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_ra_aluno`             VARCHAR(15)   UNIQUE NOT NULL,
  `possui_alergia`          BOOL          NOT NULL DEFAULT FALSE,
  `descricao_alergia`       VARCHAR(255),
  `faz_medicacao_continua`  BOOL          NOT NULL DEFAULT FALSE,
  `descricao_medicacao`     VARCHAR(255),
  `condicao_cronica`        VARCHAR(255),
  `contato_emergencia`      VARCHAR(100)  NOT NULL,
  `telefone_emergencia`     VARCHAR(11)   NOT NULL
);

-- Cardinalidade: 1 aluno → N laudos
CREATE TABLE `tb_laudo` (
  `pk_id_laudo`           INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_ra_aluno`           VARCHAR(15)   NOT NULL,
  `tipo_necessidade`      ENUM('TEA','TDAH','Def_Visual','Def_Auditiva','Def_Motora',
                               'Dislexia','Altas_Habilidades','Outro') NOT NULL,
  `cid`                   VARCHAR(10),
  `documento_anexo_url`   VARCHAR(255),
  `data_emissao`          DATE,
  `ativo`                 BOOL          NOT NULL DEFAULT TRUE
);

-- ENTIDADE ASSOCIATIVA: aluno ↔ responsável (N:N)
CREATE TABLE `tb_responsavel_aluno` (
  `pk_id_responsavel_aluno` INT         PRIMARY KEY AUTO_INCREMENT,
  `fk_ra_aluno`             VARCHAR(15) NOT NULL,
  `fk_id_responsavel`       INT         NOT NULL,
  `responsavel_principal`   BOOL        NOT NULL DEFAULT FALSE,
  `responsavel_financeiro`  BOOL        NOT NULL DEFAULT FALSE,
  `pode_retirar`            BOOL        NOT NULL DEFAULT FALSE,
  `meio_transporte`         ENUM('propria','escolar','a_pe','outro'),
  `parentesco`              ENUM('Pai','Mae','Avo','Ava','Tio','Tia','Irmao','Irma','Responsavel_legal','Outro'),
  UNIQUE KEY `uq_resp_aluno` (`fk_ra_aluno`, `fk_id_responsavel`)
);

-- ==============================================================
-- BLOCO 7 — ESTRUTURA PEDAGÓGICA
-- ==============================================================

CREATE TABLE `tb_turma` (
  `pk_id_turma`                   INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_ano_letivo`              INT           NOT NULL,
  `nome_turma`                    VARCHAR(10)   NOT NULL,
  `ano_escolar`                   TINYINT UNSIGNED NOT NULL,
  `periodo`                       ENUM('manha','tarde') NOT NULL,
  `sala_numero`                   TINYINT UNSIGNED,
  `capacidade_maxima`             TINYINT UNSIGNED,
  `nivel_dificuldade_pedagogica`  ENUM('baixo','medio','alto'),
  `indice_conflito_social`        ENUM('baixo','medio','alto'),
  UNIQUE KEY `uq_turma_ano` (`fk_id_ano_letivo`, `nome_turma`, `periodo`)
);

CREATE TABLE `tb_materia` (
  `pk_id_materia`     INT         PRIMARY KEY AUTO_INCREMENT,
  `nome_materia`      VARCHAR(60) UNIQUE NOT NULL,
  `area_conhecimento` ENUM('Linguagens','Exatas','Humanas','Ciencias','Arte','Educacao_Fisica') NOT NULL
);

-- ENTIDADE ASSOCIATIVA: turma ↔ matéria ↔ professor (grade atual)
CREATE TABLE `tb_grade_curricular` (
  `pk_id_grade`       INT   PRIMARY KEY AUTO_INCREMENT,
  `fk_id_turma`       INT   NOT NULL,
  `fk_id_materia`     INT   NOT NULL,
  `fk_id_professor`   INT   NOT NULL,
  `data_inicio`       DATE  NOT NULL,
  `data_fim`          DATE,
  UNIQUE KEY `uq_grade_turma_materia` (`fk_id_turma`, `fk_id_materia`, `data_inicio`)
);

-- Histórico de mudanças de professor na grade
CREATE TABLE `tb_historico_grade` (
  `pk_id_historico_grade` INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_grade`           INT           NOT NULL,
  `fk_id_professor`       INT           NOT NULL,
  `data_inicio`           DATE          NOT NULL,
  `data_fim`              DATE,
  `motivo_mudanca`        VARCHAR(100),
  UNIQUE KEY `uq_hist_grade_vigencia` (`fk_id_grade`, `fk_id_professor`, `data_inicio`)
);

-- ==============================================================
-- BLOCO 8 — MATRÍCULAS
-- ==============================================================

CREATE TABLE `tb_tipo_ingresso` (
  `pk_id_tipo_ingresso` INT         PRIMARY KEY AUTO_INCREMENT,
  `nome_tipo`           VARCHAR(50) UNIQUE NOT NULL,
  `descricao`           VARCHAR(200),
  `ativo`               BOOL        NOT NULL DEFAULT TRUE
);

-- Cardinalidade: 1 aluno → N matrículas (histórico por ano letivo)
CREATE TABLE `tb_matricula` (
  `pk_id_matricula`         INT             PRIMARY KEY AUTO_INCREMENT,
  `fk_ra_aluno`             VARCHAR(15)     NOT NULL,
  `fk_id_turma`             INT             NOT NULL,
  `fk_id_tipo_ingresso`     INT             NOT NULL,
  `status_matricula`        ENUM('ativa','trancada','encerrada','transferida') NOT NULL DEFAULT 'ativa',
  `resultado_final`         ENUM('Em_curso','Aprovado','Reprovado','Evadido','Transferido') NOT NULL DEFAULT 'Em_curso',
  `motivo_evasao`           ENUM(
                              'Financeiro',
                              'Mudanca_de_cidade',
                              'Conflito_escolar',
                              'Problemas_de_saude',
                              'Desinteresse',
                              'Trabalho_infantil',
                              'Outros'
                            ),
  `valor_mensalidade`       DECIMAL(10,2)   NOT NULL,
  `data_matricula`          DATE            NOT NULL,
  `observacao_pedagogica`   TEXT,
  UNIQUE KEY `uq_matricula_aluno_turma` (`fk_ra_aluno`, `fk_id_turma`)
);

-- ==============================================================
-- BLOCO 9 — AVALIAÇÕES E DESEMPENHO
-- ==============================================================

-- Cardinalidade: 1 grade → N atividades
-- colocamos o bimestre q eh necessário para associar atividade ao bimestre correto
CREATE TABLE `tb_atividade_professor` (
  `pk_id_atividade_professor` INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_grade`               INT           NOT NULL,
  `nome_atividade`            VARCHAR(100)  NOT NULL,
  `tipo_atividade`            ENUM('prova','trabalho','exercicio','projeto','seminario') NOT NULL,
  `bimestre`                  TINYINT UNSIGNED NOT NULL,
  `data_prevista`             DATE          NOT NULL,
  `peso`                      DECIMAL(4,2)  NOT NULL DEFAULT 1.00,
  `valor_maximo`              DECIMAL(4,2)  NOT NULL DEFAULT 10.00
);

-- ENTIDADE ASSOCIATIVA: matrícula ↔ atividade
CREATE TABLE `tb_nota_atividade` (
  `pk_id_nota_atividade`        INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_matricula`             INT           NOT NULL,
  `fk_id_atividade_professor`   INT           NOT NULL,
  `valor_nota`                  DECIMAL(4,2),
  `entregue_no_prazo`           BOOL          NOT NULL DEFAULT TRUE,
  `data_lancamento`             TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_nota_aluno_atividade` (`fk_id_matricula`, `fk_id_atividade_professor`)
);

-- ENTIDADE ASSOCIATIVA: matrícula ↔ grade ↔ bimestre
CREATE TABLE `tb_desempenho_academico` (
  `pk_id_desempenho`    INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_matricula`     INT           NOT NULL,
  `fk_id_grade`         INT           NOT NULL,
  `bimestre`            TINYINT UNSIGNED NOT NULL,
  `nota_final`          DECIMAL(4,2),
  `faltas`              TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `parecer_descritivo`  TEXT,
  UNIQUE KEY `uq_desempenho` (`fk_id_matricula`, `fk_id_grade`, `bimestre`)
);

-- ENTIDADE ASSOCIATIVA: matrícula ↔ bimestre (consolidação do boletim)
-- Mantida como tabela: situacao é definida pela coordenação
CREATE TABLE `tb_boletim` (
  `pk_id_boletim`   INT             PRIMARY KEY AUTO_INCREMENT,
  `fk_id_matricula` INT             NOT NULL,
  `bimestre`        TINYINT UNSIGNED NOT NULL,
  `media_geral`     DECIMAL(4,2),
  `total_faltas`    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `situacao`        ENUM('Em_curso','Aprovado','Reprovado','Risco') NOT NULL DEFAULT 'Em_curso',
  UNIQUE KEY `uq_boletim_bimestre` (`fk_id_matricula`, `bimestre`)
);

-- ==============================================================
-- BLOCO 10 — FREQUÊNCIA DE ALUNOS
-- ==============================================================

CREATE TABLE `tb_presenca_aluno` (
  `pk_id_presenca`    INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_matricula`   INT           NOT NULL,
  `fk_id_calendario`  INT           NOT NULL,
  `presenca`          BOOL          NOT NULL,
  `justificativa`     VARCHAR(255),
  UNIQUE KEY `uq_presenca_dia` (`fk_id_matricula`, `fk_id_calendario`)
);

-- ==============================================================
-- BLOCO 11 — OCORRÊNCIAS DISCIPLINARES
-- ==============================================================

CREATE TABLE `tb_ocorrencia` (
  `pk_id_ocorrencia`  INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_matricula`   INT           NOT NULL,
  `fk_id_funcionario` INT           NOT NULL,
  `tipo_ocorrencia`   ENUM('Comportamento','Bullying','Vandalismo','Agressao','Outros') NOT NULL,
  `gravidade`         ENUM('leve','moderada','grave') NOT NULL,
  `data_ocorrencia`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `descricao`         TEXT          NOT NULL,
  `foi_resolvido`     BOOL          NOT NULL DEFAULT FALSE,
  `data_resolucao`    DATETIME
);

-- ==============================================================
-- BLOCO 12 — ALERTAS DE EVASÃO
-- ==============================================================

-- REMOVIDO: fk_ra_aluno (redundante — acessível via fk_id_matricula → tb_matricula.fk_ra_aluno)
CREATE TABLE `tb_alerta_evasao` (
  `pk_id_alerta`          INT           PRIMARY KEY AUTO_INCREMENT,
  `fk_id_matricula`       INT           NOT NULL,
  `fk_responsavel_alerta` INT           NOT NULL,
  `data_alerta`           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_risco`            ENUM(
                            'Faltas_excessivas',
                            'Queda_de_desempenho',
                            'Inadimplencia',
                            'Ocorrencias_repetidas',
                            'Sem_contato_responsavel',
                            'Multiplos_fatores'
                          ) NOT NULL,
  `nivel_risco`           ENUM('baixo','medio','alto','critico') NOT NULL,
  `descricao`             TEXT,
  `status_alerta`         ENUM('aberto','em_acompanhamento','resolvido','evadiu') NOT NULL DEFAULT 'aberto',
  `data_resolucao`        DATETIME,
  `observacao_resolucao`  TEXT
);

-- ==============================================================
-- BLOCO 13 — PAGAMENTOS
-- ==============================================================

CREATE TABLE `tb_pagamento` (
  `pk_id_pagamento`   INT             PRIMARY KEY AUTO_INCREMENT,
  `fk_id_matricula`   INT             NOT NULL,
  `valor`             DECIMAL(10,2)   NOT NULL,
  `valor_pago`        DECIMAL(10,2),
  `data_vencimento`   DATE            NOT NULL,
  `data_pagamento`    DATE,
  `status`            ENUM('pendente','pago','atrasado','cancelado','estornado') NOT NULL DEFAULT 'pendente',
  `metodo`            ENUM('pix','cartao_credito','cartao_debito','boleto','dinheiro','transferencia'),
  `mes_referencia`    TINYINT UNSIGNED NOT NULL,
  `ano_referencia`    YEAR             NOT NULL,
  UNIQUE KEY `uq_pagamento_mes` (`fk_id_matricula`, `mes_referencia`, `ano_referencia`)
);

-- ==============================================================
-- FOREIGN KEYS — todas com ON DELETE RESTRICT ON UPDATE CASCADE
-- ==============================================================

-- Pessoa / Contatos
ALTER TABLE `tb_endereco`
  ADD FOREIGN KEY (`fk_id_pessoa`) REFERENCES `tb_pessoa`(`pk_id_pessoa`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_email`
  ADD FOREIGN KEY (`fk_id_pessoa`) REFERENCES `tb_pessoa`(`pk_id_pessoa`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_telefone`
  ADD FOREIGN KEY (`fk_id_pessoa`) REFERENCES `tb_pessoa`(`pk_id_pessoa`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Calendário
ALTER TABLE `tb_calendario_letivo`
  ADD FOREIGN KEY (`fk_id_ano_letivo`) REFERENCES `tb_ano_letivo`(`pk_id_ano_letivo`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_evento_escolar`
  ADD FOREIGN KEY (`fk_id_calendario`) REFERENCES `tb_calendario_letivo`(`pk_id_calendario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Funcionários
ALTER TABLE `tb_funcionario`
  ADD FOREIGN KEY (`fk_id_pessoa`) REFERENCES `tb_pessoa`(`pk_id_pessoa`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_contrato`
  ADD FOREIGN KEY (`fk_id_funcionario`) REFERENCES `tb_funcionario`(`pk_id_funcionario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_historico_cargo`
  ADD FOREIGN KEY (`fk_id_contrato`) REFERENCES `tb_contrato`(`pk_id_contrato`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_historico_cargo`
  ADD FOREIGN KEY (`fk_id_cargo`) REFERENCES `tb_cargo`(`pk_id_cargo`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_ponto_funcionario`
  ADD FOREIGN KEY (`fk_id_funcionario`) REFERENCES `tb_funcionario`(`pk_id_funcionario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_ponto_funcionario`
  ADD FOREIGN KEY (`fk_id_calendario`) REFERENCES `tb_calendario_letivo`(`pk_id_calendario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_folha_pagamento`
  ADD FOREIGN KEY (`fk_id_funcionario`) REFERENCES `tb_funcionario`(`pk_id_funcionario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_folha_pagamento`
  ADD FOREIGN KEY (`fk_id_contrato`) REFERENCES `tb_contrato`(`pk_id_contrato`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Professores
ALTER TABLE `tb_professor`
  ADD FOREIGN KEY (`fk_id_funcionario`) REFERENCES `tb_funcionario`(`pk_id_funcionario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_formacao_professor`
  ADD FOREIGN KEY (`fk_id_professor`) REFERENCES `tb_professor`(`pk_id_professor`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Responsáveis
ALTER TABLE `tb_responsavel`
  ADD FOREIGN KEY (`fk_id_pessoa`) REFERENCES `tb_pessoa`(`pk_id_pessoa`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_contato_responsavel`
  ADD FOREIGN KEY (`fk_id_responsavel`) REFERENCES `tb_responsavel`(`pk_id_responsavel`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_contato_responsavel`
  ADD FOREIGN KEY (`fk_ra_aluno`) REFERENCES `tb_aluno`(`ra`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_contato_responsavel`
  ADD FOREIGN KEY (`fk_registrado_por`) REFERENCES `tb_funcionario`(`pk_id_funcionario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Alunos
ALTER TABLE `tb_aluno`
  ADD FOREIGN KEY (`fk_id_pessoa`) REFERENCES `tb_pessoa`(`pk_id_pessoa`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_ficha_saude`
  ADD FOREIGN KEY (`fk_ra_aluno`) REFERENCES `tb_aluno`(`ra`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_laudo`
  ADD FOREIGN KEY (`fk_ra_aluno`) REFERENCES `tb_aluno`(`ra`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_responsavel_aluno`
  ADD FOREIGN KEY (`fk_ra_aluno`) REFERENCES `tb_aluno`(`ra`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_responsavel_aluno`
  ADD FOREIGN KEY (`fk_id_responsavel`) REFERENCES `tb_responsavel`(`pk_id_responsavel`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Estrutura pedagógica
ALTER TABLE `tb_turma`
  ADD FOREIGN KEY (`fk_id_ano_letivo`) REFERENCES `tb_ano_letivo`(`pk_id_ano_letivo`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_grade_curricular`
  ADD FOREIGN KEY (`fk_id_turma`) REFERENCES `tb_turma`(`pk_id_turma`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_grade_curricular`
  ADD FOREIGN KEY (`fk_id_materia`) REFERENCES `tb_materia`(`pk_id_materia`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_grade_curricular`
  ADD FOREIGN KEY (`fk_id_professor`) REFERENCES `tb_professor`(`pk_id_professor`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_historico_grade`
  ADD FOREIGN KEY (`fk_id_grade`) REFERENCES `tb_grade_curricular`(`pk_id_grade`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_historico_grade`
  ADD FOREIGN KEY (`fk_id_professor`) REFERENCES `tb_professor`(`pk_id_professor`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Matrículas
ALTER TABLE `tb_matricula`
  ADD FOREIGN KEY (`fk_ra_aluno`) REFERENCES `tb_aluno`(`ra`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_matricula`
  ADD FOREIGN KEY (`fk_id_turma`) REFERENCES `tb_turma`(`pk_id_turma`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_matricula`
  ADD FOREIGN KEY (`fk_id_tipo_ingresso`) REFERENCES `tb_tipo_ingresso`(`pk_id_tipo_ingresso`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Avaliações
ALTER TABLE `tb_atividade_professor`
  ADD FOREIGN KEY (`fk_id_grade`) REFERENCES `tb_grade_curricular`(`pk_id_grade`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_nota_atividade`
  ADD FOREIGN KEY (`fk_id_matricula`) REFERENCES `tb_matricula`(`pk_id_matricula`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_nota_atividade`
  ADD FOREIGN KEY (`fk_id_atividade_professor`) REFERENCES `tb_atividade_professor`(`pk_id_atividade_professor`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_desempenho_academico`
  ADD FOREIGN KEY (`fk_id_matricula`) REFERENCES `tb_matricula`(`pk_id_matricula`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_desempenho_academico`
  ADD FOREIGN KEY (`fk_id_grade`) REFERENCES `tb_grade_curricular`(`pk_id_grade`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_boletim`
  ADD FOREIGN KEY (`fk_id_matricula`) REFERENCES `tb_matricula`(`pk_id_matricula`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Frequência / Presença
ALTER TABLE `tb_presenca_aluno`
  ADD FOREIGN KEY (`fk_id_matricula`) REFERENCES `tb_matricula`(`pk_id_matricula`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_presenca_aluno`
  ADD FOREIGN KEY (`fk_id_calendario`) REFERENCES `tb_calendario_letivo`(`pk_id_calendario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Ocorrências
ALTER TABLE `tb_ocorrencia`
  ADD FOREIGN KEY (`fk_id_matricula`) REFERENCES `tb_matricula`(`pk_id_matricula`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_ocorrencia`
  ADD FOREIGN KEY (`fk_id_funcionario`) REFERENCES `tb_funcionario`(`pk_id_funcionario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Alertas de evasão
ALTER TABLE `tb_alerta_evasao`
  ADD FOREIGN KEY (`fk_id_matricula`) REFERENCES `tb_matricula`(`pk_id_matricula`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tb_alerta_evasao`
  ADD FOREIGN KEY (`fk_responsavel_alerta`) REFERENCES `tb_funcionario`(`pk_id_funcionario`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- Pagamentos
ALTER TABLE `tb_pagamento`
  ADD FOREIGN KEY (`fk_id_matricula`) REFERENCES `tb_matricula`(`pk_id_matricula`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- ==============================================================
-- ÍNDICES
-- ==============================================================

CREATE INDEX idx_endereco_pessoa     ON `tb_endereco`             (`fk_id_pessoa`);
CREATE INDEX idx_email_pessoa        ON `tb_email`                (`fk_id_pessoa`);
CREATE INDEX idx_telefone_pessoa     ON `tb_telefone`             (`fk_id_pessoa`);
CREATE INDEX idx_aluno_pessoa        ON `tb_aluno`                (`fk_id_pessoa`);
CREATE INDEX idx_calendario_data     ON `tb_calendario_letivo`    (`data_evento`);
CREATE INDEX idx_calendario_ano      ON `tb_calendario_letivo`    (`fk_id_ano_letivo`);
CREATE INDEX idx_turma_ano           ON `tb_turma`                (`fk_id_ano_letivo`);
CREATE INDEX idx_grade_turma         ON `tb_grade_curricular`     (`fk_id_turma`);
CREATE INDEX idx_grade_professor     ON `tb_grade_curricular`     (`fk_id_professor`);
CREATE INDEX idx_matricula_aluno     ON `tb_matricula`            (`fk_ra_aluno`);
CREATE INDEX idx_matricula_turma     ON `tb_matricula`            (`fk_id_turma`);
CREATE INDEX idx_matricula_status    ON `tb_matricula`            (`status_matricula`);
CREATE INDEX idx_matricula_resultado ON `tb_matricula`            (`resultado_final`);
CREATE INDEX idx_nota_matricula      ON `tb_nota_atividade`       (`fk_id_matricula`);
CREATE INDEX idx_desempenho_mat      ON `tb_desempenho_academico` (`fk_id_matricula`);
CREATE INDEX idx_desempenho_bim      ON `tb_desempenho_academico` (`bimestre`);
CREATE INDEX idx_presenca_matricula  ON `tb_presenca_aluno`       (`fk_id_matricula`);
CREATE INDEX idx_presenca_cal        ON `tb_presenca_aluno`       (`fk_id_calendario`);
CREATE INDEX idx_ocorrencia_mat      ON `tb_ocorrencia`           (`fk_id_matricula`);
CREATE INDEX idx_pagamento_mat       ON `tb_pagamento`            (`fk_id_matricula`);
CREATE INDEX idx_pagamento_status    ON `tb_pagamento`            (`status`);
CREATE INDEX idx_alerta_matricula    ON `tb_alerta_evasao`        (`fk_id_matricula`);
CREATE INDEX idx_alerta_status       ON `tb_alerta_evasao`        (`status_alerta`);
CREATE INDEX idx_contato_resp        ON `tb_contato_responsavel`  (`fk_id_responsavel`);
CREATE INDEX idx_contato_aluno       ON `tb_contato_responsavel`  (`fk_ra_aluno`);
CREATE INDEX idx_resp_aluno_ra       ON `tb_responsavel_aluno`    (`fk_ra_aluno`);
CREATE INDEX idx_atividade_bimestre  ON `tb_atividade_professor`  (`bimestre`);