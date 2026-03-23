<h1 align="center">🏫 AuroraEduTech — Sistema de Gestão Escolar</h1>

<p align="center">
Projeto acadêmico desenvolvido para a disciplina de <b>Banco de Dados</b><br>
ERP voltado para <b>escolas de Ensino Fundamental I (1º ao 5º ano)</b>
</p>

<hr>

<h2>🎯 Objetivo do Projeto</h2>

<p>
O <b>AuroraEduTech</b> é um projeto acadêmico que tem como objetivo projetar a arquitetura de um
<b>ERP (Enterprise Resource Planning)</b> para gestão escolar.
</p>

<p>
O sistema foi pensado para atender escolas de <b>Ensino Fundamental I (1º ao 5º ano)</b>,
integrando processos acadêmicos, financeiros e administrativos em uma única plataforma.
</p>

<p>
Além da modelagem tradicional de banco de dados, o projeto também explora a evolução dos dados
desde o nível operacional até a geração de análises estratégicas e modelos preditivos.
</p>

<hr>

<h2>🧠 Arquitetura de Dados do Projeto</h2>

<p>O projeto segue três níveis de utilização dos dados:</p>

<h3>📌 OLTP — Processamento Operacional</h3>

<p>Representa os dados capturados no dia a dia da escola.</p>

<ul>
<li>Registro de presença dos alunos</li>
<li>Notas de avaliações</li>
<li>Pagamento de mensalidades</li>
<li>Cadastro de funcionários</li>
<li>Registro de ponto</li>
</ul>

<p>Esses dados representam o nível <b>granular</b> do sistema.</p>

<h3>📊 OLAP — Informação Analítica</h3>

<p>Transformação dos dados operacionais em informações estratégicas.</p>

<ul>
<li>Média de desempenho por disciplina</li>
<li>Taxa de inadimplência</li>
<li>Frequência média dos alunos</li>
<li>Custo operacional da escola</li>
<li>Participação em atividades extracurriculares</li>
</ul>

<h3>🤖 IA — Análise Preditiva</h3>

<p>Com base no histórico de dados, o sistema poderá futuramente alimentar modelos de inteligência artificial.</p>

<ul>
<li>Probabilidade de evasão escolar</li>
<li>Previsão de inadimplência</li>
<li>Identificação de alunos com risco de baixo desempenho</li>
<li>Previsão de demanda de atividades extracurriculares</li>
</ul>

<hr>

<h2>🏛 Estrutura do ERP SisGESC</h2>

<p>O sistema foi dividido em três módulos principais.</p>

<h3>📚 Módulo Acadêmico</h3>

<p>Responsável pela gestão pedagógica da escola.</p>

<b>Principais entidades:</b>

<ul>
<li>Alunos</li>
<li>Professores</li>
<li>Turmas</li>
<li>Séries (1º ao 5º ano)</li>
<li>Disciplinas</li>
<li>Matrículas</li>
<li>Avaliações</li>
<li>Frequência</li>
</ul>

<b>Dados armazenados:</b>

<ul>
<li>Notas das avaliações</li>
<li>Presença dos alunos</li>
<li>Histórico escolar</li>
<li>Participação em atividades extracurriculares</li>
</ul>

<hr>

<h3>💰 Módulo Financeiro</h3>

<p>Responsável pelo controle financeiro da instituição.</p>

<b>Principais entidades:</b>

<ul>
<li>Mensalidades</li>
<li>Parcelas</li>
<li>Pagamentos</li>
<li>Eventos escolares</li>
<li>Passeios pedagógicos</li>
<li>Uniformes</li>
<li>Livros didáticos</li>
</ul>

<b>Exemplos de dados armazenados:</b>

<ul>
<li>Valor da mensalidade</li>
<li>Data de vencimento</li>
<li>Status de pagamento</li>
<li>Controle de inadimplência</li>
<li>Custos de eventos</li>
</ul>

<b>Eventos escolares considerados:</b>

<ul>
<li>Festa Junina</li>
<li>Dia das Mães</li>
<li>Dia dos Pais</li>
<li>Formatura do 5º ano</li>
<li>Passeios pedagógicos</li>
</ul>

<p>O módulo financeiro também se integra com o RH para:</p>

<ul>
<li>Folha de pagamento</li>
<li>PLR</li>
<li>Benefícios</li>
<li>Dados bancários</li>
</ul>

<hr>

<h3>👩‍💼 Módulo de Recursos Humanos</h3>

<p>Responsável pela gestão dos funcionários da escola.</p>

<b>Principais entidades:</b>

