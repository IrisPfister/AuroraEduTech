DROP DATABASE IF EXISTS aurora_tech;
CREATE DATABASE aurora_tech;
USE aurora_tech;

CREATE TABLE tb_pessoa (
    pk_pessoa        int          NOT NULL AUTO_INCREMENT,
    cpf              varchar(14)  NOT NULL,
    rg               varchar(12)  NULL,
    nome             varchar(80)  NOT NULL,
    sobrenome        varchar(40)  NOT NULL,
    sexo             varchar(40)  NOT NULL,
    data_nascimento  date         NOT NULL,
    nacionalidade    enum('brasileiro','estrangeiro')  NOT NULL DEFAULT 'brasileiro',
    raca             varchar(40)  NOT NULL DEFAULT 'nao informar',
    criado_em        timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em    timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_pessoa_cpf (cpf),
    CONSTRAINT chk_cpf_formato      CHECK (cpf REGEXP '^[0-9]{3}\\.[0-9]{3}\\.[0-9]{3}-[0-9]{2}$'),
    CONSTRAINT chk_data_nascimento CHECK (data_nascimento >= '1900-01-01'),
    CONSTRAINT pk_pessoa PRIMARY KEY (pk_pessoa),
    CONSTRAINT chk_sexo_opcao CHECK (sexo IN ('masculino', 'feminino', 'nao informar')),
    CONSTRAINT chk_raca_opcao CHECK (raca IN ('branca', 'negra', 'parda', 'amarela', 'indigena', 'nao informar'))
);

CREATE TABLE tb_endereco (
    pk_endereco   int           NOT NULL AUTO_INCREMENT,
    fk_pessoa     int           NOT NULL,
    cep           varchar(9)    NOT NULL,
    numero        varchar(10)   NULL,
    complemento   varchar(80)   NULL DEFAULT '',
    principal     bool          NOT NULL DEFAULT false,
    criado_em     timestamp     NOT NULL DEFAULT current_timestamp,
    atualizado_em timestamp     NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_cep_formato CHECK (cep REGEXP '^[0-9]{5}-[0-9]{3}$'),
    CONSTRAINT pk_endereco PRIMARY KEY (pk_endereco)
);

CREATE TABLE tb_email (
    pk_email      int          NOT NULL AUTO_INCREMENT,
    fk_pessoa     int          NOT NULL,
    email         varchar(100) NOT NULL,
    principal     bool         NOT NULL DEFAULT false,
    criado_em     timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_email (email),
    CONSTRAINT chk_email_formato CHECK (email REGEXP '^[^@]+@[^@]+\\.[^@]+$'),
    CONSTRAINT pk_email PRIMARY KEY (pk_email)
);

CREATE TABLE tb_telefone (
    pk_telefone int        NOT NULL AUTO_INCREMENT,
    fk_pessoa   int        NOT NULL,
    categoria   enum('celular','residencial','emergencia') NOT NULL,
    ddd         char(2)    NOT NULL,
    numero      varchar(9) NOT NULL,
    ativo       bool       NOT NULL DEFAULT true,
    principal   bool       NOT NULL DEFAULT false,
    UNIQUE INDEX uq_ddd_telefone (ddd, numero),
    CONSTRAINT chk_ddd        CHECK (ddd    REGEXP '^[0-9]{2}$'),
    CONSTRAINT chk_numero_tel CHECK (numero REGEXP '^[0-9]{8,9}$'),
    CONSTRAINT pk_telefone PRIMARY KEY (pk_telefone)
);

CREATE TABLE tb_cargo (
    pk_cargo          int          NOT NULL AUTO_INCREMENT,
    nome_cargo        varchar(60)  NOT NULL,
    descricao         varchar(200) NULL,
    nivel_hierarquico tinyint      NOT NULL DEFAULT 1,
    ativo             bool         NOT NULL DEFAULT true,
    UNIQUE INDEX uq_cargo_nome (nome_cargo),
    CONSTRAINT chk_nivel_hierarquico CHECK (nivel_hierarquico BETWEEN 1 AND 10),
    CONSTRAINT pk_cargo PRIMARY KEY (pk_cargo)
);

CREATE TABLE tb_tipo_contrato (
    pk_tipo_contrato int         NOT NULL AUTO_INCREMENT,
    descricao        varchar(30) NOT NULL,
    ativo            bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_tipo_contrato_desc (descricao),
    CONSTRAINT pk_tipo_contrato PRIMARY KEY (pk_tipo_contrato)
);

CREATE TABLE tb_status_contrato (
    pk_status_contrato int         NOT NULL AUTO_INCREMENT,
    descricao          varchar(30) NOT NULL,
    ativo              bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_status_contrato_desc (descricao),
    CONSTRAINT pk_status_contrato PRIMARY KEY (pk_status_contrato)
);

CREATE TABLE tb_nivel_formacao (
    pk_nivel_formacao int         NOT NULL AUTO_INCREMENT,
    descricao         varchar(40) NOT NULL,
    ativo             bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_nivel_formacao_desc (descricao),
    CONSTRAINT pk_nivel_formacao PRIMARY KEY (pk_nivel_formacao)
);

CREATE TABLE tb_tipo_aula (
    pk_tipo_aula int         NOT NULL AUTO_INCREMENT,
    descricao    varchar(40) NOT NULL,
    ativo        bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_tipo_aula_desc (descricao),
    CONSTRAINT pk_tipo_aula PRIMARY KEY (pk_tipo_aula)
);

CREATE TABLE tb_area_conhecimento (
    pk_area_conhecimento int         NOT NULL AUTO_INCREMENT,
    descricao            varchar(40) NOT NULL,
    ativo                bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_area_conhecimento_desc (descricao),
    CONSTRAINT pk_area_conhecimento PRIMARY KEY (pk_area_conhecimento)
);

CREATE TABLE tb_sala (
    pk_sala             int         NOT NULL AUTO_INCREMENT,
    codigo_sala         varchar(10) NOT NULL,
    nome_sala           varchar(50) NOT NULL,
    capacidade          tinyint     NOT NULL,
    andar               tinyint     NOT NULL DEFAULT 0,
    tipo_sala           varchar(30) NOT NULL DEFAULT 'Sala de Aula',
    tem_projetor        bool        NOT NULL DEFAULT false,
    tem_ar_condicionado bool        NOT NULL DEFAULT false,
    acessibilidade_pcd  bool        NOT NULL DEFAULT true,
    situacao            enum('disponivel','manutencao','desativada') NOT NULL DEFAULT 'disponivel',
    criado_em           timestamp   NOT NULL DEFAULT current_timestamp,
    atualizado_em       timestamp   NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_codigo_sala (codigo_sala),
    CONSTRAINT chk_capacidade_sala CHECK (capacidade BETWEEN 1 AND 100),
    CONSTRAINT chk_andar           CHECK (andar BETWEEN -2 AND 20),
    CONSTRAINT chk_tipo_sala       CHECK (tipo_sala IN (
        'Sala de Aula','Laboratorio Informatica','Laboratorio Ciencias',
        'Biblioteca','Auditorio','Quadra','Sala Multiuso','Sala AEE',
        'Sala de Musica','Sala de Artes','Sala de Danca'
    )),
    CONSTRAINT pk_sala PRIMARY KEY (pk_sala)
);

CREATE TABLE tb_ano_escolar (
    pk_ano_escolar int          NOT NULL AUTO_INCREMENT,
    nome_ano       varchar(30)  NOT NULL,
    ordem          tinyint      NOT NULL,
    idade_minima   tinyint      NOT NULL,
    idade_maxima   tinyint      NOT NULL,
    descricao      varchar(255) NULL,
    criado_em      timestamp    NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_nome_ano_escolar  (nome_ano),
    UNIQUE INDEX uq_ordem_ano_escolar (ordem),
    CONSTRAINT chk_ordem_ano   CHECK (ordem        BETWEEN 1 AND 5),
    CONSTRAINT chk_idade_min   CHECK (idade_minima BETWEEN 6  AND 10),
    CONSTRAINT chk_idade_max   CHECK (idade_maxima BETWEEN 7  AND 11),
    CONSTRAINT chk_idades_coer CHECK (idade_maxima > idade_minima),
    CONSTRAINT pk_ano_escolar PRIMARY KEY (pk_ano_escolar)
);

CREATE TABLE tb_ano_letivo (
    pk_ano_letivo int  NOT NULL AUTO_INCREMENT,
    ano           year NOT NULL,
    data_inicio   date NOT NULL,
    data_fim      date NOT NULL,
    ativo         bool NOT NULL DEFAULT false,
    UNIQUE INDEX uq_ano_letivo_ano (ano),
    CONSTRAINT chk_ano_letivo_datas CHECK (data_fim >= data_inicio),
    CONSTRAINT pk_ano_letivo PRIMARY KEY (pk_ano_letivo)
);

CREATE TABLE tb_tipo_ingresso (
    pk_tipo_ingresso int         NOT NULL AUTO_INCREMENT,
    descricao        varchar(60) NOT NULL,
    ativo            bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_tipo_ingresso_desc (descricao),
    CONSTRAINT pk_tipo_ingresso PRIMARY KEY (pk_tipo_ingresso)
);

CREATE TABLE tb_status_matricula (
    pk_status_matricula int         NOT NULL AUTO_INCREMENT,
    descricao           varchar(30) NOT NULL,
    ativo               bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_status_matricula_desc (descricao),
    CONSTRAINT pk_status_matricula PRIMARY KEY (pk_status_matricula)
);

CREATE TABLE tb_situacao_boletim (
    pk_situacao_boletim int         NOT NULL AUTO_INCREMENT,
    descricao           varchar(30) NOT NULL,
    ativo               bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_situacao_boletim_desc (descricao),
    CONSTRAINT pk_situacao_boletim PRIMARY KEY (pk_situacao_boletim)
);

CREATE TABLE tb_tipo_escola_anterior (
    pk_tipo_escola_anterior int         NOT NULL AUTO_INCREMENT,
    descricao               varchar(30) NOT NULL,
    ativo                   bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_tipo_escola_anterior_desc (descricao),
    CONSTRAINT pk_tipo_escola_anterior PRIMARY KEY (pk_tipo_escola_anterior)
);

