<div align="center">

<img width="1836" height="470" alt="logo-cog-solutions" src="https://github.com/user-attachments/assets/e8247644-74bb-43cc-b863-c06f8d084d40" />

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:F06543,100:1C1C1C&height=150&section=header&text=Monitoramento%20Champignon%20Paris%20%F0%9F%8D%84&fontSize=32&fontColor=ffffff&animation=fadeIn&fontAlignY=40" alt="Monitoramento Champignon Paris" width="100%" />

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=20&pause=1000&color=F06543&center=true&vCenter=true&width=600&lines=Projeto+de+Pesquisa+e+Inova%C3%A7%C3%A3o+%E2%80%94+SPTech;Arduino+%2B+sensores+de+umidade+e+temperatura+%F0%9F%8C%A1%EF%B8%8F;Menos+perda%2C+mais+controle+no+cultivo+%F0%9F%8D%84" alt="Typing SVG" />

**Monitoramento de Umidade do Substrato, do Ar e de Temperatura em Ambientes de Cultivo de Champignon Paris**

[![Status](https://img.shields.io/badge/status-em%20desenvolvimento-F06543)](#-status-do-projeto)
[![Curso](https://img.shields.io/badge/SPTech-ADS%20%7C%201ADSA-1C1C1C)](#)
[![Licença](https://img.shields.io/badge/licen%C3%A7a-acad%C3%AAmico-F06543)](#)

</div>

<br>

## 🍄 Sobre o projeto

O **Agaricus bisporus** (champignon de Paris) é o cogumelo mais cultivado no Brasil, mas é também um dos mais sensíveis: passa por fases distintas de cultivo — compostagem, pasteurização, incubação e frutificação — cada uma com sua própria faixa ideal de temperatura e umidade.

Hoje, o controle manual, baseado na experiência do produtor, torna difícil identificar **qual variável causou uma perda** e **por quanto tempo** a condição ficou fora do ideal. Isso gera perdas recorrentes de **15% a 30% do lote** por doenças, ressecamento ou falha ambiental — um problema especialmente relevante para produtores de **médio e grande porte**, que operam várias câmaras de cultivo ao mesmo tempo.

Este projeto propõe um **sistema de monitoramento** (não de automação) com sensores de umidade do substrato, umidade do ar e temperatura conectados a um Arduino, com coleta periódica dos dados, registro em banco de dados e visualização em um dashboard com alertas — para que o produtor identifique desvios a tempo e tome a decisão.

<br>

## 🔄 Como funciona

```mermaid
flowchart LR
    A[🌡️ Sensores<br/>Umidade do ar · Umidade do solo · Temperatura] --> B[🔌 Arduino]
    B --> C[⚙️ API]
    C --> D[(🗄️ Banco de Dados)]
    D --> E[📊 Dashboard]
    E --> F{Dentro da faixa ideal?}
    F -- Não --> G[🔔 Alerta ao produtor]
    F -- Sim --> H[✅ Monitoramento contínuo]
    G --> I[🧑‍🌾 Tomada de decisão do produtor]
```

<br>

## ✨ O que o sistema faz

- 🌡️ **Sensoriamento contínuo** — leitura periódica (a cada 5 min) de umidade do ar, do substrato e de temperatura.
- 🗄️ **Registro histórico** — todas as leituras salvas em banco de dados, por câmara e por lote.
- 📊 **Dashboard** — visualização em tempo real e histórico das condições de cultivo.
- 🔔 **Alertas automáticos** — aviso ao produtor sempre que uma leitura sai da faixa ideal da fase atual.
- 🧑‍🌾 **Apoio à decisão, não automação** — quem decide agir (irrigar, ventilar) continua sendo o produtor.

> [!NOTE]
> O sistema **monitora e alerta**, não soluciona a perda sozinho — a decisão final é sempre do produtor. Automação de ajustes (irrigação/ventilação), app mobile e integração com ERP estão fora do escopo deste protótipo.

<br>

## 🔗 Links do projeto

| | |
|---|---|
| 📄 Documentação do projeto | [Documento em Docs](https://bandteccom-my.sharepoint.com/:w:/g/personal/enzo_bento_sptech_school/IQAN4ZuB5iQDT5Slp7y-Jzm6AeEP08f_hE3fA4Waf_6eVE8?e=tI92Vh) |
| 🎨 Slide de apresentação | [Canva](https://canva.link/lzc4q4bkl9rcixh) |
| 🗂️ Organização do projeto | [Trello](https://trello.com/b/cUBY6c0U/cog-solutions) |
| 🔧 Montagem do Arduino | [Tinkercad](https://www.tinkercad.com/things/l5auWBOuWrV/editel?returnTo=%2Fdashboard&sharecode=yHCSTdkNJi3PoDbMhmVLzr81HFQQGqiRWNctGYehJwU) |
| 🖼️ Prototipagem do site institucional | [Figma](https://www.figma.com/design/lOQJ3ouqiGeTjRjebh4Cyk/Untitled?node-id=0-1&t=8Z2B4NwLQM1jTaju-1) |
| 📋 Backlog | [Backlog Excel](https://bandteccom-my.sharepoint.com/:x:/g/personal/enzo_bento_sptech_school/IQDjvXNZblUtQaP1piUuVKDFATaHyE8DDdHf_Cz7kLwmhhM?e=BUfgIx) |

<br>

## 🧪 Tecnologias

![Arduino](https://img.shields.io/badge/Arduino-Uno%20R3-F06543?style=flat)
![DHT11](https://img.shields.io/badge/Sensor-DHT11-1C1C1C?style=flat)
![Sensor Solo](https://img.shields.io/badge/Sensor-Umidade%20do%20Solo%20Capacitivo-F06543?style=flat)
![MySQL](https://img.shields.io/badge/Banco%20de%20Dados-MySQL-1C1C1C?style=flat)
![Linux](https://img.shields.io/badge/VM-Linux-F06543?style=flat)

<br>

## 🏆 Contribuidores do projeto (Grupo 5 — Sprint 2)

- Christian Miranda Correia
- Enzo Fuchs Bento
- Mariana de Oliveira Soares
- Paulo Henrique de Souza
- Victor dos Passos Soares de Souza
- Vitor Alexandre Osuna Arevalo

<br>

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1C1C1C,100:F06543&height=110&section=footer" alt="" width="100%" />
</div>
