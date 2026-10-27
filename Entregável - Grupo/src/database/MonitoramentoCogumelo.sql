-- Integrantes:
-- Mariana O. Soares
-- Enzo Fuchs Bento
-- Christian Miranda
-- Vitor Alexandre
-- Victor Dos Passos 
-- Paulo Henrique

CREATE DATABASE IF NOT EXISTS cog_solutions;

USE cog_solutions;

show tables;
-- caso as tabelas já existem, não queria dar alter table , já que o script precisa do modelo da tabela pronto, fazer nessa ordem pois existem constraints 
DROP TABLE IF EXISTS leitura;
DROP TABLE IF EXISTS sensor;
DROP TABLE IF EXISTS lote;
DROP TABLE IF EXISTS faixa_ideal;
DROP TABLE IF EXISTS Endereco;
DROP TABLE IF EXISTS ambienteCultivo;
DROP TABLE IF EXISTS login;
DROP TABLE IF EXISTS Usuario;
DROP TABLE IF EXISTS Empresa;

-- Tabela 1: Usuario (e-mail e senha ficam na tabela login)
CREATE TABLE Usuario (
 
idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL, 
    fkEmpresa INT,
     fkResponsavel INT,
     admin TINYINT(1),
       CONSTRAINT chk_admin_binary CHECK (admin IN (0, 1)),
    CONSTRAINT responsavel
	FOREIGN KEY (fkResponsavel) 
		REFERENCES Usuario(idUsuario)
);

