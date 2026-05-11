-- ═══════════════════════════════════════════════════════════════════════════
-- SCRIPT DML — Aurora EduTech v06
-- Carga de Dados Operacionais — IDEMPOTENTE (INSERT IGNORE)
--
-- Estratégia de idempotência:
--   • INSERT IGNORE → ignora silenciosamente duplicatas (UNIQUE ou PK)
--   • Dados com AUTO_INCREMENT usam INSERT IGNORE sem especificar PK,
--     mas com valores únicos nos campos com UNIQUE INDEX para garantir
--     que reexecuções não dupliquem registros.
--   • Onde a PK é composta (sem AUTO_INCREMENT), INSERT IGNORE protege
--     diretamente pela chave primária.

-- 1. tb_tipo_escola_anterior
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_tipo_escola_anterior (pk_tipo_escola_anterior, descricao) VALUES
(1, 'Pública Municipal'),
(2, 'Pública Estadual'),
(3, 'Particular'),
(4, 'Federal'),
(5, 'Não informado');

-- ───────────────────────────────────────────────────────────────────────────
-- 2. tb_tipo_ingresso
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_tipo_ingresso (pk_tipo_ingresso, descricao, ativo) VALUES
(1, 'Matrícula Nova',          TRUE),
(2, 'Transferência Externa',   TRUE),
(3, 'Rematrícula',             TRUE),
(4, 'Transferência Interna',   TRUE),
(5, 'Cortesia Institucional',  FALSE);

-- ───────────────────────────────────────────────────────────────────────────
-- 3. tb_status_matricula  ← 'ativa' OBRIGATÓRIO para trigger Grupo 4
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_status_matricula (pk_status_matricula, descricao) VALUES
(1, 'ativa'),
(2, 'trancada'),
(3, 'cancelada'),
(4, 'concluida'),
(5, 'pendente');

