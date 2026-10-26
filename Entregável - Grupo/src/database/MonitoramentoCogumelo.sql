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
    fkEmpresa INT,
     fkResponsavel INT,
     admin TINYINT(1),
       CONSTRAINT chk_admin_binary CHECK (admin IN (0, 1)),
    CONSTRAINT responsavel
	FOREIGN KEY (fkResponsavel) 
		REFERENCES Usuario(idUsuario)
);
 
-- tabela 2: Empresa
CREATE TABLE Empresa (
 
idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
    Empresa_nome VARCHAR(100) NOT NULL, 
    cnpj char(14),
	dtCadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);
 
-- A FK de Usuario para Empresa so pode ser criada depois da tabela Empresa existir
ALTER TABLE Usuario
    ADD CONSTRAINT fkUsuarioEmpresa
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa);
 
-- Tabela 3: estufa
CREATE TABLE ambienteCultivo (
    IdAmbienteCultivo INT AUTO_INCREMENT,
    fkEmpresa INT NOT NULL,
    nome VARCHAR(50) NOT NULL, -- Ex: 'Câmara 01'
    capacidade_sacos INT DEFAULT 800,  -- Capacidade padrão (800 a 1000 sacos)
    CONSTRAINT pkAmbiente PRIMARY KEY (IdAmbienteCultivo, fkEmpresa),
    CONSTRAINT uqAmbienteId UNIQUE (IdAmbienteCultivo),
    CONSTRAINT fkAmbienteEmpresa
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);
 
 
 
-- Tabela 4: sensor
CREATE TABLE sensor (
    idSensor INT AUTO_INCREMENT PRIMARY KEY,
    fkAmbienteCultivo INT NOT NULL,
    tipo VARCHAR(40) NOT NULL,  -- Ex: 'DHT11', 'Capacitivo - Substrato'
    CONSTRAINT chkTipo CHECK(tipo IN ('DHT11', 'Capacitivo - Substrato')),
    statuss VARCHAR(20) DEFAULT 'Ativo', -- 'Ativo', 'Inativo'
    CONSTRAINT chkStatuss CHECK(statuss IN ('Ativo', 'Inativo')),
    CONSTRAINT fkSensorAmbiente
    FOREIGN KEY (fkAmbienteCultivo) REFERENCES ambienteCultivo(IdAmbienteCultivo)
);
 
-- Tabela 5: leitura (Histórico do Sensoriamento)
CREATE TABLE leitura (
    id_leitura INT AUTO_INCREMENT,
    fkSensor   INT NOT NULL,
    umidadeAr   DECIMAL(4,1) NULL,  
    umidadeSolo DECIMAL(4,1) NULL,   
    Temperatura DECIMAL(4,1) NULL,   
    dtHora      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pkLeitura PRIMARY KEY (id_leitura, fkSensor),
    CONSTRAINT fkLeituraSensor FOREIGN KEY (fkSensor) REFERENCES sensor(idSensor)
);
 
-- Tabela 6: Endereco (1 empresa pode ter varios enderecos: matriz e filiais)
-- O campo unidade aceita apenas as palavras 'Matriz' ou 'Filial'
CREATE TABLE Endereco (
    idEndereco INT AUTO_INCREMENT,
    fkEmpresa INT NOT NULL,
    unidade VARCHAR(10) NOT NULL,
    CONSTRAINT chkUnidade CHECK(unidade IN ('Matriz', 'Filial')),
    cep CHAR(10) NOT NULL,
    logradouro VARCHAR(45) NOT NULL,
    numero CHAR(10) NOT NULL,
    complemento VARCHAR(45),
    bairro VARCHAR(45) NOT NULL,
    cidade VARCHAR(45) NOT NULL,
    UF VARCHAR(45) NOT NULL,
    CONSTRAINT pkEndereco PRIMARY KEY (idEndereco, fkEmpresa),
    CONSTRAINT fkEnderecoEmpresa
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa)
);
 
