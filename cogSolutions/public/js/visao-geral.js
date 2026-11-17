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



/* =========================================
   3. FUNCOES DE CALCULO
========================================= */

function formatar(numero) {
    return numero.toFixed(1).replace('.', ',');
}

function faixaDe(camara, chave) {
    return faixas[camara.fase][chave];
}

function estaFora(valor, faixa) {
    return valor < faixa[0] || valor > faixa[1];
}


// Quantas horas seguidas (ate agora) a leitura esta fora da faixa
function horasForaDaFaixa(serie, faixa) {
    let horas = 0;
    for (let i = serie.length - 1; i >= 0; i--) {
        if (estaFora(serie[i], faixa)) {
            horas++;
        } else {
            break;
        }
    }
    return horas;
}


// Quanto falta para voltar para a faixa (0 se estiver dentro)
function desvio(valor, faixa) {
    if (valor < faixa[0]) {
        return faixa[0] - valor;
    }
    if (valor > faixa[1]) {
        return valor - faixa[1];
    }
    return 0;
}


// Pior variavel da camara: a que esta ha mais tempo fora da faixa
function piorVariavel(camara) {
    let pior = null;
    let maiorTempo = 0;

    for (let i = 0; i < variaveis.length; i++) {
        let v = variaveis[i];
        let serie = camara[v.chave];
        let horas = horasForaDaFaixa(serie, faixaDe(camara, v.chave));

        if (horas > maiorTempo) {
            maiorTempo = horas;
            pior = v;
        }
    }

    return { variavel: pior, horas: maiorTempo };
}


// Status da camara: Ideal, Atencao (saiu da faixa) ou Critico (muito longe da faixa)
function statusDaCamara(camara) {
    let status = 'ideal';

    for (let i = 0; i < variaveis.length; i++) {
        let chave = variaveis[i].chave;
        let serie = camara[chave];
        let faixa = faixaDe(camara, chave);
        let atual = serie[serie.length - 1];

        if (estaFora(atual, faixa)) {
            let largura = faixa[1] - faixa[0];

            if (desvio(atual, faixa) > largura / 2) {
                return 'critico';
            }
            status = 'atencao';
        }
    }

    return status;
}


function textoStatus(status) {
    if (status == 'ideal') { return 'Ideal'; }
    if (status == 'atencao') { return 'Atenção'; }
    return 'Crítico';
}

function textoHoras(horas) {
    if (horas == 0) { return '—'; }
    return horas + ' h';
}



/* =========================================
   4. ALERTAS DE HOJE (simulados)
========================================= */

let alertasHoje = [
    { hora: '11:30', nivel: 'critico', titulo: 'Câmara 02 · substrato em 59,9%',   detalhe: 'abaixo', aberto: true },
    { hora: '09:40', nivel: 'ok',      titulo: 'Câmara 03 · temperatura normalizada', detalhe: 'Voltou para a faixa ideal da indução.', aberto: false },
    { hora: '09:21', nivel: 'aviso',   titulo: 'Câmara 01 · sensor reconectado',   detalhe: 'Ficou sem enviar leituras por alguns minutos.', aberto: false }
];



/* =========================================
   5. INDICADORES DO TOPO
   Nenhuma media: so o que o produtor precisa para decidir.
========================================= */