CREATE TABLE tb_categoria_atividade (
    pk_categoria   int          NOT NULL AUTO_INCREMENT,
    nome_categoria varchar(50)  NOT NULL,
    descricao      varchar(255) NULL,
    criado_em      timestamp    NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_categoria_nome (nome_categoria),
    CONSTRAINT pk_categoria_atividade PRIMARY KEY (pk_categoria)
);

CREATE TABLE tb_tipo_atividade (
    pk_tipo_atividade int         NOT NULL AUTO_INCREMENT,
    descricao         varchar(40) NOT NULL,
    ativo             bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_tipo_atividade_desc (descricao),
    CONSTRAINT pk_tipo_atividade PRIMARY KEY (pk_tipo_atividade)
);

CREATE TABLE tb_tipo_verba (
    pk_tipo_verba int         NOT NULL AUTO_INCREMENT,
    codigo_verba  varchar(10) NOT NULL,
    nome_verba    varchar(50) NOT NULL,
    natureza      char(1)     NOT NULL,
    incide_inss   bool        NOT NULL DEFAULT true,
    incide_irrf   bool        NOT NULL DEFAULT true,
    criado_em     timestamp   NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_codigo_verba (codigo_verba),
    CONSTRAINT chk_natureza_verba CHECK (natureza IN ('P','D')), -- P -> provento D -> desconto
    CONSTRAINT pk_tipo_verba PRIMARY KEY (pk_tipo_verba)
);

CREATE TABLE tb_tipo_necessidade_apoio (
    pk_tipo_necessidade       int          NOT NULL AUTO_INCREMENT,
    codigo                    varchar(10)  NOT NULL,
    nome                      varchar(100) NOT NULL,
    categoria                 varchar(50)  NOT NULL,
    descricao                 text         NULL,
    requer_laudo              bool         NOT NULL DEFAULT true,
    requer_acompanhamento_aee bool         NOT NULL DEFAULT false,
    criado_em                 timestamp    NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_codigo_necessidade (codigo),
    CONSTRAINT chk_categoria_nec CHECK (categoria IN (
        'Transtorno do Espectro Autista','Transtorno de Aprendizagem',
        'Transtorno de Atencao','Deficiencia Intelectual','Deficiencia Fisica',
        'Deficiencia Visual','Deficiencia Auditiva','Altas Habilidades',
        'Transtorno Emocional','Sindrome Genetica','Outra'
    )),
    CONSTRAINT pk_tipo_necessidade_apoio PRIMARY KEY (pk_tipo_necessidade)
);

CREATE TABLE tb_tipo_ocorrencia (
    pk_tipo_ocorrencia int         NOT NULL AUTO_INCREMENT,
    nome_tipo          varchar(50) NOT NULL,
    gravidade          tinyint     NOT NULL DEFAULT 1,
    requer_comunicado  bool        NOT NULL DEFAULT true,
    criado_em          timestamp   NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_tipo_ocorrencia_nome (nome_tipo),
    CONSTRAINT chk_gravidade CHECK (gravidade BETWEEN 1 AND 5),
    CONSTRAINT pk_tipo_ocorrencia PRIMARY KEY (pk_tipo_ocorrencia)
);

CREATE TABLE tb_nivel_risco_evasao (
    pk_nivel_risco int         NOT NULL AUTO_INCREMENT,
    descricao      varchar(30) NOT NULL,
    ordem          tinyint     NOT NULL,
    ativo          bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_nivel_risco_desc  (descricao),
    UNIQUE INDEX uq_nivel_risco_ordem (ordem),
    CONSTRAINT pk_nivel_risco_evasao PRIMARY KEY (pk_nivel_risco)
);

CREATE TABLE tb_tipo_risco_evasao (
    pk_tipo_risco_evasao int         NOT NULL AUTO_INCREMENT,
    descricao            varchar(60) NOT NULL,
    ativo                bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_tipo_risco_evasao_desc (descricao),
    CONSTRAINT pk_tipo_risco_evasao PRIMARY KEY (pk_tipo_risco_evasao)
);

CREATE TABLE tb_status_alerta (
    pk_status_alerta int         NOT NULL AUTO_INCREMENT,
    descricao        varchar(40) NOT NULL,
    ativo            bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_status_alerta_desc (descricao),
    CONSTRAINT pk_status_alerta PRIMARY KEY (pk_status_alerta)
);

CREATE TABLE tb_profissao (
    pk_profissao int          NOT NULL AUTO_INCREMENT,
    profissao    varchar(50)  NOT NULL UNIQUE,
    descricao    varchar(100) NOT NULL,
    criado_em    timestamp    NOT NULL DEFAULT current_timestamp,
    CONSTRAINT pk_profissao PRIMARY KEY (pk_profissao)
);

CREATE TABLE tb_funcionario (
    pk_funcionario int  NOT NULL AUTO_INCREMENT,
    fk_pessoa      int  NOT NULL,
    data_admissao  date NOT NULL,
    data_demissao  date NULL,
    situacao       enum('ativo','ferias','licenca','afastado','demitido') NOT NULL DEFAULT 'ativo',
    ativo          bool NOT NULL DEFAULT true,
    UNIQUE INDEX uq_funcionario_pessoa (fk_pessoa),
    CONSTRAINT chk_datas_func    CHECK (data_demissao IS NULL OR data_demissao >= data_admissao),
    CONSTRAINT chk_data_admissao CHECK (data_admissao >= '2000-01-01'),
    CONSTRAINT pk_funcionario PRIMARY KEY (pk_funcionario)
);

CREATE TABLE tb_historico_situacao_funcionario (
    pk_historico      int NOT NULL AUTO_INCREMENT,
    fk_funcionario    int NOT NULL,
    situacao_anterior enum('ativo','ferias','licenca','afastado','demitido') NOT NULL,
    situacao_nova     enum('ativo','ferias','licenca','afastado','demitido') NOT NULL,
    data_alteracao    timestamp    NOT NULL DEFAULT current_timestamp,
    motivo            varchar(255) NULL,
    CONSTRAINT pk_historico_sit_func PRIMARY KEY (pk_historico)
);

CREATE TABLE tb_contrato (
    pk_contrato           int             NOT NULL AUTO_INCREMENT,
    fk_funcionario        int             NOT NULL,
    fk_tipo_contrato      int             NOT NULL,
    fk_status_contrato    int             NOT NULL,
    carga_horaria_semanal tinyint UNSIGNED NOT NULL,
    data_inicio           date            NOT NULL,
    data_fim              date            NULL,
    CONSTRAINT chk_carga_horaria  CHECK (carga_horaria_semanal BETWEEN 1 AND 44),
    CONSTRAINT chk_contrato_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT pk_contrato PRIMARY KEY (pk_contrato)
);

CREATE TABLE tb_historico_cargo (
    pk_historico_cargo int          NOT NULL AUTO_INCREMENT,
    fk_contrato        int          NOT NULL,
    fk_cargo           int          NOT NULL,
    data_inicio        date         NOT NULL,
    data_fim           date         NULL,
    motivo_mudanca     varchar(100) NULL,
    UNIQUE INDEX uq_hist_cargo_vigencia (fk_contrato, fk_cargo, data_inicio),
    CONSTRAINT chk_hist_cargo_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT pk_historico_cargo PRIMARY KEY (pk_historico_cargo)
);

CREATE TABLE tb_historico_salario (
    pk_historico_salario int            NOT NULL AUTO_INCREMENT,
    fk_contrato          int            NOT NULL,
    salario              decimal(10,2) NOT NULL,
    data_inicio          date          NOT NULL,
    data_fim             date          NULL,
    motivo_reajuste      varchar(100)  NULL,
    UNIQUE INDEX uq_hist_salario_vigencia (fk_contrato, data_inicio),
    CONSTRAINT chk_salario_positivo_hist CHECK (salario > 0),
    CONSTRAINT chk_salario_minimo        CHECK (salario >= 1412.00),
    CONSTRAINT chk_hist_salario_datas    CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT pk_historico_salario PRIMARY KEY (pk_historico_salario)
);

CREATE TABLE tb_folha_pagamento (
    pk_folha_pagamento int            NOT NULL AUTO_INCREMENT,
    fk_contrato        int            NOT NULL,
    tipo_folha         enum('mensal','adiantamento','decimo','rescisao','ferias') NOT NULL,
    status_folha       enum('gerada','processando','paga','cancelada') NOT NULL DEFAULT 'gerada',
    total_proventos    decimal(10,2) NOT NULL DEFAULT 0.00,
    total_descontos    decimal(10,2) NOT NULL DEFAULT 0.00,
    valor_liquido      decimal(10,2) GENERATED ALWAYS AS (total_proventos - total_descontos) STORED,
    ano                year          NOT NULL,
    mes                tinyint       NOT NULL,
    data_emissao       date          NOT NULL,
    UNIQUE INDEX uq_contrato_ano_mes_tipo (fk_contrato, ano, mes, tipo_folha),
    CONSTRAINT chk_folha_valor CHECK (total_proventos >= 0),
    CONSTRAINT chk_folha_desc  CHECK (total_descontos >= 0),
    CONSTRAINT chk_folha_mes   CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT pk_folha_pagamento PRIMARY KEY (pk_folha_pagamento)
);

CREATE TABLE tb_verba_folha (
    pk_verba      int           NOT NULL AUTO_INCREMENT,
    fk_folha      int           NOT NULL,
    fk_tipo_verba int           NOT NULL,
    valor         decimal(10,2) NOT NULL,
    quantidade    decimal(5,2)  NOT NULL DEFAULT 1.00,
    referencia    varchar(120)  NULL,
    criado_em     timestamp     NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_verba_folha (fk_folha, fk_tipo_verba),
    CONSTRAINT chk_verba_valor CHECK (valor != 0),
    CONSTRAINT chk_verba_qtde  CHECK (quantidade > 0),
    CONSTRAINT pk_verba_folha PRIMARY KEY (pk_verba)
);

