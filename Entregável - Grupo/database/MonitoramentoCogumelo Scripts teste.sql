ALTER TABLE Cliente rename to Empresa;
describe Empresa;

ALTER TABLE Empresa DROP COLUMN NomeResponsavel;

CREATE TABLE Usuario (

idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT chkEmail CHECK (email LIKE '%@%'),
	dtCadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);
USE cog_solutions;
SHOW TABLES;
describe leitura;

INSERT INTO leitura (umidadeAr, umidadeSolo, temperatura, fk_sensor) VALUES
-- Leituras Câmara 01 (Incubação - Sensor Ar/Substrato)
(93.0, 73.9, 23.4,1),
(92.5, 69.1, 23.4,1),
(null,88.0 , 45.5,2);-- Queda na UR do Ar (Alerta potencial)

SELECT * FROM leitura;

DROP TABLE leitura;

CREATE TABLE leitura (
    idLeitura INT AUTO_INCREMENT PRIMARY KEY,
    umidadeAr DECIMAL(4,1) NULL,          -- Umidade Relativa do Ar em %
    umidadeSolo DECIMAL(4,1) NULL,   -- Umidade do Substrato em %
    temperatura DECIMAL(4,1) NULL,   
    dtHora DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_sensor INT , FOREIGN KEY (fk_sensor) REFERENCES sensor(idSensor)
);