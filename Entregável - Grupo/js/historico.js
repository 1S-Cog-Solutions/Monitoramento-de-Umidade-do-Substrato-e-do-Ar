// ---------- Configuração ----------
const POR_PAGINA = 6;

const TIPOS = [
  { nome: "Temperatura",        unidade: "°C", min: 16, max: 22, base: 18,  variacao: 0.6 },
  { nome: "Umidade do Ar",      unidade: "%",  min: 80, max: 90, base: 86,  variacao: 1.5 },
  { nome: "Umidade do Substrato", unidade: "%", min: 60, max: 80, base: 62, variacao: 5 },
];

// ---------- Dados de exemplo (troque pelo fetch da sua API) ----------
function gerarRegistros() {
  const registros = [];
  const fim = new Date(2026, 9, 13, 12, 0, 0); // 13/10/2026 12:00
  let semente = 7;
  const aleatorio = () => (semente = (semente * 16807) % 2147483647) / 2147483647;

  for (let i = 0; i < 288; i++) { // 288 leituras a cada 5 min = 24 h
    const data = new Date(fim.getTime() - i * 5 * 60 * 1000);
    TIPOS.forEach((t) => {
      const valor = t.base + (aleatorio() - 0.5) * 2 * t.variacao;
      registros.push({
        data,
        camara: "Câmara 02",
        fase: "Frutificação",
        tipo: t.nome,
        unidade: t.unidade,
        valor: Math.round(valor * 10) / 10,
        min: t.min,
        max: t.max,
      });
    });
  }
  return registros; // 864 registros, do mais recente ao mais antigo
}

let registros = gerarRegistros();
let pagina = 1;
let maisRecentesPrimeiro = true;

// ---------- Utilidades ----------
const pad = (n) => String(n).padStart(2, "0");
const formatarData = (d) => `${pad(d.getDate())}/${pad(d.getMonth() + 1)}/${d.getFullYear()}`;
const formatarHora = (d) => `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
const formatarValor = (r) =>
  `${String(r.valor).replace(".", ",")}${r.unidade === "°C" ? "°C" : "%"}`;
const dentroDaFaixa = (r) => r.valor >= r.min && r.valor <= r.max;

function ordenados() {
  const lista = [...registros].sort((a, b) => b.data - a.data);
  return maisRecentesPrimeiro ? lista : lista.reverse();
}

// ---------- Renderização ----------
const corpo = document.getElementById("corpo");
const contagem = document.getElementById("contagem");
const paginacao = document.getElementById("paginacao");

function renderTabela() {
  const lista = ordenados();
  const total = lista.length;
  const totalPaginas = Math.ceil(total / POR_PAGINA);
  pagina = Math.min(Math.max(pagina, 1), totalPaginas);

  const inicio = (pagina - 1) * POR_PAGINA;
  const fatia = lista.slice(inicio, inicio + POR_PAGINA);

  corpo.innerHTML = fatia
    .map((r) => {
      const ok = dentroDaFaixa(r);
      return `
        <tr>
          <td class="mono data">${formatarData(r.data)}<span class="hora">${formatarHora(r.data)}</span></td>
          <td class="suave">${r.camara}</td>
          <td class="suave">${r.fase}</td>
          <td>${r.tipo}</td>
          <td class="mono ${ok ? "" : "fora"}">${formatarValor(r)}</td>
          <td class="mono suave">${r.min}-${r.max}${r.unidade === "°C" ? "°C" : "%"}</td>
          <td><span class="badge ${ok ? "" : "fora"}">${ok ? "Dentro da faixa" : "Fora da faixa"}</span></td>
        </tr>`;
    })
    .join("");

  contagem.textContent = `Exibindo ${inicio + 1}-${inicio + fatia.length} de ${total} registros`;
  renderPaginacao(totalPaginas);
}

// Gera a lista de páginas com reticências: 1 2 3 … 144
function paginasVisiveis(atual, total) {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
  if (atual <= 3) return [1, 2, 3, "…", total];
  if (atual >= total - 2) return [1, "…", total - 2, total - 1, total];
  return [1, "…", atual - 1, atual, atual + 1, "…", total];
}

function renderPaginacao(totalPaginas) {
  const botoes = [`<button class="nav" data-ir="${pagina - 1}" ${pagina === 1 ? "disabled" : ""}>Anterior</button>`];

  paginasVisiveis(pagina, totalPaginas).forEach((p) => {
    botoes.push(
      p === "…"
        ? `<span class="reticencias">…</span>`
        : `<button data-ir="${p}" class="${p === pagina ? "atual" : ""}" ${p === pagina ? 'aria-current="page"' : ""}>${p}</button>`
    );
  });

  botoes.push(`<button class="nav" data-ir="${pagina + 1}" ${pagina === totalPaginas ? "disabled" : ""}>Próxima</button>`);
  paginacao.innerHTML = botoes.join("");
}

function renderSubtitulo() {
  const datas = registros.map((r) => r.data);
  const inicio = new Date(Math.min(...datas));
  const fim = new Date(Math.max(...datas));
  const meses = ["janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro"];
  document.getElementById("subtitulo").textContent =
    `${registros[0].camara} · ${inicio.getDate()} e ${fim.getDate()} de ${meses[fim.getMonth()]} de ${fim.getFullYear()} · ${registros.length} registros no período`;
}

// ---------- Eventos ----------
paginacao.addEventListener("click", (e) => {
  const btn = e.target.closest("button[data-ir]");
  if (!btn || btn.disabled) return;
  pagina = Number(btn.dataset.ir);
  renderTabela();
});

document.getElementById("btn-ordem").addEventListener("click", () => {
  maisRecentesPrimeiro = !maisRecentesPrimeiro;
  document.getElementById("rotulo-ordem").textContent = maisRecentesPrimeiro
    ? "Mais recentes primeiro"
    : "Mais antigos primeiro";
  document.getElementById("seta-ordem").textContent = maisRecentesPrimeiro ? "↓" : "↑";
  pagina = 1;
  renderTabela();
});

renderSubtitulo();
renderTabela();