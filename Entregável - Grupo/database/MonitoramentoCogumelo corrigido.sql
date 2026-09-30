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