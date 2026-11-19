var database = require("../database/config");

function buscarUltimasMedidas(idAquario, limite_linhas) {

    var instrucaoSql = `SELECT 
                        temperatura,
                        momento,
                        DATE_FORMAT(momento,'%H:%i:%s') as momento_grafico
                    FROM medida
                    WHERE fk_aquario = ${idAquario}
                    ORDER BY id DESC LIMIT ${limite_linhas}`;

    console.log("Executando a instrução SQL: \n" + instrucaoSql);
    return database.executar(instrucaoSql);
}

function buscarMedidasEmTempoReal(idAquario) {

    var instrucaoSql = `SELECT 
                        temperatura,
                        DATE_FORMAT(momento,'%H:%i:%s') as momento_grafico, 
                        fk_aquario 
                        FROM medida WHERE fk_aquario = ${idAquario} 
                    ORDER BY id DESC LIMIT 1`;

    console.log("Executando a instrução SQL: \n" + instrucaoSql);
    return database.executar(instrucaoSql);
}

function buscarTemperaturaAtual() {

    var instrucaoSql = `SELECT Temperatura AS temperatura FROM vw_leitura_faixa_temperatura`;

    console.log("Executando a instrução SQL: \n" + instrucaoSql);
    return database.executar(instrucaoSql);
}

function buscarUmidadeArAtual() {

    var instrucaoSql = `SELECT umidadeAr AS umidade FROM vw_leitura_umidade_ar`;

    console.log("Executando a instrução SQL: \n" + instrucaoSql);
    return database.executar(instrucaoSql);
}

function buscarUmidadeSoloAtual() {

    var instrucaoSql = `SELECT umidadeSolo AS umidade FROM vw_leitura_umidade_solo`;

    console.log("Executando a instrução SQL: \n" + instrucaoSql);
    return database.executar(instrucaoSql);
}

function buscarGraficoTemperatura() {

    var instrucaoSql = `SELECT hora, temperatura AS valor FROM vw_grafico_temperatura`;

    console.log("Executando a instrução SQL: \n" + instrucaoSql);
    return database.executar(instrucaoSql);
}

function buscarGraficoUmidadeAr() {

    var instrucaoSql = `SELECT hora, umidadeAr AS valor FROM vw_grafico_umidade_ar`;

    console.log("Executando a instrução SQL: \n" + instrucaoSql);
    return database.executar(instrucaoSql);
}

function buscarGraficoUmidadeSolo() {

    var instrucaoSql = `SELECT hora, umidadeSolo AS valor FROM vw_grafico_umidade_solo`;

    console.log("Executando a instrução SQL: \n" + instrucaoSql);
    return database.executar(instrucaoSql);
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
