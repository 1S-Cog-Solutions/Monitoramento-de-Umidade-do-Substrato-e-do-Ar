// Histórico: gráficos de tendência e exportação da tabela em CSV.
// Os dados dos gráficos são simulados até existir a API de medidas.

// Cores do tema (definidas no dashboard.css)
let cores = getComputedStyle(document.documentElement);
let verde = cores.getPropertyValue('--verde').trim();
let vermelho = cores.getPropertyValue('--vermelho').trim();
let corTexto = cores.getPropertyValue('--texto-suave').trim();
let corGrade = cores.getPropertyValue('--card-borda').trim();

// Cada gráfico tem a faixa ideal (min e max) e os valores de início e fim da simulação
let graficos = [
    { chave: 'temp',      canvas: 'chartTemp',      unidade: '°C', min: 16, max: 22, inicio: 18, fim: 17.4, variacao: 1.2 },
    { chave: 'ar',        canvas: 'chartAr',        unidade: '%',  min: 80, max: 90, inicio: 85, fim: 87.3, variacao: 2.5 },
    { chave: 'substrato', canvas: 'chartSubstrato', unidade: '%',  min: 60, max: 80, inicio: 78, fim: 59.9, variacao: 1.2 }
];

let periodos = {
    '24h': { quantidade: 24, porHora: true,  texto: 'Últimas 24 horas' },
    '7d':  { quantidade: 7,  porHora: false, texto: 'Últimos 7 dias' },
    '30d': { quantidade: 30, porHora: false, texto: 'Últimos 30 dias' }
};

let ultimaLeitura = new Date(2026, 9, 13, 12, 0);
let graficosNaTela = [];

function doisDigitos(numero) {
    if (numero < 10) {
        return '0' + numero;
    }
    return '' + numero;
}

function formatar(valor, unidade) {
    return valor.toFixed(1).replace('.', ',') + unidade;
}

// Vai do valor de início ao de fim, oscilando um pouco no meio do caminho
function gerarDados(quantidade, grafico) {
    let dados = [];
    let i = 0;

    while (i < quantidade) {
        let progresso = i / (quantidade - 1);
        let valor = grafico.inicio + (grafico.fim - grafico.inicio) * progresso
            + grafico.variacao * Math.sin(progresso * Math.PI * 4);

        dados.push(Number(valor.toFixed(1)));
        i++;
    }

    return dados;
}

// Rótulos do eixo X: horas (24h) ou dias (7 e 30 dias), terminando na última leitura
function gerarRotulos(quantidade, porHora) {
    let rotulos = [];
    let i = quantidade - 1;

    while (i >= 0) {
        let data = new Date(ultimaLeitura);

        if (porHora) {
            data.setHours(data.getHours() - i);
            rotulos.push(doisDigitos(data.getHours()) + ':00');
        } else {
            data.setDate(data.getDate() - i);
            rotulos.push(doisDigitos(data.getDate()) + '/' + doisDigitos(data.getMonth() + 1));
        }
        i--;
    }

    return rotulos;
}

function desenhar(chavePeriodo) {
    // apaga os gráficos do período anterior
    for (let i = 0; i < graficosNaTela.length; i++) {
        graficosNaTela[i].destroy();
    }
    graficosNaTela = [];

    let periodo = periodos[chavePeriodo];
    let rotulos = gerarRotulos(periodo.quantidade, periodo.porHora);
    document.getElementById('tend-sub').textContent = periodo.texto + ' · Faixas de referência da fase de frutificação';

    for (let i = 0; i < graficos.length; i++) {
        let grafico = graficos[i];
        let dados = gerarDados(periodo.quantidade, grafico);
        let atual = dados[dados.length - 1];
        let fora = atual < grafico.min || atual > grafico.max;

        let cor = verde;
        if (fora) {
            cor = vermelho;
        }

        // atualiza o card com o valor atual, mínimo, máximo e a legenda
        let card = document.querySelector('[data-grafico="' + grafico.chave + '"]');
        let legenda = card.querySelector('.legenda');

        card.classList.toggle('tend-fora', fora);
        legenda.classList.toggle('fora', fora);

        if (fora) {
            legenda.textContent = 'Fora da faixa';
        } else {
            legenda.textContent = 'Dentro da faixa';
        }

        card.querySelector('.v-atual').textContent = formatar(atual, grafico.unidade);
        card.querySelector('.v-min').textContent = formatar(Math.min(...dados), grafico.unidade);
        card.querySelector('.v-max').textContent = formatar(Math.max(...dados), grafico.unidade);

        graficosNaTela.push(new Chart(document.getElementById(grafico.canvas), {
            type: 'line',
            data: {
                labels: rotulos,
                datasets: [{
                    data: dados,
                    borderColor: cor,
                    backgroundColor: cor + '22',
                    borderWidth: 1.5,
                    tension: 0.3,
                    pointRadius: 0,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: { legend: { display: false } },
                scales: {
                    x: { ticks: { color: corTexto, font: { size: 9 }, maxTicksLimit: 7, maxRotation: 0 }, grid: { display: false } },
                    y: { ticks: { color: corTexto, font: { size: 9 }, maxTicksLimit: 4 }, grid: { color: corGrade } }
                }
            }
        }));
    }
}

// Baixa a tabela de registros como CSV (separado por ;, abre direto no Excel)
function exportarCSV() {
    let linhas = document.querySelectorAll('.tabela-wrap tr');
    let texto = '';

    for (let i = 0; i < linhas.length; i++) {
        let celulas = linhas[i].children;
        let colunas = [];

        for (let j = 0; j < celulas.length; j++) {
            let valor = celulas[j].textContent.trim();

            // a hora fica num <span> colado na data: separa com um espaço
            let hora = celulas[j].querySelector('.hora');
            if (hora) {
                valor = valor.replace(hora.textContent, ' ' + hora.textContent);
            }

            colunas.push('"' + valor + '"');
        }

        texto += colunas.join(';') + '\n';
    }

    let link = document.createElement('a');
    link.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent('﻿' + texto);
    link.download = 'historico-leituras.csv';
    link.click();
}

document.getElementById('periodo').addEventListener('change', function () {
    desenhar(this.value);
});
document.getElementById('exportar').addEventListener('click', exportarCSV);

desenhar('24h');