-- ───────────────────────────────────────────────────────────────────────────
-- 4. tb_situacao_boletim
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_situacao_boletim (pk_situacao_boletim, descricao, ativo) VALUES
(1, 'Aprovado',          TRUE),
(2, 'Reprovado',         TRUE),
(3, 'Em Recuperação',    TRUE),
(4, 'Em Andamento',      TRUE),
(5, 'Aguardando Notas',  TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 5. tb_nivel_risco_evasao
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_nivel_risco_evasao (pk_nivel_risco, descricao, ordem) VALUES
(1, 'Baixo',    1),
(2, 'Médio',    2),
(3, 'Alto',     3),
(4, 'Crítico',  4);

-- ───────────────────────────────────────────────────────────────────────────
-- 6. tb_tipo_risco_evasao
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_tipo_risco_evasao (pk_tipo_risco_evasao, descricao, ativo) VALUES
(1, 'Inadimplência Financeira',        TRUE),
(2, 'Frequência Abaixo do Mínimo',     TRUE),
(3, 'Baixo Rendimento Acadêmico',      TRUE),
(4, 'Problemas Disciplinares',         TRUE),
(5, 'Ausência de Responsável',         TRUE),
(6, 'Solicitação de Transferência',    TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 7. tb_status_alerta
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_status_alerta (pk_status_alerta, descricao, ativo) VALUES
(1, 'Aberto',          TRUE),
(2, 'Em Análise',      TRUE),
(3, 'Resolvido',       TRUE),
(4, 'Arquivado',       TRUE),
(5, 'Cancelado',       FALSE);

-- ───────────────────────────────────────────────────────────────────────────
-- 8. tb_area_conhecimento
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_area_conhecimento (pk_area_conhecimento, descricao) VALUES
(1, 'Linguagens'),
(2, 'Matemática'),
(3, 'Ciências da Natureza'),
(4, 'Ciências Humanas'),
(5, 'Artes'),
(6, 'Educação Física');

-- ───────────────────────────────────────────────────────────────────────────
-- 9. tb_materia
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_materia (pk_materia, fk_area_conhecimento, nome_materia, ativo) VALUES
(1,  1, 'Português',            TRUE),
(2,  1, 'Inglês',               TRUE),
(3,  2, 'Matemática',           TRUE),
(4,  3, 'Ciências',             TRUE),
(5,  4, 'História',             TRUE),
(6,  4, 'Geografia',            TRUE),
(7,  5, 'Artes',                TRUE),
(8,  6, 'Educação Física',      TRUE),
(9,  3, 'Física',               FALSE),
(10, 3, 'Química',              FALSE);

-- ───────────────────────────────────────────────────────────────────────────
-- 10. tb_tipo_atividade
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_tipo_atividade (pk_tipo_atividade, descricao) VALUES
(1, 'Prova'),
(2, 'Trabalho'),
(3, 'Exercício'),
(4, 'Seminário'),
(5, 'Projeto');

-- ───────────────────────────────────────────────────────────────────────────
-- 11. tb_tipo_aula
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_tipo_aula (pk_tipo_aula, descricao) VALUES
(1, 'Presencial'),
(2, 'Híbrida'),
(3, 'Reforço'),
(4, 'Educação Especial');

-- ───────────────────────────────────────────────────────────────────────────
-- 12. tb_tipo_contrato
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_tipo_contrato (pk_tipo_contrato, descricao) VALUES
(1, 'CLT'),
(2, 'PJ'),
(3, 'Estágio'),
(4, 'Temporário');

-- ───────────────────────────────────────────────────────────────────────────
-- 13. tb_cargo
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_cargo (pk_cargo, nome_cargo, descricao, ativo) VALUES
(1, 'Professor',            'Docente responsável por ministrar aulas',         TRUE),
(2, 'Coordenador',          'Coordenação pedagógica',                          TRUE),
(3, 'Diretor',              'Gestão geral da unidade escolar',                 TRUE),
(4, 'Secretário',           'Atendimento e documentação escolar',              TRUE),
(5, 'Auxiliar Administrativo', 'Suporte às atividades administrativas',        TRUE),
(6, 'Inspetor',             'Supervisão de alunos no ambiente escolar',        TRUE),
(7, 'Psicólogo Escolar',    'Acompanhamento psicológico de alunos',            TRUE),
(8, 'Porteiro',             'Controle de acesso à unidade',                    FALSE);

-- ───────────────────────────────────────────────────────────────────────────
-- 14. tb_nivel_formacao
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_nivel_formacao (pk_nivel_formacao, descricao) VALUES
(1, 'Graduação'),
(2, 'Especialização'),
(3, 'Mestrado'),
(4, 'Doutorado'),
(5, 'Técnico');

-- ───────────────────────────────────────────────────────────────────────────
-- 15. tb_profissao
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_profissao (pk_profissao, profissao, descricao) VALUES
(1, 'Médico',       'Profissional da área da saúde'),
(2, 'Engenheiro',   'Profissional de engenharia'),
(3, 'Advogado',     'Profissional do direito'),
(4, 'Professor',    'Profissional da educação'),
(5, 'Comerciante',  'Profissional do comércio'),
(6, 'Autônomo',     'Profissional liberal sem vínculo'),
(7, 'Funcionário Público', 'Servidor do setor público');

-- ───────────────────────────────────────────────────────────────────────────
-- 16. tb_tipo_verba
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_tipo_verba (pk_tipo_verba, descricao, natureza_verba, ativo) VALUES
(1,  'Salário Base',           'credito', TRUE),
(2,  'Hora Extra',             'credito', TRUE),
(3,  'Adicional Noturno',      'credito', TRUE),
(4,  'Vale Transporte',        'credito', TRUE),
(5,  'Vale Alimentação',       'credito', TRUE),
(6,  'INSS',                   'debito',  TRUE),
(7,  'IRRF',                   'debito',  TRUE),
(8,  'Desconto Falta',         'debito',  TRUE),
(9,  '13º Salário',            'credito', TRUE),
(10, 'Férias',                 'credito', TRUE),
(11, 'Rescisão',               'credito', TRUE),
(12, 'Adiantamento Quinzenal', 'credito', TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 17. tb_ano_letivo  ← apenas 2025 ativo (trigger Grupo 5)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_ano_letivo (pk_ano_letivo, ano, data_inicio, data_fim, ativo) VALUES
(1, 2023, '2023-02-06', '2023-12-15', FALSE),
(2, 2024, '2024-02-05', '2024-12-13', FALSE),
(3, 2025, '2025-02-03', '2025-12-12', TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 18. tb_turma (5 turmas em 2025 — anos_escolares 1 a 5)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_turma (pk_turma, fk_ano_letivo, nome_turma, ano_escolar, periodo, capacidade_maxima) VALUES
(1, 3, '1A', 1, 'manha', 30),
(2, 3, '2A', 2, 'manha', 30),
(3, 3, '3A', 3, 'tarde', 28),
(4, 3, '4A', 4, 'tarde', 28),
(5, 3, '5A', 5, 'manha', 25),
(6, 2, '1A', 1, 'manha', 30),
(7, 2, '2A', 2, 'tarde', 30);

-- ───────────────────────────────────────────────────────────────────────────
-- 19. tb_calendario_letivo  (dias úteis e feriados — amostra)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_calendario_letivo (pk_calendario, fk_ano_letivo, data_evento, tipo_dia, letivo) VALUES
(1,  3, '2025-02-03', 'util',     TRUE),
(2,  3, '2025-02-04', 'util',     TRUE),
(3,  3, '2025-02-05', 'util',     TRUE),
(4,  3, '2025-03-03', 'util',     TRUE),
(5,  3, '2025-03-04', 'util',     TRUE),
(6,  3, '2025-04-18', 'feriado',  FALSE),
(7,  3, '2025-04-21', 'feriado',  FALSE),
(8,  3, '2025-05-01', 'feriado',  FALSE),
(9,  3, '2025-06-02', 'util',     TRUE),
(10, 3, '2025-06-03', 'util',     TRUE),
(11, 3, '2025-07-07', 'recesso',  FALSE),
(12, 3, '2025-07-08', 'recesso',  FALSE),
(13, 3, '2025-08-04', 'util',     TRUE),
(14, 3, '2025-08-05', 'util',     TRUE),
(15, 3, '2025-09-07', 'feriado',  FALSE),
(16, 3, '2025-10-06', 'util',     TRUE),
(17, 3, '2025-10-07', 'util',     TRUE),
(18, 3, '2025-11-02', 'feriado',  FALSE),
(19, 3, '2025-11-15', 'feriado',  FALSE),
(20, 3, '2025-12-12', 'util',     TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 20. tb_evento_escolar
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_evento_escolar (pk_evento, fk_calendario, titulo_evento, descricao, hora_inicio, hora_fim) VALUES
(1, 1,  'Primeiro Dia de Aula 2025',     'Abertura do ano letivo 2025',            '07:00:00', '12:00:00'),
(2, 6,  'Sexta-feira Santa',             'Feriado nacional — Paixão de Cristo',     NULL,       NULL),
(3, 7,  'Tiradentes',                    'Feriado nacional',                        NULL,       NULL),
(4, 8,  'Dia do Trabalho',               'Feriado nacional',                        NULL,       NULL),
(5, 11, 'Recesso Escolar Julho',         'Início do recesso de meio de ano',        NULL,       NULL),
(6, 15, 'Independência do Brasil',       'Feriado nacional',                        NULL,       NULL),
(7, 20, 'Encerramento do Ano Letivo',    'Último dia letivo de 2025',              '07:00:00', '12:00:00');

-- ───────────────────────────────────────────────────────────────────────────
-- 21. tb_pessoa  (10 alunos + 5 responsáveis + 5 funcionários = 20 pessoas)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_pessoa (pk_pessoa, cpf, rg, nome, sobrenome, sexo, data_nascimento, nacionalidade, raca) VALUES
-- Alunos
(1,  '11122233344', '123456789', 'Lucas',     'Oliveira',    'masculino', '2016-03-10', 'brasileiro', 'parda'),
(2,  '22233344455', '234567890', 'Ana',       'Souza',       'feminino',  '2015-07-22', 'brasileiro', 'branca'),
(3,  '33344455566', '345678901', 'Pedro',     'Santos',      'masculino', '2014-11-05', 'brasileiro', 'negra'),
(4,  '44455566677', '456789012', 'Maria',     'Lima',        'feminino',  '2013-02-18', 'brasileiro', 'parda'),
(5,  '55566677788', '567890123', 'João',      'Costa',       'masculino', '2012-09-30', 'brasileiro', 'branca'),
(6,  '66677788899', '678901234', 'Isabela',   'Fernandes',   'feminino',  '2016-05-14', 'brasileiro', 'amarela'),
(7,  '77788899900', '789012345', 'Matheus',   'Rodrigues',   'masculino', '2015-01-27', 'brasileiro', 'parda'),
(8,  '88899900011', '890123456', 'Sophia',    'Alves',       'feminino',  '2014-08-09', 'brasileiro', 'branca'),
(9,  '99900011122', '901234567', 'Gabriel',   'Nascimento',  'masculino', '2013-12-03', 'brasileiro', 'negra'),
(10, '00011122233', '012345678', 'Valentina', 'Carvalho',    'feminino',  '2012-06-16', 'brasileiro', 'parda'),
-- Responsáveis
(11, '11122233300', '111222333', 'Carlos',    'Oliveira',    'masculino', '1985-04-20', 'brasileiro', 'parda'),
(12, '22233344400', '222333444', 'Fernanda',  'Souza',       'feminino',  '1983-09-15', 'brasileiro', 'branca'),
(13, '33344455500', '333444555', 'Roberto',   'Santos',      'masculino', '1980-12-01', 'brasileiro', 'negra'),
(14, '44455566600', '444555666', 'Patricia',  'Lima',        'feminino',  '1979-06-28', 'brasileiro', 'parda'),
(15, '55566677700', '555666777', 'Marcelo',   'Costa',       'masculino', '1975-11-11', 'brasileiro', 'branca'),
-- Funcionários
(16, '66677788800', '666777888', 'Renata',    'Mendes',      'feminino',  '1978-03-07', 'brasileiro', 'parda'),
(17, '77788899800', '777888999', 'Eduardo',   'Pereira',     'masculino', '1975-08-22', 'brasileiro', 'branca'),
(18, '88899900800', '888999000', 'Claudia',   'Martins',     'feminino',  '1982-01-14', 'brasileiro', 'negra'),
(19, '99900011800', '999000111', 'André',     'Gomes',       'masculino', '1988-05-30', 'brasileiro', 'parda'),
(20, '00011122800', '000111222', 'Juliana',   'Ribeiro',     'feminino',  '1990-10-19', 'brasileiro', 'branca');

-- ───────────────────────────────────────────────────────────────────────────
-- 22. tb_email
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_email (pk_email, fk_pessoa, email, principal) VALUES
-- Responsáveis
(1,  11, 'carlos.oliveira@email.com',    TRUE),
(2,  12, 'fernanda.souza@email.com',     TRUE),
(3,  13, 'roberto.santos@email.com',     TRUE),
(4,  14, 'patricia.lima@email.com',      TRUE),
(5,  15, 'marcelo.costa@email.com',      TRUE),
-- Funcionários
(6,  16, 'renata.mendes@escola.edu.br',  TRUE),
(7,  17, 'eduardo.pereira@escola.edu.br',TRUE),
(8,  18, 'claudia.martins@escola.edu.br',TRUE),
(9,  19, 'andre.gomes@escola.edu.br',    TRUE),
(10, 20, 'juliana.ribeiro@escola.edu.br',TRUE),
-- Emails secundários
(11, 16, 'renata.mendes@gmail.com',      FALSE),
(12, 17, 'edu.pereira@gmail.com',        FALSE);

-- ───────────────────────────────────────────────────────────────────────────
-- 23. tb_telefone
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_telefone (pk_telefone, fk_pessoa, categoria, ddd, numero, ativo, principal) VALUES
(1,  11, 'celular',      '11', '991234567', TRUE,  TRUE),
(2,  12, 'celular',      '11', '992345678', TRUE,  TRUE),
(3,  13, 'celular',      '21', '993456789', TRUE,  TRUE),
(4,  14, 'celular',      '21', '994567890', TRUE,  TRUE),
(5,  15, 'celular',      '31', '995678901', TRUE,  TRUE),
(6,  16, 'celular',      '11', '996789012', TRUE,  TRUE),
(7,  17, 'celular',      '11', '997890123', TRUE,  TRUE),
(8,  18, 'celular',      '11', '998901234', TRUE,  TRUE),
(9,  19, 'celular',      '11', '999012345', TRUE,  TRUE),
(10, 20, 'celular',      '11', '990123456', TRUE,  TRUE),
(11, 11, 'residencial',  '11', '33334444',  TRUE,  FALSE),
(12, 12, 'residencial',  '11', '33335555',  TRUE,  FALSE),
(13, 16, 'emergencia',   '11', '33336666',  TRUE,  FALSE);

-- ───────────────────────────────────────────────────────────────────────────
-- 24. tb_endereco
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_endereco (pk_endereco, fk_pessoa, cep, numero, complemento, principal) VALUES
(1,  11, '01310100', '100',  NULL,         TRUE),
(2,  12, '04038001', '250',  'Apto 32',    TRUE),
(3,  13, '20040020', '88',   NULL,         TRUE),
(4,  14, '30130010', '310',  'Casa',       TRUE),
(5,  15, '40020010', '45',   NULL,         TRUE),
(6,  16, '01001001', '500',  'Sala 2',     TRUE),
(7,  17, '01310200', '120',  NULL,         TRUE),
(8,  18, '04038002', '77',   'Apto 10',    TRUE),
(9,  19, '04038003', '33',   NULL,         TRUE),
(10, 20, '01310300', '200',  'Bloco B',    TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 25. tb_aluno  (10 alunos, pessoas 1–10)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_aluno (pk_aluno, fk_pessoa, fk_tipo_escola_anterior, data_ingresso, faz_atividade_extracurricular, ra) VALUES
(1,  1,  1, '2022-02-07', FALSE, '202200001'),
(2,  2,  2, '2021-02-08', TRUE,  '202100002'),
(3,  3,  1, '2020-02-10', FALSE, '202000003'),
(4,  4,  3, '2019-02-11', TRUE,  '201900004'),
(5,  5,  2, '2018-02-05', FALSE, '201800005'),
(6,  6,  1, '2022-02-07', TRUE,  '202200006'),
(7,  7,  3, '2021-02-08', FALSE, '202100007'),
(8,  8,  2, '2020-02-10', TRUE,  '202000008'),
(9,  9,  1, '2019-02-11', FALSE, '201900009'),
(10, 10, 3, '2018-02-05', TRUE,  '201800010');

-- ───────────────────────────────────────────────────────────────────────────
-- 26. tb_responsavel  (5 responsáveis, pessoas 11–15)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_responsavel (pk_responsavel, fk_pessoa) VALUES
(1, 11),
(2, 12),
(3, 13),
(4, 14),
(5, 15);

-- ───────────────────────────────────────────────────────────────────────────
-- 27. tb_responsavel_aluno
--   Regra trigger Grupo 8: apenas 1 responsável_principal por aluno
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_responsavel_aluno (fk_aluno, fk_responsavel, responsavel_principal, responsavel_financeiro, pode_retirar) VALUES
(1,  1, TRUE,  TRUE,  TRUE),
(2,  2, TRUE,  TRUE,  TRUE),
(3,  3, TRUE,  TRUE,  TRUE),
(4,  4, TRUE,  TRUE,  TRUE),
(5,  5, TRUE,  TRUE,  TRUE),
(6,  1, FALSE, FALSE, TRUE),   -- irmão / segundo responsável
(7,  2, FALSE, FALSE, TRUE),
(8,  3, FALSE, FALSE, TRUE),
(9,  4, FALSE, FALSE, TRUE),
(10, 5, FALSE, TRUE,  TRUE),
(6,  2, TRUE,  TRUE,  TRUE),
(7,  3, TRUE,  TRUE,  TRUE),
(8,  4, TRUE,  TRUE,  TRUE),
(9,  5, TRUE,  TRUE,  TRUE),
(10, 1, TRUE,  TRUE,  TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 28. tb_profissao_responsavel
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_profissao_responsavel (fk_responsavel, fk_profissao, ativo) VALUES
(1, 2, TRUE),
(2, 4, TRUE),
(3, 1, TRUE),
(4, 3, TRUE),
(5, 5, TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 29. tb_funcionario  (5 funcionários, pessoas 16–20)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_funcionario (pk_funcionario, fk_pessoa, ativo) VALUES
(1, 16, TRUE),
(2, 17, TRUE),
(3, 18, TRUE),
(4, 19, TRUE),
(5, 20, TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 30. tb_professor  (3 professores dentre os 5 funcionários)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_professor (pk_professor, fk_funcionario, fk_tipo_aula, utiliza_rubrica_avaliativa, atende_educacao_especial) VALUES
(1, 1, 1, TRUE,  FALSE),
(2, 2, 1, FALSE, FALSE),
(3, 3, 1, TRUE,  TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 31. tb_formacao_professor
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_formacao_professor (pk_formacao, fk_professor, fk_nivel_formacao, curso, instituicao, ano_conclusao) VALUES
(1, 1, 1, 'Letras',              'USP',      2003),
(2, 1, 2, 'Linguística Aplicada','UNICAMP',  2006),
(3, 2, 1, 'Matemática',          'UNESP',    2000),
(4, 2, 3, 'Educação Matemática', 'UNIFESP',  2008),
(5, 3, 1, 'Pedagogia',           'PUC-SP',   2005),
(6, 3, 2, 'Educação Especial',   'SENAC',    2010);

-- ───────────────────────────────────────────────────────────────────────────
-- 32. tb_contrato  (1 por funcionário — datas abertas = status ativo)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_contrato (pk_contrato, fk_funcionario, fk_tipo_contrato, status_contrato, carga_horaria_semanal, data_inicio, data_fim) VALUES
(1, 1, 1, 'ativo', 40, '2020-03-01', NULL),
(2, 2, 1, 'ativo', 40, '2018-02-15', NULL),
(3, 3, 1, 'ativo', 30, '2021-07-01', NULL),
(4, 4, 1, 'ativo', 40, '2019-01-10', NULL),
(5, 5, 2, 'ativo', 20, '2022-08-01', NULL);

-- ───────────────────────────────────────────────────────────────────────────
-- 33. tb_historico_cargo
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_historico_cargo (pk_historico_cargo, fk_contrato, fk_cargo, data_inicio, data_fim, motivo_mudanca) VALUES
(1, 1, 1, '2020-03-01', NULL,         NULL),
(2, 2, 1, '2018-02-15', NULL,         NULL),
(3, 3, 1, '2021-07-01', NULL,         NULL),
(4, 4, 2, '2019-01-10', NULL,         NULL),
(5, 5, 4, '2022-08-01', NULL,         NULL);

-- ───────────────────────────────────────────────────────────────────────────
-- 34. tb_historico_salario
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_historico_salario (pk_historico_salario, fk_contrato, salario, data_inicio, data_fim, motivo_reajuste) VALUES
(1, 1, 4500.00, '2020-03-01', '2022-02-28', 'Admissão'),
(2, 1, 5000.00, '2022-03-01', NULL,         'Reajuste anual'),
(3, 2, 4800.00, '2018-02-15', '2021-02-14', 'Admissão'),
(4, 2, 5300.00, '2021-02-15', NULL,         'Promoção'),
(5, 3, 3800.00, '2021-07-01', NULL,         'Admissão'),
(6, 4, 6500.00, '2019-01-10', NULL,         'Admissão'),
(7, 5, 2800.00, '2022-08-01', NULL,         'Admissão');

-- ───────────────────────────────────────────────────────────────────────────
-- 35. tb_grade_curricular
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_grade_curricular (pk_grade, fk_turma, fk_materia, fk_professor, data_inicio, data_fim) VALUES
(1,  1, 1, 1, '2025-02-03', NULL),   -- Turma 1A, Português, Prof.1
(2,  1, 3, 2, '2025-02-03', NULL),   -- Turma 1A, Matemática, Prof.2
(3,  1, 4, 3, '2025-02-03', NULL),   -- Turma 1A, Ciências, Prof.3
(4,  2, 1, 1, '2025-02-03', NULL),   -- Turma 2A, Português, Prof.1
(5,  2, 3, 2, '2025-02-03', NULL),   -- Turma 2A, Matemática, Prof.2
(6,  3, 1, 1, '2025-02-03', NULL),   -- Turma 3A, Português, Prof.1
(7,  3, 3, 2, '2025-02-03', NULL),   -- Turma 3A, Matemática, Prof.2
(8,  4, 1, 1, '2025-02-03', NULL),   -- Turma 4A, Português, Prof.1
(9,  4, 3, 2, '2025-02-03', NULL),   -- Turma 4A, Matemática, Prof.2
(10, 5, 1, 1, '2025-02-03', NULL),   -- Turma 5A, Português, Prof.1
(11, 5, 3, 2, '2025-02-03', NULL);   -- Turma 5A, Matemática, Prof.2

-- ───────────────────────────────────────────────────────────────────────────
-- 36. tb_horario_aula
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_horario_aula (pk_horario_aula, fk_grade, dia_semana, hora_inicio, hora_fim, sala) VALUES
-- Grade 1 (Turma 1A – Português)
(1,  1, 'segunda', '07:00:00', '07:50:00', '101'),
(2,  1, 'quarta',  '07:00:00', '07:50:00', '101'),
-- Grade 2 (Turma 1A – Matemática)
(3,  2, 'terca',   '07:00:00', '07:50:00', '101'),
(4,  2, 'quinta',  '07:00:00', '07:50:00', '101'),
-- Grade 3 (Turma 1A – Ciências)
(5,  3, 'sexta',   '07:00:00', '07:50:00', '101'),
-- Grade 4 (Turma 2A – Português)
(6,  4, 'segunda', '07:00:00', '07:50:00', '102'),
(7,  4, 'quarta',  '07:00:00', '07:50:00', '102'),
-- Grade 5 (Turma 2A – Matemática)
(8,  5, 'terca',   '07:00:00', '07:50:00', '102'),
(9,  5, 'quinta',  '07:00:00', '07:50:00', '102'),
-- Grade 6 (Turma 3A – Português)
(10, 6, 'segunda', '13:00:00', '13:50:00', '201'),
(11, 6, 'quarta',  '13:00:00', '13:50:00', '201'),
-- Grade 7 (Turma 3A – Matemática)
(12, 7, 'terca',   '13:00:00', '13:50:00', '201'),
(13, 7, 'quinta',  '13:00:00', '13:50:00', '201'),
-- Grade 8 (Turma 4A – Português)
(14, 8, 'segunda', '13:00:00', '13:50:00', '202'),
(15, 8, 'quarta',  '13:00:00', '13:50:00', '202'),
-- Grade 9 (Turma 4A – Matemática)
(16, 9, 'terca',   '13:00:00', '13:50:00', '202'),
(17, 9, 'quinta',  '13:00:00', '13:50:00', '202'),
-- Grade 10 (Turma 5A – Português)
(18, 10,'segunda', '07:00:00', '07:50:00', '103'),
(19, 10,'quarta',  '07:00:00', '07:50:00', '103'),
-- Grade 11 (Turma 5A – Matemática)
(20, 11,'terca',   '07:00:00', '07:50:00', '103'),
(21, 11,'quinta',  '07:00:00', '07:50:00', '103');

-- ───────────────────────────────────────────────────────────────────────────
-- 37. tb_matricula
--   Distribuição:
--     Turma 1 (1A, cap=30): alunos 1, 6
--     Turma 2 (2A, cap=30): alunos 2, 7
--     Turma 3 (3A, cap=28): alunos 3, 8
--     Turma 4 (4A, cap=28): alunos 4, 9
--     Turma 5 (5A, cap=25): alunos 5, 10
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_matricula (pk_matricula, fk_turma, fk_tipo_ingresso, fk_status_matricula, data_matricula, fk_aluno) VALUES
(1,  1, 3, 1, '2025-01-20', 1),
(2,  2, 3, 1, '2025-01-20', 2),
(3,  3, 3, 1, '2025-01-20', 3),
(4,  4, 3, 1, '2025-01-20', 4),
(5,  5, 3, 1, '2025-01-20', 5),
(6,  1, 3, 1, '2025-01-20', 6),
(7,  2, 3, 1, '2025-01-20', 7),
(8,  3, 3, 1, '2025-01-20', 8),
(9,  4, 3, 1, '2025-01-20', 9),
(10, 5, 3, 1, '2025-01-20', 10);

-- ───────────────────────────────────────────────────────────────────────────
-- 38. tb_contrato_financeiro
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_contrato_financeiro (pk_contrato_financeiro, fk_matricula, valor_matricula, valor_mensalidade, dia_vencimento, data_inicio, data_fim) VALUES
(1,  1,  500.00, 850.00, 10, '2025-01-20', NULL),
(2,  2,  500.00, 850.00, 10, '2025-01-20', NULL),
(3,  3,  500.00, 850.00, 10, '2025-01-20', NULL),
(4,  4,  500.00, 850.00, 10, '2025-01-20', NULL),
(5,  5,  500.00, 850.00, 10, '2025-01-20', NULL),
(6,  6,  500.00, 850.00, 15, '2025-01-20', NULL),
(7,  7,  500.00, 850.00, 15, '2025-01-20', NULL),
(8,  8,  500.00, 850.00, 15, '2025-01-20', NULL),
(9,  9,  500.00, 850.00, 15, '2025-01-20', NULL),
(10, 10, 500.00, 850.00, 15, '2025-01-20', NULL);

-- ───────────────────────────────────────────────────────────────────────────
-- 39. tb_status_pagamento
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_status_pagamento (pk_status_pagamento, descricao, ativo) VALUES
(1, 'Pendente',    TRUE),
(2, 'Pago',        TRUE),
(3, 'Atrasado',    TRUE),
(4, 'Isento',      TRUE),
(5, 'Cancelado',   FALSE);

-- ───────────────────────────────────────────────────────────────────────────
-- 40. tb_pagamento  (fev a mai/2025 × 10 alunos = 40 registros)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_pagamento (pk_pagamento, fk_contrato_financeiro, fk_status_pagamento, valor_pago, valor_original, data_vencimento, data_pagamento, mes_referencia, ano_referencia) VALUES
-- Aluno 1
(1,  1, 2, 850.00, 850.00, '2025-02-10', '2025-02-10', 2, 2025),
(2,  1, 2, 850.00, 850.00, '2025-03-10', '2025-03-08', 3, 2025),
(3,  1, 2, 850.00, 850.00, '2025-04-10', '2025-04-10', 4, 2025),
(4,  1, 1, NULL,   850.00, '2025-05-10', NULL,          5, 2025),
-- Aluno 2
(5,  2, 2, 850.00, 850.00, '2025-02-10', '2025-02-09', 2, 2025),
(6,  2, 2, 850.00, 850.00, '2025-03-10', '2025-03-10', 3, 2025),
(7,  2, 2, 850.00, 850.00, '2025-04-10', '2025-04-11', 4, 2025),
(8,  2, 1, NULL,   850.00, '2025-05-10', NULL,          5, 2025),
-- Aluno 3
(9,  3, 2, 850.00, 850.00, '2025-02-10', '2025-02-10', 2, 2025),
(10, 3, 3, NULL,   850.00, '2025-03-10', NULL,          3, 2025),
(11, 3, 3, NULL,   850.00, '2025-04-10', NULL,          4, 2025),
(12, 3, 1, NULL,   850.00, '2025-05-10', NULL,          5, 2025),
-- Aluno 4
(13, 4, 2, 850.00, 850.00, '2025-02-10', '2025-02-10', 2, 2025),
(14, 4, 2, 850.00, 850.00, '2025-03-10', '2025-03-10', 3, 2025),
(15, 4, 2, 850.00, 850.00, '2025-04-10', '2025-04-10', 4, 2025),
(16, 4, 1, NULL,   850.00, '2025-05-10', NULL,          5, 2025),
-- Aluno 5
(17, 5, 2, 850.00, 850.00, '2025-02-10', '2025-02-10', 2, 2025),
(18, 5, 2, 850.00, 850.00, '2025-03-10', '2025-03-10', 3, 2025),
(19, 5, 1, NULL,   850.00, '2025-04-10', NULL,          4, 2025),
(20, 5, 1, NULL,   850.00, '2025-05-10', NULL,          5, 2025),
-- Aluno 6
(21, 6, 2, 850.00, 850.00, '2025-02-15', '2025-02-15', 2, 2025),
(22, 6, 2, 850.00, 850.00, '2025-03-15', '2025-03-14', 3, 2025),
(23, 6, 2, 850.00, 850.00, '2025-04-15', '2025-04-15', 4, 2025),
(24, 6, 1, NULL,   850.00, '2025-05-15', NULL,          5, 2025),
-- Aluno 7
(25, 7, 2, 850.00, 850.00, '2025-02-15', '2025-02-15', 2, 2025),
(26, 7, 2, 850.00, 850.00, '2025-03-15', '2025-03-15', 3, 2025),
(27, 7, 2, 850.00, 850.00, '2025-04-15', '2025-04-15', 4, 2025),
(28, 7, 1, NULL,   850.00, '2025-05-15', NULL,          5, 2025),
-- Aluno 8
(29, 8, 2, 850.00, 850.00, '2025-02-15', '2025-02-15', 2, 2025),
(30, 8, 2, 850.00, 850.00, '2025-03-15', '2025-03-15', 3, 2025),
(31, 8, 3, NULL,   850.00, '2025-04-15', NULL,          4, 2025),
(32, 8, 1, NULL,   850.00, '2025-05-15', NULL,          5, 2025),
-- Aluno 9
(33, 9, 2, 850.00, 850.00, '2025-02-15', '2025-02-15', 2, 2025),
(34, 9, 2, 850.00, 850.00, '2025-03-15', '2025-03-15', 3, 2025),
(35, 9, 2, 850.00, 850.00, '2025-04-15', '2025-04-15', 4, 2025),
(36, 9, 1, NULL,   850.00, '2025-05-15', NULL,          5, 2025),
-- Aluno 10
(37, 10, 2, 850.00, 850.00, '2025-02-15', '2025-02-15', 2, 2025),
(38, 10, 2, 850.00, 850.00, '2025-03-15', '2025-03-15', 3, 2025),
(39, 10, 2, 850.00, 850.00, '2025-04-15', '2025-04-15', 4, 2025),
(40, 10, 1, NULL,   850.00, '2025-05-15', NULL,          5, 2025);

-- ───────────────────────────────────────────────────────────────────────────
-- 41. tb_boletim  (4 bimestres × 10 matrículas = 40 registros)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_boletim (pk_boletim, fk_matricula, fk_situacao_boletim, bimestre) VALUES
-- Matrícula 1 (aluno 1, turma 1)
(1,  1, 1, 1), (2,  1, 1, 2), (3,  1, 4, 3), (4,  1, 4, 4),
-- Matrícula 2 (aluno 2, turma 2)
(5,  2, 1, 1), (6,  2, 1, 2), (7,  2, 4, 3), (8,  2, 4, 4),
-- Matrícula 3 (aluno 3, turma 3)
(9,  3, 3, 1), (10, 3, 2, 2), (11, 3, 4, 3), (12, 3, 4, 4),
-- Matrícula 4 (aluno 4, turma 4)
(13, 4, 1, 1), (14, 4, 1, 2), (15, 4, 4, 3), (16, 4, 4, 4),
-- Matrícula 5 (aluno 5, turma 5)
(17, 5, 1, 1), (18, 5, 1, 2), (19, 5, 4, 3), (20, 5, 4, 4),
-- Matrícula 6 (aluno 6, turma 1)
(21, 6, 1, 1), (22, 6, 1, 2), (23, 6, 4, 3), (24, 6, 4, 4),
-- Matrícula 7 (aluno 7, turma 2)
(25, 7, 1, 1), (26, 7, 1, 2), (27, 7, 4, 3), (28, 7, 4, 4),
-- Matrícula 8 (aluno 8, turma 3)
(29, 8, 3, 1), (30, 8, 4, 2), (31, 8, 4, 3), (32, 8, 4, 4),
-- Matrícula 9 (aluno 9, turma 4)
(33, 9, 1, 1), (34, 9, 1, 2), (35, 9, 4, 3), (36, 9, 4, 4),
-- Matrícula 10 (aluno 10, turma 5)
(37, 10,1, 1), (38, 10,1, 2), (39, 10,4, 3), (40, 10,4, 4);

-- ───────────────────────────────────────────────────────────────────────────
-- 42. tb_atividade_professor  (2 atividades por grade × bimestre 1 e 2)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_atividade_professor (pk_atividade_professor, fk_grade, fk_tipo_atividade, nome_atividade, bimestre, data_prevista, peso, valor_maximo) VALUES
-- Grade 1 (Turma 1A, Português)
(1,  1, 1, 'Prova 1 - Interpretação de Texto', 1, '2025-03-20', 2.00, 10.00),
(2,  1, 2, 'Trabalho 1 - Redação',             1, '2025-03-27', 1.50, 10.00),
(3,  1, 1, 'Prova 2 - Gramática',              2, '2025-06-05', 2.00, 10.00),
(4,  1, 2, 'Trabalho 2 - Conto',               2, '2025-06-12', 1.50, 10.00),
-- Grade 2 (Turma 1A, Matemática)
(5,  2, 1, 'Prova 1 - Operações Básicas',      1, '2025-03-21', 2.00, 10.00),
(6,  2, 3, 'Exercício 1 - Frações',            1, '2025-03-14', 1.00, 10.00),
(7,  2, 1, 'Prova 2 - Geometria',              2, '2025-06-06', 2.00, 10.00),
(8,  2, 3, 'Exercício 2 - Porcentagem',        2, '2025-06-13', 1.00, 10.00),
-- Grade 4 (Turma 2A, Português)
(9,  4, 1, 'Prova 1 - Leitura e Compreensão',  1, '2025-03-20', 2.00, 10.00),
(10, 4, 2, 'Trabalho 1 - Poesia',              1, '2025-03-28', 1.50, 10.00),
-- Grade 5 (Turma 2A, Matemática)
(11, 5, 1, 'Prova 1 - Álgebra',                1, '2025-03-21', 2.00, 10.00),
(12, 5, 3, 'Exercício 1 - Equações',           1, '2025-03-15', 1.00, 10.00),
-- Grade 6 (Turma 3A, Português)
(13, 6, 1, 'Prova 1 - Análise Sintática',      1, '2025-03-20', 2.00, 10.00),
(14, 6, 2, 'Trabalho 1 - Dissertação',         1, '2025-03-28', 1.50, 10.00),
-- Grade 7 (Turma 3A, Matemática)
(15, 7, 1, 'Prova 1 - Números Decimais',       1, '2025-03-21', 2.00, 10.00),
(16, 7, 3, 'Exercício 1 - Divisores',          1, '2025-03-15', 1.00, 10.00);

-- ───────────────────────────────────────────────────────────────────────────
-- 43. tb_nota_atividade
--   Regra trigger Grupo 10: atividade deve pertencer à turma da matrícula
--   Matrículas 1 e 6 → Turma 1 → grades 1, 2, 3 → atividades 1–8
--   Matrículas 2 e 7 → Turma 2 → grades 4, 5   → atividades 9–12
--   Matrículas 3 e 8 → Turma 3 → grades 6, 7   → atividades 13–16
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_nota_atividade (fk_matricula, fk_atividade_professor, valor_nota, entregue_no_prazo) VALUES
-- Matrícula 1 (Turma 1A)
(1, 1,  8.50, TRUE),
(1, 2,  7.00, TRUE),
(1, 3,  9.00, TRUE),
(1, 4,  8.00, TRUE),
(1, 5,  7.50, TRUE),
(1, 6,  6.50, TRUE),
(1, 7,  8.00, TRUE),
(1, 8,  7.00, TRUE),
-- Matrícula 6 (Turma 1A)
(6, 1,  9.00, TRUE),
(6, 2,  8.50, TRUE),
(6, 3,  9.50, TRUE),
(6, 4,  8.00, TRUE),
(6, 5,  9.00, TRUE),
(6, 6,  8.00, TRUE),
(6, 7,  9.00, TRUE),
(6, 8,  8.50, TRUE),
-- Matrícula 2 (Turma 2A)
(2, 9,  8.00, TRUE),
(2, 10, 7.50, TRUE),
(2, 11, 8.50, TRUE),
(2, 12, 7.00, TRUE),
-- Matrícula 7 (Turma 2A)
(7, 9,  9.00, TRUE),
(7, 10, 8.00, TRUE),
(7, 11, 9.50, TRUE),
(7, 12, 8.50, TRUE),
-- Matrícula 3 (Turma 3A) — aluno com risco de evasão, algumas notas baixas
(3, 13, 4.50, TRUE),
(3, 14, NULL, FALSE),   -- não entregou
(3, 15, 3.00, TRUE),
(3, 16, NULL, FALSE),   -- não entregou
-- Matrícula 8 (Turma 3A)
(8, 13, 8.00, TRUE),
(8, 14, 7.50, TRUE),
(8, 15, 8.50, TRUE),
(8, 16, 7.00, TRUE);

-- ───────────────────────────────────────────────────────────────────────────
-- 44. tb_presenca_aluno
--   Regra trigger Grupo 9: horário deve pertencer à turma da matrícula
--   Horários 1–5  → grades 1, 2, 3 → Turma 1 → matrículas 1 e 6
--   Horários 6–9  → grades 4, 5   → Turma 2 → matrículas 2 e 7
--   Horários 10–13 → grades 6, 7  → Turma 3 → matrículas 3 e 8
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_presenca_aluno (pk_presenca, fk_matricula, fk_calendario_letivo, fk_horario_aula, presenca, justificativa) VALUES
-- Calendário 1 (2025-02-03, segunda)
(1,  1,  1, 1, TRUE,  NULL),    -- matr.1, hor.1 (grade 1, turma 1, segunda)
(2,  6,  1, 1, TRUE,  NULL),    -- matr.6, hor.1
(3,  2,  1, 6, TRUE,  NULL),    -- matr.2, hor.6 (grade 4, turma 2, segunda)
(4,  7,  1, 6, TRUE,  NULL),    -- matr.7, hor.6
(5,  3,  1, 10,TRUE,  NULL),    -- matr.3, hor.10 (grade 6, turma 3, segunda)
(6,  8,  1, 10,TRUE,  NULL),    -- matr.8, hor.10
-- Calendário 2 (2025-02-04, terça)
(7,  1,  2, 3, TRUE,  NULL),    -- matr.1, hor.3 (grade 2, turma 1, terça)
(8,  6,  2, 3, TRUE,  NULL),
(9,  2,  2, 8, TRUE,  NULL),    -- matr.2, hor.8 (grade 5, turma 2, terça)
(10, 7,  2, 8, TRUE,  NULL),
(11, 3,  2, 12,TRUE,  NULL),    -- matr.3, hor.12 (grade 7, turma 3, terça)
(12, 8,  2, 12,TRUE,  NULL),
-- Calendário 3 (2025-02-05, quarta)
(13, 1,  3, 2, TRUE,  NULL),    -- matr.1, hor.2 (grade 1, turma 1, quarta)
(14, 6,  3, 2, FALSE, 'Consulta médica'),  -- faltou justificado
(15, 2,  3, 7, TRUE,  NULL),    -- matr.2, hor.7 (grade 4, turma 2, quarta)
(16, 7,  3, 7, TRUE,  NULL),
(17, 3,  3, 11,FALSE, NULL),    -- matr.3 falta sem justificativa
(18, 8,  3, 11,TRUE,  NULL),
-- Calendário 4 (2025-03-03, segunda)
(19, 1,  4, 1, TRUE,  NULL),
(20, 6,  4, 1, TRUE,  NULL),
(21, 2,  4, 6, TRUE,  NULL),
(22, 7,  4, 6, FALSE, NULL),    -- matr.7 falta
(23, 3,  4, 10,FALSE, NULL),    -- matr.3 falta
(24, 8,  4, 10,TRUE,  NULL),
-- Calendário 5 (2025-03-04, terça)
(25, 1,  5, 3, TRUE,  NULL),
(26, 6,  5, 3, TRUE,  NULL),
(27, 2,  5, 8, TRUE,  NULL),
(28, 7,  5, 8, TRUE,  NULL),
(29, 3,  5, 12,FALSE, NULL),    -- matr.3 terceira falta consecutiva
(30, 8,  5, 12,TRUE,  NULL);

-- ───────────────────────────────────────────────────────────────────────────
-- 45. tb_alerta_evasao
--   Aluno 3 apresenta frequência baixa e inadimplência — gerado alertas
--   fk_responsavel_alerta = funcionário 4 (coordenador)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_alerta_evasao (pk_alerta, fk_matricula, fk_responsavel_alerta, fk_tipo_risco_evasao, fk_nivel_risco, fk_status_alerta, data_alerta, descricao, data_resolucao, observacao_resolucao) VALUES
(1, 3, 4, 2, 3, 1, '2025-03-10 08:00:00', 'Aluno com 3 faltas consecutivas sem justificativa no bimestre.',             NULL, NULL),
(2, 3, 4, 1, 2, 2, '2025-04-01 09:00:00', 'Inadimplência: mensalidades de março e abril em aberto.',                   NULL, NULL),
(3, 3, 4, 3, 3, 1, '2025-04-15 10:00:00', 'Notas abaixo da média em Português e Matemática no 1º bimestre.',           NULL, NULL),
(4, 8, 4, 3, 1, 3, '2025-02-28 08:00:00', 'Rendimento abaixo do esperado em Ciências no início do bimestre.',
    '2025-03-15 00:00:00', 'Aluno realizou atividade de recuperação e atingiu média satisfatória.');

-- ───────────────────────────────────────────────────────────────────────────
-- 46. tb_folha_pagamento  (fev e mar 2025 para os 5 contratos)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_folha_pagamento (pk_folha_pagamento, fk_contrato, tipo_folha, valor, ano, mes, data_emissao, status_folha) VALUES
-- Fevereiro 2025
(1,  1, 'folha_mensal', 5000.00, 2025, 2, '2025-02-28', 'pago'),
(2,  2, 'folha_mensal', 5300.00, 2025, 2, '2025-02-28', 'pago'),
(3,  3, 'folha_mensal', 3800.00, 2025, 2, '2025-02-28', 'pago'),
(4,  4, 'folha_mensal', 6500.00, 2025, 2, '2025-02-28', 'pago'),
(5,  5, 'folha_mensal', 2800.00, 2025, 2, '2025-02-28', 'pago'),
-- Março 2025
(6,  1, 'folha_mensal', 5000.00, 2025, 3, '2025-03-31', 'pago'),
(7,  2, 'folha_mensal', 5300.00, 2025, 3, '2025-03-31', 'pago'),
(8,  3, 'folha_mensal', 3800.00, 2025, 3, '2025-03-31', 'pago'),
(9,  4, 'folha_mensal', 6500.00, 2025, 3, '2025-03-31', 'pago'),
(10, 5, 'folha_mensal', 2800.00, 2025, 3, '2025-03-31', 'pago'),
-- Abril 2025
(11, 1, 'folha_mensal', 5000.00, 2025, 4, '2025-04-30', 'pendente'),
(12, 2, 'folha_mensal', 5300.00, 2025, 4, '2025-04-30', 'pendente'),
(13, 3, 'folha_mensal', 3800.00, 2025, 4, '2025-04-30', 'pendente'),
(14, 4, 'folha_mensal', 6500.00, 2025, 4, '2025-04-30', 'pendente'),
(15, 5, 'folha_mensal', 2800.00, 2025, 4, '2025-04-30', 'pendente');

-- ───────────────────────────────────────────────────────────────────────────
-- 47. tb_verba_folha  (verbas de crédito e débito por folha)
-- ───────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO tb_verba_folha (fk_folha_pagamento, fk_tipo_verba, valor, referencia) VALUES
-- Folha 1 (Contrato 1, fev/2025) — salário + VT + VA − INSS − IRRF
(1,  1, 5000.00, 'Salário base fev/2025'),
(1,  4,  220.00, 'VT fev/2025'),
(1,  5,  550.00, 'VA fev/2025'),
(1,  6,  550.00, 'INSS 11% fev/2025'),
(1,  7,  225.00, 'IRRF fev/2025'),
-- Folha 2 (Contrato 2, fev/2025)
(2,  1, 5300.00, 'Salário base fev/2025'),
(2,  4,  220.00, 'VT fev/2025'),
(2,  5,  550.00, 'VA fev/2025'),
(2,  6,  583.00, 'INSS 11% fev/2025'),
(2,  7,  280.00, 'IRRF fev/2025'),
-- Folha 6 (Contrato 1, mar/2025)
(6,  1, 5000.00, 'Salário base mar/2025'),
(6,  4,  220.00, 'VT mar/2025'),
(6,  5,  550.00, 'VA mar/2025'),
(6,  6,  550.00, 'INSS 11% mar/2025'),
(6,  7,  225.00, 'IRRF mar/2025'),
-- Folha 7 (Contrato 2, mar/2025)
(7,  1, 5300.00, 'Salário base mar/2025'),
(7,  4,  220.00, 'VT mar/2025'),
(7,  5,  550.00, 'VA mar/2025'),
(7,  6,  583.00, 'INSS 11% mar/2025'),
(7,  7,  280.00, 'IRRF mar/2025');

-- ═══════════════════════════════════════════════════════════════════════════

SET FOREIGN_KEY_CHECKS = 1;

-- ═══════════════════════════════════════════════════════════════════════════
-- VERIFICAÇÃO DE IDEMPOTÊNCIA — SELECT COUNT(*) em todas as tabelas
-- Execute após a 1ª carga, depois execute o script novamente e compare.
-- Os valores abaixo devem ser IDÊNTICOS nas duas execuções.
-- ═══════════════════════════════════════════════════════════════════════════
SELECT 'tb_tipo_escola_anterior'   AS tabela, COUNT(*) AS total FROM tb_tipo_escola_anterior
UNION ALL SELECT 'tb_tipo_ingresso',            COUNT(*) FROM tb_tipo_ingresso
UNION ALL SELECT 'tb_status_matricula',          COUNT(*) FROM tb_status_matricula
UNION ALL SELECT 'tb_situacao_boletim',          COUNT(*) FROM tb_situacao_boletim
UNION ALL SELECT 'tb_nivel_risco_evasao',        COUNT(*) FROM tb_nivel_risco_evasao
UNION ALL SELECT 'tb_tipo_risco_evasao',         COUNT(*) FROM tb_tipo_risco_evasao
UNION ALL SELECT 'tb_status_alerta',             COUNT(*) FROM tb_status_alerta
UNION ALL SELECT 'tb_area_conhecimento',         COUNT(*) FROM tb_area_conhecimento
UNION ALL SELECT 'tb_materia',                   COUNT(*) FROM tb_materia
UNION ALL SELECT 'tb_tipo_atividade',            COUNT(*) FROM tb_tipo_atividade
UNION ALL SELECT 'tb_tipo_aula',                 COUNT(*) FROM tb_tipo_aula
UNION ALL SELECT 'tb_tipo_contrato',             COUNT(*) FROM tb_tipo_contrato
UNION ALL SELECT 'tb_cargo',                     COUNT(*) FROM tb_cargo
UNION ALL SELECT 'tb_nivel_formacao',            COUNT(*) FROM tb_nivel_formacao
UNION ALL SELECT 'tb_profissao',                 COUNT(*) FROM tb_profissao
UNION ALL SELECT 'tb_tipo_verba',                COUNT(*) FROM tb_tipo_verba
UNION ALL SELECT 'tb_ano_letivo',                COUNT(*) FROM tb_ano_letivo
UNION ALL SELECT 'tb_turma',                     COUNT(*) FROM tb_turma
UNION ALL SELECT 'tb_calendario_letivo',         COUNT(*) FROM tb_calendario_letivo
UNION ALL SELECT 'tb_evento_escolar',            COUNT(*) FROM tb_evento_escolar
UNION ALL SELECT 'tb_pessoa',                    COUNT(*) FROM tb_pessoa
UNION ALL SELECT 'tb_email',                     COUNT(*) FROM tb_email
UNION ALL SELECT 'tb_telefone',                  COUNT(*) FROM tb_telefone
UNION ALL SELECT 'tb_endereco',                  COUNT(*) FROM tb_endereco
UNION ALL SELECT 'tb_aluno',                     COUNT(*) FROM tb_aluno
UNION ALL SELECT 'tb_responsavel',               COUNT(*) FROM tb_responsavel
UNION ALL SELECT 'tb_responsavel_aluno',         COUNT(*) FROM tb_responsavel_aluno
UNION ALL SELECT 'tb_profissao_responsavel',     COUNT(*) FROM tb_profissao_responsavel
UNION ALL SELECT 'tb_funcionario',               COUNT(*) FROM tb_funcionario
UNION ALL SELECT 'tb_professor',                 COUNT(*) FROM tb_professor
UNION ALL SELECT 'tb_formacao_professor',        COUNT(*) FROM tb_formacao_professor
UNION ALL SELECT 'tb_contrato',                  COUNT(*) FROM tb_contrato
UNION ALL SELECT 'tb_historico_cargo',           COUNT(*) FROM tb_historico_cargo
UNION ALL SELECT 'tb_historico_salario',         COUNT(*) FROM tb_historico_salario
UNION ALL SELECT 'tb_grade_curricular',          COUNT(*) FROM tb_grade_curricular
UNION ALL SELECT 'tb_horario_aula',              COUNT(*) FROM tb_horario_aula
UNION ALL SELECT 'tb_matricula',                 COUNT(*) FROM tb_matricula
UNION ALL SELECT 'tb_contrato_financeiro',       COUNT(*) FROM tb_contrato_financeiro
UNION ALL SELECT 'tb_status_pagamento',          COUNT(*) FROM tb_status_pagamento
UNION ALL SELECT 'tb_pagamento',                 COUNT(*) FROM tb_pagamento
UNION ALL SELECT 'tb_boletim',                   COUNT(*) FROM tb_boletim
UNION ALL SELECT 'tb_atividade_professor',       COUNT(*) FROM tb_atividade_professor
UNION ALL SELECT 'tb_nota_atividade',            COUNT(*) FROM tb_nota_atividade
UNION ALL SELECT 'tb_presenca_aluno',            COUNT(*) FROM tb_presenca_aluno
UNION ALL SELECT 'tb_alerta_evasao',             COUNT(*) FROM tb_alerta_evasao
UNION ALL SELECT 'tb_folha_pagamento',           COUNT(*) FROM tb_folha_pagamento
UNION ALL SELECT 'tb_verba_folha',               COUNT(*) FROM tb_verba_folha;

-- FIM DO SCRIPT DE CARGA