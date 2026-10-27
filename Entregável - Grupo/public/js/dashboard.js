
/* =========================================
   1. CONFIGURACOES DOS GRAFICOS
========================================= */

// Limites de referencia
let temperaturaMinima = 16;
let temperaturaMaxima = 22;

let umidadeArMinima = 80;
let umidadeArMaxima = 90;

let umidadeSubstratoMinima = 60;
let umidadeSubstratoMaxima = 80;


// Cores utilizadas nos graficos
let verde = '#1c7423';
let vermelho = '#d94343';


// Horarios das ultimas 24 horas
let horarios = [
    '00:00', '01:00', '02:00', '03:00',
    '04:00', '05:00', '06:00', '07:00',
    '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00',
    '16:00', '17:00', '18:00', '19:00',
    '20:00', '21:00', '22:00', '23:00'
];


// Gerar os rotulos dos dias
function gerarDias(quantidade) {
    let dias = [];

    for (let i = 1; i <= quantidade; i++) {
        dias.push('Dia ' + i);
    }

    return dias;
}


// =========================================
// 2. DADOS SIMULADOS
// =========================================

// Temperatura em graus Celsius
let temperaturas = [
    18.2, 18.5, 18.7, 19.0, 19.2,
    19.5, 19.8, 20.1, 20.3, 20.0,
    19.7, 19.5, 19.2, 18.9, 18.6,
    18.4, 18.1, 17.9, 17.5, 17.8,
    18.0, 18.3, 18.5, 18.7, 19.0,
    19.3, 19.5, 22.8, 21.5, 17.0
];


// Umidade do ar em porcentagem
let umidadesAr = [
    85, 86, 87, 86, 85,
    84, 83, 84, 85, 86,
    87, 88, 87, 86, 85,
    84, 83, 82, 81, 83,
    84, 85, 86, 87, 88,
    89, 91, 88, 85, 79
];


// Umidade do substrato em porcentagem
let umidadesSubstrato = [
    65, 66, 67, 68, 69,
    70, 71, 72, 73, 74,
    75, 76, 75, 74, 73,
    72, 71, 70, 69, 68,
    67, 66, 65, 64, 63,
    62, 61, 59, 65, 82
];


// =========================================
// 3. IDENTIFICAR VALORES FORA DA FAIXA
// =========================================

function criarCores(dados, minimo, maximo) {
    let cores = [];

    for (let i = 0; i < dados.length; i++) {

        if (dados[i] < minimo || dados[i] > maximo) {
            cores.push(vermelho);
        } else {
            cores.push(verde);
        }

    }

    return cores;
}


// =========================================
// 4. CRIAR O GRAFICO DE TEMPERATURA
// =========================================

let chartTemp = new Chart(
    document.getElementById('chartTemp'),
    {
        type: 'line',

        data: {
            labels: horarios,

            datasets: [
                {
                    data: Array(24).fill(temperaturaMinima),
                    borderWidth: 0,
                    pointRadius: 0
                },
                {
                    data: Array(24).fill(temperaturaMaxima),
                    borderWidth: 0,
                    pointRadius: 0,

                }
            },

            scales: {
                y: {
                    min: 12,
                    max: 26
                }
            }
        }
    }
);


// =========================================
// 5. CRIAR O GRAFICO DE UMIDADE DO AR
// =========================================

let chartAr = new Chart(
    document.getElementById('chartAr'),
    {
        type: 'line',

        data: {
            labels: horarios,

            datasets: [
                {
                    data: Array(24).fill(umidadeArMinima),
                    borderWidth: 0,
                    pointRadius: 0
                },
                {
                    data: Array(24).fill(umidadeArMaxima),
                    borderWidth: 0,
                    pointRadius: 0,
                    fill: '-1',
                    backgroundColor: 'rgba(46, 139, 92, 0.10)'
                },
                {
                    data: umidadesAr.slice(-24),
                    borderColor: verde,
                    pointBackgroundColor: criarCores(
                        umidadesAr.slice(-24),
                        umidadeArMinima,
                        umidadeArMaxima
                    ),
                    pointRadius: 3,
                    borderWidth: 2,
                    tension: 0.3
                }
            ]
        },

        options: {
            responsive: true,
            maintainAspectRatio: false,

            plugins: {
                legend: {
                    display: false
                }
            },

            scales: {
                y: {
                    min: 70,
                    max: 100
                }
            }
        }
    }
);


