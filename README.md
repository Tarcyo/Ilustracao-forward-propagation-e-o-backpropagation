# 🧠 Rede Neural Interativa

### Ilustração de forward propagation e backpropagation

Aplicativo didático desenvolvido em **Flutter e Dart** para acompanhar os cálculos de uma rede neural: das entradas à previsão, da construção da perda aos gradientes e à atualização dos parâmetros.

A demonstração utiliza uma tarefa de **regressão do consumo de energia** com dados simulados. A interface apresenta o grafo da rede, destaca os neurônios envolvidos e exibe fórmulas, substituições numéricas e resultados em cada etapa.

| Identificação | Informação |
|---|---|
| 👨‍💻 Autor | **Tarcyo Guilherme Maia Borges** |
| 📚 Disciplina | Introdução a Redes Neurais Artificiais |
| 👨‍🏫 Professor | Thierson Couto Rosa |
| 🏛️ Instituição | Instituto de Informática — Universidade Federal de Goiás, Câmpus Samambaia |
| 🧩 Arquitetura | **2 entradas → 3 neurônios → 3 neurônios → 1 saída** |
| 🔢 Parâmetros | **18 pesos e 7 vieses** |
| 🎯 Perda | NLL gaussiana com desvio padrão fixo, retirando a constante independente dos parâmetros |

> **Para executar rapidamente:** utilize a pasta **`build web para executar`**. Basta ter Python 3 e um navegador; essa opção dispensa a instalação do Flutter e de pacotes via `pip`.

## 🧭 Navegação