-- Tabela 7: lote (ciclo de cultivo de uma câmara)
-- Relacao IDENTIFICADORA com ambienteCultivo: a PK e composta (id_lote, fkAmbienteCultivo)
CREATE TABLE lote (
    id_lote INT AUTO_INCREMENT,
    fkAmbienteCultivo INT NOT NULL,
    fase_atual VARCHAR(45) NOT NULL,
    CONSTRAINT chkFaseLote CHECK(fase_atual IN ('Compostagem', 'Pasteurização', 'Incubação', 'Indução', 'Frutificação')),
    dt_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_final DATETIME NULL, -- NULL = lote em andamento
    CONSTRAINT chkLoteDatas CHECK(dt_final IS NULL OR dt_final >= dt_inicio),
    CONSTRAINT pkLote PRIMARY KEY (id_lote, fkAmbienteCultivo),
    CONSTRAINT fkLoteAmbiente
    FOREIGN KEY (fkAmbienteCultivo) REFERENCES ambienteCultivo(IdAmbienteCultivo)
);
 
-- Tabela 8: faixa_ideal (limites minimo e maximo por empresa, fase e parametro)
-- O parametro usa o mesmo nome das colunas da tabela leitura
-- Relacao IDENTIFICADORA com Empresa: a PK e composta (idfaixa_ideal, fkEmpresa)
CREATE TABLE faixa_ideal (
    idfaixa_ideal INT AUTO_INCREMENT,
    fkEmpresa INT NOT NULL,
    fase VARCHAR(45) NOT NULL,
    CONSTRAINT chkFaseFaixa CHECK(fase IN ('Compostagem', 'Pasteurização', 'Incubação', 'Indução', 'Frutificação')),
    parametro VARCHAR(45) NOT NULL,
    CONSTRAINT chkParametro CHECK(parametro IN ('umidadeAr', 'umidadeSolo', 'temperatura')),
    valor_min DECIMAL(4,1) NOT NULL,
    valor_max DECIMAL(4,1) NOT NULL,
    CONSTRAINT chkFaixaValores CHECK(valor_min <= valor_max),
    CONSTRAINT pkFaixa PRIMARY KEY (idfaixa_ideal, fkEmpresa),
    CONSTRAINT fkFaixaEmpresa
    FOREIGN KEY (fkEmpresa) REFERENCES Empresa(idEmpresa),
    CONSTRAINT uqFaixa UNIQUE (fkEmpresa, fase, parametro)
);
 
 
 
 
-- Insert into Empresa (precisa vir antes de Usuario, que referencia a Empresa)
INSERT INTO Empresa (Empresa_nome, cnpj) VALUES
('Cogumelos Cogumaster SP', '12345678000195'),
('Estufas e Cogumelos Brasil', '38710932000175'),
('Fungicultura Paris Brasil', '98765432000110');
 
INSERT INTO Usuario (nome, email, senha, fkEmpresa, fkResponsavel, admin) VALUES
('Ana Lima',      'ana@cogumaster.com.br',        'Teste@123', 1, Null,1),  -- id 1 (gestora)
('Diego Rocha',   'diego@estufascogumelos.com.br','Teste@123', 1, 1,1),  -- id 2 (gestor), responsável: Ana
('Fábio Teixeira','fabio@parisbrasil.com.br',     'Teste@123', 1, 1,1),  -- id 3 (gestor), responsável: Ana
('Helena Duarte', 'helena@semempresa.com',        'Teste@123', NULL, NULL, NULL); -- id 4 (sem empresa)
 
INSERT INTO Usuario (nome, email, senha, fkEmpresa, fkResponsavel, admin) VALUES
('Bruno Costa',   'bruno@cogumaster.com.br',      'Teste@123', 1, 1,0),     -- id 5, responsável: Ana
('Elisa Prado',   'elisa@estufascogumelos.com.br','Teste@123', 1, 2,0),     -- id 6, responsável: Diego
('Gustavo Alves', 'gustavo@parisbrasil.com.br',   'Teste@123', 1, 3,0);     -- id 7, responsável: Fábio
 
INSERT INTO Usuario (nome, email, senha, fkEmpresa, fkResponsavel, admin) VALUES
('Carla Mendes',  'carla@cogumaster.com.br',      'Teste@123', 1, 2,0);     -- id 8, responsável: Diego
 
-- Inserindo Estufas / Câmaras de Cultivo
INSERT INTO ambienteCultivo  (nome, capacidade_sacos, fkEmpresa) VALUES
('Câmara 01', 1000, 1),          -- id 1, Cogumaster
('Câmara 02', 800, 1),           -- id 2, Cogumaster
('Estufa A - Mogi', 950, 2);     -- id 3, Estufas e Cogumelos Brasil
 