CREATE TABLE tb_professor (
    pk_professor               int         NOT NULL AUTO_INCREMENT,
    fk_funcionario             int         NOT NULL,
    fk_tipo_aula               int         NULL,
    titulacao                  varchar(30) NOT NULL DEFAULT 'Graduacao',
    regime_contratacao         varchar(20) NOT NULL DEFAULT 'Integral',
    registro_mec               varchar(20) NULL,
    utiliza_rubrica_avaliativa bool        NOT NULL DEFAULT false,
    atende_educacao_especial   bool        NOT NULL DEFAULT false,
    UNIQUE INDEX uq_professor_funcionario (fk_funcionario),
    CONSTRAINT chk_titulacao CHECK (titulacao          IN ('Graduacao','Especializacao','Mestrado','Doutorado')),
    CONSTRAINT chk_regime    CHECK (regime_contratacao IN ('Integral','Parcial','Horista')),
    CONSTRAINT pk_professor PRIMARY KEY (pk_professor)
);

CREATE TABLE tb_formacao_professor (
    pk_formacao       int          NOT NULL AUTO_INCREMENT,
    fk_professor      int          NOT NULL,
    fk_nivel_formacao int          NOT NULL,
    curso             varchar(100) NOT NULL,
    instituicao       varchar(100) NULL,
    ano_conclusao     year         NULL,
    principal         bool         NOT NULL DEFAULT false,
    CONSTRAINT chk_ano_conclusao CHECK (ano_conclusao IS NULL OR ano_conclusao <= 2100),
    CONSTRAINT pk_formacao_professor PRIMARY KEY (pk_formacao)
);

CREATE TABLE tb_carga_horaria_professor (
    pk_carga       int       NOT NULL AUTO_INCREMENT,
    fk_professor   int       NOT NULL,
    horas_semanais tinyint   NOT NULL,
    horas_mensais  smallint  NOT NULL,
    data_inicio    date      NOT NULL,
    data_fim       date      NULL,
    criado_em      timestamp NOT NULL DEFAULT current_timestamp,
    CONSTRAINT chk_horas_semanais CHECK (horas_semanais BETWEEN 1 AND 44),
    CONSTRAINT chk_horas_mensais  CHECK (horas_mensais  BETWEEN 4 AND 200),
    CONSTRAINT chk_datas_carga    CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT pk_carga_horaria PRIMARY KEY (pk_carga)
);

CREATE TABLE tb_calendario_letivo (
    pk_calendario          int  NOT NULL AUTO_INCREMENT,
    fk_ano_letivo          int  NOT NULL,
    data_inicio            date NOT NULL,
    data_fim               date NOT NULL,
    dias_letivos_previstos int  NOT NULL DEFAULT 200,
    horas_totais_previstas int  NOT NULL DEFAULT 800,
    situacao               enum('planejado','andamento','encerrado') NOT NULL DEFAULT 'planejado',
    observacoes            text NULL,
    criado_em              timestamp NOT NULL DEFAULT current_timestamp,
    atualizado_em          timestamp NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_calendario_ano (fk_ano_letivo),
    CONSTRAINT chk_datas_calendario CHECK (data_fim > data_inicio),
    CONSTRAINT chk_dias_minimos     CHECK (dias_letivos_previstos >= 200),
    CONSTRAINT chk_horas_minimas    CHECK (horas_totais_previstas >= 800),
    CONSTRAINT pk_calendario PRIMARY KEY (pk_calendario)
);

CREATE TABLE tb_evento_escolar (
    pk_evento     int          NOT NULL AUTO_INCREMENT,
    fk_calendario int          NOT NULL,
    nome_evento   varchar(100) NOT NULL,
    tipo_evento   varchar(30)  NOT NULL,
    data_inicio   date         NOT NULL,
    data_fim      date         NOT NULL,
    dia_letivo    bool         NOT NULL DEFAULT false,
    hora_inicio   time         NULL,
    hora_fim      time         NULL,
    descricao     text         NULL,
    observacoes   varchar(255) NULL,
    criado_em     timestamp    NOT NULL DEFAULT current_timestamp,
    CONSTRAINT chk_tipo_evento    CHECK (tipo_evento IN (
        'Feriado Nacional','Feriado Estadual','Feriado Municipal',
        'Recesso Escolar','Ferias','Reuniao Pedagogica','Conselho de Classe',
        'Reuniao de Pais','Evento Escolar','Prova Bimestral','Recuperacao',
        'Apresentacao Musical','Mostra Cultural','Competicao Esportiva'
    )),
    CONSTRAINT chk_datas_evento   CHECK (data_fim >= data_inicio),
    CONSTRAINT chk_evento_horario CHECK (hora_fim IS NULL OR hora_fim > hora_inicio),
    CONSTRAINT pk_evento_escolar PRIMARY KEY (pk_evento)
);

CREATE TABLE tb_periodo_letivo (
    pk_periodo         int         NOT NULL AUTO_INCREMENT,
    fk_calendario      int         NOT NULL,
    numero_periodo     tinyint     NOT NULL,
    nome_periodo       varchar(30) NOT NULL,
    data_inicio        date        NOT NULL,
    data_fim           date        NOT NULL,
    data_inicio_provas date        NULL,
    data_fim_provas    date        NULL,
    data_entrega_notas date        NULL,
    situacao           enum('futuro','andamento','encerrado') NOT NULL DEFAULT 'futuro',
    criado_em          timestamp   NOT NULL DEFAULT current_timestamp,
    atualizado_em      timestamp   NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_periodo_calendario (fk_calendario, numero_periodo),
    CONSTRAINT chk_numero_periodo CHECK (numero_periodo BETWEEN 1 AND 4),
    CONSTRAINT chk_datas_periodo  CHECK (data_fim > data_inicio),
    CONSTRAINT pk_periodo_letivo PRIMARY KEY (pk_periodo)
);

CREATE TABLE tb_materia (
    pk_materia            int         NOT NULL AUTO_INCREMENT,
    fk_area_conhecimento  int         NOT NULL,
    fk_ano_escolar        int         NULL,
    nome_materia          varchar(60) NOT NULL,
    carga_horaria_semanal tinyint     NOT NULL DEFAULT 1,
    obrigatoria           bool        NOT NULL DEFAULT true,
    ativo                 bool        NOT NULL DEFAULT true,
    UNIQUE INDEX uq_materia_nome (nome_materia),
    CONSTRAINT chk_carga_semanal CHECK (carga_horaria_semanal BETWEEN 1 AND 20),
    CONSTRAINT pk_materia PRIMARY KEY (pk_materia)
);

CREATE TABLE tb_turma (
    pk_turma          int                                  NOT NULL AUTO_INCREMENT,
    fk_ano_letivo     int                                  NOT NULL,
    fk_ano_escolar    int                                  NOT NULL,
    fk_sala           int                                  NULL,
    nome_turma        varchar(10)                          NOT NULL,
    periodo           enum('manha','tarde','integral')     NOT NULL,
    capacidade_maxima tinyint UNSIGNED                     NULL,
    situacao          enum('aberta','fechada','cancelada') NOT NULL DEFAULT 'aberta',
    criado_em         timestamp                            NOT NULL DEFAULT current_timestamp,
    atualizado_em     timestamp                            NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_turma_ano (fk_ano_letivo, nome_turma, periodo),
    CONSTRAINT chk_capacidade CHECK (capacidade_maxima IS NULL OR capacidade_maxima BETWEEN 1 AND 40),
    CONSTRAINT pk_turma PRIMARY KEY (pk_turma)
);

CREATE TABLE tb_grade_curricular (
    pk_grade     int  NOT NULL AUTO_INCREMENT,
    fk_turma     int  NOT NULL,
    fk_materia   int  NOT NULL,
    fk_professor int  NOT NULL,
    data_inicio  date NOT NULL,
    data_fim     date NULL,
    UNIQUE INDEX uq_grade_turma_materia (fk_turma, fk_materia, data_inicio),
    CONSTRAINT chk_grade_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT pk_grade_curricular PRIMARY KEY (pk_grade)
);

CREATE TABLE tb_horario_aula (
    pk_horario_aula int                                               NOT NULL AUTO_INCREMENT,
    fk_grade        int                                               NOT NULL,
    fk_sala         int                                               NULL,
    dia_semana      enum('segunda','terca','quarta','quinta','sexta') NOT NULL,
    hora_inicio     time                                              NOT NULL,
    hora_fim        time                                              NOT NULL,
    UNIQUE INDEX uq_horario_grade_dia_hora (fk_grade, dia_semana, hora_inicio),
    CONSTRAINT chk_horario_aula CHECK (hora_fim > hora_inicio),
    CONSTRAINT pk_horario_aula PRIMARY KEY (pk_horario_aula)
);

CREATE TABLE tb_responsavel (
    pk_responsavel  int          NOT NULL AUTO_INCREMENT,
    fk_pessoa       int          NOT NULL,
    grau_parentesco varchar(30)  NOT NULL DEFAULT 'Outro',
    local_trabalho  varchar(100) NULL,
    criado_em       timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em   timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_responsavel_pessoa (fk_pessoa),
    CONSTRAINT chk_parentesco CHECK (grau_parentesco IN (
        'Mae','Pai','Avo Paterno','Avo Paterna','Avo Materno','Avo Materna',
        'Tio','Tia','Padrasto','Madrasta','Irmao Maior','Irma Maior',
        'Tutor Legal','Outro'
    )),
    CONSTRAINT pk_responsavel PRIMARY KEY (pk_responsavel)
);

CREATE TABLE tb_profissao_responsavel (
    pk_profissao_responsavel int       NOT NULL AUTO_INCREMENT,
    fk_responsavel           int       NOT NULL,
    fk_profissao             int       NOT NULL,
    ativo                    bool      NOT NULL DEFAULT true,
    criado_em                timestamp NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_responsavel_profissao (fk_responsavel, fk_profissao),
    CONSTRAINT pk_profissao_responsavel PRIMARY KEY (pk_profissao_responsavel)
);

CREATE TABLE tb_aluno (
    pk_ra                   varchar(15) NOT NULL,
    fk_pessoa               int         NOT NULL,
    fk_tipo_escola_anterior int         NULL,
    data_ingresso           date        NOT NULL,
    situacao                enum('ativo','transferido','evadido','concluido','inativo') NOT NULL DEFAULT 'ativo',
    criado_em               timestamp   NOT NULL DEFAULT current_timestamp,
    atualizado_em           timestamp   NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_aluno_pessoa (fk_pessoa),
    CONSTRAINT pk_aluno PRIMARY KEY (pk_ra)
);

