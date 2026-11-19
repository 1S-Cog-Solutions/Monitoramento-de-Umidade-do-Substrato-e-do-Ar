var medidaModel = require("../models/medidaModel");

function buscarUltimasMedidas(req, res) {

    const limite_linhas = 7;

    var idAquario = req.params.idAquario;

    console.log(`Recuperando as ultimas ${limite_linhas} medidas`);

    medidaModel.buscarUltimasMedidas(idAquario, limite_linhas).then(function (resultado) {
        if (resultado.length > 0) {
            res.status(200).json(resultado);
        } else {
            res.status(204).send("Nenhum resultado encontrado!")
        }
    }).catch(function (erro) {
        console.log(erro);
        console.log("Houve um erro ao buscar as ultimas medidas.", erro.sqlMessage);
        res.status(500).json(erro.sqlMessage);
    });
}


function buscarMedidasEmTempoReal(req, res) {

    var idAquario = req.params.idAquario;

    console.log(`Recuperando medidas em tempo real`);

    medidaModel.buscarMedidasEmTempoReal(idAquario).then(function (resultado) {
        if (resultado.length > 0) {
            res.status(200).json(resultado);
        } else {
            res.status(204).send("Nenhum resultado encontrado!")
        }
    }).catch(function (erro) {
        console.log(erro);
        console.log("Houve um erro ao buscar as ultimas medidas.", erro.sqlMessage);
        res.status(500).json(erro.sqlMessage);
    });
}

function buscarTemperaturaAtual(req, res) {

    console.log(`Recuperando a temperatura atual`);

    medidaModel.buscarTemperaturaAtual().then(function (resultado) {
        if (resultado.length > 0) {
            res.status(200).json(resultado[0]);
        } else {
            res.status(204).send("Nenhum resultado encontrado!")
        }
    }).catch(function (erro) {
        console.log(erro);
        console.log("Houve um erro ao buscar a temperatura atual.", erro.sqlMessage);
        res.status(500).json(erro.sqlMessage);
    });
}

function buscarUmidadeArAtual(req, res) {

    console.log(`Recuperando a umidade do ar atual`);

    medidaModel.buscarUmidadeArAtual().then(function (resultado) {
        if (resultado.length > 0) {
            res.status(200).json(resultado[0]);
        } else {
            res.status(204).send("Nenhum resultado encontrado!")
        }
    }).catch(function (erro) {
        console.log(erro);
        console.log("Houve um erro ao buscar a umidade do ar atual.", erro.sqlMessage);
        res.status(500).json(erro.sqlMessage);
    });
}

function buscarUmidadeSoloAtual(req, res) {

    console.log(`Recuperando a umidade do substrato atual`);

    medidaModel.buscarUmidadeSoloAtual().then(function (resultado) {
        if (resultado.length > 0) {
            res.status(200).json(resultado[0]);
        } else {
            res.status(204).send("Nenhum resultado encontrado!")
        }
    }).catch(function (erro) {
        console.log(erro);
        console.log("Houve um erro ao buscar a umidade do substrato atual.", erro.sqlMessage);
        res.status(500).json(erro.sqlMessage);
    });
}

function buscarGraficoTemperatura(req, res) {

    console.log(`Recuperando o gráfico de temperatura das últimas 24 h`);

    medidaModel.buscarGraficoTemperatura().then(function (resultado) {
        if (resultado.length > 0) {
            res.status(200).json(resultado);
        } else {
            res.status(204).send("Nenhum resultado encontrado!")
        }
    }).catch(function (erro) {
        console.log(erro);
        console.log("Houve um erro ao buscar o gráfico de temperatura.", erro.sqlMessage);
        res.status(500).json(erro.sqlMessage);
    });
}

function buscarGraficoUmidadeAr(req, res) {

    console.log(`Recuperando o gráfico de umidade do ar das últimas 24 h`);

    medidaModel.buscarGraficoUmidadeAr().then(function (resultado) {
        if (resultado.length > 0) {
            res.status(200).json(resultado);
        } else {
            res.status(204).send("Nenhum resultado encontrado!")
        }
    }).catch(function (erro) {
        console.log(erro);
        console.log("Houve um erro ao buscar o gráfico de umidade do ar.", erro.sqlMessage);
        res.status(500).json(erro.sqlMessage);
    });
}

function buscarGraficoUmidadeSolo(req, res) {

    console.log(`Recuperando o gráfico de umidade do substrato das últimas 24 h`);

    medidaModel.buscarGraficoUmidadeSolo().then(function (resultado) {
        if (resultado.length > 0) {
            res.status(200).json(resultado);
        } else {
            res.status(204).send("Nenhum resultado encontrado!")
        }
    }).catch(function (erro) {
        console.log(erro);
        console.log("Houve um erro ao buscar o gráfico de umidade do substrato.", erro.sqlMessage);
        res.status(500).json(erro.sqlMessage);
    });
}

module.exports = {
    buscarUltimasMedidas,
    buscarMedidasEmTempoReal,
    buscarTemperaturaAtual,
    buscarUmidadeArAtual,
    buscarUmidadeSoloAtual,
    buscarGraficoTemperatura,
    buscarGraficoUmidadeAr,
    buscarGraficoUmidadeSolo

}