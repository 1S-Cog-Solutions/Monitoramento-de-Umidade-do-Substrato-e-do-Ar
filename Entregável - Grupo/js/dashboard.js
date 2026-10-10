const graficoDeBarras = document.querySelector("#barChart");
const graficoDeLinhas = document.querySelector("#lineChart");

Chart.defaults.color = '#fff';

  new Chart(graficoDeBarras, {
    type: 'line',
    data: {
      labels: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho'],
      datasets: [{
        label: 'Umidade do Solo',
        data: [22, 24, 27, 23, 20, 18],
        borderWidth: 1,
        backgroundColor: '#22dbdb',
        borderColor: '#22dbdb',
      },
    ]
    },
    options: {
      scales: {
        y: {
          beginAtZero: true
        }
      }
    }
  });

  new Chart(graficoDeLinhas, {
    type: 'line',
    data: {
      labels: ['12:00:01', '12:00:03', '12:00:05', '12:00:07', '12:00:09', '12:00:11'],
      datasets: [{
        label: 'Temperatura',
        data: [30, 29, 28, 25, 22, 23],
        borderWidth: 1,
        backgroundColor: '#ec7d33',
        borderColor: '#ec7d33',
      },
      {
        label: 'Umidade do Ar',
        data: [80, 82, 80, 85, 80, 83],
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