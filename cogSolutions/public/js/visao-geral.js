/*DASHBOARD - VISAO GERAL*/


/*FAIXAS IDEAIS POR FASE*/

let faixas = {
    'Incubação':    { temp: [20, 22], ar: [90, 95], sub: [65, 70] },
    'Indução':      { temp: [23, 25], ar: [90, 95], sub: [70, 75] },
    'Frutificação': { temp: [16, 22], ar: [80, 90], sub: [60, 65] }
};


/*DADOS SIMULADOS*/

let horarios = [];
for (let i = 0; i < 24; i++) {
    let hora = (12 + i) % 24;
    horarios.push((hora < 10 ? '0' : '') + hora + ':00');
}

function gerarSerie(base, variacao, deslocamento) {
    let serie = [];
    for (let i = 0; i < 24; i++) {
        let valor = base + variacao * Math.sin((i + deslocamento) / 3.5);
        serie.push(Math.round(valor * 10) / 10);
    }
    return serie;
}

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


/*FUNCOES DE CALCULO*/

function formatar(numero) {
    return numero.toFixed(1).replace('.', ',');
}

function faixaDe(camara, chave) {
    return faixas[camara.fase][chave];
}

function estaFora(valor, faixa) {
    return valor < faixa[0] || valor > faixa[1];
}

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

function desvio(valor, faixa) {
    if (valor < faixa[0]) {
        return faixa[0] - valor;
    }
    if (valor > faixa[1]) {
        return valor - faixa[1];
    }
    return 0;
}

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


/*ALERTAS DE HOJE*/

let alertasHoje = [
    { hora: '11:30', nivel: 'critico', titulo: 'Câmara 02 · substrato em 59,9%',   detalhe: 'abaixo', aberto: true },
    { hora: '09:40', nivel: 'ok',      titulo: 'Câmara 03 · temperatura normalizada', detalhe: 'Voltou para a faixa ideal da indução.', aberto: false },
    { hora: '09:21', nivel: 'aviso',   titulo: 'Câmara 01 · sensor reconectado',   detalhe: 'Ficou sem enviar leituras por alguns minutos.', aberto: false }
];


/*INDICADORES DO TOPO*/

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
}


/*TABELA DE CAMARAS*/

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


/*LEITURAS ATUAIS*/

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

        let largura = faixa[1] - faixa[0];
        let escalaMin = faixa[0] - largura;
        let escalaMax = faixa[1] + largura;
        let posicao = (atual - escalaMin) / (escalaMax - escalaMin) * 100;
        if (posicao < 2) { posicao = 2; }
        if (posicao > 98) { posicao = 98; }
        let inicioFaixa = (faixa[0] - escalaMin) / (escalaMax - escalaMin) * 100;
        let larguraFaixa = largura / (escalaMax - escalaMin) * 100;

        let frase = 'Dentro da faixa';
        if (atual < faixa[0]) {
            frase = formatar(faixa[0] - atual) + ' ' + v.delta + ' abaixo do mínimo';
        } else if (atual > faixa[1]) {
            frase = formatar(atual - faixa[1]) + ' ' + v.delta + ' acima do máximo';
        }

        let seta = variacao >= 0 ? '▲' : '▼';
        let tendencia = seta + ' ' + formatar(Math.abs(variacao)) + ' ' + v.delta + ' em 3 h';

        html += '<div class="leitura-card' + (fora ? ' alerta' : '') + '">';
        html += '<div class="leitura-topo"><span class="kpi-label">' + v.nome + '</span>';
        html += '<img src="../assets/icon/' + v.icone + '" alt="" class="card-icon"></div>';
        html += '<strong>' + formatar(atual) + v.unidade + '</strong>';
        html += '<div class="escala"><div class="zona-ideal" style="left:' + inicioFaixa + '%; width:' + larguraFaixa + '%"></div>';
        html += '<div class="marcador' + (fora ? ' fora' : '') + '" style="left:' + posicao + '%"></div></div>';
        html += '<div class="escala-rotulos"><span>ideal: ' + faixa[0] + '–' + faixa[1] + v.unidade + '</span><span>' + tendencia + '</span></div>';
        html += '<span class="faixa ' + (fora ? 'fora' : 'ok') + '">' + frase + '</span>';
        html += '</div>';
    }

    document.getElementById('leituras').innerHTML = html;
}


/*GRAFICOS*/

function coresDosPontos(dados, faixa) {
    let cores = [];
    for (let i = 0; i < dados.length; i++) {
        cores.push(estaFora(dados[i], faixa) ? corVermelha : corVerde);
    }
    return cores;
}