CREATE TABLE tb_responsavel_aluno (
    fk_ra_aluno            varchar(15) NOT NULL,
    fk_responsavel         int         NOT NULL,
    responsavel_principal  bool        NOT NULL DEFAULT false,
    responsavel_financeiro bool        NOT NULL DEFAULT false,
    pode_retirar           bool        NOT NULL DEFAULT false,
    CONSTRAINT pk_responsavel_aluno PRIMARY KEY (fk_ra_aluno, fk_responsavel)
);

CREATE TABLE tb_matricula (
    pk_matricula        int          NOT NULL AUTO_INCREMENT,
    fk_ra_aluno         varchar(15)  NOT NULL,
    fk_turma            int          NOT NULL,
    fk_tipo_ingresso    int          NOT NULL,
    fk_status_matricula int          NOT NULL,
    data_matricula      date         NOT NULL,
    percentual_desconto decimal(5,2) NOT NULL DEFAULT 0.00,
    criado_em           timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em       timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_matricula_aluno_turma (fk_ra_aluno, fk_turma),
    CONSTRAINT chk_desconto CHECK (percentual_desconto BETWEEN 0 AND 100),
    CONSTRAINT pk_matricula PRIMARY KEY (pk_matricula)
);

CREATE TABLE tb_atestado (
    pk_atestado  int         NOT NULL AUTO_INCREMENT,
    fk_matricula int         NOT NULL,
    data_inicio  date        NOT NULL,
    data_fim     date        NOT NULL,
    descricao    varchar(50) NULL,
    criado_em    timestamp   NOT NULL DEFAULT current_timestamp,
    CONSTRAINT chk_atestado_datas CHECK (data_fim >= data_inicio),
    CONSTRAINT pk_atestado PRIMARY KEY (pk_atestado)
);

CREATE TABLE tb_presenca_aluno (
    pk_presenca     int          NOT NULL AUTO_INCREMENT,
    fk_matricula    int          NOT NULL,
    fk_calendario   int          NOT NULL,
    fk_horario_aula int          NOT NULL,
    fk_atestado     int          NULL,
    presenca        bool         NOT NULL,
    justificativa   varchar(255) NULL,
    UNIQUE INDEX uq_presenca_dia (fk_matricula, fk_calendario, fk_horario_aula),
    CONSTRAINT pk_presenca_aluno PRIMARY KEY (pk_presenca)
);

CREATE TABLE tb_atividade_extracurricular (
    pk_atividade   int           NOT NULL AUTO_INCREMENT,
    fk_categoria   int           NULL,
    nome_atividade varchar(100)  NOT NULL,
    descricao      varchar(100)  NULL,
    turno          enum('manha','tarde','integral') NOT NULL,
    vagas          tinyint       NOT NULL DEFAULT 20,
    valor_mensal   decimal(10,2) NOT NULL DEFAULT 0.00,
    ativo          bool          NOT NULL DEFAULT true,
    criado_em      timestamp     NOT NULL DEFAULT current_timestamp,
    atualizado_em  timestamp     NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_atividade_nome (nome_atividade),
    CONSTRAINT chk_valor_ativ CHECK (valor_mensal >= 0),
    CONSTRAINT pk_atividade_extracurricular PRIMARY KEY (pk_atividade)
);

CREATE TABLE tb_aluno_atividade (
    fk_ra_aluno  varchar(15) NOT NULL,
    fk_atividade int         NOT NULL,
    data_inicio  date        NOT NULL,
    data_fim     date        NULL,
    UNIQUE INDEX uq_aluno_atividade (fk_ra_aluno, fk_atividade),
    CONSTRAINT chk_aluno_ativ_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT pk_aluno_atividade PRIMARY KEY (fk_ra_aluno, fk_atividade)
);

CREATE TABLE tb_turma_atividade (
    pk_turma_ativ int         NOT NULL AUTO_INCREMENT,
    fk_atividade  int         NOT NULL,
    fk_professor  int         NOT NULL,
    fk_sala       int         NULL,
    nome_turma    varchar(50) NOT NULL,
    ano_letivo    year        NOT NULL,
    dia_semana    tinyint     NOT NULL,
    hora_inicio   time        NOT NULL,
    hora_fim      time        NOT NULL,
    capacidade    tinyint     NOT NULL DEFAULT 15,
    situacao      enum('aberta','fechada','cancelada') NOT NULL DEFAULT 'aberta',
    criado_em     timestamp   NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_turma_ativ_nome (fk_atividade, nome_turma, ano_letivo),
    CONSTRAINT chk_dia_ativ        CHECK (dia_semana BETWEEN 1 AND 6),
    CONSTRAINT chk_horario_ativ    CHECK (hora_fim > hora_inicio),
    CONSTRAINT chk_capacidade_ativ CHECK (capacidade BETWEEN 1 AND 50),
    CONSTRAINT pk_turma_atividade PRIMARY KEY (pk_turma_ativ)
);

CREATE TABLE tb_inscricao_atividade (
    pk_inscricao        int          NOT NULL AUTO_INCREMENT,
    fk_ra_aluno         varchar(15)  NOT NULL,
    fk_turma_ativ       int          NOT NULL,
    data_inscricao      date         NOT NULL,
    data_cancelamento   date         NULL,
    motivo_cancelamento varchar(255) NULL,
    situacao            enum('ativa','cancelada','concluida','suspensa') NOT NULL DEFAULT 'ativa',
    criado_em           timestamp    NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_inscricao_aluno_turma (fk_ra_aluno, fk_turma_ativ),
    CONSTRAINT chk_data_cancel CHECK (data_cancelamento IS NULL OR data_cancelamento >= data_inscricao),
    CONSTRAINT pk_inscricao_atividade PRIMARY KEY (pk_inscricao)
);

CREATE TABLE tb_atividade_professor (
    pk_atividade_professor int              NOT NULL AUTO_INCREMENT,
    fk_grade               int              NOT NULL,
    fk_tipo_atividade      int              NOT NULL,
    nome_atividade         varchar(100)     NOT NULL,
    bimestre               tinyint UNSIGNED NOT NULL,
    data_prevista          date             NOT NULL,
    peso                   decimal(4,2)     NOT NULL DEFAULT 1.00,
    valor_maximo           decimal(4,2)     NOT NULL DEFAULT 10.00,
    CONSTRAINT chk_bimestre     CHECK (bimestre    BETWEEN 1 AND 4),
    CONSTRAINT chk_peso         CHECK (peso        > 0),
    CONSTRAINT chk_valor_maximo CHECK (valor_maximo > 0),
    CONSTRAINT pk_atividade_professor PRIMARY KEY (pk_atividade_professor)
);

CREATE TABLE tb_nota_atividade (
    pk_nota_atividade      int          NOT NULL AUTO_INCREMENT,
    fk_matricula           int          NOT NULL,
    fk_atividade_professor int          NOT NULL,
    valor_nota             decimal(4,2) NULL,
    entregue_no_prazo      bool         NOT NULL DEFAULT true,
    data_lancamento        timestamp    NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_nota_aluno_atividade (fk_matricula, fk_atividade_professor),
    CONSTRAINT chk_nota_positiva CHECK (valor_nota IS NULL OR valor_nota >= 0),
    CONSTRAINT pk_nota_atividade PRIMARY KEY (pk_nota_atividade)
);

CREATE TABLE tb_avaliacao (
    pk_avaliacao   int          NOT NULL AUTO_INCREMENT,
    fk_turma       int          NOT NULL,
    fk_materia     int          NOT NULL,
    fk_periodo     int          NOT NULL,
    nome_avaliacao varchar(50)  NOT NULL,
    tipo_avaliacao varchar(30)  NOT NULL,
    data_avaliacao date         NOT NULL,
    nota_maxima    decimal(4,2) NOT NULL DEFAULT 10.00,
    peso           decimal(3,2) NOT NULL DEFAULT 1.00,
    criado_em      timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em  timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tipo_aval   CHECK (tipo_avaliacao IN ('Prova','Trabalho','Seminario','Participacao','Exercicio','Recuperacao')),
    CONSTRAINT chk_nota_maxima CHECK (nota_maxima BETWEEN 1 AND 100),
    CONSTRAINT chk_peso_aval   CHECK (peso BETWEEN 0.1 AND 10.0),
    CONSTRAINT pk_avaliacao PRIMARY KEY (pk_avaliacao)
);

CREATE TABLE tb_nota_aluno (
    pk_nota       int          NOT NULL AUTO_INCREMENT,
    fk_avaliacao  int          NOT NULL,
    fk_ra_aluno   varchar(15)  NOT NULL,
    nota_obtida   decimal(5,2) NULL,
    observacao    varchar(255) NULL,
    criado_em     timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_nota_avaliacao_aluno (fk_avaliacao, fk_ra_aluno),
    CONSTRAINT chk_nota_aluno_positiva CHECK (nota_obtida IS NULL OR nota_obtida >= 0),
    CONSTRAINT pk_nota_aluno PRIMARY KEY (pk_nota)
);

CREATE TABLE tb_registro_frequencia (
    pk_frequencia int          NOT NULL AUTO_INCREMENT,
    fk_turma      int          NOT NULL,
    fk_ra_aluno   varchar(15)  NOT NULL,
    data_aula     date         NOT NULL,
    presente      bool         NOT NULL DEFAULT true,
    justificativa varchar(255) NULL,
    criado_em     timestamp    NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_freq_turma_aluno_data (fk_turma, fk_ra_aluno, data_aula),
    CONSTRAINT pk_registro_frequencia PRIMARY KEY (pk_frequencia)
);

CREATE TABLE tb_consolidacao_periodo (
    pk_consolidacao       int          NOT NULL AUTO_INCREMENT,
    fk_ra_aluno           varchar(15)  NOT NULL,
    fk_materia            int          NOT NULL,
    fk_periodo            int          NOT NULL,
    media_periodo         decimal(4,2) NOT NULL,
    total_faltas          int          NOT NULL DEFAULT 0,
    percentual_frequencia decimal(5,2) NOT NULL DEFAULT 100.00,
    situacao_periodo      enum('aprovado','recuperacao','reprovado','pendente') NOT NULL DEFAULT 'pendente',
    observacoes           varchar(255) NULL,
    criado_em             timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em         timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_consolidacao (fk_ra_aluno, fk_materia, fk_periodo),
    CONSTRAINT chk_media_periodo CHECK (media_periodo         BETWEEN 0 AND 10),
    CONSTRAINT chk_faltas        CHECK (total_faltas          >= 0),
    CONSTRAINT chk_freq_periodo  CHECK (percentual_frequencia BETWEEN 0 AND 100),
    CONSTRAINT pk_consolidacao_periodo PRIMARY KEY (pk_consolidacao)
);

