Chart.defaults.color = "#c4c4c9";
Chart.defaults.borderColor = "#2c2d31";
Chart.defaults.font.family = "'Nunito', Arial, sans-serif";

// Cores da marca: laranja e branco sobre preto
const corTemp = "#ee6340";
const corUmid = "#ffffff";

const horarios    = ["12:00", "13:00", "14:00", "15:00", "16:00", "17:00"];
const temperatura = [30, 29, 28, 25, 22, 23];
const umidade     = [80, 82, 80, 85, 80, 83];

const meses       = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho"];
const tempMedia   = [22, 24, 27, 23, 20, 18];
const umidMedia   = [90, 89, 93, 87, 88, 82];

new Chart(document.getElementById("graficoLinhas"), {
  type: "line",
  data: {
    labels: horarios,
    datasets: [
      {
        label: "Temperatura (°C)",
        data: temperatura,
        borderColor: corTemp,
        backgroundColor: corTemp,
        tension: 0.3
      },
      {
        label: "Umidade (%)",
        data: umidade,
        borderColor: corUmid,
        backgroundColor: corUmid,
        tension: 0.3
      }
    ]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: { title: { display: true, text: "Horário" } },
      y: { beginAtZero: true }
    }
  }
});

new Chart(document.getElementById("graficoBarras"), {
  type: "bar",
  data: {
    labels: meses,
    datasets: [
      {
        label: "Temperatura média (°C)",
        data: tempMedia,
        backgroundColor: corTemp,
        borderRadius: 4
      },
      {
        label: "Umidade média (%)",
        data: umidMedia,
        backgroundColor: corUmid,
        borderRadius: 4
      }
    ]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: { title: { display: true, text: "Mês" } },
      y: { beginAtZero: true }
    }
  }
});