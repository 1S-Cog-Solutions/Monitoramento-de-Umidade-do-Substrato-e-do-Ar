// sessão
function validarSessao() {
    let email = sessionStorage.EMAIL_USUARIO;
    let nome = sessionStorage.NOME_USUARIO;
    let empresa = sessionStorage.EMPRESA_USUARIO;

    if (email != null && nome != null) {
        // textContent mostra o nome como texto puro (mais seguro que innerHTML)
        b_usuario.textContent = nome;

        if (document.getElementById("b_empresa") != null) {
            b_empresa.textContent = empresa || "";
        }
    } else {
        window.location = "../login.html";
    }
}

function limparSessao() {
    sessionStorage.clear();
    window.location = "../login.html";
}