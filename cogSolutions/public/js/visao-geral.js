/* =========================================
   DASHBOARD - VISAO GERAL DA UNIDADE
   A tela responde 3 perguntas do produtor:
   1) Esta tudo bem agora?            -> indicadores do topo
   2) Qual camara precisa de mim?     -> tabela de camaras
   3) O que esta acontecendo nela?    -> leituras + graficos
========================================= */


/* =========================================
   1. FAIXAS IDEAIS POR FASE (documentacao do PI)
========================================= */

let faixas = {
    'Incubação':    { temp: [20, 22], ar: [90, 95], sub: [65, 70] },
    'Indução':      { temp: [23, 25], ar: [90, 95], sub: [70, 75] },
    'Frutificação': { temp: [16, 22], ar: [80, 90], sub: [60, 65] }
};



/* =========================================
   2. DADOS SIMULADOS (ultimas 24 horas, 1 leitura por hora)
   Quando a API estiver ligada, estes vetores vem do banco.
========================================= */

let horarios = [];
for (let i = 0; i < 24; i++) {
    let hora = (12 + i) % 24;
    horarios.push((hora < 10 ? '0' : '') + hora + ':00');
}


// Gera uma serie suave em torno de um valor base
function gerarSerie(base, variacao, deslocamento) {
    let serie = [];
    for (let i = 0; i < 24; i++) {
        let valor = base + variacao * Math.sin((i + deslocamento) / 3.5);
        serie.push(Math.round(valor * 10) / 10);
    }
    return serie;
}


// Camara 02: o substrato vai secando e sai da faixa nas ultimas 3 horas
let substratoCamara2 = gerarSerie(63.5, 0.8, 4);
substratoCamara2[18] = 62.4;
substratoCamara2[19] = 61.5;
substratoCamara2[20] = 60.4;
substratoCamara2[21] = 59.8;
substratoCamara2[22] = 59.7;
substratoCamara2[23] = 59.9;

let temperaturaCamara2 = gerarSerie(18.5, 1.2, 2);
temperaturaCamara2[23] = 17.4;

let arCamara2 = gerarSerie(86, 1.5, 6);
arCamara2[23] = 87.3;


let camaras = [
    {
        nome: 'Câmara 01',
        fase: 'Incubação',
        temp: gerarSerie(21, 0.5, 0),
        ar:   gerarSerie(92.5, 1.2, 3),
        sub:  gerarSerie(67.5, 1, 5)
    },
    {
        nome: 'Câmara 02',
        fase: 'Frutificação',
        temp: temperaturaCamara2,
        ar:   arCamara2,
        sub:  substratoCamara2
    },
    {
        nome: 'Câmara 03',
        fase: 'Indução',
        temp: gerarSerie(24, 0.5, 1),
        ar:   gerarSerie(92, 1, 7),
        sub:  gerarSerie(72.5, 1, 2)
    }
];


let variaveis = [
    { chave: 'temp', nome: 'Temperatura',          unidade: '°C', delta: '°C',   canvas: 'chartTemp', resumo: 'resumoTemp', icone: 'temperature.png' },
    { chave: 'ar',   nome: 'Umidade do ar',        unidade: '%',  delta: 'p.p.', canvas: 'chartAr',   resumo: 'resumoAr',   icone: 'umidade-ar.png' },
    { chave: 'sub',  nome: 'Umidade do substrato', unidade: '%',  delta: 'p.p.', canvas: 'chartSub',  resumo: 'resumoSub',  icone: 'umidade-solo.png' }
];

let corVerde = '#2e8b5c';
let corVermelha = '#d83939';

let camaraSelecionada = 1;
let graficos = {};