-- tabela 2: Empresa
-- chaveAcesso: chave da empresa digitada no login (a mesma para todos os usuarios dela)
CREATE TABLE Empresa (
 
idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
    Empresa_nome VARCHAR(100) NOT NULL, 
    cnpj char(14),
    chaveAcesso VARCHAR(100) NOT NULL UNIQUE,
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
-- DHT11 mede umidade do ar e temperatura; Capacitivo mede a umidade do solo (substrato)
CREATE TABLE sensor (
    idSensor INT AUTO_INCREMENT PRIMARY KEY,
    fkAmbienteCultivo INT NOT NULL,
    tipo VARCHAR(40) NOT NULL,  -- Ex: 'DHT11', 'Capacitivo - Substrato'
    CONSTRAINT chkTipo CHECK(tipo IN ('DHT11/Capacitivo - Substrato','DHT11', 'Capacitivo - Substrato')),
    statuss VARCHAR(20) DEFAULT 'Ativo', -- 'Ativo', 'Inativo'
    CONSTRAINT chkStatuss CHECK(statuss IN ('Ativo', 'Inativo')),
    CONSTRAINT fkSensorAmbiente
    FOREIGN KEY (fkAmbienteCultivo) REFERENCES ambienteCultivo(IdAmbienteCultivo)
);
 
-- Tabela 5: leitura (Histórico do Sensoriamento)
-- O DHT11 preenche umidadeAr e Temperatura; o Capacitivo preenche umidadeSolo (o resto fica NULL)
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
-- As 5 fases do cultivo: Compostagem, Pasteurização, Incubação, Casing e Frutificação
CREATE TABLE lote (
    id_lote INT AUTO_INCREMENT,
    fkAmbienteCultivo INT NOT NULL,
    fase_atual VARCHAR(45) NOT NULL,
    CONSTRAINT chkFaseLote CHECK(fase_atual IN ('Compostagem', 'Pasteurização', 'Incubação', 'Casing', 'Frutificação')),
    dt_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_final DATETIME NULL, -- NULL = lote em andamento
    CONSTRAINT chkLoteDatas CHECK(dt_final IS NULL OR dt_final >= dt_inicio),
    CONSTRAINT pkLote PRIMARY KEY (id_lote, fkAmbienteCultivo),
    CONSTRAINT fkLoteAmbiente
    FOREIGN KEY (fkAmbienteCultivo) REFERENCES ambienteCultivo(IdAmbienteCultivo)
);
 
-- Tabela 8: faixa_ideal (limites minimo e maximo por empresa, fase e parametro)
-- O parametro usa o mesmo nome das colunas da tabela leitura
CREATE TABLE faixa_ideal (
    idfaixa_ideal INT AUTO_INCREMENT,
    fkEmpresa INT NOT NULL,
    fase VARCHAR(45) NOT NULL,
    CONSTRAINT chkFaseFaixa CHECK(fase IN ('Compostagem', 'Pasteurização', 'Incubação', 'Casing', 'Frutificação')),
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

-- Tabela 9: login (relacao 1:1 com Usuario: fkUsuario e UNIQUE)
-- Guarda o e-mail e a senha do usuario. No login entram: email (login), chaveAcesso (Empresa) e senha (login)
CREATE TABLE login (
    idLogin INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT chkEmailLogin CHECK (email LIKE '%@%'),
    senha VARCHAR(50) NOT NULL,
    fkUsuario INT NOT NULL UNIQUE,
    CONSTRAINT fkLoginUsuario
    FOREIGN KEY (fkUsuario) REFERENCES Usuario(idUsuario)
);
 
 


-- Insert into Empresa (precisa vir antes de Usuario, que referencia a Empresa)
INSERT INTO Empresa (Empresa_nome, cnpj, chaveAcesso) VALUES
('Cogumelos Cogumaster SP', '12345678000195', 'COG-7K2M9X'),
('Estufas e Cogumelos Brasil', '38710932000175', 'EST-4P8Q1Z'),
('Fungicultura Paris Brasil', '98765432000110', 'FUN-2R6T5W');

INSERT INTO Usuario (nome, fkEmpresa, fkResponsavel, admin) VALUES
('Ana Lima',       1, Null,1),  -- id 1 (gestora)
('Diego Rocha',    1, 1,1),  -- id 2 (gestor), responsável: Ana
('Fábio Teixeira', 1, 1,1),  -- id 3 (gestor), responsável: Ana
('Helena Duarte',  NULL, NULL, NULL); -- id 4 (sem empresa)
 
INSERT INTO Usuario (nome, fkEmpresa, fkResponsavel, admin) VALUES
('Bruno Costa',    1, 1,0),     -- id 5, responsável: Ana
('Elisa Prado',    1, 2,0),     -- id 6, responsável: Diego
('Gustavo Alves',  1, 3,0);     -- id 7, responsável: Fábio
 
INSERT INTO Usuario (nome, fkEmpresa, fkResponsavel, admin) VALUES
('Carla Mendes',   1, 2,0);     -- id 8, responsável: Diego

-- Inserindo Logins (e-mail e senha de cada usuário; a Helena fica sem login de propósito)
INSERT INTO login (nome, email, senha, fkUsuario) VALUES
('Ana Lima',      'ana@cogumaster.com.br',        'Teste@123', 1),
('Diego Rocha',   'diego@estufascogumelos.com.br','Teste@123', 2),
('Fábio Teixeira','fabio@parisbrasil.com.br',     'Teste@123', 3),
('Bruno Costa',   'bruno@cogumaster.com.br',      'Teste@123', 5),
('Elisa Prado',   'elisa@estufascogumelos.com.br','Teste@123', 6),
('Gustavo Alves', 'gustavo@parisbrasil.com.br',   'Teste@123', 7),
('Carla Mendes',  'carla@cogumaster.com.br',      'Teste@123', 8);

-- Inserindo Estufas / Câmaras de Cultivo
INSERT INTO ambienteCultivo  (nome, capacidade_sacos, fkEmpresa) VALUES
('Câmara 01', 1000, 1),          -- id 1, Cogumaster
('Câmara 02', 800, 1),           -- id 2, Cogumaster
('Estufa A - Mogi', 950, 2);     -- id 3, Estufas e Cogumelos Brasil

insert into ambienteCultivo (nome, capacidade_sacos, fkEmpresa) values
('camara 03', 1200, 1);   -- id 4, Cogumaster (ainda sem sensor)




-- Inserindo Sensores (DHT11 = ar e temperatura; Capacitivo = umidade do solo)
-- A posição de cada sensor ficou nos comentários, pois a tabela sensor não tem esse campo
INSERT INTO sensor (tipo, statuss, fkAmbienteCultivo) VALUES
('DHT11/Capacitivo - Substrato', 'Ativo', 1),                    -- id 1, Setor Central - Altura 1.8m
('DHT11/Capacitivo - Substrato', 'Ativo', 1),   -- id 2, Setor Central - Altura 1.8m
('Capacitivo - Substrato', 'Ativo', 1),   -- id 3, Prateleira A - Saco 12
('DHT11', 'Ativo', 2),                    -- id 4, Setor Sul - Prateleira B
('Capacitivo - Substrato', 'Ativo', 2),   -- id 5, Prateleira B - Saco 45
('DHT11', 'Inativo', 3),                  -- id 6, Setor Norte - Prateleira C
('Capacitivo - Substrato', 'Ativo', 3);   -- id 7, Prateleira C - Saco 08

-- Inserindo Histórico de Leituras (Simulando leituras a cada 5 minutos)
-- DHT11 grava umidadeAr e Temperatura; Capacitivo grava só umidadeSolo
-- Fase Incubação: Esperado Temp ~20°C, UR Ar ~90-95%, Substrato ~65-70%
-- Fase Frutificação: Esperado Temp 16-22°C, UR Ar ~80-90%
INSERT INTO leitura (umidadeAr, umidadeSolo, Temperatura, fkSensor) VALUES
-- Leituras Câmara 01 (Incubação) com a data e hora atuais
(93.0, 23.0, 23.4, 1),   -- temperatura acima do máximo (alerta)
(92.5, 30.2, 21.5, 1),
(null, 88.0, null, 2);   -- substrato muito acima do máximo (alerta)

-- Leituras com data e hora definidas
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

-- Inserindo Faixas Ideais da empresa 1 para as 5 fases (valores da documentação do projeto)
-- Compostagem: ar irrelevante (processo ao ar livre) | Pasteurização: ar ~100%
-- Casing: a documentação só diz "UR do ar mantida alta" (assumido 90 a 95) e não traz temperatura
-- Obs: o DHT11 só mede 0 a 50 °C e 20 a 90% de umidade; os valores acima disso são só de referência
INSERT INTO faixa_ideal (fase, parametro, valor_min, valor_max, fkEmpresa) VALUES
('Compostagem',   'umidadeSolo', 70.0, 75.0, 1),
('Compostagem',   'temperatura', 70.0, 80.0, 1),
('Pasteurização', 'umidadeAr',   95.0, 100.0, 1),
('Pasteurização', 'umidadeSolo', 65.0, 70.0, 1),
('Pasteurização', 'temperatura', 58.0, 60.0, 1),
('Incubação',     'umidadeAr',   90.0, 95.0, 1),
('Incubação',     'umidadeSolo', 65.0, 70.0, 1),
('Incubação',     'temperatura', 20.0, 22.0, 1),
('Casing',        'umidadeAr',   90.0, 95.0, 1),
('Casing',        'umidadeSolo', 70.0, 75.0, 1),
('Frutificação',  'umidadeAr',   80.0, 90.0, 1),
('Frutificação',  'umidadeSolo', 60.0, 65.0, 1),
('Frutificação',  'temperatura', 16.0, 22.0, 1);

-- Faixas da empresa 2 (só Frutificação, que é a fase dos lotes dela)
-- A empresa 3 fica sem faixas de propósito, para testar o LEFT JOIN
INSERT INTO faixa_ideal (fase, parametro, valor_min, valor_max, fkEmpresa) VALUES
('Frutificação',  'umidadeAr',   80.0, 90.0, 2),
('Frutificação',  'umidadeSolo', 60.0, 65.0, 2),
('Frutificação',  'temperatura', 16.0, 22.0, 2);


-- testes ---------

SELECT * FROM Empresa;
SELECT * FROM Usuario;
SELECT * FROM login;
SELECT * FROM ambienteCultivo;
SELECT * FROM leitura;
SELECT * FROM sensor;
SELECT * FROM Endereco;
SELECT * FROM lote;
SELECT * FROM faixa_ideal;




-- JOINS PARA A APRESENTAÇÃO _____________________________________

SHOW TABLES;


-- ===== A) LOGIN -> USUARIO -> EMPRESA =====

-- A1 JOIN: cada login com o usuário e a empresa dele
SELECT lg.idLogin,
       lg.email,
       u.nome         AS usuario,
       e.Empresa_nome AS empresa,
       u.admin
FROM login lg
JOIN Usuario u ON u.idUsuario = lg.fkUsuario
JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
ORDER BY e.Empresa_nome, u.nome;

-- A2 Autenticação: e-mail + chave de acesso da empresa + senha (retorna 1 linha se tudo estiver certo)
SELECT u.idUsuario, u.nome, u.admin, e.Empresa_nome AS empresa
FROM login lg
JOIN Usuario u ON u.idUsuario = lg.fkUsuario
JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
WHERE lg.email = 'ana@cogumaster.com.br'
  AND e.chaveAcesso = 'COG-7K2M9X'
  AND lg.senha = 'Teste@123';

-- A3 Autenticação com a chave de outra empresa (não retorna nenhuma linha)
SELECT u.idUsuario, u.nome, u.admin, e.Empresa_nome AS empresa
FROM login lg
JOIN Usuario u ON u.idUsuario = lg.fkUsuario
JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
WHERE lg.email = 'ana@cogumaster.com.br'
  AND e.chaveAcesso = 'EST-4P8Q1Z'
  AND lg.senha = 'Teste@123';

-- A4 LEFT JOIN: usuários sem login (não conseguem entrar no sistema)
SELECT u.idUsuario, u.nome
FROM Usuario u
LEFT JOIN login lg ON lg.fkUsuario = u.idUsuario
WHERE lg.idLogin IS NULL;


-- ===== B) CAMINHO: EMPRESA -> ENDEREÇO -> USUÁRIOS -> LOGIN =====

