CREATE DATABASE monitoramento_cogumelo;

USE monitoramento_cogumelo;

CREATE TABLE medicao( -- Tabela de medicao para os valores
	medicaoId INT PRIMARY KEY AUTO_INCREMENT,
    nomeSensor VARCHAR(30), -- nome do sensor
    nomeAmbiente VARCHAR(40) NOT NULL, -- ambiente que está localizado o sensor
    nomeCliente VARCHAR(40) NOT NULL, -- cliente que está localizada a medição
    valor DECIMAL(6, 2) NOT NULL, -- valor do sensor
    registro DATETIME DEFAULT CURRENT_TIMESTAMP -- Data do registro
);

CREATE TABLE sensor(
	sensorId INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(30) NOT NULL, -- Nome técnico do sensor
    tipo VARCHAR(30) NOT NULL, -- Tipo do sensor (umidade do solo, umidade do ar)
    statuss VARCHAR(8) DEFAULT('Ativo') NOT NULL CONSTRAINT chkStatuss CHECK(statuss IN('Ativo', 'Inativo')), -- Status do sensor
    unidadeDeMedida VARCHAR(30), -- Unidade de medida do sensor
    descrição VARCHAR(200) -- Descrição do sensor
);

CREATE TABLE cliente(
	clienteId INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL, -- Nome do cliente
    cnpj CHAR(18) UNIQUE, -- CNPJ
    email VARCHAR(20) NOT NULL -- Email do cliente 
);

CREATE TABLE lote(
	idLote INT PRIMARY KEY AUTO_INCREMENT,
	nome VARCHAR(40) NOT NULL, -- Nome do ambiente
    nomeCliente VARCHAR(50) NOT NULL, -- Nome do cliente que possui o lote
    faseCultivo VARCHAR(40) NOT NULL-- Fase de cultivo do cogumelo
);

-- ====================== INSERÇÕES ======================

-- SENSORES
INSERT INTO sensor (nome, tipo, statuss, unidadeDeMedida, descrição) VALUES
('SEN-UMS-01', 'Umidade do Solo', 'Ativo', '%', 'Sensor capacitivo de umidade do solo'),
('SEN-UMA-01', 'Umidade do Ar', 'Ativo', '%', 'Sensor de umidade relativa do ar'),
('SEN-TEMP-01', 'Temperatura', 'Ativo', '°C', 'Sensor de temperatura ambiente'),
('SEN-CO2-01', 'CO2', 'Ativo', 'ppm', 'Sensor de concentração de CO2'),
('SEN-LUX-01', 'Luminosidade', 'Inativo', 'lux', 'Sensor de luminosidade');

-- CLIENTES
INSERT INTO cliente (nome, cnpj, email) VALUES
('Fungi Cultivo Ltda', '12.345.678/0001-90', 'contato@fungi.com'),
('Cogumelos SP', '98.765.432/0001-10', 'sac@cogsp.com'),
('AgroShiitake ME', '11.222.333/0001-44', 'vendas@agrosh.com');

-- LOTES
INSERT INTO lote (nome, nomeCliente, faseCultivo) VALUES
('Estufa A', 'Fungi Cultivo Ltda', 'Frutificação'),
('Estufa B', 'Fungi Cultivo Ltda', 'Colonização'),
('Sala 1', 'Cogumelos SP', 'Incubação'),
('Sala 2', 'AgroShiitake ME', 'Frutificação');

INSERT INTO medicao (nomeSensor, nomeAmbiente, nomeCliente, valor, registro) VALUES
('SEN-UMS-01', 'Estufa A', 'Fungi Cultivo Ltda', 78.50, '2026-09-01 08:00:00'),
('SEN-UMS-01', 'Estufa A', 'Fungi Cultivo Ltda', 80.10, '2026-09-01 12:00:00'),
('SEN-UMA-01', 'Estufa A', 'Fungi Cultivo Ltda', 85.30, '2026-09-01 08:00:00'),
('SEN-UMA-01', 'Estufa A', 'Fungi Cultivo Ltda', 83.00, '2026-09-01 12:00:00'),
('SEN-TEMP-01', 'Estufa A', 'Fungi Cultivo Ltda', 22.50, '2026-09-01 08:00:00'),
('SEN-TEMP-01', 'Estufa A', 'Fungi Cultivo Ltda', 24.10, '2026-09-01 12:00:00'),
('SEN-CO2-01', 'Sala 1', 'Cogumelos SP', 650.00, '2026-09-01 08:00:00'),
('SEN-CO2-01', 'Sala 1', 'Cogumelos SP', 700.20, '2026-09-01 12:00:00'),
('SEN-TEMP-01', 'Sala 1', 'Cogumelos SP', 23.40, '2026-09-01 09:00:00'),
('SEN-UMS-01', 'Sala 2', 'AgroShiitake ME', 70.00, '2026-09-01 09:00:00'),
('SEN-TEMP-01', 'Sala 2', 'AgroShiitake ME', 21.00, '2026-09-01 09:00:00'),

-- Leituras fora da faixa ideal (para testar alertas depois)
('SEN-UMS-01', 'Estufa A', 'Fungi Cultivo Ltda', 45.00, '2026-09-02 08:00:00'),
('SEN-UMA-01', 'Sala 1', 'Cogumelos SP', 55.00, '2026-09-02 08:00:00'),
('SEN-TEMP-01', 'Sala 2', 'AgroShiitake ME', 32.00, '2026-09-02 08:00:00'),
('SEN-CO2-01', 'Estufa A', 'Fungi Cultivo Ltda', 1200.00, '2026-09-02 08:00:00');


-- MEDIÇÃO sem data de registro
-- Ambos nomeSensor e registro NULL ao mesmo tempo
INSERT INTO medicao (nomeSensor, nomeAmbiente, nomeCliente, valor, registro) VALUES
(NULL, 'Sala 2', 'AgroShiitake ME', 68.90, NULL);

-- SENSOR sem unidade de medida e sem descrição
INSERT INTO sensor (nome, tipo, statuss, unidadeDeMedida, descrição) VALUES
('SEN-PH-01', 'pH do Substrato', 'Ativo', NULL, NULL);

-- SENSOR sem descrição, mas com unidade preenchida
INSERT INTO sensor (nome, tipo, statuss, unidadeDeMedida, descrição) VALUES
('SEN-PRES-01', 'Pressão Atmosférica', 'Inativo', 'Celsius', NULL);

SELECT * FROM medicao;
SELECT * FROM lote;
SELECT * FROM cliente;
SELECT * FROM medicao;