CREATE TABLE tb_historico_escolar (
    pk_historico              int          NOT NULL AUTO_INCREMENT,
    fk_ra_aluno               varchar(15)  NOT NULL,
    fk_ano_escolar            int          NOT NULL,
    ano_letivo                year         NOT NULL,
    media_final               decimal(4,2) NOT NULL,
    total_faltas_ano          int          NOT NULL DEFAULT 0,
    percentual_frequencia_ano decimal(5,2) NOT NULL DEFAULT 100.00,
    carga_horaria_cumprida    int          NOT NULL DEFAULT 0,
    resultado_final           varchar(25)  NOT NULL,
    data_conclusao            date         NULL,
    observacoes               text         NULL,
    criado_em                 timestamp    NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_hist_escolar (fk_ra_aluno, fk_ano_escolar, ano_letivo),
    CONSTRAINT chk_media_final     CHECK (media_final               BETWEEN 0 AND 10),
    CONSTRAINT chk_freq_ano        CHECK (percentual_frequencia_ano BETWEEN 0 AND 100),
    CONSTRAINT chk_resultado_final CHECK (resultado_final IN (
        'Aprovado','Reprovado por Nota','Reprovado por Frequencia',
        'Aprovado pelo Conselho','Transferido','Em Andamento'
    )),
    CONSTRAINT pk_historico_escolar PRIMARY KEY (pk_historico)
);

CREATE TABLE tb_boletim (
    pk_boletim          int              NOT NULL AUTO_INCREMENT,
    fk_matricula        int              NOT NULL,
    fk_situacao_boletim int              NOT NULL,
    bimestre            tinyint UNSIGNED NOT NULL,
    UNIQUE INDEX uq_boletim_bimestre (fk_matricula, bimestre),
    CONSTRAINT chk_bimestre_boletim CHECK (bimestre BETWEEN 1 AND 4),
    CONSTRAINT pk_boletim PRIMARY KEY (pk_boletim)
);

CREATE TABLE tb_aluno_necessidade (
    pk_aluno_necessidade    int          NOT NULL AUTO_INCREMENT,
    fk_ra_aluno             varchar(15)  NOT NULL,
    fk_tipo_necessidade     int          NOT NULL,
    data_identificacao      date         NOT NULL,
    data_laudo              date         NULL,
    numero_laudo            varchar(50)  NULL,
    profissional_laudo      varchar(100) NULL,
    crm_crp                 varchar(20)  NULL,
    nivel_suporte           tinyint      NOT NULL DEFAULT 1,
    descricao_detalhada     text         NULL,
    observacoes_pedagogicas text         NULL,
    ativo                   bool         NOT NULL DEFAULT true,
    criado_em               timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em           timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_aluno_necessidade (fk_ra_aluno, fk_tipo_necessidade),
    CONSTRAINT chk_nivel_suporte CHECK (nivel_suporte BETWEEN 1 AND 3),
    CONSTRAINT pk_aluno_necessidade PRIMARY KEY (pk_aluno_necessidade)
);

CREATE TABLE tb_pdi (
    pk_pdi                   int          NOT NULL AUTO_INCREMENT,
    fk_ra_aluno              varchar(15)  NOT NULL,
    fk_professor_responsavel int          NOT NULL,
    fk_professor_aee         int          NULL,
    ano_letivo               year         NOT NULL,
    data_elaboracao          date         NOT NULL,
    objetivos_gerais         text         NOT NULL,
    objetivos_especificos    text         NOT NULL,
    estrategias_pedagogicas  text         NOT NULL,
    adaptacoes_curriculares  text         NULL,
    adaptacoes_avaliativas   text         NULL,
    recursos_necessarios     text         NULL,
    cronograma               text         NULL,
    situacao                 enum('vigente','revisao','encerrado','cancelado') NOT NULL DEFAULT 'vigente',
    observacoes              text         NULL,
    criado_em                timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em            timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_pdi_aluno_ano (fk_ra_aluno, ano_letivo),
    CONSTRAINT pk_pdi PRIMARY KEY (pk_pdi)
);

CREATE TABLE tb_acompanhamento_pdi (
    pk_acompanhamento        int          NOT NULL AUTO_INCREMENT,
    fk_pdi                   int          NOT NULL,
    fk_professor_registro    int          NOT NULL,
    data_registro            date         NOT NULL,
    tipo_registro            varchar(30)  NOT NULL,
    descricao                text         NOT NULL,
    avancos_observados       text         NULL,
    dificuldades_encontradas text         NULL,
    ajustes_propostos        text         NULL,
    criado_em                timestamp    NOT NULL DEFAULT current_timestamp,
    CONSTRAINT chk_tipo_registro_pdi CHECK (tipo_registro IN (
        'observacao diaria','avaliacao semanal','avaliacao mensal',
        'reuniao com familia','reuniao multidisciplinar','ajuste de estrategia'
    )),
    CONSTRAINT pk_acompanhamento_pdi PRIMARY KEY (pk_acompanhamento)
);

CREATE TABLE tb_atendimento_aee (
    pk_atendimento_aee int          NOT NULL AUTO_INCREMENT,
    fk_ra_aluno        varchar(15)  NOT NULL,
    fk_professor_aee   int          NOT NULL,
    fk_sala            int          NULL,
    ano_letivo         year         NOT NULL,
    dias_semana        varchar(50)  NOT NULL,
    hora_inicio        time         NOT NULL,
    hora_fim           time         NOT NULL,
    tipo_atendimento   varchar(50)  NOT NULL,
    objetivos          text         NOT NULL,
    situacao           enum('ativo','suspenso','encerrado') NOT NULL DEFAULT 'ativo',
    criado_em          timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em      timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_aee_aluno_ano (fk_ra_aluno, ano_letivo),
    CONSTRAINT chk_horarios_aee   CHECK (hora_fim > hora_inicio),
    CONSTRAINT chk_tipo_atend_aee CHECK (tipo_atendimento IN ('individual','pequeno grupo','orientacao familiar','apoio pedagogico')),
    CONSTRAINT pk_atendimento_aee PRIMARY KEY (pk_atendimento_aee)
);

CREATE TABLE tb_sessao_aee (
    pk_sessao             int  NOT NULL AUTO_INCREMENT,
    fk_atendimento_aee    int  NOT NULL,
    data_sessao           date NOT NULL,
    hora_inicio           time NOT NULL,
    hora_fim              time NOT NULL,
    presente              bool NOT NULL DEFAULT true,
    atividades_realizadas text NOT NULL,
    observacoes           text NULL,
    criado_em             timestamp NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_sessao_aee (fk_atendimento_aee, data_sessao),
    CONSTRAINT chk_horario_sessao CHECK (hora_fim > hora_inicio),
    CONSTRAINT pk_sessao_aee PRIMARY KEY (pk_sessao)
);

CREATE TABLE tb_contrato_financeiro (
    pk_contrato_financeiro int           NOT NULL AUTO_INCREMENT,
    fk_ra_aluno            varchar(15)   NOT NULL,
    fk_responsavel         int           NOT NULL,
    fk_matricula           int           NULL,
    ano_letivo             year          NOT NULL,
    valor_mensalidade      decimal(10,2) NOT NULL,
    numero_parcelas        tinyint       NOT NULL DEFAULT 12,
    dia_vencimento         tinyint       NOT NULL DEFAULT 10,
    situacao               enum('ativo','suspenso','cancelado','encerrado') NOT NULL DEFAULT 'ativo',
    data_assinatura        date          NOT NULL,
    criado_em              timestamp     NOT NULL DEFAULT current_timestamp,
    atualizado_em          timestamp     NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_contrato_fin_aluno_ano (fk_ra_aluno, ano_letivo),
    CONSTRAINT chk_valor_mensalidade CHECK (valor_mensalidade > 0),
    CONSTRAINT chk_parcelas          CHECK (numero_parcelas BETWEEN 1 AND 12),
    CONSTRAINT chk_dia_venc          CHECK (dia_vencimento BETWEEN 1 AND 28),
    CONSTRAINT pk_contrato_financeiro PRIMARY KEY (pk_contrato_financeiro)
);

CREATE TABLE tb_mensalidade (
    pk_mensalidade  int           NOT NULL AUTO_INCREMENT,
    fk_contrato     int           NOT NULL,
    numero_parcela  tinyint       NOT NULL,
    data_vencimento date          NOT NULL,
    valor_cobrado   decimal(10,2) NOT NULL,
    situacao        enum('pendente','paga','atrasada','cancelada','parcial') NOT NULL DEFAULT 'pendente',
    criado_em       timestamp     NOT NULL DEFAULT current_timestamp,
    atualizado_em   timestamp     NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_mensalidade_parcela (fk_contrato, numero_parcela),
    CONSTRAINT chk_parcela_mens  CHECK (numero_parcela BETWEEN 1 AND 12),
    CONSTRAINT chk_valor_cobrado CHECK (valor_cobrado > 0),
    CONSTRAINT pk_mensalidade PRIMARY KEY (pk_mensalidade)
);

CREATE TABLE tb_pagamento (
    pk_pagamento    int           NOT NULL AUTO_INCREMENT,
    fk_mensalidade  int           NOT NULL,
    data_pagamento  date          NOT NULL,
    valor_pago      decimal(10,2) NOT NULL,
    forma_pagamento varchar(30)   NOT NULL,
    numero_recibo   varchar(20)   NOT NULL,
    observacao      varchar(255)  NULL,
    criado_em       timestamp     NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_numero_recibo (numero_recibo),
    CONSTRAINT chk_valor_pago CHECK (valor_pago > 0),
    CONSTRAINT chk_forma_pag  CHECK (forma_pagamento IN (
        'Dinheiro','PIX','Cartao Credito','Cartao Debito','Boleto','Transferencia','Cheque'
    )),
    CONSTRAINT pk_pagamento PRIMARY KEY (pk_pagamento)
);