-- B1 JOIN: empresas e seus endereços (matriz ou filial)
SELECT e.idEmpresa,
       e.Empresa_nome                           AS empresa,
       en.unidade,
       CONCAT(en.logradouro, ', ', en.numero)   AS endereco,
       en.cidade,
       en.UF
FROM Empresa e
JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
ORDER BY e.Empresa_nome, en.unidade, en.cidade;

-- B2 Caminho completo: empresa (com a matriz) -> usuários -> login
--    LEFT JOIN em tudo para aparecerem empresas sem matriz, sem usuários ou sem login
SELECT e.Empresa_nome                                           AS empresa,
       COALESCE(CONCAT(en.cidade, '/', en.UF), 'Sem matriz')    AS matriz,
       COALESCE(u.nome, 'Sem usuário')                          AS usuario,
       COALESCE(lg.email, 'Sem login')                          AS emailLogin
FROM Empresa e
LEFT JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
                     AND en.unidade = 'Matriz'
LEFT JOIN Usuario u   ON u.fkEmpresa = e.idEmpresa
LEFT JOIN login lg    ON lg.fkUsuario = u.idUsuario
ORDER BY e.Empresa_nome, u.nome;


-- ===== C) EMPRESA -> AMBIENTE -> LOTE =====

-- C1 JOIN: empresa, câmara e lotes
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.id_lote,
       lo.fase_atual  AS fase,
       lo.dt_inicio,
       lo.dt_final