function criarGrafico(variavel) {
    let camara = camaras[camaraSelecionada];
    let faixa = faixaDe(camara, variavel.chave);
    let dados = camara[variavel.chave];
    let largura = faixa[1] - faixa[0];

    graficos[variavel.chave] = new Chart(
        document.getElementById(variavel.canvas),
        {
            type: 'line',
            data: {
                labels: horarios,
                datasets: [
                    {
                        data: Array(24).fill(faixa[0]),
                        borderWidth: 0,
                        pointRadius: 0
                    },
                    {
                        data: Array(24).fill(faixa[1]),
                        borderWidth: 0,
                        pointRadius: 0,
                        fill: '-1',
                        backgroundColor: 'rgba(46, 139, 92, 0.14)'
                    },
                    {
                        data: dados,
                        borderColor: '#9a9a9a',
                        borderWidth: 1.5,
                        tension: 0.3,
                        pointRadius: 3,
                        pointBackgroundColor: coresDosPontos(dados, faixa),
                        pointBorderColor: coresDosPontos(dados, faixa)
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: false,
                plugins: { legend: { display: false } },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { autoSkip: true, maxTicksLimit: 4, maxRotation: 0, color: '#6b6b6b', font: { size: 11 } }
                    },
                    y: {
                        suggestedMin: faixa[0] - largura * 0.6,
                        suggestedMax: faixa[1] + largura * 0.6,
                        grid: { color: '#ececec' },
                        ticks: { color: '#6b6b6b' }
                    }
                }
            }
        }
    );
}

function atualizarGrafico(variavel) {
    let camara = camaras[camaraSelecionada];
    let faixa = faixaDe(camara, variavel.chave);
    let dados = camara[variavel.chave];
    let largura = faixa[1] - faixa[0];
    let grafico = graficos[variavel.chave];

    grafico.data.datasets[0].data = Array(24).fill(faixa[0]);
    grafico.data.datasets[1].data = Array(24).fill(faixa[1]);
    grafico.data.datasets[2].data = dados;
    grafico.data.datasets[2].pointBackgroundColor = coresDosPontos(dados, faixa);
    grafico.data.datasets[2].pointBorderColor = coresDosPontos(dados, faixa);
    grafico.options.scales.y.suggestedMin = faixa[0] - largura * 0.6;
    grafico.options.scales.y.suggestedMax = faixa[1] + largura * 0.6;
    grafico.update();
}

function desenharResumos() {
    let camara = camaras[camaraSelecionada];

    for (let i = 0; i < variaveis.length; i++) {
        let v = variaveis[i];
        let serie = camara[v.chave];
        let faixa = faixaDe(camara, v.chave);
        let foraTotal = 0;

        for (let k = 0; k < serie.length; k++) {
            if (estaFora(serie[k], faixa)) {
                foraTotal++;
            }
        }

        let elemento = document.getElementById(v.resumo);
        if (foraTotal == 0) {
            elemento.innerHTML = 'Sempre dentro da faixa';
            elemento.className = 'resumo-grafico ok';
        } else {
            elemento.innerHTML = foraTotal + ' h fora da faixa nas últimas 24 h';
            elemento.className = 'resumo-grafico fora';
        }
    }
}


/*ALERTAS RECENTES*/

function desenharAlertas() {
    let camara = camaras[1];
    let serie = camara.sub;
    let faixa = faixaDe(camara, 'sub');
    let horas = horasForaDaFaixa(serie, faixa);

    let html = '';

    for (let i = 0; i < alertasHoje.length; i++) {
        let a = alertasHoje[i];
        let detalhe = a.detalhe;

        if (a.detalhe == 'abaixo') {
            detalhe = 'Abaixo do mínimo (' + faixa[0] + '%) há ' + horas + ' h. Verificar a irrigação.';
        }

        html += '<li class="' + a.nivel + '"><time>' + a.hora + '</time><div>';
        html += '<b>' + a.titulo + '</b><span>' + detalhe + '</span></div></li>';
    }

    document.getElementById('listaAlertas').innerHTML = html;
}


/*TROCAR DE CAMARA*/

function selecionarCamara(indice) {
    camaraSelecionada = indice;

    desenharTabela();
    desenharLeituras();
    desenharResumos();

    for (let i = 0; i < variaveis.length; i++) {
        atualizarGrafico(variaveis[i]);
    }
}


/*INICIAR A TELA*/

desenharIndicadores();
desenharTabela();
desenharLeituras();
desenharResumos();
desenharAlertas();

for (let i = 0; i < variaveis.length; i++) {
    criarGrafico(variaveis[i]);
}