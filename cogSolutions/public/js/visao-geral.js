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