FROM Empresa e
JOIN ambienteCultivo a ON a.fkEmpresa         = e.idEmpresa
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
ORDER BY e.Empresa_nome, a.nome, lo.dt_inicio;

-- C2 LEFT JOIN: todas as empresas, mesmo sem câmara e sem lote
SELECT e.Empresa_nome                         AS empresa,
       COALESCE(a.nome, 'Sem câmara')         AS camara,
       COALESCE(lo.fase_atual, 'Sem lote')    AS fase,
       lo.dt_inicio,
       lo.dt_final
FROM Empresa e
LEFT JOIN ambienteCultivo a ON a.fkEmpresa         = e.idEmpresa
LEFT JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
ORDER BY e.Empresa_nome, a.nome, lo.dt_inicio;

-- C3 Lotes em andamento (sem data final)
SELECT e.Empresa_nome AS empresa, a.nome AS camara, lo.id_lote, lo.fase_atual AS fase, lo.dt_inicio
FROM lote lo
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = lo.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
WHERE lo.dt_final IS NULL
ORDER BY e.Empresa_nome, a.nome;


-- ===== D) LEITURA -> SENSOR =====

-- D1 JOIN: leituras com o sensor e a câmara (mais recentes primeiro)
SELECT l.id_leitura,
       l.dtHora,
       a.nome AS camara,
       s.idSensor,
       s.tipo AS sensor,
       l.umidadeAr,
       l.umidadeSolo,
       l.Temperatura
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
ORDER BY l.dtHora DESC, l.id_leitura;

-- D2 Só o DHT11: umidade do ar e temperatura
SELECT l.dtHora, a.nome AS camara, s.idSensor, l.umidadeAr, l.Temperatura
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
WHERE s.tipo = 'DHT11'
ORDER BY l.dtHora DESC;