<ul>
<li>Funcionários</li>
<li>Funções</li>
<li>Controle de ponto</li>
<li>Ausências</li>
<li>Férias</li>
<li>Habilidades extras</li>
</ul>

<b>Dados armazenados:</b>

<ul>
<li>Dados cadastrais</li>
<li>Documentação legal</li>
<li>Cargo / função</li>
<li>Jornada de trabalho</li>
<li>Registro de ponto</li>
<li>Dados bancários</li>
</ul>

<p>
Uma característica importante no <b>Ensino Fundamental I</b> é o registro de habilidades
extracurriculares dos funcionários.
</p>

<b>Exemplos:</b>

<ul>
<li>Ballet</li>
<li>Robótica</li>
<li>Jazz</li>
<li>Judô</li>
</ul>

<hr>

<h2>🔄 Modelagem de Processos</h2>

<p>
O projeto inclui o mapeamento dos principais processos da gestão escolar
por meio de <b>fluxogramas de processos</b>.
</p>

<p>Alguns processos modelados:</p>

<ul>
<li>Matrícula de alunos</li>
<li>Gestão acadêmica durante o ano letivo</li>
<li>Controle financeiro de mensalidades</li>
<li>Organização de eventos escolares</li>
<li>Gestão de funcionários</li>
<li>Controle de férias e ausências</li>
</ul>

<p>Os fluxogramas estão sendo desenvolvidos utilizando <b>Draw.io</b>.</p>

<hr>

<h2>📊 Granularidade dos Dados</h2>

<p>Durante a modelagem discutimos o nível de detalhamento necessário para análises futuras.</p>

<ul>
<li>Frequência registrada <b>por aula</b></li>
<li>Notas registradas <b>por atividade</b></li>
<li>Pagamentos registrados <b>por parcela</b></li>
</ul>

<p>Esse nível de detalhamento permite análises mais precisas no futuro.</p>

<hr>

<h2>📏 Arquitetura ANSI-SPARC</h2>

<p>A modelagem considera três níveis de abstração:</p>

<ul>
<li><b>Nível Conceitual</b> — relacionamento entre entidades</li>
<li><b>Nível Lógico</b> — estrutura normalizada do banco</li>
<li><b>Nível Externo</b> — visões específicas para cada área da escola</li>
</ul>

<p>Exemplos de visões:</p>

<ul>
<li>Coordenação pedagógica</li>
<li>Direção</li>
<li>Financeiro</li>
</ul>

<hr>

<h2>📌 Etapas do Projeto</h2>

<ol>
<li>Levantamento de requisitos</li>
<li>Modelagem de processos</li>
<li>Identificação das entidades</li>
<li>Definição de regras de negócio</li>
<li>Dicionário de dados</li>
<li>Modelagem conceitual</li>
<li>Modelagem lógica</li>
<li>Preparação para análise OLAP</li>
<li>Definição de perguntas para IA</li>
</ol>

<hr>

<h2>👥 Organização do Trabalho</h2>

<p>O grupo foi dividido em três frentes:</p>

<ul>
<li>📚 Acadêmico</li>
<li>💰 Financeiro</li>
<li>👩‍💼 Recursos Humanos</li>
</ul>

<p>Cada equipe será responsável por definir:</p>

<ul>
<li>Entidades</li>
<li>Regras de negócio</li>
<li>Dados operacionais</li>
<li>Indicadores analíticos</li>
</ul>

<hr>

<h2>📈 Evolução do Projeto</h2>

<p>
Este repositório será atualizado continuamente conforme o avanço do projeto.
</p>

<p>Serão adicionados:</p>

<ul>
<li>Diagramas de processos</li>
<li>Modelos conceituais</li>
<li>Modelos lógicos</li>
<li>Dicionário de dados</li>
<li>Regras de negócio</li>
<li>Documentação técnica</li>
</ul>

<hr>

<h2>🚧 Status do Projeto</h2>

<p><b>🟡 Em desenvolvimento</b></p>

<p>Atualmente estamos na fase de:</p>

<ul>
<li>Levantamento de requisitos</li>
<li>Modelagem de processos</li>
<li>Definição inicial das entidades</li>
</ul>

<hr>

<h2>💡 Observação</h2>

<p>
O AuroraEduTech representa a construção conceitual do <b>"cérebro digital"</b> de uma instituição escolar.
</p>

<p>
A qualidade da modelagem de dados determina diretamente a qualidade das
informações analíticas e previsões futuras.
</p>

<p>
<b>Dados mal estruturados geram decisões equivocadas.</b>
</p>
