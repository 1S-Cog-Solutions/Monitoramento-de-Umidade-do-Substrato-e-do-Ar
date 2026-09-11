-- 1. Criação do Banco de Dados
CREATE DATABASE cog_solution;
USE cog_solution;

-- 2. Tabela de Clientes
CREATE TABLE cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    cpf_cnpj VARCHAR(18) NOT NULL
);

-- 3. Tabela de Sensores
CREATE TABLE sensor (
    idSensor INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL, -- Ex: DHT11, Umidade de Solo, Temperatura
    status_sensor VARCHAR(20) DEFAULT 'Ativo', -- Ex: Ativo, Inativo, Manutenção
    localizacao VARCHAR(100)
);

-- 4. Tabela (Atendimento / Suporte Técnico)
CREATE TABLE suporte (
    idSuporte INT PRIMARY KEY AUTO_INCREMENT,
    assunto VARCHAR(100) NOT NULL,
    descricao TEXT,
    data_abertura DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_chamado VARCHAR(20) DEFAULT 'Aberto'
);

-- 1. Inserindo dados na tabela cliente
INSERT INTO cliente (nome, email, telefone, cpf_cnpj) VALUES
('João Silva', 'joao.silva@email.com', '(11) 98765-4321', '123.456.789-00'),
('Maria Oliveira', 'maria.oliveira@email.com', '(11) 97654-3210', '987.654.321-11'),
('Cogumelos do Vale Ltda', 'contato@cogumelosvale.com', '(11) 3344-5566', '12.345.678/0001-99');

-- 2. Inserindo dados na tabela sensor
INSERT INTO sensor (tipo, status_sensor, localizacao) VALUES
('DHT11 - Umidade e Temperatura', 'Ativo', 'Estufa 01 - Setor A'),
('LM35 - Temperatura', 'Ativo', 'Estufa 01 - Setor B'),
('DHT11 - Umidade e Temperatura', 'Manutenção', 'Estufa 02 - Setor Principal');

-- 3. Inserindo dados na tabela suporte
INSERT INTO suporte (assunto, descricao, status_chamado) VALUES
('Falha na leitura do sensor', 'O sensor da Estufa 02 parou de enviar dados de umidade.', 'Aberto'),
('Dúvida no Dashboard', 'Gostaria de saber como exportar os relatórios mensais.', 'Em Andamento'),
('Calibração de equipamento', 'Solicitação de visita técnica para calibrar os sensores de temperatura.', 'Concluído');

select * FROM cliente