CREATE TABLE tb_inadimplencia (
    pk_inadimplencia int           NOT NULL AUTO_INCREMENT,
    fk_mensalidade   int           NOT NULL,
    data_registro    date          NOT NULL,
    dias_atraso      smallint      NOT NULL DEFAULT 0,
    valor_multa      decimal(10,2) NOT NULL DEFAULT 0.00,
    valor_juros      decimal(10,2) NOT NULL DEFAULT 0.00,
    situacao         enum('aberto','negociacao','quitada','juridico') NOT NULL DEFAULT 'aberto',
    criado_em        timestamp     NOT NULL DEFAULT current_timestamp,
    atualizado_em    timestamp     NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uq_inad_mensalidade (fk_mensalidade),
    CONSTRAINT chk_dias_atraso CHECK (dias_atraso >= 0),
    CONSTRAINT chk_multa       CHECK (valor_multa >= 0),
    CONSTRAINT chk_juros       CHECK (valor_juros >= 0),
    CONSTRAINT pk_inadimplencia PRIMARY KEY (pk_inadimplencia)
);

CREATE TABLE tb_alerta_evasao (
    pk_alerta             int      NOT NULL AUTO_INCREMENT,
    fk_matricula          int      NOT NULL,
    fk_responsavel_alerta int      NOT NULL,
    fk_tipo_risco_evasao  int      NOT NULL,
    fk_nivel_risco        int      NOT NULL,
    fk_status_alerta      int      NOT NULL,
    data_alerta           datetime NOT NULL DEFAULT current_timestamp,
    descricao             text     NULL,
    data_resolucao        datetime NULL,
    observacao_resolucao  text     NULL,
    CONSTRAINT pk_alerta_evasao PRIMARY KEY (pk_alerta)
);

CREATE TABLE tb_evasao_escolar (
    pk_evasao    int         NOT NULL AUTO_INCREMENT,
    fk_ra_aluno  varchar(15) NOT NULL,
    fk_matricula int         NOT NULL,
    data_evasao  date        NOT NULL,
    motivo       varchar(50) NOT NULL,
    detalhes     text        NULL,
    criado_em    timestamp   NOT NULL DEFAULT current_timestamp,
    CONSTRAINT chk_motivo_evasao CHECK (motivo IN (
        'Transferencia','Abandono','Mudanca de Cidade',
        'Problemas Financeiros','Problemas de Saude','Outro'
    )),
    CONSTRAINT pk_evasao_escolar PRIMARY KEY (pk_evasao)
);

CREATE TABLE tb_ocorrencia_disciplinar (
    pk_ocorrencia       int          NOT NULL AUTO_INCREMENT,
    fk_ra_aluno         varchar(15)  NOT NULL,
    fk_tipo_ocorrencia  int          NOT NULL,
    fk_funcionario      int          NOT NULL,
    data_ocorrencia     date         NOT NULL,
    descricao           text         NOT NULL,
    testemunhas         varchar(255) NULL,
    medida_aplicada     varchar(100) NULL,
    ciencia_responsavel bool         NOT NULL DEFAULT false,
    data_ciencia        date         NULL,
    criado_em           timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em       timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_data_ciencia CHECK (data_ciencia IS NULL OR data_ciencia >= data_ocorrencia),
    CONSTRAINT pk_ocorrencia_disciplinar PRIMARY KEY (pk_ocorrencia)
);

CREATE TABLE tb_comunicado (
    pk_comunicado   int          NOT NULL AUTO_INCREMENT,
    fk_funcionario  int          NOT NULL,
    titulo          varchar(100) NOT NULL,
    conteudo        text         NOT NULL,
    tipo_comunicado varchar(30)  NOT NULL,
    destinatarios   varchar(50)  NOT NULL DEFAULT 'Todos',
    data_publicacao date         NOT NULL,
    data_expiracao  date         NULL,
    prioridade      tinyint      NOT NULL DEFAULT 2,
    criado_em       timestamp    NOT NULL DEFAULT current_timestamp,
    atualizado_em   timestamp    NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_tipo_comunicado  CHECK (tipo_comunicado IN (
        'Informativo','Reuniao','Evento','Urgente','Financeiro','Pedagogico','Extracurricular'
    )),
    CONSTRAINT chk_destinatarios    CHECK (destinatarios IN ('Todos','Professores','Responsaveis','Alunos','Funcionarios')),
    CONSTRAINT chk_prioridade       CHECK (prioridade BETWEEN 1 AND 5),
    CONSTRAINT chk_datas_comunicado CHECK (data_expiracao IS NULL OR data_expiracao >= data_publicacao),
    CONSTRAINT pk_comunicado PRIMARY KEY (pk_comunicado)
);

CREATE TABLE tb_leitura_comunicado (
    pk_leitura    int       NOT NULL AUTO_INCREMENT,
    fk_comunicado int       NOT NULL,
    fk_pessoa     int       NOT NULL,
    data_leitura  timestamp NOT NULL DEFAULT current_timestamp,
    UNIQUE INDEX uq_leitura_comunicado (fk_comunicado, fk_pessoa),
    CONSTRAINT pk_leitura_comunicado PRIMARY KEY (pk_leitura)
);