-- D3 Só o capacitivo: umidade do solo (substrato)
SELECT l.dtHora, a.nome AS camara, s.idSensor, l.umidadeSolo
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
WHERE s.tipo = 'Capacitivo - Substrato'
ORDER BY l.dtHora DESC;

-- D4 Leitura + lote: o lote é descoberto pela câmara do sensor e pela data da leitura
SELECT l.id_leitura,
       l.dtHora,
       a.nome        AS camara,
       lo.id_lote,
       lo.fase_atual AS fase,
       s.tipo        AS sensor,
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


-- ===== E) FAIXA IDEAL (5 FASES) COM LEITURA =====

-- E1 As faixas ideais de cada empresa, na ordem das fases do cultivo
--    (Compostagem, Pasteurização, Incubação, Casing, Frutificação)
SELECT e.Empresa_nome AS empresa,
       f.fase,
       f.parametro,
       f.valor_min,
       f.valor_max
FROM faixa_ideal f
JOIN Empresa e ON e.idEmpresa = f.fkEmpresa
ORDER BY e.Empresa_nome, f.idfaixa_ideal;

-- E2 Faixa ideal + leitura (umidade do ar, DHT11): cada leitura com os limites da fase do lote
SELECT a.nome        AS camara,
       lo.fase_atual AS fase,
       l.dtHora,
       l.umidadeAr   AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN faixa_ideal f     ON f.fkEmpresa = a.fkEmpresa
                      AND f.fase      = lo.fase_atual
                      AND f.parametro = 'umidadeAr'
ORDER BY a.nome, l.dtHora;


-- ===== F) DASHBOARD COM ALERTA (FAIXA IDEAL + LEITURA) =====
-- Alerta = leitura abaixo do mínimo ou acima do máximo da faixa da empresa para a fase do lote
-- O DHT11 gera alerta de umidade do ar e de temperatura; o capacitivo, de umidade do solo

-- F1 Alerta de umidade do AR (DHT11)
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeAr    AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
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

-- F2 Alerta de TEMPERATURA (DHT11)
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.Temperatura  AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
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

-- F3 Alerta de umidade do SOLO (sensor capacitivo)
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeSolo  AS valorLido,
       f.valor_min,
       f.valor_max
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'Capacitivo - Substrato'
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

-- F4 DASHBOARD do DHT11: umidade do ar e temperatura na mesma linha, cada uma com a sua faixa ideal
--    LEFT JOIN nas faixas porque algumas fases não têm faixa de ar ou de temperatura (ex.: Compostagem e Casing)
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeAr,
       fa.valor_min   AS arMin,
       fa.valor_max   AS arMax,
       l.Temperatura,
       ft.valor_min   AS tempMin,
       ft.valor_max   AS tempMax
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
LEFT JOIN faixa_ideal fa ON fa.fkEmpresa = e.idEmpresa
                        AND fa.fase       = lo.fase_atual
                        AND fa.parametro  = 'umidadeAr'
LEFT JOIN faixa_ideal ft ON ft.fkEmpresa = e.idEmpresa
                        AND ft.fase       = lo.fase_atual
                        AND ft.parametro  = 'temperatura'
WHERE l.umidadeAr < fa.valor_min OR l.umidadeAr > fa.valor_max
   OR l.Temperatura < ft.valor_min OR l.Temperatura > ft.valor_max
ORDER BY l.dtHora, a.nome;

-- F5 Indicador: quantos alertas do DHT11 (ar ou temperatura) cada câmara teve
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       COUNT(l.id_leitura) AS qtdAlertasDHT11
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
LEFT JOIN faixa_ideal fa ON fa.fkEmpresa = e.idEmpresa
                        AND fa.fase       = lo.fase_atual
                        AND fa.parametro  = 'umidadeAr'
LEFT JOIN faixa_ideal ft ON ft.fkEmpresa = e.idEmpresa
                        AND ft.fase       = lo.fase_atual
                        AND ft.parametro  = 'temperatura'
WHERE l.umidadeAr < fa.valor_min OR l.umidadeAr > fa.valor_max
   OR l.Temperatura < ft.valor_min OR l.Temperatura > ft.valor_max
GROUP BY e.Empresa_nome, a.nome
ORDER BY qtdAlertasDHT11 DESC, a.nome;

