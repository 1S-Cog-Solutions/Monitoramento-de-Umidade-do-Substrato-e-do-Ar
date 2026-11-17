// Página de Alertas: filtros, marcar como resolvido e contadores.
// Os alertas aqui são exemplos fixos no HTML. Quando existir a tabela de alertas
// no banco, é só montar os <article class="alerta"> a partir dos dados da API.

let statusAtual = 'todos';

function aplicarFiltros() {
    let camara = sel_camara.value;
    let severidade = sel_severidade.value;
    let alertas = document.querySelectorAll('.alerta');
    let visiveis = 0;

    for (let i = 0; i < alertas.length; i++) {
        let alerta = alertas[i];
        let passaStatus = statusAtual == 'todos' || alerta.dataset.status == statusAtual;
        let passaCamara = camara == 'todas' || alerta.dataset.camara == camara;
        let passaSeveridade = severidade == 'todas' || alerta.dataset.severidade == severidade;
        let mostrar = passaStatus && passaCamara && passaSeveridade;

        alerta.hidden = !mostrar;

        if (mostrar) {
            visiveis++;
        }
    }

    sem_alertas.hidden = visiveis > 0;
}

function trocarAba(botao, status) {
    statusAtual = status;

    let abas = document.querySelectorAll('.aba');
    for (let i = 0; i < abas.length; i++) {
        abas[i].classList.remove('ativa');
    }
    botao.classList.add('ativa');

    aplicarFiltros();
}

// Conta quantos alertas existem com o filtro informado (ex.: '[data-status="ativo"]')
function contar(filtro) {
    return document.querySelectorAll('.alerta' + filtro).length;
}

function atualizarContagens() {
    cont_todos.textContent = contar('');
    cont_ativos.textContent = contar('[data-status="ativo"]');
    cont_resolvidos.textContent = contar('[data-status="resolvido"]');

    kpi_ativos.textContent = contar('[data-status="ativo"]');
    kpi_criticos.textContent = contar('[data-status="ativo"][data-severidade="critico"]');
    kpi_atencao.textContent = contar('[data-status="ativo"][data-severidade="atencao"]');
    kpi_resolvidos.textContent = contar('[data-status="resolvido"][data-dia="hoje"]');
}

function resolver(botao) {
    let alerta = botao.closest('.alerta');
    let status = alerta.querySelector('.status');

    alerta.dataset.status = 'resolvido';
    alerta.dataset.dia = 'hoje';
    alerta.classList.add('resolvido');

    status.className = 'status resolvido';
    status.textContent = 'Resolvido';

    atualizarContagens();
    aplicarFiltros();
}

function resolverTodos() {
    let botoes = document.querySelectorAll('.alerta[data-status="ativo"] .btn-resolver');
    for (let i = 0; i < botoes.length; i++) {
        resolver(botoes[i]);
    }
}
