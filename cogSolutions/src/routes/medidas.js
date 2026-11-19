var express = require("express");
var router = express.Router();

var medidaController = require("../controllers/medidaController");

router.get("/ultimas/:idAquario", function (req, res) {
    medidaController.buscarUltimasMedidas(req, res);
});

router.get("/tempo-real/:idAquario", function (req, res) {
    medidaController.buscarMedidasEmTempoReal(req, res);
})

router.get("/temperatura-atual", function (req, res) {
    medidaController.buscarTemperaturaAtual(req, res);
})

router.get("/umidade-ar-atual", function (req, res) {
    medidaController.buscarUmidadeArAtual(req, res);
})

router.get("/umidade-solo-atual", function (req, res) {
    medidaController.buscarUmidadeSoloAtual(req, res);
})

router.get("/grafico-temperatura", function (req, res) {
    medidaController.buscarGraficoTemperatura(req, res);
})

router.get("/grafico-umidade-ar", function (req, res) {
    medidaController.buscarGraficoUmidadeAr(req, res);
})

router.get("/grafico-umidade-solo", function (req, res) {
    medidaController.buscarGraficoUmidadeSolo(req, res);
})

module.exports = router;