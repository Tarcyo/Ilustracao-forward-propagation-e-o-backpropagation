# 🧠 Rede Neural Interativa

Aplicativo em **Flutter e Dart** para demonstrar o **forward propagation**, o **backpropagation** e a atualização dos parâmetros de uma rede neural.

**Autor:** Tarcyo Guilherme Maia Borges  
**Disciplina:** Introdução a Redes Neurais Artificiais — INF/UFG  
**Professor:** Thierson Couto Rosa

## 🎥 Apresentação

**[▶️ Assistir ao vídeo da demonstração](https://drive.google.com/file/d/1sSj_5TR1N05C82u4JYaz0i_JZA2UJRuM/view)**

O vídeo apresenta o primeiro ciclo completo. O aplicativo permite explorar dois ciclos.

## 🎯 O trabalho

A tarefa é uma **regressão do consumo de energia** de dois aparelhos idealizados. As entradas são suas horas de uso, e as potências constantes são **0,2 kW** e **0,4 kW**.

O alvo simulado é calculado por **`y = 0,2 × x₁ + 0,4 × x₂`**. Essa fórmula fornece a referência; a previsão é calculada pela rede. Para **1 h** do aparelho A e **2 h** do aparelho B, o alvo é **1 kWh**.

O objetivo é entender os cálculos. Os dois ciclos utilizam a mesma amostra, sem avaliar generalização.

## ⚙️ Implementação

| Elemento | Configuração |
|---|---|
| Arquitetura | **2 → 3 → 3 → 1**, com duas camadas ocultas |
| Parâmetros | **18 pesos e 7 vieses** |
| Ativação | **ReLU** nas camadas ocultas e na saída |
| Taxa de aprendizado | **0,1** |
| Demonstração | **2 ciclos e 50 etapas visuais** |
| Perda | **NLL gaussiana**, com desvio padrão fixo de **1 kWh**, sem a constante independente dos parâmetros |

Os cálculos são escritos explicitamente em Dart, com operações básicas e `dart:math`, **sem diferenciação automática**. A interface apresenta somatórios, ativações, perda, deltas, gradientes e propostas de atualização.

Primeiro são calculados todos os gradientes; depois, os pesos e vieses são atualizados conjuntamente.

## 🖱️ Como usar

1. Clique em **“Usar exemplo: A = 1 h, B = 2 h”** e depois em **“Iniciar demonstração”**.
2. Avance ou volte pelos botões ou pelas teclas **← / →** para inspecionar as etapas.
3. Utilize **“Ver pesos e vieses desta ida”** para consultar os parâmetros e continue até a segunda ida para observar o ajuste.

O alvo é calculado automaticamente. A navegação revisita as etapas registradas, sem reaplicar atualizações.

## 🚀 Executar o aplicativo pronto

**Requisitos:** Python 3.7 ou superior e um navegador. Essa opção dispensa Flutter e instalação de pacotes via `pip`.

Baixe e extraia o repositório. No terminal, a partir da pasta principal:

```powershell
cd "builld web para executar"
python servidor.py --port 8080
```

Acesse **[http://127.0.0.1:8080/](http://127.0.0.1:8080/)**. Mantenha o terminal aberto e use **Ctrl+C** para encerrar.

Se necessário, substitua `python` por `py` no Windows ou por `python3` no Linux/macOS. Mantenha `servidor.py` junto ao `index.html` e às subpastas do build. O Python fornece o servidor local; os cálculos são executados pelo aplicativo no navegador.

## 🛠️ Código-fonte

A implementação está em **[lib/main.dart](lib/main.dart)**. Para executar pelo fonte, utilize o Flutter SDK com Dart compatível com **`>=3.10.3 <4.0.0`** e o Chrome:

```bash
flutter pub get
flutter run -d chrome
```

Para recompilar, execute `flutter build web --release`. Os arquivos são gerados em **`build/web`**; atualize a pasta **`builld web para executar`** após modificar o código.

## ✅ Conferência do exemplo

Para entradas **1** e **2**, com alvo **1**:

| Passagem | Previsão | Perda E |
|---|---:|---:|
| Primeira ida | **0,405** | **0,1770125** |
| Segunda ida, após a primeira atualização | **≈ 0,550110** | **≈ 0,101201** |

**A previsão e a perda exibidas ao concluir um ciclo pertencem à ida anterior à atualização daquele ciclo.**
