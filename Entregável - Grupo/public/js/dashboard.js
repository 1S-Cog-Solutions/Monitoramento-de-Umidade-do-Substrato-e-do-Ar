const GRAFICOS = [
    { id: 'chartTemp',      min: 16, max: 22, base: 18, amp: 2.5, fase: 0 },
    { id: 'chartAr',        min: 80, max: 90, base: 86, amp: 3,   fase: 1 },
    { id: 'chartSubstrato', min: 60, max: 80, base: 64, amp: 6,   fase: 2 }
];
const PONTOS = { '24h': 24, '7d': 28, '30d': 30 };

const css = getComputedStyle(document.documentElement);
const VERDE = css.getPropertyValue('--verde').trim();
const VERMELHO = css.getPropertyValue('--vermelho').trim();
const SUAVE = css.getPropertyValue('--texto-suave').trim();
const BORDA = css.getPropertyValue('--card-borda').trim();

const bandaFaixa = {
    id: 'bandaFaixa',
    beforeDatasetsDraw(chart, _args, opt) {
        const { ctx, chartArea: a, scales: { y } } = chart;
        const topo = y.getPixelForValue(opt.max);
        const base = y.getPixelForValue(opt.min);
        ctx.save();
        ctx.fillStyle = 'rgba(94, 201, 123, 0.08)';
        ctx.fillRect(a.left, topo, a.right - a.left, base - topo);
        ctx.restore();
    }
};

function gerarDados(n, g) {
    return Array.from({ length: n }, (_, i) =>
        +(g.base + g.amp * Math.sin((i / n) * Math.PI * 2 + g.fase) + Math.sin(i * 1.7) * g.amp * 0.15).toFixed(1));
}

function gerarRotulos(periodo, n) {
    return Array.from({ length: n }, (_, i) =>
        periodo === '24h' ? String(i).padStart(2, '0') + ':00' : 'Dia ' + (i + 1));
}

const instancias = [];

function desenhar(periodo) {
    instancias.splice(0).forEach(c => c.destroy());
    const n = PONTOS[periodo];
    const rotulos = gerarRotulos(periodo, n);

    GRAFICOS.forEach(g => {
        const fora = v => v < g.min || v > g.max;
        instancias.push(new Chart(document.getElementById(g.id), {
            type: 'line',
            data: {
                labels: rotulos,
                datasets: [{
                    data: gerarDados(n, g),
                    borderWidth: 1.5,
                    tension: 0.35,
                    pointRadius: 0,
                    segment: {
                        borderColor: c => (fora(c.p0.parsed.y) || fora(c.p1.parsed.y)) ? VERMELHO : VERDE
                    }
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: { legend: { display: false }, bandaFaixa: { min: g.min, max: g.max } },
                scales: {
                    x: { ticks: { color: SUAVE, font: { size: 9 }, maxTicksLimit: 8 }, grid: { display: false } },
                    y: {
                        suggestedMin: g.min - 4,
                        suggestedMax: g.max + 4,
                        ticks: { color: SUAVE, font: { size: 9 }, maxTicksLimit: 4 },
                        grid: { color: BORDA }
                    }
                }
            },
            plugins: [bandaFaixa]
        }));
    });
}

document.getElementById('periodo').addEventListener('change', e => desenhar(e.target.value));
desenhar('24h');