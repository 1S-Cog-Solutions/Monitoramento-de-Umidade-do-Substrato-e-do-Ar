-- Integrantes:
-- Mariana O. Soares
-- Enzo Fuchs Bento
-- Christian Miranda
-- Vitor Alexandre
-- Victor Dos Passos 
-- Paulo Henrique

CREATE DATABASE cog_solutions;

USE cog_solutions;

show tables;
-- caso as tabelas já existem, não queria dar alter table , já que o script precisa do modelo da tabela pronto, fazer nessa ordem pois existem constraints 
DROP TABLE IF EXISTS leitura;
DROP TABLE IF EXISTS sensor;
DROP TABLE IF EXISTS lote;
DROP TABLE IF EXISTS faixa_ideal;
DROP TABLE IF EXISTS Endereco;
DROP TABLE IF EXISTS ambienteCultivo;
DROP TABLE IF EXISTS Usuario;
DROP TABLE IF EXISTS Empresa;

-- Tabela 1: Usuario
CREATE TABLE Usuario (

idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL,
    senha varchar(50) NOT NULL,
    CONSTRAINT chkEmailuser CHECK (email LIKE '%@%'),
	dtCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_Empresa INT,
     fk_Responsavel INT,
     adminstrador TINYINT ,
       CONSTRAINT chk_admin_binary CHECK (adminstrador IN (0, 1)),
    CONSTRAINT responsavel
	FOREIGN KEY (fk_Responsavel) 
		REFERENCES Usuario(idUsuario)
);