- [Objetivo didático e relação com a atividade](#objetivo)
- [Executar o aplicativo já compilado](#executar-build)
- [Como explorar a demonstração](#como-usar)
- [Tarefa de regressão e arquitetura](#rede)
- [Cálculos implementados](#calculos)
- [Resultados do exemplo](#resultados)
- [Organização do projeto e do código](#estrutura)
- [Executar e recompilar com Flutter](#executar-flutter)
- [Dúvidas de execução](#duvidas)
- [Referências técnicas](#referencias)

<a id="objetivo"></a>
## 🎓 Objetivo didático e relação com a atividade

O objetivo é tornar visível **como cada valor da rede é obtido** e como a regra da cadeia conecta a perda aos pesos e aos vieses.

O aplicativo permite inspecionar:

1. A entrada de cada neurônio e o peso de cada conexão.
2. A soma ponderada, a adição do viés e a aplicação da ReLU.
3. A previsão e a construção da perda por máxima verossimilhança.
4. As derivadas da perda e os deltas das camadas.
5. Os gradientes dos pesos e dos vieses.
6. As propostas de atualização e sua aplicação conjunta.
7. Uma segunda passagem com os parâmetros atualizados no primeiro ciclo.

| Requisito da atividade | Implementação no projeto |
|---|---|
| Rede pequena com pelo menos duas camadas escondidas | Duas camadas ocultas com três neurônios cada |
| Explicitar a tarefa da rede | Regressão do consumo de dois aparelhos idealizados |
| Apresentar valores e cálculos passo a passo | 50 etapas registradas, com fórmulas e resultados |
| Preferir uma perda construída por máxima verossimilhança | NLL de uma normal com média dada pela rede e desvio padrão fixo |
| Explicitar os cálculos da ida e das derivadas | Operações e laços escritos em Dart, com aplicação explícita da regra da cadeia |

**O foco é a compreensão do algoritmo.** São realizados dois ciclos sobre a mesma amostra. Esse experimento ilustra os cálculos e o ajuste dos parâmetros; não mede generalização nem demonstra convergência ou obtenção do máximo de verossimilhança.

<a id="executar-build"></a>
## 🚀 Executar o aplicativo já compilado

### 1. Obter os arquivos

Baixe e extraia o repositório ou faça o clone com Git:

```bash
git clone https://github.com/Tarcyo/Ilustracao-forward-propagation-e-o-backpropagation.git
cd Ilustracao-forward-propagation-e-o-backpropagation
```

Se utilizar o ZIP, abra o terminal dentro da pasta extraída que contém o `README.md` e a pasta **`build web para executar`**.

### 2. Iniciar o servidor local

**Requisitos:** Python 3.7 ou superior e um navegador atualizado, como Chrome ou Edge.

No Windows, pelo PowerShell:

```powershell
cd "build web para executar"
python servidor.py --port 8080
```

Se o comando `python` não estiver disponível e o inicializador do Python estiver instalado, utilize:

```powershell
py servidor.py --port 8080
```

No Linux ou macOS, utilize `python3` no lugar de `python`.

### 3. Abrir o aplicativo

O servidor tenta abrir o navegador automaticamente. Também é possível acessar:

**[http://127.0.0.1:8080/](http://127.0.0.1:8080/)**

Mantenha o terminal aberto durante o uso. Para encerrar o servidor, pressione **Ctrl+C**.

### Opções do servidor

| Opção | Efeito |
|---|---|
| `--port 8080` | Define a porta; sem essa opção, o padrão é **8000** |
| `--no-browser` | Inicia o servidor sem tentar abrir o navegador |
| `--help` | Mostra as opções disponíveis |

Exemplo com outra porta:

```powershell
python servidor.py --port 8081 --no-browser
```

O arquivo **`servidor.py` deve permanecer junto ao `index.html`** e às pastas `assets`, `canvaskit` e `icons`. Ele serve os arquivos a partir da própria pasta, independentemente do diretório em que o terminal foi aberto.

**Papel do Python:** fornecer o servidor HTTP local. A interface e os cálculos da rede pertencem ao aplicativo Flutter compilado e são executados no navegador. O endereço `127.0.0.1` funciona no computador em que o servidor está rodando.

<a id="como-usar"></a>
## 🖱️ Como explorar a demonstração

### Exemplo sugerido para avaliação

1. Na tela inicial, clique em **“Usar exemplo: A = 1 h, B = 2 h”**.
2. Confira as entradas **1** e **2** e o consumo de referência **1 kWh**, calculado automaticamente.
3. Clique em **“Iniciar demonstração”**.
4. Avance pela primeira ida, conferindo somatórios, vieses e ativações.
5. Observe os neurônios em que a ReLU retorna zero.
6. Acompanhe a perda, as derivadas e a propagação dos deltas.
7. Confira os gradientes e as propostas de atualização.
8. Na conclusão do primeiro ciclo, avance para observar a segunda ida com os novos parâmetros.

### Controles e leitura da interface

| Controle ou elemento | Função |
|---|---|
| **Setas da tela** | Voltar ou avançar uma etapa |
| **Teclas ← e →** | Navegar pelas etapas quando a demonstração está em foco |
| **Contador inferior** | Identificar a etapa atual e o ciclo correspondente |
| **Ver pesos e vieses desta ida** | Inspecionar os parâmetros associados à passagem exibida |
| **Ver parâmetros atualizados** | Inspecionar os parâmetros após a atualização conjunta |
| **Alterar entradas** | Voltar ao formulário e preparar outra demonstração |
| **Rever desde o início** | Revisitar as etapas já calculadas |
| **Cálculos / Rede**, em telas compactas | Alternar entre os painéis |

| Cor | Significado |
|---|---|
| 🔵 Azul | Propagação de ida e fluxo das ativações |
| 🟣 Roxo | Retropropagação e fluxo dos gradientes |
| 🟢 Verde | Atualização ou conclusão do ciclo |

As horas podem ser informadas com **ponto ou vírgula decimal**, devem ser não negativas e podem variar de **0 a 1000**. O alvo é somente leitura e acompanha automaticamente as entradas.

### Como a navegação funciona internamente

Ao iniciar uma demonstração, o programa calcula os dois ciclos e registra **25 etapas por ciclo**, totalizando **50 registros** com cópias dos valores e dos parâmetros correspondentes.

Avançar e voltar permite inspecionar esses registros sem reaplicar atualizações. Ao confirmar novas entradas, uma nova demonstração é calculada com os mesmos parâmetros iniciais, o que facilita a reprodução dos resultados.

<a id="rede"></a>
## ⚡ Tarefa de regressão e arquitetura

### Dados simulados

A tarefa consiste em estimar o consumo de energia de dois aparelhos idealizados a partir de suas horas de uso. As potências permanecem constantes:

| Grandeza | Significado | Valor ou unidade |
|---|---|---|
| $x_1$ | Horas de uso do aparelho A | h |
| $x_2$ | Horas de uso do aparelho B | h |
| $P_A$ | Potência do aparelho A | 0,2 kW |
| $P_B$ | Potência do aparelho B | 0,4 kW |
| $y$ | Consumo de referência | kWh |
| $\hat y$ | Consumo previsto pela rede | kWh |

O alvo simulado é calculado por:

$$
y = 0{,}2x_1 + 0{,}4x_2
$$

No exemplo padrão:

$$
x_1 = 1,\quad x_2 = 2,\quad y = 0{,}2(1) + 0{,}4(2) = 1\ \text{kWh}
$$

**Essa fórmula gera a referência para comparação.** A previsão é obtida pelos pesos, vieses e ativações da própria rede.

### Configuração da rede

| Camada | Quantidade de neurônios | Ativação |
|---|---:|---|
| Entrada | 2 | Valores informados pelo usuário |
| Oculta 1 | 3 | ReLU |
| Oculta 2 | 3 | ReLU |
| Saída | 1 | ReLU |

São **18 pesos**: 6 na primeira camada, 9 na segunda e 3 na saída. Os **7 vieses** correspondem aos 7 neurônios das camadas ocultas e de saída.

A taxa de aprendizado é **0,1**, fixa na interface. A ReLU da saída mantém a previsão não negativa, de acordo com o contexto do consumo.

<details>
<summary><strong>🔢 Parâmetros iniciais para reprodução dos cálculos</strong></summary>

Em cada linha, os pesos seguem a ordem das entradas ou dos neurônios da camada anterior.

| Camada | Neurônio | Pesos de entrada | Viés |
|---|---:|---|---:|
| Oculta 1 | 1 | `0,4; −0,2` | `0,1` |
| Oculta 1 | 2 | `−0,3; 0,5` | `0,1` |
| Oculta 1 | 3 | `0,2; −0,4` | `0,1` |
| Oculta 2 | 1 | `0,3; 0,2; −0,1` | `0,1` |
| Oculta 2 | 2 | `−0,2; 0,4; 0,3` | `0,1` |
| Oculta 2 | 3 | `0,1; −0,3; 0,2` | `0,05` |
| Saída | 1 | `0,5; 0,4; 0,2` | `0,1` |

</details>

<a id="calculos"></a>
## 🧮 Cálculos implementados

### 1. Propagação de ida

Para cada neurônio, são calculados a soma ponderada com viés e o resultado da ativação:

$$
z_j^{(\ell)} = \sum_i w_{ji}^{(\ell)} a_i^{(\ell-1)} + b_j^{(\ell)},
\qquad a_j^{(\ell)} = \operatorname{ReLU}(z_j^{(\ell)})
$$

$$
\operatorname{ReLU}(z) = \max(0,z)
$$

Na primeira camada, as ativações de entrada são os próprios valores $x_1$ e $x_2$. Nas camadas seguintes, são as saídas da camada anterior.

Por exemplo, no primeiro neurônio da primeira camada:

$$
z = 1(0{,}4) + 2(-0{,}2) + 0{,}1 = 0{,}1,
\qquad a = 0{,}1
$$

No terceiro neurônio dessa camada, o somatório é **−0,5**, e a ReLU produz **0**. Esse caso também permite observar o bloqueio do gradiente na volta.

### 2. Perda por máxima verossimilhança

Para construir a perda, adota-se a hipótese didática de que o consumo, dadas as entradas, segue uma normal cuja média é a previsão da rede e cujo desvio padrão é fixo em **1 kWh**:

$$
Y \mid x \sim \mathcal{N}(\hat y(x;\theta),\sigma^2),
\qquad \sigma = 1\ \text{kWh}
$$

Maximizar a densidade atribuída ao alvo observado equivale a maximizar seu logaritmo e, portanto, a minimizar o negativo desse logaritmo: a **negative log-likelihood**, ou **NLL**.

Trabalhando com os valores numéricos do consumo expressos em kWh e com desvio padrão numérico igual a 1:

$$
\mathrm{NLL} = -\ln p(y\mid x)
= \frac{1}{2}(\hat y-y)^2 + \frac{1}{2}\ln(2\pi)
$$

Como a constante $C=\frac{1}{2}\ln(2\pi)$ independe dos pesos e dos vieses, a perda utilizada na retropropagação é:

$$
E = \mathrm{NLL} - C = \frac{1}{2}(\hat y-y)^2
$$

Retirar essa constante preserva os gradientes e os parâmetros que minimizam a função. A interface apresenta **a NLL completa, a constante, a log-verossimilhança e a perda $E$**.

A normal é uma hipótese para definir a perda; os dados simulados do exemplo continuam sendo gerados **sem ruído**. O cálculo da NLL é feito diretamente no domínio logarítmico, evitando calcular uma exponencial muito pequena para depois aplicar seu logaritmo.

### 3. Retropropagação

A derivada inicial é:

$$
\frac{\partial E}{\partial \hat y} = \hat y-y
$$

Define-se o delta como a derivada da perda em relação ao somatório do neurônio, antes da ativação:

$$
\delta_j^{(\ell)} = \frac{\partial E}{\partial z_j^{(\ell)}}
$$

Na saída, a regra da cadeia resulta em:

$$
\delta^{(\mathrm{saida})} = (\hat y-y)\operatorname{ReLU}'(z^{(\mathrm{saida})})
$$

Nas camadas ocultas, somam-se as contribuições dos caminhos que seguem para a próxima camada:

$$
\delta_j^{(\ell)} = \operatorname{ReLU}'(z_j^{(\ell)})
\sum_k w_{kj}^{(\ell+1)}\delta_k^{(\ell+1)}
$$

Para $z>0$, a derivada da ReLU é 1; para $z<0$, é 0. Em **$z=0$**, o programa adota **0 como convenção**, pois a derivada clássica não existe nesse ponto.

### 4. Gradientes e atualização conjunta

Os gradientes dos parâmetros de cada neurônio são:

$$
\frac{\partial E}{\partial w_{ji}^{(\ell)}} = \delta_j^{(\ell)}a_i^{(\ell-1)},
\qquad
\frac{\partial E}{\partial b_j^{(\ell)}} = \delta_j^{(\ell)}
$$

As propostas de atualização seguem a descida do gradiente:

$$
\theta_{\mathrm{novo}} = \theta_{\mathrm{anterior}} - \eta\nabla_\theta E,
\qquad \eta = 0{,}1
$$

**Todos os gradientes de um ciclo usam os parâmetros anteriores.** Somente depois de terminar esses cálculos, as atualizações dos 18 pesos e dos 7 vieses são aplicadas conjuntamente. Isso evita misturar pesos novos e antigos na retropropagação de uma mesma passagem.

Um gradiente de peso pode ser zero porque a entrada daquela conexão é zero ou porque o delta do neurônio é zero. A interface mostra ambos os casos no exemplo.

<a id="resultados"></a>
## ✅ Resultados do exemplo padrão

Para **$x_1=1$, $x_2=2$ e $y=1$**, a primeira ida produz:

| Resultado | Valor |
|---|---|
| Ativações da oculta 1 | `[0,1; 0,8; 0]` |
| Ativações da oculta 2 | `[0,29; 0,4; 0]` |
| Previsão inicial | **0,405 kWh** |
| Perda $E$ | **0,1770125** |
| NLL completa | **≈ 1,0959510332** |
| Derivada em relação à saída | **−0,595** |
| Delta da saída | **−0,595** |
| Deltas da oculta 2 | `[−0,2975; −0,238; 0]` |
| Deltas da oculta 1 | `[−0,04165; −0,1547; 0]` |

### Exemplo de uma atualização

Para o primeiro peso que liga a segunda camada oculta à saída:

$$
\frac{\partial E}{\partial w} = (-0{,}595)(0{,}29) = -0{,}17255
$$

$$
w_{\mathrm{novo}} = 0{,}5 - 0{,}1(-0{,}17255) = 0{,}517255
$$

O viés da saída passa de **0,1** para **0,1595**.

### Comparação das duas idas

| Medição | Parâmetros utilizados | Previsão $\hat y$ | Perda $E$ |
|---|---|---:|---:|
| Primeira ida | Parâmetros iniciais | `0,405` | `0,1770125` |
| Segunda ida | Parâmetros após a primeira atualização conjunta | `≈ 0,550109524` | `≈ 0,101200720` |

Essas medições mostram a redução da perda **nessa mesma amostra** entre a primeira e a segunda ida.

> **Como interpretar a tela de conclusão:** as ativações, a previsão e a perda mostradas ao concluir um ciclo pertencem à ida realizada **antes da atualização daquele ciclo**. A segunda ida avalia o efeito da primeira atualização. Ao concluir o segundo ciclo, não é realizada uma terceira ida para medir o efeito da segunda atualização.

Os valores da interface são arredondados para apresentação; os cálculos utilizam os valores em ponto flutuante disponíveis em Dart. No vídeo de apresentação, é acompanhado o **primeiro ciclo completo**; o aplicativo permite continuar e explorar o segundo.

<a id="estrutura"></a>
## 🗂️ Organização do projeto e do código

| Caminho | Conteúdo |
|---|---|
| [`lib/main.dart`](lib/main.dart) | Implementação dos cálculos, das etapas e da interface |
| [`assets/fonte.ttf`](assets/fonte.ttf) | Fonte utilizada pelo aplicativo |
| [`web/`](web/) | Arquivos de inicialização da versão web |
| [`pubspec.yaml`](pubspec.yaml) | Configuração do projeto, dependências e fonte |
| [`pubspec.lock`](pubspec.lock) | Versões resolvidas das dependências |
| [Build web para executar](build%20web%20para%20executar/) | Aplicativo já compilado para execução no navegador |
| [Servidor Python](build%20web%20para%20executar/servidor.py) | Servidor HTTP local para o build pronto |

### Onde localizar cada parte em `lib/main.dart`

| Elemento | Responsabilidade |
|---|---|
| `calcularConsumoDeReferencia` | Calcular o alvo simulado a partir das horas de uso |
| `calcularDemonstracaoCompleta` | Executar os dois ciclos, calcular forward, perda, derivadas, gradientes e atualizações, registrando as etapas |
| `EtapaDaDemonstracao` | Preservar os dados e os parâmetros associados a cada etapa |
| `copiarPesos`, `copiarVieses` e `copiarValoresDosNeuronios` | Criar cópias dos valores para preservar o histórico |
| `EstadoDaTelaDaDemonstracao` | Controlar formulário, validação, navegação e seleção da etapa |
| `PainelDosCalculos` | Exibir fórmulas, contas e resultados |
| `PainelDaRede` e `DesenhoDaRede` | Exibir o grafo, os destaques e o fluxo entre camadas |

### Tecnologias e responsabilidades

| Tecnologia | Utilização |
|---|---|
| **Dart** | Operações numéricas, laços e implementação explícita da regra da cadeia |
| **`dart:math`** | Logaritmo natural e constante pi usados na NLL |
| **Flutter** | Formulários, navegação, painéis e desenho da rede |
| **Python / biblioteca padrão** | Servir os arquivos estáticos do build web localmente |

Os cálculos da rede não dependem de bibliotecas de redes neurais ou de diferenciação automática. A retropropagação está escrita explicitamente no código-fonte.

<a id="executar-flutter"></a>
## 🛠️ Executar e recompilar com Flutter

Esta opção permite estudar, alterar e recompilar o código-fonte. Para apenas utilizar o aplicativo pronto, siga a seção [Executar o aplicativo já compilado](#executar-build).

### Requisitos

- Flutter SDK com Dart compatível com **`>=3.10.3 <4.0.0`**, conforme o `pubspec.yaml`.
- Google Chrome para executar o comando de desenvolvimento abaixo.
- Conexão com a internet para obter as dependências e os componentes necessários.

O Dart já acompanha o Flutter SDK. Na raiz do projeto, onde está o `pubspec.yaml`, execute:

```bash
flutter --version
flutter doctor
flutter pub get
flutter run -d chrome
```

No Windows com Microsoft Edge disponível, também é possível utilizar:

```powershell
flutter run -d edge
```

### Gerar um novo build web

Na raiz do projeto:

```bash
flutter build web --release
```

O Flutter gera os arquivos em **`build/web`**. Para usar o servidor fornecido com esse novo build, copie o arquivo `servidor.py` para essa pasta.

No PowerShell, a partir da raiz:

```powershell
Copy-Item ".\build web para executar\servidor.py" ".\build\web\servidor.py"
python ".\build\web\servidor.py" --port 8080
```

**`build/web` é a saída da compilação; `build web para executar` é a cópia distribuída neste repositório.** Quando alterar o código-fonte, gere um novo build e atualize o conteúdo da pasta distribuída, mantendo o `servidor.py`. Alterações em `lib/main.dart` não modificam automaticamente a versão já compilada.

<a id="duvidas"></a>
## 🔧 Dúvidas de execução

| Situação | Como resolver |
|---|---|
| `python` não é reconhecido no Windows | Verifique a instalação do Python; se o inicializador estiver disponível, use `py servidor.py --port 8080` |
| A porta 8080 está ocupada | Execute `python servidor.py --port 8081` e utilize a URL informada no terminal |
| O servidor informa que não encontrou `index.html` | Coloque `servidor.py` junto ao `index.html` do build web |
| O navegador não abriu automaticamente | Acesse manualmente o endereço exibido pelo servidor |
| O aplicativo não carregou | Confira se o terminal continua aberto e se toda a pasta do build foi extraída, incluindo seus arquivos e subpastas |
| A tela inicial está sem valores | Clique em **“Usar exemplo: A = 1 h, B = 2 h”** ou informe as horas dos dois aparelhos |
| A versão exibida não reflete mudanças no código | Recompile, atualize a pasta distribuída e recarregue a página; se necessário, limpe os dados do site no navegador |
| O comando `flutter` não é reconhecido | Instale e configure o Flutter SDK para trabalhar com o fonte, ou utilize o build pronto com Python |

Execute o build por HTTP utilizando o servidor fornecido. Dependendo da configuração de inicialização do Flutter, o navegador pode precisar de internet para carregar componentes externos.

<a id="referencias"></a>
## 📖 Referências técnicas

- [Documentação do Flutter: aplicações web](https://docs.flutter.dev/platform-integration/web/building)
- [Documentação do Flutter: compilação e publicação web](https://docs.flutter.dev/deployment/web)
- [Documentação do Python: servidores HTTP da biblioteca padrão](https://docs.python.org/3.12/library/http.server.html)

---

**Autor:** Tarcyo Guilherme Maia Borges · **Disciplina:** Introdução a Redes Neurais Artificiais · **INF/UFG**
