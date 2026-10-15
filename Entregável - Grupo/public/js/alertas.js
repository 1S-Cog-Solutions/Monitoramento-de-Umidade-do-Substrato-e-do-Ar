// Página de Alertas: filtros, marcar como resolvido e contadores.
// Os alertas aqui são exemplos fixos no HTML. Quando existir a tabela de alertas
// no banco, é só montar os <article class="alerta"> a partir dos dados da API.

var statusAtual = 'todos';

function aplicarFiltros() {
    var camara = document.getElementById('sel_camara').value;
    var severidade = document.getElementById('sel_severidade').value;
    var alertas = document.querySelectorAll('.alerta');
    var visiveis = 0;

    alertas.forEach(function (alerta) {
        var passaStatus = statusAtual === 'todos' || alerta.dataset.status === statusAtual;
        var passaCamara = camara === 'todas' || alerta.dataset.camara === camara;
        var passaSeveridade = severidade === 'todas' || alerta.dataset.severidade === severidade;
        var mostrar = passaStatus && passaCamara && passaSeveridade;

        alerta.hidden = !mostrar;

        if (mostrar) {
            visiveis++;
        }
    });

    document.getElementById('sem_alertas').hidden = visiveis > 0;
}

function trocarAba(botao, status) {
    statusAtual = status;

    document.querySelectorAll('.aba').forEach(function (aba) {
        aba.classList.remove('ativa');
    });
    botao.classList.add('ativa');

    aplicarFiltros();
}

function atualizarContagens() {
    var total = document.querySelectorAll('.alerta').length;
    var ativos = document.querySelectorAll('.alerta[data-status="ativo"]').length;
    var resolvidos = document.querySelectorAll('.alerta[data-status="resolvido"]').length;

    document.getElementById('cont_todos').textContent = total;
    document.getElementById('cont_ativos').textContent = ativos;
    document.getElementById('cont_resolvidos').textContent = resolvidos;

    document.getElementById('kpi_ativos').textContent = ativos;
    document.getElementById('kpi_criticos').textContent =
        document.querySelectorAll('.alerta[data-status="ativo"][data-severidade="critico"]').length;
    document.getElementById('kpi_atencao').textContent =
        document.querySelectorAll('.alerta[data-status="ativo"][data-severidade="atencao"]').length;
    document.getElementById('kpi_resolvidos').textContent =
        document.querySelectorAll('.alerta[data-status="resolvido"][data-dia="hoje"]').length;
}

function resolver(botao) {
    var alerta = botao.closest('.alerta');
    var status = alerta.querySelector('.status');

    alerta.dataset.status = 'resolvido';
    alerta.dataset.dia = 'hoje';
    alerta.classList.add('resolvido');

    status.className = 'status resolvido';
    status.textContent = 'Resolvido';

    atualizarContagens();
    aplicarFiltros();
}

function resolverTodos() {
    document.querySelectorAll('.alerta[data-status="ativo"] .btn-resolver').forEach(function (botao) {
        resolver(botao);
    });
}