insert into ambienteCultivo (nome, capacidade_sacos, fkEmpresa) values
('camara 03', 1200, 1);   -- id 4, Cogumaster (ainda sem sensor)
 
 
 
 
-- Inserindo Sensores (DHT11 e Umidade de Solo/Substrato)
-- A posição de cada sensor ficou nos comentários, pois a tabela sensor não tem esse campo
INSERT INTO sensor (tipo, statuss, fkAmbienteCultivo) VALUES
('DHT11', 'Ativo', 1),                    -- id 1, Setor Central - Altura 1.8m
('Capacitivo - Substrato', 'Ativo', 1),   -- id 2, Setor Central - Altura 1.8m
('Capacitivo - Substrato', 'Ativo', 1),   -- id 3, Prateleira A - Saco 12
('DHT11', 'Ativo', 2),                    -- id 4, Setor Sul - Prateleira B
('Capacitivo - Substrato', 'Ativo', 2),   -- id 5, Prateleira B - Saco 45
('DHT11', 'Inativo', 3),                  -- id 6, Setor Norte - Prateleira C
('Capacitivo - Substrato', 'Ativo', 3);   -- id 7, Prateleira C - Saco 08
 
-- Inserindo Histórico de Leituras (Simulando leituras a cada 5 minutos)
-- Fase Incubação: Esperado Temp ~20°C, UR Ar ~90-95%, Substrato ~70-75%
-- Fase Frutificação: Esperado Temp 16-22°C, UR Ar ~80-90%
INSERT INTO leitura (umidadeAr, umidadeSolo, Temperatura, fkSensor) VALUES
-- Leituras Câmara 01 (Incubação - Sensor Ar/Substrato)
(93.0, 73.9, 23.4,1),
(92.5, 69.1, 23.4,1),
(null,88.0 , 45.5,2);-- Queda na UR do Ar (Alerta potencial)
 
-- Leituras com data e hora definidas (DHT11 mede ar e temperatura; Capacitivo mede substrato)
INSERT INTO leitura (umidadeAr, umidadeSolo, Temperatura, fkSensor, dtHora) VALUES
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
 
 
 
 
-- Inserindo Endereços (unidade: apenas 'Matriz' ou 'Filial')
INSERT INTO Endereco (unidade, cep, logradouro, numero, complemento, bairro, cidade, UF, fkEmpresa) VALUES
('Matriz', '08730-000', 'Estrada dos Cogumelos', '1200', 'Sítio 3', 'Taboão', 'Mogi das Cruzes', 'SP', 1),   -- matriz Cogumaster
('Filial', '13400-000', 'Rua das Estufas', '85', NULL, 'Centro', 'Piracicaba', 'SP', 1),                      -- filial Cogumaster
('Matriz', '08600-000', 'Avenida Fungicultura', '450', 'Galpão B', 'Jardim Paulista', 'Suzano', 'SP', 2);     -- Estufas e Cogumelos Brasil (só matriz)
-- A empresa 3 (Fungicultura Paris Brasil) fica sem endereço de propósito, para testar o LEFT JOIN
 
-- Inserindo Lotes (ciclos de cultivo)
INSERT INTO lote (fase_atual, dt_inicio, dt_final, fkAmbienteCultivo) VALUES
('Frutificação', '2026-06-01 08:00:00', '2026-10-04 18:00:00', 1),  -- id 1, Câmara 01 (lote encerrado)
('Incubação',    '2026-10-05 08:00:00', NULL, 1),                   -- id 2, Câmara 01 (em andamento)
('Frutificação', '2026-09-20 08:00:00', NULL, 2),                   -- id 3, Câmara 02 (em andamento)
('Frutificação', '2026-10-01 08:00:00', NULL, 3),                   -- id 4, Estufa A - Mogi (em andamento)
('Compostagem',  '2026-10-12 08:00:00', NULL, 4);                   -- id 5, camara 03 (em andamento)
 
select * from lote where fase_atual in ('Frutificação');
 
-- Inserindo Faixas Ideais (valores da documentação do projeto)
-- A empresa 3 fica sem faixas de propósito, para testar o LEFT JOIN
INSERT INTO faixa_ideal (fase, parametro, valor_min, valor_max, fkEmpresa) VALUES
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
 
 
-- testes ---------
 
SELECT * FROM Empresa;
SELECT * FROM Usuario;
SELECT * FROM ambienteCultivo;
SELECT * FROM leitura;
SELECT * FROM sensor;
SELECT * FROM Endereco;
SELECT * FROM lote;
SELECT * FROM faixa_ideal;
 
 
 
 
-- JOINS _____________________________________
 
