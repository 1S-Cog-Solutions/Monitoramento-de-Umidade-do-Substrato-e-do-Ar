-- Integrantes:
-- Mariana O. Soares
-- Enzo Fuchs Bento
-- Christian Miranda
-- Vitor Alexandre
-- Victor Dos Passos 
-- Paulo Henrique

CREATE DATABASE cog_solutions;

USE cog_solutions;

-- Tabela 1: Usuario
CREATE TABLE Usuario (

idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT chkEmail CHECK (email LIKE '%@%'),
	dtCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_Empresa INT,
    fk_Rensponsavel INT
);

CREATE TABLE Empresa (

idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
    Empresa_nome VARCHAR(100) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT chkEmail CHECK (email LIKE '%@%'),
    telefone char(20),
    cnpj char(14),
	dtCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_Empresa INT,
    fk_Rensponsavel INT
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
    temperatura DECIMAL(4,1) NULL,   
    dtHora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_sensor INT , FOREIGN KEY (fk_sensor) REFERENCES sensor(idSensor)
);

-- Insert into
INSERT INTO Empresa (nomeEmpresa, nomeResponsavel, email, telefone, cnpj) VALUES
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
INSERT INTO leitura (umidadeAr, umidadeSolo, temperatura, fk_sensor) VALUES
-- Leituras Câmara 01 (Incubação - Sensor Ar/Substrato)
(93.0, 73.9, 23.4,1),
(92.5, 69.1, 23.4,1),
(null,88.0 , 45.5,2);-- Queda na UR do Ar (Alerta potencial)

SELECT * FROM leitura;-- Queda na UR do Ar (Alerta potencial)


SELECT * FROM Empresa;
SELECT * FROM ambienteCultivo;
SELECT * FROM leitura;
SELECT * FROM sensor;
describe Empresa;

select * from leitura where umidadeAr and umidadeSolo is not null; 


select * from ambienteCultivo where faseCultivo in ('Frutificação');

insert into ambienteCultivo values
(default,'camara 03','Compostagem',1200);

describe Empresa;

