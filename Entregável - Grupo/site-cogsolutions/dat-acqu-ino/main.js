// importa os bibliotecas necessários
const serialport = require('serialport');
const express = require('express');
const mysql = require('mysql2');

// constantes para configurações
const SERIAL_BAUD_RATE = 9600;
const SERVIDOR_PORTA = 3300;

// habilita ou desabilita a inserção de dados no banco de dados
const HABILITAR_OPERACAO_INSERIR = true;

// função para comunicação serial
const serial = async (
    valoresSensorUmidadeAr,
    valoresSensorUmidadeSolo,
    valoresSensorTemperatura

) => {

    // conexão com o banco de dados MySQL
    let poolBancoDados = mysql.createPool(
        {
            host: 'localhost',
            user: 'sensor',
            password: 'vrdwevjf1234@#$%',
            database: 'cog_solutions',
            port: 3306
        }
    ).promise();

    
   


    // lista as portas seriais disponíveis e procura pelo Arduino
    const portas = await serialport.SerialPort.list();
    const portaArduino = portas.find((porta) => porta.vendorId == 2341 && porta.productId == 43);
    if (!portaArduino) {
        throw new Error('O arduino não foi encontrado em nenhuma porta serial');
    }

    // configura a porta serial com o baud rate especificado
    const arduino = new serialport.SerialPort(
        {
            path: portaArduino.path,
            baudRate: SERIAL_BAUD_RATE
        }
    );

    // evento quando a porta serial é aberta
    arduino.on('open', () => {
        console.log(`A leitura do arduino foi iniciada na porta ${portaArduino.path} utilizando Baud Rate de ${SERIAL_BAUD_RATE}`);
    });

    // processa os dados recebidos do Arduino
    arduino.pipe(new serialport.ReadlineParser({ delimiter: '\r\n' })).on('data', async (data) => {
        console.log(data);
        const valores = data.split(';');
        const sensorUmidadeAr = parseFloat(valores[0]);
        const sensorUmidadeSolo = parseInt(valores[1]);
        const sensorTemperatura = parseFloat(valores[2]);

        // armazena os valores dos sensores nos arrays correspondentes
        valoresSensorUmidadeAr.push(sensorUmidadeAr);
        valoresSensorUmidadeSolo.push(sensorUmidadeSolo);
        valoresSensorTemperatura.push(sensorTemperatura);

        // insere os dados no banco de dados (se habilitado)
        if (HABILITAR_OPERACAO_INSERIR) {

            // este insert irá inserir os dados na tabela "medida"
            await poolBancoDados.execute(
                'INSERT INTO leitura (  umidadeAr, umidadeSolo, temperatura, fk_sensor ) VALUES (?, ?, ?, ?)',
                [ sensorUmidadeAr, sensorUmidadeSolo, sensorTemperatura, 1 ]
            );
            console.log("valores inseridos no banco: ", sensorUmidadeAr + ", " + sensorUmidadeSolo + ", " + sensorTemperatura );

        }

    });

    // evento para lidar com erros na comunicação serial
    arduino.on('error', (mensagem) => {
        console.error(`Erro no arduino (Mensagem: ${mensagem}`)
    });
}

// função para criar e configurar o servidor web
const servidor = (
    valoresSensorUmidadeAr,
    valoresSensorUmidadeSolo,
    valoresSensorTemperatura
) => {
    const app = express();

    // configurações de requisição e resposta
    app.use((request, response, next) => {
        response.header('Access-Control-Allow-Origin', '*');
        response.header('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept');
        next();
    });

    // inicia o servidor na porta especificada
    app.listen(SERVIDOR_PORTA, () => {
        console.log(`API executada com sucesso na porta ${SERVIDOR_PORTA}`);
    });

    // define os endpoints da API para cada tipo de sensor
    app.get('/sensores/UmidadeAr', (_, response) => {
        return response.json(valoresSensorUmidadeAr);
    });
    app.get('/sensores/UmidadeSolo', (_, response) => {
        return response.json(valoresSensorUmidadeSolo);
    });

     app.get('/sensores/Temperatura', (_, response) => {
        return response.json(valoresSensorTemperatura);
    });
}

// função principal assíncrona para iniciar a comunicação serial e o servidor web
(async () => {
    // arrays para armazenar os valores dos sensores
    const valoresSensorUmidadeAr = [];
    const valoresSensorUmidadeSolo = [];
    const valoresSensorTemperatura = [];

    // inicia a comunicação serial
    await serial(
        valoresSensorUmidadeAr,
        valoresSensorUmidadeSolo,
        valoresSensorTemperatura
    );

    // inicia o servidor web
    servidor(
        valoresSensorUmidadeAr,
        valoresSensorUmidadeSolo,
        valoresSensorTemperatura
    );
})();