SHOW TABLES;
 
-- 3.1 JOIN: usuários que têm empresa
SELECT u.idUsuario, u.nome AS usuario, u.email, e.Empresa_nome AS empresa
FROM Usuario u
JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
ORDER BY e.Empresa_nome, u.nome;
 
-- 3.2 auto JOIN: usuário e seu responsável
--     LEFT JOIN para os gestores (sem responsável) não sumirem do resultado
SELECT u.idUsuario,
       u.nome                              AS usuario,
       COALESCE(r.nome, 'Sem responsável') AS responsavel
FROM Usuario u
LEFT JOIN Usuario r ON r.idUsuario = u.fkResponsavel
ORDER BY u.idUsuario;
 
-- 3.3 Visão completa: usuário + empresa + responsável
SELECT u.idUsuario,
       u.nome                                      AS usuario,
       COALESCE(e.Empresa_nome, 'Sem empresa')     AS empresa,
       COALESCE(r.nome, 'Sem responsável')         AS responsavel
FROM Usuario u
LEFT JOIN Empresa e ON e.idEmpresa  = u.fkEmpresa
LEFT JOIN Usuario r ON r.idUsuario  = u.fkResponsavel
ORDER BY empresa, u.nome;
 
-- 3.4 Cadeia hierárquica (usuário -> responsável -> responsável do responsável)
SELECT u.nome  AS usuario,
       r.nome  AS responsavel,
       r2.nome AS responsavelDoResponsavel
FROM Usuario u
LEFT JOIN Usuario r  ON r.idUsuario  = u.fkResponsavel
LEFT JOIN Usuario r2 ON r2.idUsuario = r.fkResponsavel
WHERE u.fkResponsavel IS NOT NULL;
 
-- 3.5 Quantos subordinados diretos cada pessoa tem
SELECT r.idUsuario,
       r.nome AS responsavel,
       e.Empresa_nome AS empresa,
       COUNT(u.idUsuario) AS qtdSubordinados
FROM Usuario r
LEFT JOIN Usuario u ON u.fkResponsavel = r.idUsuario
LEFT JOIN Empresa e ON e.idEmpresa     = r.fkEmpresa
GROUP BY r.idUsuario, r.nome, e.Empresa_nome
ORDER BY qtdSubordinados DESC, r.nome;
 
 
 
 
-- 3.7 Usuários sem empresa
SELECT u.idUsuario, u.nome, u.email
FROM Usuario u
LEFT JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
WHERE e.idEmpresa IS NULL;
 
 
 
 
-- JOINS DAS NOVAS TABELAS _____________________________________
 
-- ---------- Endereco ----------
 
-- 4.1 JOIN: empresas e seus endereços (matriz ou filial)
SELECT e.idEmpresa,
       e.Empresa_nome                           AS empresa,
       en.unidade,
       CONCAT(en.logradouro, ', ', en.numero)   AS endereco,
       en.cidade,
       en.UF
FROM Empresa e
JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
ORDER BY e.Empresa_nome, en.unidade, en.cidade;
 
-- 4.2 LEFT JOIN: empresas sem endereço cadastrado
SELECT e.idEmpresa, e.Empresa_nome AS empresa
FROM Empresa e
LEFT JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
WHERE en.idEndereco IS NULL;
 
-- 4.3 Quantos endereços cada empresa tem
SELECT e.idEmpresa,
       e.Empresa_nome AS empresa,
       COUNT(en.idEndereco) AS qtdEnderecos
FROM Empresa e
LEFT JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
GROUP BY e.idEmpresa, e.Empresa_nome
ORDER BY qtdEnderecos DESC, e.Empresa_nome;
 
-- 4.3.1 JOIN: empresas que possuem filial
SELECT e.idEmpresa, e.Empresa_nome AS empresa, en.cidade AS cidadeFilial
FROM Empresa e
JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
WHERE en.unidade = 'Filial';
 
-- 4.3.2 LEFT JOIN: empresas sem matriz cadastrada
SELECT e.idEmpresa, e.Empresa_nome AS empresa
FROM Empresa e
LEFT JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
                     AND en.unidade = 'Matriz'
WHERE en.idEndereco IS NULL;
 
-- 4.3.3 Quantas matrizes e filiais cada empresa tem
SELECT e.Empresa_nome AS empresa,
       en.unidade,
       COUNT(en.idEndereco) AS qtd
