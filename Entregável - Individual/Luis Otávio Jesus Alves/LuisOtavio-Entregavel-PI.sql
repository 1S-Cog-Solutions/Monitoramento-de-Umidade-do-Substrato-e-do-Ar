CREATE DATABASE monitoramentoEstufa;

use monitoramentoEstufa;

CREATE TABLE cliente(
	idCliente INT PRIMARY KEY AUTO_INCREMENT, -- id do cliente
    nomeEmpresa VARCHAR(60) NOT NULL, -- nome da empresa
    CNPJ CHAR(18) UNIQUE NOT NULL, -- CNPJ DO CLIENTE
    statuss CHAR(1) NOT NULL, -- status 1 (ativo) - 0 (inativo)
    CONSTRAINT chkStatus CHECK (statuss IN (1, 0)),
    email VARCHAR(80) NOT NULL, -- email do cliente
    CONSTRAINT chkEmail CHECK(email LIKE '%@%'), -- conferir se o email contém @
    dtCadastro DATETIME default current_timestamp -- data que o cliente foi cadastrado
);

CREATE TABLE sensor(
	idSensor INT PRIMARY KEY AUTO_INCREMENT, -- id do sensor
    nome VARCHAR(45) NOT NULL, -- modelo do sensor
    tipo_sensor VARCHAR(45) NOT NULL-- tipo do sensor
);
CREATE TABLE leitura(
	idLeitura INT PRIMARY KEY AUTO_INCREMENT, -- id de leitura
    valor Decimal(5,2) NOT NULL, -- valor dos sensores
    unidade_medida VARCHAR(2) NOT NULL, -- unidade de medida
    CONSTRAINT chkUnidade CHECK (unidade_medida IN ('°C', '%')), -- conferir se os valores estão entre °C e %
    dtLeitura DATETIME DEFAULT CURRENT_TIMESTAMP -- data e horario de quando a leitura foi feita
);
CREATE TABLE alerta(
	idAlerta INT PRIMARY KEY AUTO_INCREMENT, -- id do alerta
    dtAlerta DATETIME DEFAULT CURRENT_TIMESTAMP, -- data e horario de quando foi emitido o alerta
    descricao VARCHAR(250) NOT NULL -- conteúdo do alerta
);

