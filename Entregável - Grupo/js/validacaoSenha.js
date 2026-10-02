function validarSenha() {
    let senha = ipt_senha.value;
    let divRegrasSenhas = document.querySelector('#regras-senhas');

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
}