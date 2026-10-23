const css = getComputedStyle(document.documentElement);
const cor = nome => css.getPropertyValue(nome).trim();
const VERDE = cor('--verde'), VERMELHO = cor('--vermelho'), SUAVE = cor('--texto-suave'), BORDA = cor('--card-borda');

const GRAFICOS = [
    { chave: 'temp',      id: 'chartTemp',      un: '°C', min: 16, max: 22, base: 18, queda: 0,   amp: 1.2, fase: 0.5, alvo: 17.4 },
    { chave: 'ar',        id: 'chartAr',        un: '%',  min: 80, max: 90, base: 85, queda: 0,   amp: 2.5, fase: 2,   alvo: 87.3 },
    { chave: 'substrato', id: 'chartSubstrato', un: '%',  min: 60, max: 80, base: 78, queda: -18, amp: 1.2, fase: 0,   alvo: 59.9 }
];
const PERIODOS = {
    '24h': { n: 24, passoMin: 60,   hora: true, texto: 'Últimas 24 horas' },
    '7d':  { n: 7,  passoMin: 1440,             texto: 'Últimos 7 dias' },
    '30d': { n: 30, passoMin: 1440,             texto: 'Últimos 30 dias' }
};
const FIM = new Date(2026, 9, 13, 12, 0);
const pad = v => String(v).padStart(2, '0');
const fmt = (v, un) => v.toFixed(1).replace('.', ',') + un;

function gerarSerie(n, g) {
    const f = i => g.base + g.queda * (i / (n - 1)) + g.amp * Math.sin((i / n) * Math.PI * 4 + g.fase);
    const ajuste = g.alvo - f(n - 1);
    return Array.from({ length: n }, (_, i) => +(f(i) + ajuste * (i / (n - 1))).toFixed(1));
}

function gerarRotulos(p) {
    return Array.from({ length: p.n }, (_, i) => {
        const d = new Date(FIM - (p.n - 1 - i) * p.passoMin * 60000);
        return p.hora ? `${pad(d.getHours())}:${pad(d.getMinutes())}` : `${pad(d.getDate())}/${pad(d.getMonth() + 1)}`;
    });
}

const instancias = [];

function desenhar(chavePeriodo) {
    instancias.splice(0).forEach(c => c.destroy());
    const p = PERIODOS[chavePeriodo];
    const rotulos = gerarRotulos(p);
    document.getElementById('tend-sub').textContent = `${p.texto} · Faixas de referência da fase de frutificação`;

    GRAFICOS.forEach(g => {
        const dados = gerarSerie(p.n, g);
        const ultimo = dados[dados.length - 1];
        const fora = ultimo < g.min || ultimo > g.max;
        const linha = fora ? VERMELHO : VERDE;

        const card = document.querySelector(`[data-grafico="${g.chave}"]`);
        const legenda = card.querySelector('.legenda');
        card.classList.toggle('tend-fora', fora);
        legenda.classList.toggle('fora', fora);
        legenda.textContent = fora ? 'Fora da faixa' : 'Dentro da faixa';
        card.querySelector('.v-atual').textContent = fmt(ultimo, g.un);
        card.querySelector('.v-min').textContent = fmt(Math.min(...dados), g.un);
        card.querySelector('.v-max').textContent = fmt(Math.max(...dados), g.un);

        instancias.push(new Chart(document.getElementById(g.id), {
            type: 'line',
            data: {
                labels: rotulos,
                datasets: [{
                    data: dados,
                    borderColor: linha,
                    borderWidth: 1.5,
                    tension: 0.3,
                    pointRadius: 0,
                    fill: true,
                    backgroundColor: ctx => {
                        const a = ctx.chart.chartArea;
                        if (!a) return linha + '22';
                        const gr = ctx.chart.ctx.createLinearGradient(0, a.top, 0, a.bottom);
                        gr.addColorStop(0, linha + '40');
                        gr.addColorStop(1, linha + '00');
                        return gr;
                    }
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: { legend: { display: false } },
                scales: {
                    x: { ticks: { color: SUAVE, font: { size: 9 }, maxTicksLimit: 7, maxRotation: 0 }, grid: { display: false } },
                    y: { ticks: { color: SUAVE, font: { size: 9 }, maxTicksLimit: 4 }, grid: { color: BORDA } }
                }
            }
        }));
    });
}

document.getElementById('periodo').addEventListener('change', e => desenhar(e.target.value));
desenhar('24h');

document.getElementById('exportar').addEventListener('click', () => {
    const linhas = [...document.querySelectorAll('.tabela-wrap tr')].map(tr =>
        [...tr.children].map(td =>
            '"' + td.textContent.trim().replace(/(\d{4})(\d{2}:)/, '$1 $2').replace(/\s+/g, ' ').replace(/"/g, '""') + '"'
        ).join(';'));
    const blob = new Blob(['\ufeff' + linhas.join('\n')], { type: 'text/csv;charset=utf-8' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'historico-leituras.csv';
    a.click();
    URL.revokeObjectURL(a.href);
});