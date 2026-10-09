-- Integrantes:
-- Mariana O. Soares
-- Enzo Fuchs Bento
-- Christian Miranda
-- Vitor Alexandre
-- Victor Dos Passos 
-- Paulo Henrique

CREATE DATABASE cog_solutions;

USE cog_solutions;
select * from Usuario;

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
    CONSTRAINT responsavel
	FOREIGN KEY (fk_Responsavel) 
		REFERENCES Usuario(idUsuario)
);

ALTER TABLE Usuario
    ADD CONSTRAINT fkUsuarioEmpresa
    FOREIGN KEY (fk_Empresa) REFERENCES Empresa(idEmpresa);



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

-- Insert into Empresa
INSERT INTO Empresa (empresa_nome, email, cnpj) VALUES
('Cogumelos Cogumaster SP', 'contato@cogumaster.com.br', '12345678000195'),
('Estufas e Cogumelos Brasil',  'contato@estufascogumelos.com.br',  '38710932000175'),
('Fungicultura Paris Brasil',  'atendimento@parisbrasil.com.br','98765432000110');

select * from Empresa;

-- Tabela 3: estufa
CREATE TABLE ambienteCultivo (
    idambienteCultivo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL, -- Ex: 'Câmara 01 - Incubação'
    faseCultivo VARCHAR(40) NOT NULL,
    CONSTRAINT chkFaseCultivo CHECK(faseCultivo IN ('Compostagem', 'Incubação', 'Frutificação', 'Pasteurização')),
    Camaras INT ,
    capacidadeSacos INT DEFAULT 800  -- Capacidade padrão (800 a 1000 sacos)
);
drop table sensor;



-- Tabela 4: sensor
CREATE TABLE sensor (
    idSensor INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(40) NOT NULL,  -- Ex: 'DHT11', 'Capacitivo - Substrato'
    CONSTRAINT chkTipo CHECK(tipo IN ('DHT11', 'Capacitivo - Substrato')),
    posicaoAmbienteCultivo VARCHAR(50), -- Ex: 'Setor Norte - Prateleira 2'
    statuss VARCHAR(20) DEFAULT 'Ativo', -- 'Ativo', 'Inativo'
    CONSTRAINT chkStatuss CHECK(statuss IN ('Ativo', 'Inativo')),
    descricao VARCHAR(80)
);

-- Tabela 5: leitura (Histórico do Sensoriamento)

CREATE TABLE leitura (
    id_sensor INT PRIMARY KEY auto_increment,
    umidadeAr   DECIMAL(4,1) NULL,  
    umidadeSolo DECIMAL(4,1) NULL,   
    temperatura DECIMAL(4,1) NULL,   
	fk_sensor   INT NOT NULL,
     dtHora      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fkLeituraSensor FOREIGN KEY (fk_sensor) REFERENCES sensor(idSensor)
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
INSERT INTO ambienteCultivo  (nome, faseCultivo, capacidadeSacos) VALUES
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


-- testes ---------

SELECT * FROM Empresa;
SELECT * FROM ambienteCultivo;
SELECT * FROM leitura;
SELECT * FROM sensor;


select * from leitura where umidadeAr and umidadeSolo is not null; 


select * from ambienteCultivo where faseCultivo in ('Frutificação');

insert into ambienteCultivo values
(default,'camara 03','Compostagem',1200);




-- JOINS _____________________________________

select * from  usuario;
select * from  empresa;


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
       u.nome                                  AS usuario,
       concat(e.empresa_nome, 'Sem empresa') AS empresa,
       CONCAT(r.nome, 'Sem responsável')     AS responsavel
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
 
 