-- tabela 2: Empresa
CREATE TABLE Empresa (

idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
    empresa_nome VARCHAR(100) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT chkEmail CHECK (email LIKE '%@%'),
    telefone char(20),
    cnpj char(14),
	dtCadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- A FK de Usuario para Empresa so pode ser criada depois da tabela Empresa existir
ALTER TABLE Usuario
    ADD CONSTRAINT fkUsuarioEmpresa
    FOREIGN KEY (fk_Empresa) REFERENCES Empresa(idEmpresa);

-- Insert into Empresa
INSERT INTO Empresa (empresa_nome, email, cnpj) VALUES
('Cogumelos Cogumaster SP', 'contato@cogumaster.com.br', '12345678000195'),
('Estufas e Cogumelos Brasil',  'contato@estufascogumelos.com.br',  '38710932000175'),
('Fungicultura Paris Brasil',  'atendimento@parisbrasil.com.br','98765432000110');

select * from Empresa;

-- Tabela 3: estufa
-- A fase do cultivo deixou de ficar aqui e passou para a tabela lote (Tabela 7)
CREATE TABLE ambienteCultivo (
    idambienteCultivo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL, -- Ex: 'Câmara 01'
    capacidadeSacos INT DEFAULT 800,  -- Capacidade padrão (800 a 1000 sacos)
    fk_Empresa INT NOT NULL,
    CONSTRAINT fkAmbienteEmpresa
    FOREIGN KEY (fk_Empresa) REFERENCES Empresa(idEmpresa)
);



-- (outra tabela para o vidro que abrange o substrato)

-- Tabela 4: sensor
CREATE TABLE sensor (
    idSensor INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(40) NOT NULL,  -- Ex: 'DHT11', 'Capacitivo - Substrato'
    CONSTRAINT chkTipo CHECK(tipo IN ('DHT11', 'Capacitivo - Substrato')),
    posicaoAmbienteCultivo VARCHAR(50), -- Ex: 'Setor Norte - Prateleira 2'
    statuss VARCHAR(20) DEFAULT 'Ativo', -- 'Ativo', 'Inativo'
    CONSTRAINT chkStatuss CHECK(statuss IN ('Ativo', 'Inativo')),
    descricao VARCHAR(80),
    fk_ambienteCultivo INT NOT NULL,
    CONSTRAINT fkSensorAmbiente
    FOREIGN KEY (fk_ambienteCultivo) REFERENCES ambienteCultivo(idambienteCultivo)
);

-- Tabela 5: leitura (Histórico do Sensoriamento)

CREATE TABLE leitura (
    id_leitura INT PRIMARY KEY auto_increment,
    umidadeAr   DECIMAL(4,1) NULL,  
    umidadeSolo DECIMAL(4,1) NULL,   
    temperatura DECIMAL(4,1) NULL,   
	fk_sensor   INT NOT NULL,
     dtHora      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fkLeituraSensor FOREIGN KEY (fk_sensor) REFERENCES sensor(idSensor)
);

-- Tabela 6: Endereco (1 empresa pode ter varios enderecos: matriz e filiais)
CREATE TABLE Endereco (
    idEndereco INT AUTO_INCREMENT PRIMARY KEY,
    cep CHAR(10) NOT NULL,
    logradouro VARCHAR(45) NOT NULL,
    numero CHAR(10) NOT NULL,
    complemento VARCHAR(45),
    bairro VARCHAR(45) NOT NULL,
    cidade VARCHAR(45) NOT NULL,
    UF CHAR(2) NOT NULL,
    fk_Empresa INT NOT NULL,
    CONSTRAINT fkEnderecoEmpresa
    FOREIGN KEY (fk_Empresa) REFERENCES Empresa(idEmpresa)
);

-- Tabela 7: lote (ciclo de cultivo de uma câmara)
CREATE TABLE lote (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    fase_atual VARCHAR(40) NOT NULL,
    CONSTRAINT chkFaseLote CHECK(fase_atual IN ('Compostagem', 'Pasteurização', 'Incubação', 'Indução', 'Frutificação')),
    dt_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_final DATETIME NULL, -- NULL = lote em andamento
    CONSTRAINT chkLoteDatas CHECK(dt_final IS NULL OR dt_final >= dt_inicio),
    fk_ambienteCultivo INT NOT NULL,
    CONSTRAINT fkLoteAmbiente
    FOREIGN KEY (fk_ambienteCultivo) REFERENCES ambienteCultivo(idambienteCultivo)
);

-- Tabela 8: faixa_ideal (limites minimo e maximo por empresa, fase e parametro)
-- O parametro usa o mesmo nome das colunas da tabela leitura
CREATE TABLE faixa_ideal (
    idfaixa_ideal INT AUTO_INCREMENT PRIMARY KEY,
    fase VARCHAR(40) NOT NULL,
    CONSTRAINT chkFaseFaixa CHECK(fase IN ('Compostagem', 'Pasteurização', 'Incubação', 'Indução', 'Frutificação')),
    parametro VARCHAR(45) NOT NULL,
    CONSTRAINT chkParametro CHECK(parametro IN ('umidadeAr', 'umidadeSolo', 'temperatura')),
    valor_min DECIMAL(4,1) NOT NULL,
    valor_max DECIMAL(4,1) NOT NULL,
    CONSTRAINT chkFaixaValores CHECK(valor_min <= valor_max),
    fk_Empresa INT NOT NULL,
    CONSTRAINT fkFaixaEmpresa
    FOREIGN KEY (fk_Empresa) REFERENCES Empresa(idEmpresa),
    CONSTRAINT uqFaixa UNIQUE (fk_Empresa, fase, parametro)
);

INSERT INTO Usuario (nome, email, senha, fk_Empresa, fk_Responsavel) VALUES
('Ana Lima',      'ana@cogumaster.com.br',        'Teste@123', 1, NULL),  -- id 1 (gestora)
('Diego Rocha',   'diego@estufascogumelos.com.br','Teste@123', 2, NULL),  -- id 2 (gestor)
('Fábio Teixeira','fabio@parisbrasil.com.br',     'Teste@123', 3, NULL),  -- id 3 (gestor)
('Helena Duarte', 'helena@semempresa.com',        'Teste@123', NULL, NULL); -- id 4 (sem empresa)
 
INSERT INTO Usuario (nome, email, senha, fk_Empresa, fk_Responsavel) VALUES
('Bruno Costa',   'bruno@cogumaster.com.br',      'Teste@123', 1, 1),     -- id 5, responsável: Ana
('Elisa Prado',   'elisa@estufascogumelos.com.br','Teste@123', 2, 2),     -- id 6, responsável: Diego
('Gustavo Alves', 'gustavo@parisbrasil.com.br',   'Teste@123', 3, 3);     -- id 7, responsável: Fábio
 
INSERT INTO Usuario (nome, email, senha, fk_Empresa, fk_Responsavel) VALUES
('Carla Mendes',  'carla@cogumaster.com.br',      'Teste@123', 1, 5);     -- id 8, responsável: Bruno (3º nível)



-- Inserindo Estufas / Câmaras de Cultivo
INSERT INTO ambienteCultivo  (nome, capacidadeSacos, fk_Empresa) VALUES
('Câmara 01', 1000, 1),          -- id 1, Cogumaster
('Câmara 02', 800, 1),           -- id 2, Cogumaster
('Estufa A - Mogi', 950, 2);     -- id 3, Estufas e Cogumelos Brasil

-- Inserindo Sensores (DHT11 e Umidade de Solo/Substrato)
INSERT INTO sensor (tipo, posicaoAmbienteCultivo, statuss, descricao, fk_ambienteCultivo) VALUES
('DHT11', 'Setor Central - Altura 1.8m', 'Ativo', 'Medição da umidade do ar', 1),                 -- id 1
('Capacitivo - Substrato', 'Setor Central - Altura 1.8m', 'Ativo', 'Medição da umidade do substrato', 1), -- id 2
('Capacitivo - Substrato', 'Prateleira A - Saco 12', 'Ativo', 'Medição da umidade do substrato', 1),      -- id 3
('DHT11', 'Setor Sul - Prateleira B', 'Ativo', 'Medição da umidade do ar', 2),                    -- id 4
('Capacitivo - Substrato', 'Prateleira B - Saco 45', 'Ativo', 'Medição da umidade do substrato', 2),      -- id 5
('DHT11', 'Setor Norte - Prateleira C', 'Inativo', 'Medição da umidade do ar', 3),                -- id 6
('Capacitivo - Substrato', 'Prateleira C - Saco 08', 'Ativo', 'Medição da umidade do substrato', 3);     -- id 7

-- Inserindo Histórico de Leituras (Simulando leituras a cada 5 minutos)
-- Fase Incubação: Esperado Temp ~20°C, UR Ar ~90-95%, Substrato ~70-75%
-- Fase Frutificação: Esperado Temp 16-22°C, UR Ar ~80-90%
INSERT INTO leitura (umidadeAr, umidadeSolo, temperatura, fk_sensor) VALUES
-- Leituras Câmara 01 (Incubação - Sensor Ar/Substrato)
(93.0, 73.9, 23.4,1),
(92.5, 69.1, 23.4,1),
(null,88.0 , 45.5,2);-- Queda na UR do Ar (Alerta potencial)

-- Leituras com data e hora definidas (DHT11 mede ar e temperatura; Capacitivo mede substrato)
INSERT INTO leitura (umidadeAr, umidadeSolo, temperatura, fk_sensor, dtHora) VALUES
-- Câmara 01 - lote encerrado (Frutificação)
(82.0, null, 18.0, 1, '2026-09-15 08:00:00'),
(null, 58.0, null, 2, '2026-09-15 08:00:00'),
-- Câmara 01 - lote atual (Incubação)
(93.5, null, 21.0, 1, '2026-10-18 08:00:00'),
(92.0, null, 21.2, 1, '2026-10-18 08:05:00'),
(84.0, null, 24.5, 1, '2026-10-18 08:10:00'),   -- ar e temperatura fora da faixa
(null, 68.0, null, 2, '2026-10-18 08:00:00'),
(null, 67.5, null, 2, '2026-10-18 08:05:00'),
(null, 62.0, null, 2, '2026-10-18 08:10:00'),   -- substrato abaixo do mínimo
(null, 71.0, null, 3, '2026-10-18 08:00:00'),   -- substrato acima do máximo
(null, 69.0, null, 3, '2026-10-18 08:05:00'),
-- Câmara 02 (Frutificação)
(85.0, null, 18.5, 4, '2026-10-18 08:00:00'),
(88.0, null, 19.0, 4, '2026-10-18 08:05:00'),
(78.0, null, 23.5, 4, '2026-10-18 08:10:00'),   -- ar abaixo e temperatura acima
(null, 62.0, null, 5, '2026-10-18 08:00:00'),
(null, 63.5, null, 5, '2026-10-18 08:05:00'),
(null, 58.0, null, 5, '2026-10-18 08:10:00'),   -- substrato abaixo do mínimo
-- Estufa A - Mogi (Frutificação) - o sensor 6 está inativo e não tem leituras
(null, 61.0, null, 7, '2026-10-18 08:00:00'),
(null, 64.0, null, 7, '2026-10-18 08:05:00'),
(null, 66.5, null, 7, '2026-10-18 08:10:00');   -- substrato acima do máximo


-- testes ---------

SELECT * FROM Empresa;
SELECT * FROM ambienteCultivo;
SELECT * FROM leitura;
SELECT * FROM sensor;


select * from leitura where umidadeAr is not null and umidadeSolo is not null; 


insert into ambienteCultivo (nome, capacidadeSacos, fk_Empresa) values
('camara 03', 1200, 1);   -- id 4, Cogumaster (ainda sem sensor)



-- Inserindo Endereços
INSERT INTO Endereco (cep, logradouro, numero, complemento, bairro, cidade, UF, fk_Empresa) VALUES
('08730-000', 'Estrada dos Cogumelos', '1200', 'Sítio 3', 'Taboão', 'Mogi das Cruzes', 'SP', 1),   -- matriz Cogumaster
('13400-000', 'Rua das Estufas', '85', NULL, 'Centro', 'Piracicaba', 'SP', 1),                      -- filial Cogumaster
('08600-000', 'Avenida Fungicultura', '450', 'Galpão B', 'Jardim Paulista', 'Suzano', 'SP', 2);     -- Estufas e Cogumelos Brasil
-- A empresa 3 (Fungicultura Paris Brasil) fica sem endereço de propósito, para testar o LEFT JOIN

-- Inserindo Lotes (ciclos de cultivo)
INSERT INTO lote (fase_atual, dt_inicio, dt_final, fk_ambienteCultivo) VALUES
('Frutificação', '2026-06-01 08:00:00', '2026-10-04 18:00:00', 1),  -- id 1, Câmara 01 (lote encerrado)
('Incubação',    '2026-10-05 08:00:00', NULL, 1),                   -- id 2, Câmara 01 (em andamento)
('Frutificação', '2026-09-20 08:00:00', NULL, 2),                   -- id 3, Câmara 02 (em andamento)
('Frutificação', '2026-10-01 08:00:00', NULL, 3),                   -- id 4, Estufa A - Mogi (em andamento)
('Compostagem',  '2026-10-12 08:00:00', NULL, 4);                   -- id 5, camara 03 (em andamento)

select * from lote where fase_atual in ('Frutificação');

-- Inserindo Faixas Ideais (valores da documentação do projeto)
-- A empresa 3 fica sem faixas de propósito, para testar o LEFT JOIN
INSERT INTO faixa_ideal (fase, parametro, valor_min, valor_max, fk_Empresa) VALUES
('Compostagem',   'umidadeSolo', 70.0, 75.0, 1),
('Incubação',     'umidadeAr',   90.0, 95.0, 1),
('Incubação',     'umidadeSolo', 65.0, 70.0, 1),
('Incubação',     'temperatura', 20.0, 22.0, 1),
('Indução',       'umidadeSolo', 70.0, 75.0, 1),
('Frutificação',  'umidadeAr',   80.0, 90.0, 1),
('Frutificação',  'umidadeSolo', 60.0, 65.0, 1),
('Frutificação',  'temperatura', 16.0, 22.0, 1),
('Frutificação',  'umidadeAr',   80.0, 90.0, 2),
('Frutificação',  'umidadeSolo', 60.0, 65.0, 2),
('Frutificação',  'temperatura', 16.0, 22.0, 2);

SELECT * FROM Endereco;
SELECT * FROM lote;
SELECT * FROM faixa_ideal;




-- JOINS _____________________________________

SHOW TABLES;
 
-- 3.1 JOIN: usuários que têm empresa
SELECT u.idUsuario, u.nome AS usuario, u.email, e.empresa_nome AS empresa
FROM Usuario u
JOIN Empresa e ON e.idEmpresa = u.fk_Empresa
ORDER BY e.empresa_nome, u.nome;
 
-- 3.2 auto JOIN: usuário e seu responsável
--     LEFT JOIN para os gestores (sem responsável) não sumirem do resultado
SELECT u.idUsuario,
       u.nome                              AS usuario,
       COALESCE(r.nome, 'Sem responsável') AS responsavel
FROM Usuario u
LEFT JOIN Usuario r ON r.idUsuario = u.fk_Responsavel
ORDER BY u.idUsuario;
 
-- 3.3 Visão completa: usuário + empresa + responsável
SELECT u.idUsuario,
       u.nome                                      AS usuario,
       COALESCE(e.empresa_nome, 'Sem empresa')     AS empresa,
       COALESCE(r.nome, 'Sem responsável')         AS responsavel
FROM Usuario u
LEFT JOIN Empresa e ON e.idEmpresa  = u.fk_Empresa
LEFT JOIN Usuario r ON r.idUsuario  = u.fk_Responsavel
ORDER BY empresa, u.nome;
 
-- 3.4 Cadeia hierárquica (usuário -> responsável -> responsável do responsável)
SELECT u.nome  AS usuario,
       r.nome  AS responsavel,
       r2.nome AS responsavelDoResponsavel
FROM Usuario u
LEFT JOIN Usuario r  ON r.idUsuario  = u.fk_Responsavel
LEFT JOIN Usuario r2 ON r2.idUsuario = r.fk_Responsavel
WHERE u.fk_Responsavel IS NOT NULL;
 
-- 3.5 Quantos subordinados diretos cada pessoa tem
SELECT r.idUsuario,
       r.nome AS responsavel,
       e.empresa_nome AS empresa,
       COUNT(u.idUsuario) AS qtdSubordinados
FROM Usuario r
LEFT JOIN Usuario u ON u.fk_Responsavel = r.idUsuario
LEFT JOIN Empresa e ON e.idEmpresa      = r.fk_Empresa
GROUP BY r.idUsuario, r.nome, e.empresa_nome
ORDER BY qtdSubordinados DESC, r.nome;
 



-- 3.7 Usuários sem empresa
SELECT u.idUsuario, u.nome, u.email
FROM Usuario u
LEFT JOIN Empresa e ON e.idEmpresa = u.fk_Empresa
WHERE e.idEmpresa IS NULL;
 
 


-- JOINS DAS NOVAS TABELAS _____________________________________

-- ---------- Endereco ----------

-- 4.1 JOIN: empresas e seus endereços
SELECT e.idEmpresa,
       e.empresa_nome                           AS empresa,
       CONCAT(en.logradouro, ', ', en.numero)   AS endereco,
       en.cidade,
       en.UF
FROM Empresa e
JOIN Endereco en ON en.fk_Empresa = e.idEmpresa
ORDER BY e.empresa_nome, en.cidade;

-- 4.2 LEFT JOIN: empresas sem endereço cadastrado
SELECT e.idEmpresa, e.empresa_nome AS empresa
FROM Empresa e
LEFT JOIN Endereco en ON en.fk_Empresa = e.idEmpresa
WHERE en.idEndereco IS NULL;

-- 4.3 Quantos endereços cada empresa tem
SELECT e.idEmpresa,
       e.empresa_nome AS empresa,
       COUNT(en.idEndereco) AS qtdEnderecos
FROM Empresa e
LEFT JOIN Endereco en ON en.fk_Empresa = e.idEmpresa
GROUP BY e.idEmpresa, e.empresa_nome
ORDER BY qtdEnderecos DESC, e.empresa_nome;


-- ---------- ambienteCultivo ----------

-- 4.4 JOIN: câmaras e a empresa dona
SELECT a.idambienteCultivo,
       a.nome AS camara,
       a.capacidadeSacos,
       e.empresa_nome AS empresa
FROM ambienteCultivo a
JOIN Empresa e ON e.idEmpresa = a.fk_Empresa
ORDER BY e.empresa_nome, a.nome;

-- 4.5 LEFT JOIN: empresas sem nenhuma câmara
SELECT e.idEmpresa, e.empresa_nome AS empresa
FROM Empresa e
LEFT JOIN ambienteCultivo a ON a.fk_Empresa = e.idEmpresa
WHERE a.idambienteCultivo IS NULL;

-- 4.6 Quantas câmaras cada empresa tem
SELECT e.idEmpresa,
       e.empresa_nome AS empresa,
       COUNT(a.idambienteCultivo) AS qtdCamaras
FROM Empresa e
LEFT JOIN ambienteCultivo a ON a.fk_Empresa = e.idEmpresa
GROUP BY e.idEmpresa, e.empresa_nome
ORDER BY qtdCamaras DESC, e.empresa_nome;


-- ---------- lote ----------

-- 4.7 JOIN: lotes com a câmara e a empresa
SELECT lo.id_lote,
       e.empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       lo.dt_inicio,
       lo.dt_final
FROM lote lo
JOIN ambienteCultivo a ON a.idambienteCultivo = lo.fk_ambienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fk_Empresa
ORDER BY e.empresa_nome, a.nome, lo.dt_inicio;

-- 4.8 Lotes em andamento (sem data final)
SELECT lo.id_lote, a.nome AS camara, lo.fase_atual AS fase, lo.dt_inicio
FROM lote lo
JOIN ambienteCultivo a ON a.idambienteCultivo = lo.fk_ambienteCultivo
WHERE lo.dt_final IS NULL
ORDER BY a.nome;

-- 4.9 Lotes encerrados
SELECT lo.id_lote, a.nome AS camara, lo.fase_atual AS fase, lo.dt_inicio, lo.dt_final
FROM lote lo
JOIN ambienteCultivo a ON a.idambienteCultivo = lo.fk_ambienteCultivo
WHERE lo.dt_final IS NOT NULL
ORDER BY lo.dt_final;

-- 4.10 Quantos lotes cada câmara já teve
SELECT a.idambienteCultivo,
       a.nome AS camara,
       COUNT(lo.id_lote) AS qtdLotes
FROM ambienteCultivo a
LEFT JOIN lote lo ON lo.fk_ambienteCultivo = a.idambienteCultivo
GROUP BY a.idambienteCultivo, a.nome
ORDER BY qtdLotes DESC, a.nome;


-- ---------- sensor ----------

-- 4.11 JOIN: sensores com a câmara e a empresa
SELECT s.idSensor,
       s.tipo,
       s.posicaoAmbienteCultivo AS posicao,
       s.statuss                AS status,
       a.nome                   AS camara,
       e.empresa_nome           AS empresa
FROM sensor s
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fk_Empresa
ORDER BY e.empresa_nome, a.nome, s.idSensor;

-- 4.12 LEFT JOIN: câmaras sem nenhum sensor instalado
SELECT a.idambienteCultivo, a.nome AS camara
FROM ambienteCultivo a
LEFT JOIN sensor s ON s.fk_ambienteCultivo = a.idambienteCultivo
WHERE s.idSensor IS NULL;

-- 4.13 Quantos sensores cada câmara tem
SELECT a.idambienteCultivo,
       a.nome AS camara,
       COUNT(s.idSensor) AS qtdSensores
FROM ambienteCultivo a
LEFT JOIN sensor s ON s.fk_ambienteCultivo = a.idambienteCultivo
GROUP BY a.idambienteCultivo, a.nome
ORDER BY qtdSensores DESC, a.nome;

-- 4.14 Sensores inativos e onde estão
SELECT s.idSensor, s.tipo, s.posicaoAmbienteCultivo AS posicao, a.nome AS camara
FROM sensor s
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
WHERE s.statuss = 'Inativo';


-- ---------- leitura ----------

-- 4.15 JOIN: leituras com o sensor e a câmara (mais recentes primeiro)
SELECT l.id_leitura,
       l.dtHora,
       a.nome AS camara,
       s.tipo AS sensor,
       l.umidadeAr,
       l.umidadeSolo,
       l.temperatura
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fk_sensor
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
ORDER BY l.dtHora DESC, l.id_leitura;

-- 4.16 LEFT JOIN: sensores sem nenhuma leitura (possível falha de comunicação)
SELECT s.idSensor, s.tipo, s.statuss AS status, a.nome AS camara
FROM sensor s
LEFT JOIN leitura l ON l.fk_sensor = s.idSensor
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
WHERE l.id_leitura IS NULL;

-- 4.17 Quantas leituras cada sensor enviou
SELECT s.idSensor,
       s.tipo,
       a.nome AS camara,
       COUNT(l.id_leitura) AS qtdLeituras
FROM sensor s
LEFT JOIN leitura l ON l.fk_sensor = s.idSensor
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
GROUP BY s.idSensor, s.tipo, a.nome
ORDER BY qtdLeituras DESC, s.idSensor;

-- 4.18 Leitura + lote: o lote é descoberto pela câmara do sensor e pela data da leitura
SELECT l.id_leitura,
       l.dtHora,
       a.nome         AS camara,
       lo.id_lote,
       lo.fase_atual  AS fase,
       l.umidadeAr,
       l.umidadeSolo,
       l.temperatura
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fk_sensor
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
JOIN lote lo           ON lo.fk_ambienteCultivo = a.idambienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
ORDER BY lo.id_lote, l.dtHora;

-- 4.19 Quantas leituras cada lote recebeu
SELECT lo.id_lote,
       a.nome        AS camara,
       lo.fase_atual AS fase,
       COUNT(l.id_leitura) AS qtdLeituras
FROM lote lo
JOIN ambienteCultivo a ON a.idambienteCultivo = lo.fk_ambienteCultivo
LEFT JOIN sensor s     ON s.fk_ambienteCultivo = a.idambienteCultivo
LEFT JOIN leitura l    ON l.fk_sensor = s.idSensor
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
GROUP BY lo.id_lote, a.nome, lo.fase_atual
ORDER BY lo.id_lote;


-- ---------- faixa_ideal ----------

-- 4.20 JOIN: faixas ideais de cada empresa
SELECT e.empresa_nome AS empresa,
       f.fase,
       f.parametro,
       f.valor_min,
       f.valor_max
FROM faixa_ideal f
JOIN Empresa e ON e.idEmpresa = f.fk_Empresa
ORDER BY e.empresa_nome, f.fase, f.parametro;

-- 4.21 LEFT JOIN: empresas sem nenhuma faixa configurada
SELECT e.idEmpresa, e.empresa_nome AS empresa
FROM Empresa e
LEFT JOIN faixa_ideal f ON f.fk_Empresa = e.idEmpresa
WHERE f.idfaixa_ideal IS NULL;

-- 4.22 Alerta de umidade do AR fora da faixa
--      (faixa da empresa dona da câmara, na fase do lote vigente na data da leitura)
SELECT e.empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeAr    AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fk_sensor
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fk_Empresa
JOIN lote lo           ON lo.fk_ambienteCultivo = a.idambienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN faixa_ideal f     ON f.fk_Empresa = e.idEmpresa
                      AND f.fase       = lo.fase_atual
                      AND f.parametro  = 'umidadeAr'
WHERE l.umidadeAr < f.valor_min OR l.umidadeAr > f.valor_max
ORDER BY l.dtHora;

-- 4.23 Alerta de umidade do SUBSTRATO fora da faixa
SELECT e.empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeSolo  AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fk_sensor
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fk_Empresa
JOIN lote lo           ON lo.fk_ambienteCultivo = a.idambienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN faixa_ideal f     ON f.fk_Empresa = e.idEmpresa
                      AND f.fase       = lo.fase_atual
                      AND f.parametro  = 'umidadeSolo'
WHERE l.umidadeSolo < f.valor_min OR l.umidadeSolo > f.valor_max
ORDER BY l.dtHora;

-- 4.24 Alerta de TEMPERATURA fora da faixa
SELECT e.empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.temperatura  AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fk_sensor
JOIN ambienteCultivo a ON a.idambienteCultivo = s.fk_ambienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fk_Empresa
JOIN lote lo           ON lo.fk_ambienteCultivo = a.idambienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN faixa_ideal f     ON f.fk_Empresa = e.idEmpresa
                      AND f.fase       = lo.fase_atual
                      AND f.parametro  = 'temperatura'
WHERE l.temperatura < f.valor_min OR l.temperatura > f.valor_max
ORDER BY l.dtHora;


-- ---------- Visão completa ----------

-- 4.25 Empresa -> câmara -> sensor -> quantidade de leituras
--      LEFT JOIN em tudo para não sumirem empresas sem câmara, câmaras sem sensor e sensores sem leitura
SELECT e.empresa_nome                          AS empresa,
       COALESCE(a.nome, 'Sem câmara')          AS camara,
       COALESCE(s.tipo, 'Sem sensor')          AS sensor,
       COUNT(l.id_leitura)                     AS qtdLeituras
FROM Empresa e
LEFT JOIN ambienteCultivo a ON a.fk_Empresa        = e.idEmpresa
LEFT JOIN sensor s          ON s.fk_ambienteCultivo = a.idambienteCultivo
LEFT JOIN leitura l         ON l.fk_sensor          = s.idSensor
GROUP BY e.empresa_nome, a.nome, s.idSensor, s.tipo
ORDER BY e.empresa_nome, a.nome, s.idSensor;