// =========================================
// 6. CRIAR O GRAFICO DE UMIDADE DO SUBSTRATO
// =========================================

let chartSubstrato = new Chart(
    document.getElementById('chartSubstrato'),
    {
        type: 'line',

        data: {
            labels: horarios,

            datasets: [
                {
                    data: Array(24).fill(umidadeSubstratoMinima),
                    borderWidth: 0,
                    pointRadius: 0
                },
                {
                    data: Array(24).fill(umidadeSubstratoMaxima),
                    borderWidth: 0,
                    pointRadius: 0,
                    fill: '-1',
                    backgroundColor: 'rgba(46, 139, 92, 0.10)'
                },
                {
                    data: umidadesSubstrato.slice(-24),
                    borderColor: verde,
                    pointBackgroundColor: criarCores(
                        umidadesSubstrato.slice(-24),
                        umidadeSubstratoMinima,
                        umidadeSubstratoMaxima
                    ),
                    pointRadius: 3,
                    borderWidth: 2,
                    tension: 0.3
                }
            ]
        },

        options: {
            responsive: true,
            maintainAspectRatio: false,

            plugins: {
                legend: {
                    display: false
                }
            },

            scales: {
                y: {
                    min: 50,
                    max: 90
                }
            }
        }
    }
);


// =========================================
// 7. ATUALIZAR OS GRAFICOS
// =========================================

function atualizarGraficos(rotulos, temp, ar, substrato) {

    // Atualizar temperatura
    chartTemp.data.labels = rotulos;

    chartTemp.data.datasets[0].data =
        Array(rotulos.length).fill(temperaturaMinima);

    chartTemp.data.datasets[1].data =
        Array(rotulos.length).fill(temperaturaMaxima);

    chartTemp.data.datasets[2].data = temp;

    chartTemp.data.datasets[2].pointBackgroundColor =
        criarCores(temp, temperaturaMinima, temperaturaMaxima);

    chartTemp.update();


    // Atualizar umidade do ar
    chartAr.data.labels = rotulos;

    chartAr.data.datasets[0].data =
        Array(rotulos.length).fill(umidadeArMinima);

    chartAr.data.datasets[1].data =
        Array(rotulos.length).fill(umidadeArMaxima);

    chartAr.data.datasets[2].data = ar;

    chartAr.data.datasets[2].pointBackgroundColor =
        criarCores(ar, umidadeArMinima, umidadeArMaxima);

    chartAr.update();


    // Atualizar umidade do substrato
    chartSubstrato.data.labels = rotulos;

    chartSubstrato.data.datasets[0].data =
        Array(rotulos.length).fill(umidadeSubstratoMinima);

    chartSubstrato.data.datasets[1].data =
        Array(rotulos.length).fill(umidadeSubstratoMaxima);

    chartSubstrato.data.datasets[2].data = substrato;

    chartSubstrato.data.datasets[2].pointBackgroundColor =
        criarCores(
            substrato,
            umidadeSubstratoMinima,
            umidadeSubstratoMaxima
        );

    chartSubstrato.update();
}


// =========================================
// 8. TROCAR O PERIODO DOS GRAFICOS
// =========================================

function desenhar(periodo) {

    let rotulos = [];
    let temp = [];
    let ar = [];
    let substrato = [];

    if (periodo == '24h') {

        rotulos = horarios.slice(-24);
        temp = temperaturas.slice(-24);
        ar = umidadesAr.slice(-24);
        substrato = umidadesSubstrato.slice(-24);

    } else if (periodo == '7d') {

        rotulos = gerarDias(28);
        temp = temperaturas.slice(-28);
        ar = umidadesAr.slice(-28);
        substrato = umidadesSubstrato.slice(-28);

    } else if (periodo == '30d') {

        rotulos = gerarDias(30);
        temp = temperaturas.slice(-30);
        ar = umidadesAr.slice(-30);
        substrato = umidadesSubstrato.slice(-30);

    }

    atualizarGraficos(rotulos, temp, ar, substrato);
}


// =========================================
// 9. SELETOR DE PERIODO
// =========================================

document.getElementById('periodo').addEventListener(
    'change',
    function () {
        desenhar(this.value);
    }
);


// Iniciar com as ultimas 24 horas
desenhar('24h');