FROM Empresa e
JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
GROUP BY e.Empresa_nome, en.unidade
ORDER BY e.Empresa_nome, en.unidade;
 
 
-- ---------- ambienteCultivo ----------
 
-- 4.4 JOIN: câmaras e a empresa dona
SELECT a.IdAmbienteCultivo,
       a.nome AS camara,
       a.capacidade_sacos,
       e.Empresa_nome AS empresa
FROM ambienteCultivo a
JOIN Empresa e ON e.idEmpresa = a.fkEmpresa
ORDER BY e.Empresa_nome, a.nome;
 
-- 4.5 LEFT JOIN: empresas sem nenhuma câmara
SELECT e.idEmpresa, e.Empresa_nome AS empresa
FROM Empresa e
LEFT JOIN ambienteCultivo a ON a.fkEmpresa = e.idEmpresa
WHERE a.IdAmbienteCultivo IS NULL;
 
-- 4.6 Quantas câmaras cada empresa tem
SELECT e.idEmpresa,
       e.Empresa_nome AS empresa,
       COUNT(a.IdAmbienteCultivo) AS qtdCamaras
FROM Empresa e
LEFT JOIN ambienteCultivo a ON a.fkEmpresa = e.idEmpresa
GROUP BY e.idEmpresa, e.Empresa_nome
ORDER BY qtdCamaras DESC, e.Empresa_nome;
 
 
-- ---------- lote ----------
 
-- 4.7 JOIN: lotes com a câmara e a empresa
SELECT lo.id_lote,
       e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       lo.dt_inicio,
       lo.dt_final
FROM lote lo
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = lo.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
ORDER BY e.Empresa_nome, a.nome, lo.dt_inicio;
 
-- 4.8 Lotes em andamento (sem data final)
SELECT lo.id_lote, a.nome AS camara, lo.fase_atual AS fase, lo.dt_inicio
FROM lote lo
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = lo.fkAmbienteCultivo
WHERE lo.dt_final IS NULL
ORDER BY a.nome;
 
-- 4.9 Lotes encerrados
SELECT lo.id_lote, a.nome AS camara, lo.fase_atual AS fase, lo.dt_inicio, lo.dt_final
FROM lote lo
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = lo.fkAmbienteCultivo
WHERE lo.dt_final IS NOT NULL
ORDER BY lo.dt_final;
 
-- 4.10 Quantos lotes cada câmara já teve
SELECT a.IdAmbienteCultivo,
       a.nome AS camara,
       COUNT(lo.id_lote) AS qtdLotes
FROM ambienteCultivo a
LEFT JOIN lote lo ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
GROUP BY a.IdAmbienteCultivo, a.nome
ORDER BY qtdLotes DESC, a.nome;
 
 
-- ---------- sensor ----------
 
-- 4.11 JOIN: sensores com a câmara e a empresa
SELECT s.idSensor,
       s.tipo,
       s.statuss      AS status,
       a.nome         AS camara,
       e.Empresa_nome AS empresa
FROM sensor s
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
ORDER BY e.Empresa_nome, a.nome, s.idSensor;
 
-- 4.12 LEFT JOIN: câmaras sem nenhum sensor instalado
SELECT a.IdAmbienteCultivo, a.nome AS camara
FROM ambienteCultivo a
LEFT JOIN sensor s ON s.fkAmbienteCultivo = a.IdAmbienteCultivo
WHERE s.idSensor IS NULL;
 
-- 4.13 Quantos sensores cada câmara tem
SELECT a.IdAmbienteCultivo,
       a.nome AS camara,
       COUNT(s.idSensor) AS qtdSensores
FROM ambienteCultivo a
LEFT JOIN sensor s ON s.fkAmbienteCultivo = a.IdAmbienteCultivo
GROUP BY a.IdAmbienteCultivo, a.nome
ORDER BY qtdSensores DESC, a.nome;
 
-- 4.14 Sensores inativos e onde estão
SELECT s.idSensor, s.tipo, a.nome AS camara
FROM sensor s
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
WHERE s.statuss = 'Inativo';
 
 
-- ---------- leitura ----------
 
-- 4.15 JOIN: leituras com o sensor e a câmara (mais recentes primeiro)
SELECT l.id_leitura,
       l.dtHora,
       a.nome AS camara,
       s.tipo AS sensor,
       l.umidadeAr,
       l.umidadeSolo,
       l.Temperatura
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
ORDER BY l.dtHora DESC, l.id_leitura;
 