ALTER TABLE tb_endereco ADD CONSTRAINT fk_endereco_pessoa FOREIGN KEY (fk_pessoa) REFERENCES tb_pessoa (pk_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_email ADD CONSTRAINT fk_email_pessoa FOREIGN KEY (fk_pessoa) REFERENCES tb_pessoa (pk_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_telefone ADD CONSTRAINT fk_telefone_pessoa FOREIGN KEY (fk_pessoa) REFERENCES tb_pessoa (pk_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_responsavel ADD CONSTRAINT fk_responsavel_pessoa FOREIGN KEY (fk_pessoa) REFERENCES tb_pessoa (pk_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_funcionario ADD CONSTRAINT fk_funcionario_pessoa FOREIGN KEY (fk_pessoa) REFERENCES tb_pessoa (pk_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_historico_situacao_funcionario ADD CONSTRAINT fk_hist_sit_func FOREIGN KEY (fk_funcionario) REFERENCES tb_funcionario (pk_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_contrato ADD CONSTRAINT fk_contrato_funcionario FOREIGN KEY (fk_funcionario) REFERENCES tb_funcionario (pk_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_contrato ADD CONSTRAINT fk_contrato_tipo FOREIGN KEY (fk_tipo_contrato) REFERENCES tb_tipo_contrato (pk_tipo_contrato) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_contrato ADD CONSTRAINT fk_contrato_status FOREIGN KEY (fk_status_contrato) REFERENCES tb_status_contrato (pk_status_contrato) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_historico_cargo ADD CONSTRAINT fk_hist_cargo_contrato FOREIGN KEY (fk_contrato) REFERENCES tb_contrato (pk_contrato) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_historico_cargo ADD CONSTRAINT fk_hist_cargo_cargo FOREIGN KEY (fk_cargo) REFERENCES tb_cargo (pk_cargo) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_historico_salario ADD CONSTRAINT fk_hist_salario_contrato FOREIGN KEY (fk_contrato) REFERENCES tb_contrato (pk_contrato) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_folha_pagamento ADD CONSTRAINT fk_folha_contrato FOREIGN KEY (fk_contrato) REFERENCES tb_contrato (pk_contrato) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_verba_folha ADD CONSTRAINT fk_verba_folha_folha FOREIGN KEY (fk_folha) REFERENCES tb_folha_pagamento (pk_folha_pagamento) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_verba_folha ADD CONSTRAINT fk_verba_tipo FOREIGN KEY (fk_tipo_verba) REFERENCES tb_tipo_verba (pk_tipo_verba) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_professor ADD CONSTRAINT fk_professor_funcionario FOREIGN KEY (fk_funcionario) REFERENCES tb_funcionario (pk_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_professor ADD CONSTRAINT fk_professor_tipo_aula FOREIGN KEY (fk_tipo_aula) REFERENCES tb_tipo_aula (pk_tipo_aula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_formacao_professor ADD CONSTRAINT fk_formacao_professor FOREIGN KEY (fk_professor) REFERENCES tb_professor (pk_professor) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_formacao_professor ADD CONSTRAINT fk_formacao_nivel FOREIGN KEY (fk_nivel_formacao) REFERENCES tb_nivel_formacao (pk_nivel_formacao) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_carga_horaria_professor ADD CONSTRAINT fk_carga_professor FOREIGN KEY (fk_professor) REFERENCES tb_professor (pk_professor) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_calendario_letivo ADD CONSTRAINT fk_calendario_ano FOREIGN KEY (fk_ano_letivo) REFERENCES tb_ano_letivo (pk_ano_letivo) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_evento_escolar ADD CONSTRAINT fk_evento_calendario FOREIGN KEY (fk_calendario) REFERENCES tb_calendario_letivo (pk_calendario) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_periodo_letivo ADD CONSTRAINT fk_periodo_calendario FOREIGN KEY (fk_calendario) REFERENCES tb_calendario_letivo (pk_calendario) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_turma ADD CONSTRAINT fk_turma_ano_letivo FOREIGN KEY (fk_ano_letivo) REFERENCES tb_ano_letivo (pk_ano_letivo) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_turma ADD CONSTRAINT fk_turma_ano_escolar FOREIGN KEY (fk_ano_escolar) REFERENCES tb_ano_escolar (pk_ano_escolar) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_turma ADD CONSTRAINT fk_turma_sala FOREIGN KEY (fk_sala) REFERENCES tb_sala (pk_sala) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_materia ADD CONSTRAINT fk_materia_area FOREIGN KEY (fk_area_conhecimento) REFERENCES tb_area_conhecimento (pk_area_conhecimento) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_materia ADD CONSTRAINT fk_materia_ano_escolar FOREIGN KEY (fk_ano_escolar) REFERENCES tb_ano_escolar (pk_ano_escolar) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_grade_curricular ADD CONSTRAINT fk_grade_turma FOREIGN KEY (fk_turma) REFERENCES tb_turma (pk_turma) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_grade_curricular ADD CONSTRAINT fk_grade_materia FOREIGN KEY (fk_materia) REFERENCES tb_materia (pk_materia) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_grade_curricular ADD CONSTRAINT fk_grade_professor FOREIGN KEY (fk_professor) REFERENCES tb_professor (pk_professor) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_horario_aula ADD CONSTRAINT fk_horario_grade FOREIGN KEY (fk_grade) REFERENCES tb_grade_curricular (pk_grade) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_horario_aula ADD CONSTRAINT fk_horario_sala FOREIGN KEY (fk_sala) REFERENCES tb_sala (pk_sala) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_aluno ADD CONSTRAINT fk_aluno_pessoa FOREIGN KEY (fk_pessoa) REFERENCES tb_pessoa (pk_pessoa) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_aluno ADD CONSTRAINT fk_aluno_tipo_escola FOREIGN KEY (fk_tipo_escola_anterior) REFERENCES tb_tipo_escola_anterior (pk_tipo_escola_anterior) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_responsavel_aluno ADD CONSTRAINT fk_resp_aluno_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_responsavel_aluno ADD CONSTRAINT fk_resp_aluno_responsavel FOREIGN KEY (fk_responsavel) REFERENCES tb_responsavel (pk_responsavel) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_profissao_responsavel ADD CONSTRAINT fk_prof_resp_responsavel FOREIGN KEY (fk_responsavel) REFERENCES tb_responsavel (pk_responsavel) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_profissao_responsavel ADD CONSTRAINT fk_prof_resp_profissao FOREIGN KEY (fk_profissao) REFERENCES tb_profissao (pk_profissao) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_matricula ADD CONSTRAINT fk_matricula_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_matricula ADD CONSTRAINT fk_matricula_turma FOREIGN KEY (fk_turma) REFERENCES tb_turma (pk_turma) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_matricula ADD CONSTRAINT fk_matricula_tipo_ingresso FOREIGN KEY (fk_tipo_ingresso) REFERENCES tb_tipo_ingresso (pk_tipo_ingresso) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_matricula ADD CONSTRAINT fk_matricula_status FOREIGN KEY (fk_status_matricula) REFERENCES tb_status_matricula (pk_status_matricula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_atestado ADD CONSTRAINT fk_atestado_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula (pk_matricula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_presenca_aluno ADD CONSTRAINT fk_presenca_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula (pk_matricula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_presenca_aluno ADD CONSTRAINT fk_presenca_calendario FOREIGN KEY (fk_calendario) REFERENCES tb_calendario_letivo (pk_calendario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_presenca_aluno ADD CONSTRAINT fk_presenca_horario FOREIGN KEY (fk_horario_aula) REFERENCES tb_horario_aula (pk_horario_aula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_presenca_aluno ADD CONSTRAINT fk_presenca_atestado FOREIGN KEY (fk_atestado) REFERENCES tb_atestado (pk_atestado) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE tb_atividade_extracurricular ADD CONSTRAINT fk_ativ_categoria FOREIGN KEY (fk_categoria) REFERENCES tb_categoria_atividade (pk_categoria) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_aluno_atividade ADD CONSTRAINT fk_aluno_ativ_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_aluno_atividade ADD CONSTRAINT fk_aluno_ativ_ativ FOREIGN KEY (fk_atividade) REFERENCES tb_atividade_extracurricular (pk_atividade) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_turma_atividade ADD CONSTRAINT fk_turma_ativ_ativ FOREIGN KEY (fk_atividade) REFERENCES tb_atividade_extracurricular (pk_atividade) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_turma_atividade ADD CONSTRAINT fk_turma_ativ_professor FOREIGN KEY (fk_professor) REFERENCES tb_professor (pk_professor) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_turma_atividade ADD CONSTRAINT fk_turma_ativ_sala FOREIGN KEY (fk_sala) REFERENCES tb_sala (pk_sala) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_inscricao_atividade ADD CONSTRAINT fk_inscricao_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_inscricao_atividade ADD CONSTRAINT fk_inscricao_turma_ativ FOREIGN KEY (fk_turma_ativ) REFERENCES tb_turma_atividade (pk_turma_ativ) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_atividade_professor ADD CONSTRAINT fk_atividade_grade FOREIGN KEY (fk_grade) REFERENCES tb_grade_curricular (pk_grade) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_atividade_professor ADD CONSTRAINT fk_atividade_tipo FOREIGN KEY (fk_tipo_atividade) REFERENCES tb_tipo_atividade (pk_tipo_atividade) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_nota_atividade ADD CONSTRAINT fk_nota_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula (pk_matricula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_nota_atividade ADD CONSTRAINT fk_nota_atividade_prof FOREIGN KEY (fk_atividade_professor) REFERENCES tb_atividade_professor (pk_atividade_professor) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_avaliacao ADD CONSTRAINT fk_avaliacao_turma FOREIGN KEY (fk_turma) REFERENCES tb_turma (pk_turma) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_avaliacao ADD CONSTRAINT fk_avaliacao_materia FOREIGN KEY (fk_materia) REFERENCES tb_materia (pk_materia) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_avaliacao ADD CONSTRAINT fk_avaliacao_periodo FOREIGN KEY (fk_periodo) REFERENCES tb_periodo_letivo (pk_periodo) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_nota_aluno ADD CONSTRAINT fk_nota_aluno_avaliacao FOREIGN KEY (fk_avaliacao) REFERENCES tb_avaliacao (pk_avaliacao) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_nota_aluno ADD CONSTRAINT fk_nota_aluno_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_registro_frequencia ADD CONSTRAINT fk_freq_turma FOREIGN KEY (fk_turma) REFERENCES tb_turma (pk_turma) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_registro_frequencia ADD CONSTRAINT fk_freq_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_consolidacao_periodo ADD CONSTRAINT fk_consol_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_consolidacao_periodo ADD CONSTRAINT fk_consol_materia FOREIGN KEY (fk_materia) REFERENCES tb_materia (pk_materia) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_consolidacao_periodo ADD CONSTRAINT fk_consol_periodo FOREIGN KEY (fk_periodo) REFERENCES tb_periodo_letivo (pk_periodo) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_historico_escolar ADD CONSTRAINT fk_hist_escolar_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_historico_escolar ADD CONSTRAINT fk_hist_escolar_ano FOREIGN KEY (fk_ano_escolar) REFERENCES tb_ano_escolar (pk_ano_escolar) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_boletim ADD CONSTRAINT fk_boletim_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula (pk_matricula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_boletim ADD CONSTRAINT fk_boletim_situacao FOREIGN KEY (fk_situacao_boletim) REFERENCES tb_situacao_boletim (pk_situacao_boletim) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_aluno_necessidade ADD CONSTRAINT fk_aluno_nec_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_aluno_necessidade ADD CONSTRAINT fk_aluno_nec_tipo FOREIGN KEY (fk_tipo_necessidade) REFERENCES tb_tipo_necessidade_apoio (pk_tipo_necessidade) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_pdi ADD CONSTRAINT fk_pdi_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_pdi ADD CONSTRAINT fk_pdi_professor FOREIGN KEY (fk_professor_responsavel) REFERENCES tb_professor (pk_professor) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_pdi ADD CONSTRAINT fk_pdi_prof_aee FOREIGN KEY (fk_professor_aee) REFERENCES tb_professor (pk_professor) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE tb_acompanhamento_pdi ADD CONSTRAINT fk_acomp_pdi FOREIGN KEY (fk_pdi) REFERENCES tb_pdi (pk_pdi) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_acompanhamento_pdi ADD CONSTRAINT fk_acomp_professor FOREIGN KEY (fk_professor_registro) REFERENCES tb_professor (pk_professor) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_atendimento_aee ADD CONSTRAINT fk_aee_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_atendimento_aee ADD CONSTRAINT fk_aee_professor FOREIGN KEY (fk_professor_aee) REFERENCES tb_professor (pk_professor) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_atendimento_aee ADD CONSTRAINT fk_aee_sala FOREIGN KEY (fk_sala) REFERENCES tb_sala (pk_sala) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_sessao_aee ADD CONSTRAINT fk_sessao_atendimento FOREIGN KEY (fk_atendimento_aee) REFERENCES tb_atendimento_aee (pk_atendimento_aee) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_contrato_financeiro ADD CONSTRAINT fk_cont_fin_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_contrato_financeiro ADD CONSTRAINT fk_cont_fin_responsavel FOREIGN KEY (fk_responsavel) REFERENCES tb_responsavel (pk_responsavel) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_contrato_financeiro ADD CONSTRAINT fk_cont_fin_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula (pk_matricula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_mensalidade ADD CONSTRAINT fk_mensalidade_contrato FOREIGN KEY (fk_contrato) REFERENCES tb_contrato_financeiro (pk_contrato_financeiro) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_pagamento ADD CONSTRAINT fk_pagamento_mensalidade FOREIGN KEY (fk_mensalidade) REFERENCES tb_mensalidade (pk_mensalidade) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_inadimplencia ADD CONSTRAINT fk_inad_mensalidade FOREIGN KEY (fk_mensalidade) REFERENCES tb_mensalidade (pk_mensalidade) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula (pk_matricula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_funcionario FOREIGN KEY (fk_responsavel_alerta) REFERENCES tb_funcionario (pk_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_tipo_risco FOREIGN KEY (fk_tipo_risco_evasao) REFERENCES tb_tipo_risco_evasao (pk_tipo_risco_evasao) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_nivel_risco FOREIGN KEY (fk_nivel_risco) REFERENCES tb_nivel_risco_evasao (pk_nivel_risco) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_alerta_evasao ADD CONSTRAINT fk_alerta_status FOREIGN KEY (fk_status_alerta) REFERENCES tb_status_alerta (pk_status_alerta) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_evasao_escolar ADD CONSTRAINT fk_evasao_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_evasao_escolar ADD CONSTRAINT fk_evasao_matricula FOREIGN KEY (fk_matricula) REFERENCES tb_matricula (pk_matricula) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_ocorrencia_disciplinar ADD CONSTRAINT fk_ocor_aluno FOREIGN KEY (fk_ra_aluno) REFERENCES tb_aluno (pk_ra) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_ocorrencia_disciplinar ADD CONSTRAINT fk_ocor_tipo FOREIGN KEY (fk_tipo_ocorrencia) REFERENCES tb_tipo_ocorrencia (pk_tipo_ocorrencia) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_ocorrencia_disciplinar ADD CONSTRAINT fk_ocor_funcionario FOREIGN KEY (fk_funcionario) REFERENCES tb_funcionario (pk_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_comunicado ADD CONSTRAINT fk_comunicado_funcionario FOREIGN KEY (fk_funcionario) REFERENCES tb_funcionario (pk_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tb_leitura_comunicado ADD CONSTRAINT fk_leitura_comunicado FOREIGN KEY (fk_comunicado) REFERENCES tb_comunicado (pk_comunicado) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tb_leitura_comunicado ADD CONSTRAINT fk_leitura_pessoa FOREIGN KEY (fk_pessoa) REFERENCES tb_pessoa (pk_pessoa) ON DELETE CASCADE ON UPDATE CASCADE;


CREATE INDEX idx_pessoa_nome ON tb_pessoa (nome, sobrenome);
CREATE INDEX idx_func_situacao ON tb_funcionario (situacao);
CREATE INDEX idx_aluno_situacao ON tb_aluno (situacao);
CREATE INDEX idx_matricula_situacao ON tb_matricula (fk_status_matricula);
CREATE INDEX idx_turma_ano ON tb_turma (fk_ano_letivo);
CREATE INDEX idx_horario_dia ON tb_horario_aula (dia_semana);
CREATE INDEX idx_nota_atividade ON tb_nota_atividade (fk_atividade_professor);
CREATE INDEX idx_presenca_calendario ON tb_presenca_aluno (fk_calendario);
CREATE INDEX idx_alerta_data ON tb_alerta_evasao (data_alerta);
CREATE INDEX idx_mensalidade_venc ON tb_mensalidade (data_vencimento);
CREATE INDEX idx_mensalidade_sit ON tb_mensalidade (situacao);
CREATE INDEX idx_pagamento_data ON tb_pagamento (data_pagamento);
CREATE INDEX idx_freq_data ON tb_registro_frequencia (data_aula);
CREATE INDEX idx_nota_avaliacao ON tb_nota_aluno (fk_avaliacao);
CREATE INDEX idx_consolidacao_aluno ON tb_consolidacao_periodo (fk_ra_aluno);
CREATE INDEX idx_aluno_necessidade ON tb_aluno_necessidade (fk_ra_aluno);
CREATE INDEX idx_tipo_necessidade ON tb_aluno_necessidade (fk_tipo_necessidade);
CREATE INDEX idx_pdi_aluno ON tb_pdi (fk_ra_aluno);
CREATE INDEX idx_aee_aluno ON tb_atendimento_aee (fk_ra_aluno);
CREATE INDEX idx_inscricao_aluno ON tb_inscricao_atividade (fk_ra_aluno);
CREATE INDEX idx_inscricao_turma ON tb_inscricao_atividade (fk_turma_ativ);
CREATE INDEX idx_ocorrencia_aluno ON tb_ocorrencia_disciplinar (fk_ra_aluno);
CREATE INDEX idx_hist_salario_cont ON tb_historico_salario (fk_contrato, data_fim);
CREATE INDEX idx_hist_cargo_cont ON tb_historico_cargo (fk_contrato, data_fim);

DELIMITER //

CREATE TRIGGER trg_check_nota_maxima_ins
BEFORE INSERT ON tb_nota_atividade
FOR EACH ROW
BEGIN
    DECLARE v_nota_maxima DECIMAL(4,2);
    SELECT valor_maximo INTO v_nota_maxima
    FROM tb_atividade_professor
    WHERE pk_atividade_professor = NEW.fk_atividade_professor;
    IF NEW.valor_nota IS NOT NULL AND NEW.valor_nota > v_nota_maxima THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nota obtida excede o valor maximo da atividade';
    END IF;
END//

CREATE TRIGGER trg_check_nota_maxima_upd
BEFORE UPDATE ON tb_nota_atividade
FOR EACH ROW
BEGIN
    DECLARE v_nota_maxima DECIMAL(4,2);
    SELECT valor_maximo INTO v_nota_maxima
    FROM tb_atividade_professor
    WHERE pk_atividade_professor = NEW.fk_atividade_professor;
    IF NEW.valor_nota IS NOT NULL AND NEW.valor_nota > v_nota_maxima THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nota obtida excede o valor maximo da atividade';
    END IF;
END//

CREATE TRIGGER trg_check_nota_aluno_ins
BEFORE INSERT ON tb_nota_aluno
FOR EACH ROW
BEGIN
    DECLARE v_nota_maxima DECIMAL(4,2);
    SELECT nota_maxima INTO v_nota_maxima
    FROM tb_avaliacao
    WHERE pk_avaliacao = NEW.fk_avaliacao;
    IF NEW.nota_obtida IS NOT NULL AND NEW.nota_obtida > v_nota_maxima THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nota obtida excede a nota maxima da avaliacao';
    END IF;
END//

CREATE TRIGGER trg_check_nota_aluno_upd
BEFORE UPDATE ON tb_nota_aluno
FOR EACH ROW
BEGIN
    DECLARE v_nota_maxima DECIMAL(4,2);
    SELECT nota_maxima INTO v_nota_maxima
    FROM tb_avaliacao
    WHERE pk_avaliacao = NEW.fk_avaliacao;
    IF NEW.nota_obtida IS NOT NULL AND NEW.nota_obtida > v_nota_maxima THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nota obtida excede a nota maxima da avaliacao';
    END IF;
END//

CREATE TRIGGER trg_historico_funcionario
AFTER UPDATE ON tb_funcionario
FOR EACH ROW
BEGIN
    IF OLD.situacao != NEW.situacao THEN
        INSERT INTO tb_historico_situacao_funcionario
            (fk_funcionario, situacao_anterior, situacao_nova)
        VALUES
            (NEW.pk_funcionario, OLD.situacao, NEW.situacao);
    END IF;
END//

CREATE TRIGGER trg_check_capacidade_turma
BEFORE INSERT ON tb_matricula
FOR EACH ROW
BEGIN
    DECLARE v_capacidade INT;
    DECLARE v_matriculados INT;
    SELECT capacidade_maxima INTO v_capacidade
    FROM tb_turma WHERE pk_turma = NEW.fk_turma;
    SELECT COUNT(*) INTO v_matriculados
    FROM tb_matricula
    WHERE fk_turma = NEW.fk_turma
      AND fk_status_matricula IN (
          SELECT pk_status_matricula FROM tb_status_matricula WHERE descricao = 'Ativa'
      );
    IF v_capacidade IS NOT NULL AND v_matriculados >= v_capacidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Turma ja atingiu capacidade maxima';
    END IF;
END//

CREATE TRIGGER trg_check_conflito_horario_prof_ins
BEFORE INSERT ON tb_horario_aula
FOR EACH ROW
BEGIN
    DECLARE v_conflitos INT;
    SELECT COUNT(*) INTO v_conflitos
    FROM tb_horario_aula h
    JOIN tb_grade_curricular g ON g.pk_grade = h.fk_grade
    WHERE g.fk_professor = (
              SELECT fk_professor FROM tb_grade_curricular WHERE pk_grade = NEW.fk_grade
          )
      AND h.dia_semana  = NEW.dia_semana
      AND h.hora_inicio < NEW.hora_fim
      AND h.hora_fim    > NEW.hora_inicio;
    IF v_conflitos > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Professor ja possui aula neste horario';
    END IF;
END//

CREATE TRIGGER trg_check_conflito_horario_prof_upd
BEFORE UPDATE ON tb_horario_aula
FOR EACH ROW
BEGIN
    DECLARE v_conflitos INT;
    SELECT COUNT(*) INTO v_conflitos
    FROM tb_horario_aula h
    JOIN tb_grade_curricular g ON g.pk_grade = h.fk_grade
    WHERE g.fk_professor = (
              SELECT fk_professor FROM tb_grade_curricular WHERE pk_grade = NEW.fk_grade
          )
      AND h.pk_horario_aula <> NEW.pk_horario_aula
      AND h.dia_semana      = NEW.dia_semana
      AND h.hora_inicio     < NEW.hora_fim
      AND h.hora_fim        > NEW.hora_inicio;
    IF v_conflitos > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Professor ja possui aula neste horario';
    END IF;
END//

CREATE TRIGGER trg_check_conflito_horario_sala_ins
BEFORE INSERT ON tb_horario_aula
FOR EACH ROW
BEGIN
    DECLARE v_conflitos INT;
    IF NEW.fk_sala IS NOT NULL THEN
        SELECT COUNT(*) INTO v_conflitos
        FROM tb_horario_aula
        WHERE fk_sala     = NEW.fk_sala
          AND dia_semana  = NEW.dia_semana
          AND hora_inicio < NEW.hora_fim
          AND hora_fim    > NEW.hora_inicio;
        IF v_conflitos > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sala ja esta ocupada neste horario';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_check_conflito_horario_sala_upd
BEFORE UPDATE ON tb_horario_aula
FOR EACH ROW
BEGIN
    DECLARE v_conflitos INT;
    IF NEW.fk_sala IS NOT NULL THEN
        SELECT COUNT(*) INTO v_conflitos
        FROM tb_horario_aula
        WHERE fk_sala         = NEW.fk_sala
          AND pk_horario_aula <> NEW.pk_horario_aula
          AND dia_semana      = NEW.dia_semana
          AND hora_inicio     < NEW.hora_fim
          AND hora_fim        > NEW.hora_inicio;
        IF v_conflitos > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sala ja esta ocupada neste horario';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_check_capacidade_turma_ativ
BEFORE INSERT ON tb_inscricao_atividade
FOR EACH ROW
BEGIN
    DECLARE v_capacidade INT;
    DECLARE v_inscritos  INT;
    SELECT capacidade INTO v_capacidade
    FROM tb_turma_atividade WHERE pk_turma_ativ = NEW.fk_turma_ativ;
    SELECT COUNT(*) INTO v_inscritos
    FROM tb_inscricao_atividade
    WHERE fk_turma_ativ = NEW.fk_turma_ativ AND situacao = 'Ativa';
    IF v_inscritos >= v_capacidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Turma de atividade extracurricular ja atingiu capacidade maxima';
    END IF;
END//

DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_check_contrato_ativo
BEFORE INSERT ON tb_contrato
FOR EACH ROW
BEGIN
    DECLARE v_ativos INT;
    SELECT COUNT(*) INTO v_ativos
    FROM tb_contrato c
    JOIN tb_status_contrato sc ON sc.pk_status_contrato = c.fk_status_contrato
    WHERE c.fk_funcionario = NEW.fk_funcionario
      AND sc.descricao = 'Ativo';
    IF v_ativos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Funcionario ja possui um contrato ativo';
    END IF;
END//
DELIMITER ;