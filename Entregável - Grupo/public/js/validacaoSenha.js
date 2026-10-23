function validarSenha() {
    let senha = ipt_senha.value;
    let divRegrasSenhas = document.querySelector('#regras');

    let estiloMaiuscula = "";
    let estiloMinuscula = "";
    let estiloNumero = "";
    let estiloCaractereEspecial = "";
    let numeros = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    let temNumero = false;
    let contador = 0;
    let contadorCaractere = 0;
    let caracteresEspeciais = ['@', '!', '#', '$', '%', '&', '*', '(', ')', '/', '?', ',', '.', '[', ']', '{', '}', '+', '=', '-', '_']
    let temCaracterEspecial = false;
    


    while (contador < numeros.length) {
        if (senha.includes(numeros[contador])) {
            temNumero = true;

        }
        contador ++;
    }

    while (contadorCaractere < caracteresEspeciais.length) {
        if (senha.includes(caracteresEspeciais[contadorCaractere])) {
            temCaracterEspecial = true;
        }
        contadorCaractere ++;
    }

    if (senha != senha.toLowerCase()) {
        estiloMaiuscula = "color: #22b122;";
    }

    if (senha != senha.toUpperCase()) {
        estiloMinuscula = "color: #22b122;";
    }

    if (temNumero) {
        estiloNumero = "color: #22b122;";
    }

    if (temCaracterEspecial) {
        estiloCaractereEspecial = "color: #22b122;"
    }

    divRegrasSenhas.innerHTML = `
        <p style="${estiloMaiuscula}">Pelo menos uma letra maiúscula (A-Z).</p> 
        <p style="${estiloMinuscula}">Pelo menos uma letra minúscula (a-z).</p>
        <p style="${estiloNumero}">Pelo menos um número (0-9).</p>
        <p style="${estiloCaractereEspecial}">Pelo menos um caractere especial.</p>
    `;

    if (senha === '') {
        divRegrasSenhas.innerHTML = ``;
    }
}

function verificarSenhas() {
    let senha = ipt_senha.value;
    let confirmarSenha = ipt_confirmar_senha.value;

    let divRegrasSenhas = document.querySelector('#validar');

    if (senha === confirmarSenha) {
        divRegrasSenhas.innerHTML = `
        <p style="color: #22b122">As senhas são iguais!</p>`
    } 
    
    if (senha !== confirmarSenha || senha == '' || confirmarSenha == '') {
        divRegrasSenhas.innerHTML = `
        <p style="color: #e01111">As senhas precisam ser iguais!</p>`
    }

    
}

function senhaCumpreRegras(senha) {
    let numeros = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    let caracteresEspeciais = ['@', '!', '#', '$', '%', '&', '*', '(', ')', '/', '?', ',', '.', '[', ']', '{', '}', '+', '=', '-', '_'];
    let temNumero = false;
    let temCaracterEspecial = false;
    let contador = 0;

    while (contador < numeros.length) {
        if (senha.includes(numeros[contador])) {
            temNumero = true;
        }
        contador++;
    }

    contador = 0;
    while (contador < caracteresEspeciais.length) {
        if (senha.includes(caracteresEspeciais[contador])) {
            temCaracterEspecial = true;
        }
        contador++;
    }

    let temMaiuscula = senha != senha.toLowerCase();
    let temMinuscula = senha != senha.toUpperCase();

    return temMaiuscula && temMinuscula && temNumero && temCaracterEspecial;
}

function cadastrar() {
    let nome = ipt_nome.value.trim();
    let email = ipt_email.value.trim();
    let senha = ipt_senha.value;
    let confirmarSenha = ipt_confirmar_senha.value;
    let chave = ipt_chave.value.trim();

    if (nome == '' || email == '' || senha == '' || confirmarSenha == '' || chave == '') {
        alert('Preencha todos os campos.');
    } else if (!email.includes('@') || !email.includes('.')) {
        alert('Digite um e-mail válido.');
    } else if (!senhaCumpreRegras(senha)) {
        alert('A senha precisa cumprir todas as regras indicadas.');
    } else if (senha !== confirmarSenha) {
        alert('As senhas precisam ser iguais.');
    } else {
        alert('Conta criada com sucesso!');
        window.location.href = 'dashboard/dashboard.html';
    }
}