-- F6 Indicador: quantos alertas de umidade do solo (capacitivo) cada câmara teve
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       COUNT(l.id_leitura) AS qtdAlertasSolo
FROM leitura l
JOIN sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'Capacitivo - Substrato'
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN faixa_ideal f     ON f.fkEmpresa = e.idEmpresa
                      AND f.fase       = lo.fase_atual
                      AND f.parametro  = 'umidadeSolo'
WHERE l.umidadeSolo < f.valor_min OR l.umidadeSolo > f.valor_max
GROUP BY e.Empresa_nome, a.nome
ORDER BY qtdAlertasSolo DESC, a.nome;


-- ===== G) JOINS DE APOIO (falhas de monitoramento) =====

-- G1 LEFT JOIN: sensores sem nenhuma leitura (possível falha de comunicação)
SELECT s.idSensor, s.tipo, s.statuss AS status, a.nome AS camara
FROM sensor s
LEFT JOIN leitura l ON l.fkSensor = s.idSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
WHERE l.id_leitura IS NULL;

-- G2 LEFT JOIN: câmaras sem nenhum sensor instalado
SELECT e.Empresa_nome AS empresa, a.IdAmbienteCultivo, a.nome AS camara
FROM ambienteCultivo a
JOIN Empresa e     ON e.idEmpresa = a.fkEmpresa
LEFT JOIN sensor s ON s.fkAmbienteCultivo = a.IdAmbienteCultivo
WHERE s.idSensor IS NULL;

-- G3 Quantas leituras cada sensor enviou
SELECT s.idSensor,
       s.tipo,
       a.nome AS camara,
       COUNT(l.id_leitura) AS qtdLeituras
FROM sensor s
LEFT JOIN leitura l ON l.fkSensor = s.idSensor
JOIN ambienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
GROUP BY s.idSensor, s.tipo, a.nome
ORDER BY qtdLeituras DESC, s.idSensor;


-- ===== H) HIERARQUIA DE USUÁRIOS =====

-- H1 JOIN: usuários que têm empresa
SELECT u.idUsuario, u.nome AS usuario, e.Empresa_nome AS empresa
FROM Usuario u
JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
ORDER BY e.Empresa_nome, u.nome;
 
-- H2 auto JOIN: usuário e seu responsável
--    LEFT JOIN para os gestores (sem responsável) não sumirem do resultado
SELECT u.idUsuario,
       u.nome                              AS usuario,
       COALESCE(r.nome, 'Sem responsável') AS responsavel
FROM Usuario u
LEFT JOIN Usuario r ON r.idUsuario = u.fkResponsavel
ORDER BY u.idUsuario;
 
-- H3 Visão completa: usuário + empresa + responsável
SELECT u.idUsuario,
       u.nome                                      AS usuario,
       COALESCE(e.Empresa_nome, 'Sem empresa')     AS empresa,
       COALESCE(r.nome, 'Sem responsável')         AS responsavel
FROM Usuario u
LEFT JOIN Empresa e ON e.idEmpresa  = u.fkEmpresa
LEFT JOIN Usuario r ON r.idUsuario  = u.fkResponsavel
ORDER BY empresa, u.nome;
 
-- H4 Cadeia hierárquica (usuário -> responsável -> responsável do responsável)
SELECT u.nome  AS usuario,
       r.nome  AS responsavel,
       r2.nome AS responsavelDoResponsavel
FROM Usuario u
LEFT JOIN Usuario r  ON r.idUsuario  = u.fkResponsavel
LEFT JOIN Usuario r2 ON r2.idUsuario = r.fkResponsavel
WHERE u.fkResponsavel IS NOT NULL;
 
-- H5 Quantos subordinados diretos cada pessoa tem
SELECT r.idUsuario,
       r.nome AS responsavel,
       e.Empresa_nome AS empresa,
       COUNT(u.idUsuario) AS qtdSubordinados
FROM Usuario r
LEFT JOIN Usuario u ON u.fkResponsavel = r.idUsuario
LEFT JOIN Empresa e ON e.idEmpresa     = r.fkEmpresa
GROUP BY r.idUsuario, r.nome, e.Empresa_nome
ORDER BY qtdSubordinados DESC, r.nome;

-- H6 Usuários sem empresa
SELECT u.idUsuario, u.nome
FROM Usuario u
LEFT JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
WHERE e.idEmpresa IS NULL;