-- 4.16 LEFT JOIN: sensores sem nenhuma leitura (possível falha de comunicação)
SELECT s.idSensor, s.tipo, s.statuss AS status, a.nome AS camara
FROM sensor s
LEFT JOIN leitura l ON l.fkSensor = s.idSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
WHERE l.id_leitura IS NULL;
 
-- 4.17 Quantas leituras cada sensor enviou
SELECT s.idSensor,
       s.tipo,
       a.nome AS camara,
       COUNT(l.id_leitura) AS qtdLeituras
FROM sensor s
LEFT JOIN leitura l ON l.fkSensor = s.idSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
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
       l.Temperatura
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
ORDER BY lo.id_lote, l.dtHora;
 
-- 4.19 Quantas leituras cada lote recebeu
SELECT lo.id_lote,
       a.nome        AS camara,
       lo.fase_atual AS fase,
       COUNT(l.id_leitura) AS qtdLeituras
FROM lote lo
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = lo.fkAmbienteCultivo
LEFT JOIN sensor s     ON s.fkAmbienteCultivo = a.IdAmbienteCultivo
LEFT JOIN leitura l    ON l.fkSensor = s.idSensor
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
GROUP BY lo.id_lote, a.nome, lo.fase_atual
ORDER BY lo.id_lote;
 
 
-- ---------- faixa_ideal ----------
 
-- 4.20 JOIN: faixas ideais de cada empresa
SELECT e.Empresa_nome AS empresa,
       f.fase,
       f.parametro,
       f.valor_min,
       f.valor_max
FROM faixa_ideal f
JOIN Empresa e ON e.idEmpresa = f.fkEmpresa
ORDER BY e.Empresa_nome, f.fase, f.parametro;
 
-- 4.21 LEFT JOIN: empresas sem nenhuma faixa configurada
SELECT e.idEmpresa, e.Empresa_nome AS empresa
FROM Empresa e
LEFT JOIN faixa_ideal f ON f.fkEmpresa = e.idEmpresa
WHERE f.idfaixa_ideal IS NULL;
 
-- 4.22 Alerta de umidade do AR fora da faixa
--      (faixa da empresa dona da câmara, na fase do lote vigente na data da leitura)
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeAr    AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN faixa_ideal f     ON f.fkEmpresa = e.idEmpresa
                      AND f.fase       = lo.fase_atual
                      AND f.parametro  = 'umidadeAr'
WHERE l.umidadeAr < f.valor_min OR l.umidadeAr > f.valor_max
ORDER BY l.dtHora;
 
-- 4.23 Alerta de umidade do SUBSTRATO fora da faixa
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeSolo  AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN faixa_ideal f     ON f.fkEmpresa = e.idEmpresa
                      AND f.fase       = lo.fase_atual
                      AND f.parametro  = 'umidadeSolo'
WHERE l.umidadeSolo < f.valor_min OR l.umidadeSolo > f.valor_max
ORDER BY l.dtHora;
 
-- 4.24 Alerta de TEMPERATURA fora da faixa
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.Temperatura  AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN faixa_ideal f     ON f.fkEmpresa = e.idEmpresa
                      AND f.fase       = lo.fase_atual
                      AND f.parametro  = 'temperatura'
WHERE l.Temperatura < f.valor_min OR l.Temperatura > f.valor_max
ORDER BY l.dtHora;
 
 
-- ---------- Visão completa ----------
 
-- 4.25 Empresa -> câmara -> sensor -> quantidade de leituras
--      LEFT JOIN em tudo para não sumirem empresas sem câmara, câmaras sem sensor e sensores sem leitura
SELECT e.Empresa_nome                          AS empresa,
       COALESCE(a.nome, 'Sem câmara')          AS camara,
       COALESCE(s.tipo, 'Sem sensor')          AS sensor,
       COUNT(l.id_leitura)                     AS qtdLeituras
FROM Empresa e
LEFT JOIN ambienteCultivo a ON a.fkEmpresa         = e.idEmpresa
LEFT JOIN sensor s          ON s.fkAmbienteCultivo = a.IdAmbienteCultivo
LEFT JOIN leitura l         ON l.fkSensor          = s.idSensor
GROUP BY e.Empresa_nome, a.nome, s.idSensor, s.tipo
ORDER BY e.Empresa_nome, a.nome, s.idSensor;
