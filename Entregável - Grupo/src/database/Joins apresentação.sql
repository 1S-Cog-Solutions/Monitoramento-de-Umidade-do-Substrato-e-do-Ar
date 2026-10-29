
-- testes ---------

SELECT * FROM Empresa;
SELECT * FROM Usuario;
SELECT * FROM login;
SELECT * FROM ambienteCultivo;
SELECT * FROM leitura;
SELECT * FROM sensor;
SELECT * FROM Endereco;
SELECT * FROM lote;
SELECT * FROM Parametro;

-- ===== A1 LOGIN -> USUARIO -> EMPRESA =====

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

-- ===== 2) CAMINHO: EMPRESA -> ENDEREÇO -> USUÁRIOS -> LOGIN =====
 
-- B1 JOIN: empresas e seus endereços
SELECT e.idEmpresa,
       e.Empresa_nome                           AS empresa,
       CONCAT(en.logradouro, ', ', en.numero)   AS endereco,
       en.cidade,
       en.UF
FROM Empresa e
JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
ORDER BY e.Empresa_nome, en.cidade;
 
 -- ===== 3) FAIXA IDEAL (TABELA PARAMETRO, 5 FASES) COM LEITURA =====
 
-- E1 As faixas ideais de cada empresa, na ordem das fases do cultivo
--    (Compostagem, Pasteurização, Incubação, Casing, Frutificação)
SELECT e.Empresa_nome AS empresa,
       p.fase,
       p.faixa_ideal  AS parametro,
       p.valor_min,
       p.valor_max
FROM Parametro p
JOIN Empresa e ON e.idEmpresa = p.fkEmpresa
ORDER BY e.Empresa_nome, p.idfaixa_ideal;
 
 
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
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
ORDER BY l.dtHora DESC, l.id_leitura;
 
 
 
 
-- B2 Caminho completo: empresa -> endereço -> usuários -> login
--    LEFT JOIN em tudo para aparecerem empresas sem endereço, sem usuários ou sem login
SELECT e.Empresa_nome                       AS empresa,
       CONCAT(en.cidade, '/', en.UF)        AS cidade,
       u.nome                               AS usuario,
       lg.email                             AS emailLogin
FROM Empresa e
LEFT JOIN Endereco en ON en.fkEmpresa = e.idEmpresa
LEFT JOIN Usuario u   ON u.fkEmpresa  = e.idEmpresa
LEFT JOIN Login lg    ON lg.fkUsuario = u.idUsuario
ORDER BY e.Empresa_nome, u.nome;
 
-- B3 auto JOIN: cada filial com a sua matriz (Unidade = idEmpresa da matriz)
SELECT f.idEmpresa,
       f.Empresa_nome AS filial,
       m.Empresa_nome AS matriz
FROM Empresa f
JOIN Empresa m ON m.idEmpresa = f.Unidade
ORDER BY m.Empresa_nome, f.Empresa_nome;
 
-- B4 auto RIGHT JOIN: todas as matrizes e as suas filiais (matriz sem filial aparece com filial vazia)
SELECT m.idEmpresa,
       m.Empresa_nome AS matriz,
       f.Empresa_nome AS filial
FROM Empresa f
RIGHT JOIN Empresa m ON f.Unidade = m.idEmpresa
WHERE m.Unidade IS NULL
ORDER BY m.Empresa_nome, f.Empresa_nome;
 
-- B5 Filiais com a matriz e o endereço da filial
SELECT f.Empresa_nome                       AS filial,
       m.Empresa_nome                       AS matriz,
       CONCAT(en.cidade, '/', en.UF)        AS cidadeDaFilial
FROM Empresa f
JOIN Empresa m   ON m.idEmpresa = f.Fkmatriz
JOIN Endereco en ON en.fkEmpresa = f.idEmpresa;
 
 
-- ===== C) EMPRESA -> AMBIENTE -> LOTE =====
 
-- C1 JOIN: empresa, câmara e lotes
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.id_lote,
       lo.fase_atual  AS fase,
       lo.dt_inicio,
       lo.dt_final
FROM Empresa e
JOIN AmbienteCultivo a ON a.fkEmpresa          = e.idEmpresa
JOIN Lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
ORDER BY e.Empresa_nome, a.nome, lo.dt_inicio;
 
