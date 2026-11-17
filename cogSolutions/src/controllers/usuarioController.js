var usuarioModel = require("../models/usuarioModel");

function autenticar(req, res) {
    var email = req.body.emailServer;
    var senha = req.body.senhaServer;

    if (email == undefined || email == "") {
        res.status(400).send("Seu e-mail está vazio!");
    } else if (senha == undefined || senha == "") {
        res.status(400).send("Sua senha está vazia!");
    } else {

        usuarioModel.autenticar(email.trim().toLowerCase(), senha)
            .then(function (resultado) {
                if (resultado.length == 1) {
                    // Devolve só o que o site precisa guardar (a senha nunca volta)
                    res.json(resultado[0]);
                } else {
                    res.status(403).send("E-mail e/ou senha inválido(s)");
                }
            })
            .catch(function (erro) {
                console.log("\nHouve um erro ao realizar o login! Erro: ", erro.sqlMessage || erro);
                res.status(500).json(erro.sqlMessage || "Erro ao realizar o login");
            });
    }
}

async function cadastrar(req, res) {
    var nome = req.body.nomeServer;
    var email = req.body.emailServer;
    var senha = req.body.senhaServer;
    var chave = req.body.chaveServer;

    if (nome == undefined || nome == "") {
        res.status(400).send("Seu nome está vazio!");
    } else if (email == undefined || email == "") {
        res.status(400).send("Seu e-mail está vazio!");
    } else if (senha == undefined || senha == "") {
        res.status(400).send("Sua senha está vazia!");
    } else if (senha.length > 50) {
        res.status(400).send("A senha pode ter no máximo 50 caracteres!");
    } else if (chave == undefined || chave == "") {
        res.status(400).send("A chave da empresa está vazia!");
    } else {

        email = email.trim().toLowerCase();

        try {
            // 1) A chave precisa existir
            var empresas = await usuarioModel.buscarEmpresaPorChave(chave.trim());
            if (empresas.length == 0) {
                res.status(404).send("Chave da empresa inválida");
                return;
            }

            // 2) O e-mail não pode estar cadastrado
            var emails = await usuarioModel.emailJaExiste(email);
            if (emails.length > 0) {
                res.status(409).send("Este e-mail já está cadastrado");
                return;
            }

            // 3) Cria o usuário e depois o login ligado a ele
            var novoUsuario = await usuarioModel.cadastrarUsuario(nome.trim(), empresas[0].idEmpresa);
            await usuarioModel.cadastrarLogin(nome.trim(), email, senha, novoUsuario.insertId);

            res.status(201).json({ mensagem: "Conta criada com sucesso!" });
        } catch (erro) {
            console.log("\nHouve um erro ao realizar o cadastro! Erro: ", erro.sqlMessage || erro);
            res.status(500).json(erro.sqlMessage || "Erro ao realizar o cadastro");
        }
    }
}

module.exports = {
    autenticar,
    cadastrar
}