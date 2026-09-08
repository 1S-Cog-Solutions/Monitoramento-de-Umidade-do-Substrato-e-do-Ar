CREATE DATABASE cog_solutions;

USE cog_solutions;

-- Tabela 1: cliente
CREATE TABLE cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nomeEmpresa VARCHAR(100) NOT NULL, 
    nomeResponsavel VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT chkEmail CHECK (email LIKE '%@%'),
    telefone VARCHAR(20),
    cnpj CHAR(14) UNIQUE,
    dtCadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela 2: estufa
CREATE TABLE ambienteCultivo (
    idAmbienteCultivo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL, -- Ex: 'Câmara 01 - Incubação'
    faseCultivo VARCHAR(40) NOT NULL,
    CONSTRAINT chkFaseCultivo CHECK(faseCultivo IN ('Compostagem', 'Incubação', 'Frutificação', 'Pasteurização')),
    capacidadeSacos INT DEFAULT 800  -- Capacidade padrão (800 a 1000 sacos)
);

-- Tabela 3: sensor
CREATE TABLE sensor (
    idSensor INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(40) NOT NULL,  -- Ex: 'DHT11', 'Capacitivo - Substrato'
    CONSTRAINT chkTipo CHECK(tipo IN ('DHT11', 'Capacitivo - Substrato')),
    posicaoAmbienteCultivo VARCHAR(50),                       -- Ex: 'Setor Norte - Prateleira 2'
    statuss VARCHAR(20) DEFAULT 'Ativo', -- 'Ativo', 'Inativo'
    CONSTRAINT chkStatuss CHECK(statuss IN ('Ativo', 'Inativo')),
    descricao VARCHAR(80)
);

-- Tabela 4: leitura (Histórico do Sensoriamento)
CREATE TABLE leitura (
    idLeitura INT AUTO_INCREMENT PRIMARY KEY,
    umidadeAr DECIMAL(4,1) NULL,          -- Umidade Relativa do Ar em %
    umidadeSolo DECIMAL(4,1) NULL,   -- Umidade do Substrato em %
    dtHora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ================================== MUDAR O INSERT E ADICIONAR ALTER TABLES
ALTER TABLE sensor MODIFY COLUMN tipo VARCHAR(30);
DESC sensor;

INSERT INTO cliente (nomeEmpresa, nomeResponsavel, email, telefone, cnpj) VALUES
('Cogumelos Cogumaster SP', 'Carlos Eduardo Silva', 'contato@cogumaster.com.br', '(11) 98765-4321', '12345678000195'),
('Estufas e Cogumelos Brasil', 'Jorge Alvares', 'contato@estufascogumelos.com.br', '(11) 99452-7172', '38710932000175'),
('Fungicultura Paris Brasil', 'Mariana Oliveira', 'atendimento@parisbrasil.com.br', '(11) 97123-8899', '98765432000110');

-- Inserindo Estufas / Câmaras de Cultivo
INSERT INTO ambienteCultivo (nome, faseCultivo, capacidadeSacos) VALUES
('Câmara 01', 'Incubação', 1000),
('Câmara 02', 'Frutificação', 800),
('Estufa A - Mogi', 'Frutificação', 950);

-- Inserindo Sensores (DHT11 e Umidade de Solo/Substrato)
INSERT INTO sensor (tipo, posicaoAmbienteCultivo, statuss, descricao) VALUES
('DHT11', 'Setor Central - Altura 1.8m', 'Ativo', 'Medição da umidade do ar'),
('Capacitivo - Substrato', 'Setor Central - Altura 1.8m', 'Ativo', 'Medição da umidade do substrato'),
('Capacitivo - Substrato', 'Prateleira A - Saco 12', 'Ativo', 'Medição da umidade do substrato'),
('DHT11', 'Setor Sul - Prateleira B', 'Ativo', 'Medição da umidade do ar'),
('Capacitivo - Substrato', 'Prateleira B - Saco 45', 'Ativo', 'Medição da umidade do substrato'),
('DHT11', 'Setor Norte - Prateleira C', 'Inativo', 'Medição da umidade do ar');

-- Inserindo Histórico de Leituras (Simulando leituras a cada 5 minutos)
-- Fase Incubação: Esperado Temp ~20°C, UR Ar ~90-95%, Substrato ~70-75%
-- Fase Frutificação: Esperado Temp 16-22°C, UR Ar ~80-90%
INSERT INTO leitura (umidadeAr, umidadeSolo, dtHora) VALUES
-- Leituras Câmara 01 (Incubação - Sensor Ar/Substrato)
(93.0, 73.9, '2026-03-03 10:00:00'),
(92.5, 69.1, '2026-03-03 10:05:00'),
(88.0, 80.0, '2026-03-03 10:10:00'), -- Queda na UR do Ar (Alerta potencial)

-- Leituras Câmara 01 (Incubação - Sensor Substrato)
(NULL, 74.5, '2026-03-03 10:00:00'),
(NULL, 73.0, '2026-03-03 10:05:00'),
(NULL, 68.5, '2026-03-03 10:10:00'), -- Substrato ressecando (Alerta)

-- Leituras Câmara 02 (Frutificação - Sensor Ar)
(85.0, NULL, '2026-03-03 10:00:00'),
(84.5, NULL, '2026-03-03 10:05:00'),
(75.0, NULL, '2026-03-03 10:10:00'), -- Umidade abaixo de 80% em Frutificação (Risco de Bacterial Blotch)

-- Leituras Câmara 02 (Frutificação - Sensor Substrato)
(NULL, 71.0, '2026-03-03 10:00:00'),
(NULL, 70.8, '2026-03-03 10:05:00');

SELECT * FROM cliente;
SELECT * FROM ambienteCultivo;
SELECT * FROM leitura;
SELECT * FROM sensor;
