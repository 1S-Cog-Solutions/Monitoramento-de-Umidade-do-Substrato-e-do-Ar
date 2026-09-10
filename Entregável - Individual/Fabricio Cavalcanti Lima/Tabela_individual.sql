
USE sprint1;

CREATE TABLE sensor(
idSensor INT PRIMARY KEY auto_increment,
tipoSensor VARCHAR(40),
constraint chkTipo check(tipoSensor in('Ar','Solo')),
statusSensor VARCHAR(40),
constraint chkStatus check(statusSensor in('Ativo','Inativo')),
localizacaoSetor VARCHAR(40)
);

CREATE TABLE cliente(
idCliente INT PRIMARY KEY auto_increment,
nome VARCHAR(40),
email VARCHAR(40) UNIQUE,
telefone CHAR(13) UNIQUE,
localidade VARCHAR(40),
cnpj CHAR(14) UNIQUE,
data_cadastro datetime default current_timestamp
 );
 
CREATE TABLE umidade(
idUmidade INT primary key auto_increment,
parteDoCiclo VARCHAR(40),
umidadeAtual INT,
mediaDia INT,
mediaCiclo INT,
localizacaoSetor VARCHAR(40)
);


INSERT INTO sensor  VALUES
(default,'Ar', 'Ativo', 'Setor A '),
(default,'Ar', 'Ativo', 'Setor B'),
(default,'Ar', 'Inativo', 'Setor C'),
(default,'Solo', 'Ativo', 'Setor B'),
(default,'Solo', 'Ativo', 'Setor D');

INSERT INTO cliente VALUES
(default ,'Cogumelos do Vale LTDA', 'contato@cogumelosdovale.com.br', '11987654321', 'São Paulo', '12345678000195','2025-05-21'),
(default ,'Hortifruti Organicos S.A.', 'compras@organicos.com.br', '1932547698', 'Campinas', '98765432000110','2025-07-20'),
(default ,'Bistrô Fungi Gourmet', 'pedidos@fungigourmet.com.br', '11912345678', 'São Paulo', '45678912000133','2025-04-03'),
(default ,'Distribuidora Fungaia', 'vendas@fungaia.com', '21976543210', 'Rio de Janeiro', '78912345000166','2025-08-04');

INSERT INTO umidade VALUES
(default ,'Colonização', 82, 80, 81, 'Setor A'),
(default ,'Pasteurização', 95, 94, 95, 'Setor B'),
(default ,'Frutificação', 90, 89, 90, 'Setor B'),
(default ,'Descanso de Bloco', 75, 76, 75, 'Setor C');


SELECT * FROM sensor;
SELECT * FROM umidade;
SELECT * FROM cliente;
