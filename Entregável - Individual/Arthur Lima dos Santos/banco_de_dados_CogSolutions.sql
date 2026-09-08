create database CogSolutionsLTDA;
use CogSolutionsLTDA;


CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    constraint chkemail check (email like ('%@%')),
    telefone VARCHAR(20),
    dtcadastro date, 
    cnpj char(18)
);
drop table clientes;
describe clientes;

CREATE TABLE sensores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_estufa INT,
    tipo VARCHAR(30),
    modelo VARCHAR(50),
    dtinstalacao DATE,
    CONSTRAINT chktipo CHECK (tipo IN ('umidade_ar', 'umidade_substrato'))
);
drop table sensores;
describe sensores;

CREATE TABLE estufas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    nome VARCHAR(50),
    tpSensor char(4),
    constraint chksensor check (tpSensor in('lm35'))
);
drop table estufas;
describe estufas;

CREATE TABLE leituras (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_sensor INT,
    valor DECIMAL(5,2),
    dthora DATETIME
); 
drop table leituras;
describe leituras;

INSERT INTO clientes (nome, email, telefone, dtcadastro, cnpj) VALUES
('Cogumelos do Vale', 'contato@cogumelosdovale.com', '11976543210', '2026-02-10', '23.456.789/0001-11'),
('Fungos & Cia', 'vendas@fungosecia.com', '11965432109', '2026-03-05', '34.567.890/0001-22'),
('Shiitake Bom', 'atendimento@shiitakebom.com', '11954321098', '2026-04-20', '45.678.901/0001-33');

INSERT INTO estufas (id_cliente, nome, tpSensor) VALUES
(2, 'Estufa Vale - Cogumelo Ostra', 'lm35'),
(3, 'Estufa Fungos - Portobello', 'lm35'),
(4, 'Estufa Shiitake Bom - Principal', 'lm35');

INSERT INTO sensores (id_estufa, tipo, modelo, dtinstalacao) VALUES
(2, 'umidade_ar', 'DHT22', '2026-02-12'),
(3, 'umidade_substrato', 'YL-69', '2026-03-07'),
(4, 'umidade_ar', 'DHT11', '2026-04-22');

INSERT INTO leituras (id_sensor, valor, dthora) VALUES
(3, 82.10, '2026-09-05 08:00:00'),
(4, 55.40, '2026-09-05 08:00:00'),
(5, 70.90, '2026-09-05 08:00:00'); 