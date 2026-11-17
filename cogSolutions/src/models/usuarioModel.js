var database = require("../database/config");

// Procura o usuário pelo e-mail e senha (tabelas login, Usuario e Empresa)
function autenticar(email, senha) {
    var instrucaoSql = `
        SELECT u.idUsuario AS id, l.nome, l.email, u.admin, e.idEmpresa, e.Empresa_nome AS empresa
        FROM login l
        JOIN Usuario u ON u.idUsuario = l.fkUsuario
        LEFT JOIN Empresa e ON e.idEmpresa = u.fkEmpresa
        WHERE l.email = ? AND l.senha = ?;
    `;
    return database.executar(instrucaoSql, [email, senha]);
}

// Procura a empresa pela chave de acesso digitada no cadastro
function buscarEmpresaPorChave(chave) {
    var instrucaoSql = `
        SELECT idEmpresa, Empresa_nome FROM Empresa WHERE chaveAcesso = ?;
    `;
    return database.executar(instrucaoSql, [chave]);
}

// Confere se o e-mail já está cadastrado
function emailJaExiste(email) {
    var instrucaoSql = `
        SELECT idLogin FROM login WHERE email = ?;
    `;
    return database.executar(instrucaoSql, [email]);
}

// Cria o usuário já vinculado à empresa (admin = 0, usuário comum)
function cadastrarUsuario(nome, fkEmpresa) {
    var instrucaoSql = `
        INSERT INTO Usuario (nome, fkEmpresa, admin) VALUES (?, ?, 0);
    `;
    return database.executar(instrucaoSql, [nome, fkEmpresa]);
}

// Cria o login (e-mail e senha) do usuário recém criado
function cadastrarLogin(nome, email, senha, fkUsuario) {
    var instrucaoSql = `
        INSERT INTO login (nome, email, senha, fkUsuario) VALUES (?, ?, ?, ?);
    `;
    return database.executar(instrucaoSql, [nome, email, senha, fkUsuario]);
}

module.exports = {
    autenticar,
    buscarEmpresaPorChave,
    emailJaExiste,
    cadastrarUsuario,
    cadastrarLogin
};