-- C2 RIGHT JOIN: todas as empresas, mesmo sem câmara e sem lote
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       lo.dt_inicio,
       lo.dt_final
FROM Lote lo
RIGHT JOIN AmbienteCultivo a ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
RIGHT JOIN Empresa e         ON a.fkEmpresa          = e.idEmpresa
ORDER BY e.Empresa_nome, a.nome, lo.dt_inicio;
 
-- C3 Lotes em andamento (sem data final)
SELECT e.Empresa_nome AS empresa, a.nome AS camara, lo.id_lote, lo.fase_atual AS fase, lo.dt_inicio
FROM Lote lo
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = lo.fkAmbienteCultivo
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
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
ORDER BY l.dtHora DESC, l.id_leitura;
 
-- D2 Só o DHT11: umidade do ar e temperatura
SELECT l.dtHora, a.nome AS camara, s.idSensor, l.umidadeAr, l.Temperatura
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
WHERE s.tipo = 'DHT11'
ORDER BY l.dtHora DESC;
 
-- D3 Só o capacitivo: umidade do solo (substrato)
SELECT l.dtHora, a.nome AS camara, s.idSensor, l.umidadeSolo
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
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
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
ORDER BY lo.id_lote, l.dtHora;
 
 
 
-- E2 RIGHT JOIN: todas as empresas e as faixas que elas têm (empresa sem faixa aparece com faixa vazia)
SELECT e.Empresa_nome AS empresa,
       p.fase,
       p.faixa_ideal  AS parametro,
       p.valor_min,
       p.valor_max
FROM Parametro p
RIGHT JOIN Empresa e ON p.fkEmpresa = e.idEmpresa
ORDER BY e.Empresa_nome, p.idfaixa_ideal;
 
-- E3 Faixa ideal + leitura (umidade do ar, DHT11): cada leitura com os limites da fase do lote
SELECT a.nome        AS camara,
       lo.fase_atual AS fase,
       l.dtHora,
       l.umidadeAr   AS valorLido,
       p.valor_min,
       p.valor_max
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN Parametro p       ON p.fkEmpresa  = a.fkEmpresa
                      AND p.fase        = lo.fase_atual
                      AND p.faixa_ideal = 'umidadeAr'
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
       p.valor_min,
       p.valor_max
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN Lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN Parametro p       ON p.fkEmpresa  = e.idEmpresa
                      AND p.fase        = lo.fase_atual
                      AND p.faixa_ideal = 'umidadeAr'
WHERE l.umidadeAr < p.valor_min OR l.umidadeAr > p.valor_max
ORDER BY l.dtHora;
 
-- F2 Alerta de TEMPERATURA (DHT11)
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.Temperatura  AS valorLido,
       p.valor_min,
       p.valor_max
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN Lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN Parametro p       ON p.fkEmpresa  = e.idEmpresa
                      AND p.fase        = lo.fase_atual
                      AND p.faixa_ideal = 'temperatura'
WHERE l.Temperatura < p.valor_min OR l.Temperatura > p.valor_max
ORDER BY l.dtHora;
 
-- F3 Alerta de umidade do SOLO (sensor capacitivo)
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeSolo  AS valorLido,
       p.valor_min,
       p.valor_max
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'Capacitivo - Substrato'
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN Lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
JOIN Parametro p       ON p.fkEmpresa  = e.idEmpresa
                      AND p.fase        = lo.fase_atual
                      AND p.faixa_ideal = 'umidadeSolo'
WHERE l.umidadeSolo < p.valor_min OR l.umidadeSolo > p.valor_max
ORDER BY l.dtHora;
 
-- F4 DASHBOARD do DHT11: umidade do ar e temperatura na mesma linha, cada uma com a sua faixa ideal
--    LEFT JOIN nas faixas porque algumas fases não têm faixa de ar ou de temperatura (ex.: Compostagem e Casing)
SELECT e.Empresa_nome AS empresa,
       a.nome         AS camara,
       lo.fase_atual  AS fase,
       l.dtHora,
       l.umidadeAr,
       pa.valor_min   AS arMin,
       pa.valor_max   AS arMax,
       l.Temperatura,
       pt.valor_min   AS tempMin,
       pt.valor_max   AS tempMax
