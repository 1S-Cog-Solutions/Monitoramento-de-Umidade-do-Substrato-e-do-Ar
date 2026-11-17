// Telas de projeção (TV, telão): o painel é desenhado para 1366x768
// e aumenta de tamanho proporcionalmente em telas maiores.
// Em telas pequenas (celular) não faz nada.
function ajustarTamanho() {
    let largura = window.innerWidth;
    let altura = window.innerHeight;
    let escala = Math.min(largura / 1366, altura / 768);

    if (largura < 1101 || escala < 1.1) {
        escala = 1;
    }

    if (escala > 2.2) {
        escala = 2.2;
    }

    document.documentElement.style.zoom = escala;

    // altura da janela já descontando o aumento (substitui o 100vh do CSS)
    document.documentElement.style.setProperty('--vh', (altura / escala) + 'px');
}

ajustarTamanho();
window.addEventListener('resize', ajustarTamanho);