function desenharIndicadores() {
    let emAlerta = 0;
    let nomeAlerta = '';
    let maiorTempo = 0;
    let textoMaiorTempo = 'Nenhuma leitura fora da faixa';

    for (let i = 0; i < camaras.length; i++) {
        let camara = camaras[i];

        if (statusDaCamara(camara) != 'ideal') {
            emAlerta++;
            nomeAlerta = camara.nome;
        }

        let p = piorVariavel(camara);
        if (p.horas > maiorTempo) {
            maiorTempo = p.horas;
            textoMaiorTempo = camara.nome + ' · ' + p.variavel.nome.toLowerCase();
        }
    }

    let abertos = 0;
    for (let i = 0; i < alertasHoje.length; i++) {
        if (alertasHoje[i].aberto) {
            abertos++;
        }
    }
    let resolvidos = alertasHoje.length - abertos;

    let classeAlerta = emAlerta > 0 ? 'kpi-card destaque' : 'kpi-card';
    let subAlerta = emAlerta > 0 ? nomeAlerta + ' precisa de atenção' : 'Todas as câmaras na faixa ideal';

}


    let html = '';

    html += '<div class="' + classeAlerta + '">';
    html += '<span class="kpi-label">Câmaras em alerta</span>';
    html += '<strong>' + emAlerta + '<small> de ' + camaras.length + '</small></strong>';
    html += '<p>' + subAlerta + '</p></div>';

    html += '<div class="kpi-card">';
    html += '<span class="kpi-label">Maior tempo fora da faixa</span>';
    html += '<strong>' + (maiorTempo > 0 ? maiorTempo + '<small> h</small>' : '—') + '</strong>';
    html += '<p>' + textoMaiorTempo + '</p></div>';

    html += '<div class="kpi-card">';
    html += '<span class="kpi-label">Alertas hoje</span>';
    html += '<strong>' + alertasHoje.length + '</strong>';
    html += '<p>' + abertos + ' aberto · ' + resolvidos + ' resolvidos</p></div>';

    html += '<div class="kpi-card">';
    html += '<span class="kpi-label">Sensores ativos</span>';
    html += '<strong>6<small> de 6</small></strong>';
    html += '<p>última leitura recebida há 2 min</p></div>';

    document.getElementById('kpis').innerHTML = html;



/* =========================================
   6. TABELA DE CAMARAS
========================================= */

function desenharTabela() {
    let html = '';

    for (let i = 0; i < camaras.length; i++) {
        let camara = camaras[i];
        let status = statusDaCamara(camara);
        let pior = piorVariavel(camara);

        let detalhe = '—';
        if (pior.variavel != null) {
            detalhe = pior.horas + ' h <span class="detalhe">' + pior.variavel.nome.toLowerCase() + '</span>';
        }

        let classe = i == camaraSelecionada ? 'selecionada' : '';

        html += '<tr class="' + classe + '" onclick="selecionarCamara(' + i + ')">';
        html += '<td>' + camara.nome + '</td>';
        html += '<td>' + camara.fase + '</td>';
        html += '<td><span class="pill ' + status + '">' + textoStatus(status) + '</span></td>';
        html += '<td>' + detalhe + '</td>';
        html += '</tr>';
    }

    document.getElementById('tabelaCamaras').innerHTML = html;
}



/* =========================================
   7. LEITURAS ATUAIS DA CAMARA SELECIONADA
   Cada cartao mostra onde o valor esta em relacao a faixa ideal.
========================================= */

function desenharLeituras() {
    let camara = camaras[camaraSelecionada];
    let html = '';

    document.getElementById('tituloCamara').innerHTML = camara.nome;
    document.getElementById('faseCamara').innerHTML = 'Fase atual: ' + camara.fase.toLowerCase();

    for (let i = 0; i < variaveis.length; i++) {
        let v = variaveis[i];
        let serie = camara[v.chave];
        let faixa = faixaDe(camara, v.chave);
        let atual = serie[serie.length - 1];
        let antes = serie[serie.length - 4];
        let variacao = atual - antes;
        let fora = estaFora(atual, faixa);

        // Escala da barra: faixa ideal com uma folga de uma "largura" de cada lado
        let largura = faixa[1] - faixa[0];
        let escalaMin = faixa[0] - largura;
        let escalaMax = faixa[1] + largura;
        let posicao = (atual - escalaMin) / (escalaMax - escalaMin) * 100;
        if (posicao < 2) { posicao = 2; }
        if (posicao > 98) { posicao = 98; }
        let inicioFaixa = (faixa[0] - escalaMin) / (escalaMax - escalaMin) * 100;
        let larguraFaixa = largura / (escalaMax - escalaMin) * 100;
    }

    document.getElementById('leituras').innerHTML = html;
}