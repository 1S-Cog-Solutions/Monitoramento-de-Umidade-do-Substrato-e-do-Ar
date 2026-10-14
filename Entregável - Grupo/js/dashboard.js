const graficoDeBarras = document.querySelector("#barChart");
const graficoDeLinhas = document.querySelector("#lineChart");

Chart.defaults.color = '#fff';

  new Chart(graficoDeBarras, {
    type: 'line',
    data: {
      labels: ['11:35', '11:40', '11:45', '11:50', '11:55', '12:00'],
      datasets: [{
        label: 'Umidade do Solo',
        data: [57.5, 60.7, 63.4, 64.6, 62.3, 59.9],
        borderWidth: 1,
        backgroundColor: '#22dbdb',
        borderColor: '#22dbdb',
      },
    ]
    },
    options: {
      scales: {
        y: {
          beginAtZero: true,
          max: 100
        }
      }
    }
  });

  new Chart(graficoDeLinhas, {
    type: 'line',
    data: {
      labels: ['11:35', '11:40', '11:45', '11:50', '11:55', '12:00'],
      datasets: [{
        label: 'Temperatura',
        data: [18.2, 18.4, 18.1, 17.8, 17.7, 17.4],
        borderWidth: 1,
        backgroundColor: '#ec7d33',
        borderColor: '#ec7d33',
      },
      {
        label: 'Umidade do Ar',
        data: [86.6, 85.2, 86.6, 86.8, 86.7, 87.3],
        borderWidth: 1,
        backgroundColor: '#357cce',
        borderColor: '#357cce',

      }
    ]
    },
    options: {
      scales: {
        y: {
          beginAtZero: true,
        }
      }
    }
  });