FROM Leitura l
JOIN Sensor s          ON s.idSensor          = l.fkSensor
                      AND s.tipo = 'DHT11'
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
JOIN Empresa e         ON e.idEmpresa         = a.fkEmpresa
JOIN Lote lo           ON lo.fkAmbienteCultivo = a.IdAmbienteCultivo
                      AND l.dtHora >= lo.dt_inicio
                      AND (lo.dt_final IS NULL OR l.dtHora <= lo.dt_final)
LEFT JOIN Parametro pa ON pa.fkEmpresa  = e.idEmpresa
                      AND pa.fase        = lo.fase_atual
                      AND pa.faixa_ideal = 'umidadeAr'
LEFT JOIN Parametro pt ON pt.fkEmpresa  = e.idEmpresa
                      AND pt.fase        = lo.fase_atual
                      AND pt.faixa_ideal = 'temperatura'
WHERE l.umidadeAr < pa.valor_min OR l.umidadeAr > pa.valor_max
   OR l.Temperatura < pt.valor_min OR l.Temperatura > pt.valor_max
ORDER BY l.dtHora, a.nome;
 
 
-- ===== G) JOINS DE APOIO (falhas de monitoramento) =====
 
-- G1 RIGHT JOIN: sensores sem nenhuma leitura (possível falha de comunicação)
SELECT s.idSensor, s.tipo, s.statuss AS status, a.nome AS camara
FROM Leitura l
RIGHT JOIN Sensor s    ON l.fkSensor = s.idSensor
JOIN AmbienteCultivo a ON a.IdAmbienteCultivo = s.fkAmbienteCultivo
WHERE l.id_leitura IS NULL;
 
-- G2 RIGHT JOIN: câmaras sem nenhum sensor instalado
SELECT e.Empresa_nome AS empresa, a.IdAmbienteCultivo, a.nome AS camara
FROM Sensor s
RIGHT JOIN AmbienteCultivo a ON s.fkAmbienteCultivo = a.IdAmbienteCultivo
JOIN Empresa e               ON e.idEmpresa = a.fkEmpresa
WHERE s.idSensor IS NULL;
 
 
-- ===== H) HIERARQUIA DE USUÁRIOS =====
 
-- H1 JOIN: usuários que têm empresa
SELECT u.idUsuario, u.nome AS usuario, e.Empresa_nome AS empresa
FROM Usuario u
JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
ORDER BY e.Empresa_nome, u.nome;
 
-- H2 auto JOIN: usuário e seu responsável
--    LEFT JOIN para os gestores (sem responsável) não sumirem do resultado
SELECT u.idUsuario,
       u.nome AS usuario,
       r.nome AS responsavel
FROM Usuario u
LEFT JOIN Usuario r ON r.idUsuario = u.fkResponsavel
ORDER BY u.idUsuario;
 
-- H3 Visão completa: usuário + empresa + responsável
SELECT u.idUsuario,
       u.nome         AS usuario,
       e.Empresa_nome AS empresa,
       r.nome         AS responsavel
FROM Usuario u
LEFT JOIN Empresa e ON e.idEmpresa  = u.fkEmpresa
LEFT JOIN Usuario r ON r.idUsuario  = u.fkResponsavel
ORDER BY e.Empresa_nome, u.nome;
 
-- H4 Cadeia hierárquica (usuário -> responsável -> responsável do responsável)
SELECT u.nome  AS usuario,
       r.nome  AS responsavel,
       r2.nome AS responsavelDoResponsavel
FROM Usuario u
LEFT JOIN Usuario r  ON r.idUsuario  = u.fkResponsavel
LEFT JOIN Usuario r2 ON r2.idUsuario = r.fkResponsavel
WHERE u.fkResponsavel IS NOT NULL;
 
-- H5 Cada responsável com os seus subordinados diretos
SELECT r.nome AS responsavel,
       u.nome AS subordinado
FROM Usuario r
JOIN Usuario u ON u.fkResponsavel = r.idUsuario
ORDER BY r.nome, u.nome;
 
-- H6 Usuários sem empresa
SELECT u.idUsuario, u.nome
FROM Usuario u
LEFT JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
WHERE e.idEmpresa IS NULL;
 
