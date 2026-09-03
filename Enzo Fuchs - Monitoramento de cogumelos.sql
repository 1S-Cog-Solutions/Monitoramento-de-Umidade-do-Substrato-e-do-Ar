CREATE DATABASE cog_solutions;

USE cog_solutions;

-- Tabela 1: cliente
CREATE TABLE cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nomeEmpresa VARCHAR(100) NOT NULL,
    nomeResponsavel VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    cnpj CHAR(14) UNIQUE,
    dtCadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela 2: estufa
CREATE TABLE ambienteCultivo (
    idAmbienteCultivo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL, -- Ex: 'Câmara 01 - Incubação'
    faseCultivo VARCHAR(40) NOT NULL, -- Ex: 'Incubação', 'Frutificação', 'Camada de Cobertura'
    capacidadeSacos INT DEFAULT 800  -- Capacidade padrão (800 a 1000 sacos)
);

-- Tabela 3: sensor
CREATE TABLE sensor (
    idSensor INT AUTO_INCREMENT PRIMARY KEY,
    codigoIdentificador VARCHAR(30) NOT NULL UNIQUE, -- Ex: 'SENS-DHT11-01'
    tipoSensor VARCHAR(40) NOT NULL,                -- Ex: 'DHT11 - Umidade Ar / Temp', 'Capacitivo - Substrato'
    posicaoAmbienteCultivo VARCHAR(50),                       -- Ex: 'Setor Norte - Prateleira 2'
    statusSensor VARCHAR(20) DEFAULT 'Ativo'        -- 'Ativo', 'Inativo', 'Manutenção'
);

-- Tabela 4: leitura (Histórico do Sensoriamento)
CREATE TABLE leitura (
    idLeitura INT AUTO_INCREMENT PRIMARY KEY,
    umidadeAr DECIMAL(4,1) NULL,          -- Umidade Relativa do Ar em %
    umidadeSolo DECIMAL(4,1) NULL,   -- Umidade do Substrato em %
    dtHora DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO cliente (nomeEmpresa, nomeResponsavel, email, telefone, cnpj) VALUES
('Cogumelos Cogumaster SP', 'Carlos Eduardo Silva', 'contato@cogumaster.com.br', '(11) 98765-4321', '12345678000195'),
('Fungicultura Paris Brasil', 'Mariana Oliveira', 'atendimento@parisbrasil.com.br', '(11) 97123-8899', '98765432000110');

-- Inserindo Estufas / Câmaras de Cultivo
INSERT INTO estufa (nomeCamara, faseCultivo, capacidadeSacos) VALUES
('Câmara 01', 'Incubação/Colonização', 1000),
('Câmara 02', 'Frutificação (Sala de Cultivo)', 800),
('Estufa A - Mogi', 'Frutificação (Sala de Cultivo)', 950);

-- Inserindo Sensores (DHT11 e Umidade de Solo/Substrato)
INSERT INTO sensor (codigoIdentificador, tipoSensor, posicaoEstufa, statusSensor) VALUES
('SENS-AR-01', 'DHT11 - Ar/Temp', 'Setor Central - Altura 1.8m', 'Ativo'),
('SENS-SUB-01', 'Capacitivo - Substrato', 'Prateleira A - Saco 12', 'Ativo'),
('SENS-AR-02', 'DHT11 - Ar/Temp', 'Setor Sul - Prateleira B', 'Ativo'),
('SENS-SUB-02', 'Capacitivo - Substrato', 'Prateleira B - Saco 45', 'Ativo'),
('SENS-AR-03', 'DHT11 - Ar/Temp', 'Setor Norte - Prateleira C', 'Manutenção');

-- Inserindo Histórico de Leituras (Simulando leituras a cada 5 minutos)
-- Fase Incubação: Esperado Temp ~20°C, UR Ar ~90-95%, Substrato ~70-75%
-- Fase Frutificação: Esperado Temp 16-22°C, UR Ar ~80-90%
INSERT INTO leitura (temperatura, umidadeAr, umidadeSolo, dtHora) VALUES
-- Leituras Câmara 01 (Incubação - Sensor Ar)
(20.5, 93.0, NULL, '2026-03-03 10:00:00'),
(20.8, 92.5, NULL, '2026-03-03 10:05:00'),
(21.0, 88.0, NULL, '2026-03-03 10:10:00'), -- Queda na UR do Ar (Alerta potencial)

-- Leituras Câmara 01 (Incubação - Sensor Substrato)
(NULL, NULL, 74.5, '2026-03-03 10:00:00'),
(NULL, NULL, 73.0, '2026-03-03 10:05:00'),
(NULL, NULL, 68.5, '2026-03-03 10:10:00'), -- Substrato ressecando (Alerta)

-- Leituras Câmara 02 (Frutificação - Sensor Ar)
(18.2, 85.0, NULL, '2026-03-03 10:00:00'),
(18.5, 84.5, NULL, '2026-03-03 10:05:00'),
(19.0, 75.0, NULL, '2026-03-03 10:10:00'), -- Umidade abaixo de 80% em Frutificação (Risco de Bacterial Blotch)

-- Leituras Câmara 02 (Frutificação - Sensor Substrato)
(NULL, NULL, 71.0, '2026-03-03 10:00:00'),
(NULL, NULL, 70.8, '2026-03-03 10:05:00');

SELECT * FROM cliente;
SELECT * FROM estufa;
SELECT * FROM leitura;
SELECT * FROM sensor;