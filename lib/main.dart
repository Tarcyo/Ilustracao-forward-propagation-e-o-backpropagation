

import 'dart:math' as matematica;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AplicativoDeRedeNeural());
}

const Color corDeFundo = Color(0xFFF5F6F8);
const Color corDoTexto = Color(0xFF182431);
const Color corDoTextoSecundario = Color(0xFF627081);
const Color corDaBorda = Color(0xFFE2E7ED);
const Color corDaIda = Color(0xFF2563EB);
const Color corDaVolta = Color(0xFF7C3AED);
const Color corDaAtualizacao = Color(0xFF087F65);

const double potenciaDoAparelhoAEmKw = 0.2;
const double potenciaDoAparelhoBEmKw = 0.4;

double calcularConsumoDeReferencia(double horasDeA, double horasDeB) {
  return potenciaDoAparelhoAEmKw * horasDeA +
      potenciaDoAparelhoBEmKw * horasDeB;
}


enum FaseDaDemonstracao {
  entradas,
  propagacaoDireta,
  erro,
  retropropagacao,
  atualizacao,
  conclusao,
}

class LinhaDeCalculo {
  final String rotulo;
  final String expressao;

  const LinhaDeCalculo(this.rotulo, this.expressao);
}

class EtapaDaDemonstracao {
  final int numeroDoCiclo;
  final FaseDaDemonstracao fase;
  final String titulo;
  final String descricao;
  final String formula;
  final String rotuloDoResultado;
  final String resultado;
  final String observacao;
  final List<LinhaDeCalculo> calculos;
  final List<List<double?>> valoresDosNeuronios;
  final List<List<List<double>>> pesos;
  final List<List<double>> vieses;
  final int? indiceDaCamadaEmDestaque;
  final int? indiceDoNeuronioEmDestaque;
  final bool parametrosJaAtualizados;

  EtapaDaDemonstracao({
    required this.numeroDoCiclo,
    required this.fase,
    required this.titulo,
    required this.descricao,
    required this.formula,
    required this.rotuloDoResultado,
    required this.resultado,
    required this.calculos,
    required List<List<double?>> valoresDosNeuronios,
    required List<List<List<double>>> pesos,
    required List<List<double>> vieses,
    this.observacao = '',
    this.indiceDaCamadaEmDestaque,
    this.indiceDoNeuronioEmDestaque,
    this.parametrosJaAtualizados = false,
  }) : valoresDosNeuronios = copiarValoresDosNeuronios(valoresDosNeuronios),
       pesos = copiarPesos(pesos),
       vieses = copiarVieses(vieses);
}

class ResumoDoCiclo {
  final int numeroDoCiclo;
  final double saidaAntesDaAtualizacao;
  final double erroAntesDaAtualizacao;

  const ResumoDoCiclo({
    required this.numeroDoCiclo,
    required this.saidaAntesDaAtualizacao,
    required this.erroAntesDaAtualizacao,
  });
}

class DemonstracaoCalculada {
  final List<EtapaDaDemonstracao> etapas;
  final List<ResumoDoCiclo> resumos;
  final double primeiraEntrada;
  final double segundaEntrada;
  final double valorEsperado;
  final double taxaDeAprendizado;

  const DemonstracaoCalculada({
    required this.etapas,
    required this.resumos,
    required this.primeiraEntrada,
    required this.segundaEntrada,
    required this.valorEsperado,
    required this.taxaDeAprendizado,
  });
}



List<List<List<double>>> copiarPesos(List<List<List<double>>> pesosOriginais) {
  final List<List<List<double>>> copiaDasCamadas = [];
  for (
    int indiceDaCamada = 0;
    indiceDaCamada < pesosOriginais.length;
    indiceDaCamada++
  ) {
    final List<List<double>> copiaDosNeuronios = [];
    for (
      int indiceDoNeuronio = 0;
      indiceDoNeuronio < pesosOriginais[indiceDaCamada].length;
      indiceDoNeuronio++
    ) {
      final List<double> copiaDasConexoes = [];
      for (
        int indiceDaEntrada = 0;
        indiceDaEntrada <
            pesosOriginais[indiceDaCamada][indiceDoNeuronio].length;
        indiceDaEntrada++
      ) {
        copiaDasConexoes.add(
          pesosOriginais[indiceDaCamada][indiceDoNeuronio][indiceDaEntrada],
        );
      }
      copiaDosNeuronios.add(List<double>.unmodifiable(copiaDasConexoes));
    }
    copiaDasCamadas.add(List<List<double>>.unmodifiable(copiaDosNeuronios));
  }
  return List<List<List<double>>>.unmodifiable(copiaDasCamadas);
}

List<List<double>> copiarVieses(List<List<double>> viesesOriginais) {
  final List<List<double>> copiaDasCamadas = [];
  for (
    int indiceDaCamada = 0;
    indiceDaCamada < viesesOriginais.length;
    indiceDaCamada++
  ) {
    final List<double> copiaDosNeuronios = [];
    for (
      int indiceDoNeuronio = 0;
      indiceDoNeuronio < viesesOriginais[indiceDaCamada].length;
      indiceDoNeuronio++
    ) {
      copiaDosNeuronios.add(viesesOriginais[indiceDaCamada][indiceDoNeuronio]);
    }
    copiaDasCamadas.add(List<double>.unmodifiable(copiaDosNeuronios));
  }
  return List<List<double>>.unmodifiable(copiaDasCamadas);
}

List<List<double?>> copiarValoresDosNeuronios(List<List<double?>> originais) {
  final List<List<double?>> copia = [];
  for (
    int indiceDaCamada = 0;
    indiceDaCamada < originais.length;
    indiceDaCamada++
  ) {
    final List<double?> valoresDaCamada = [];
    for (
      int indiceDoNeuronio = 0;
      indiceDoNeuronio < originais[indiceDaCamada].length;
      indiceDoNeuronio++
    ) {
      valoresDaCamada.add(originais[indiceDaCamada][indiceDoNeuronio]);
    }
    copia.add(List<double?>.unmodifiable(valoresDaCamada));
  }
  return List<List<double?>>.unmodifiable(copia);
}

String formatarNumero(double numero) {
  if (numero == 0) return '0';
  if (numero.abs() < 0.000001 || numero.abs() >= 1000000) {
    return numero.toStringAsExponential(4).replaceAll('.', ',');
  }
  String texto = numero.toStringAsFixed(6);
  texto = texto.replaceFirst(RegExp(r'0+$'), '');
  texto = texto.replaceFirst(RegExp(r'\.$'), '');
  return texto.replaceAll('.', ',');
}

String nomeDoNeuronio(int indiceDaCamada, int indiceDoNeuronio) {
  if (indiceDaCamada == 0) return 'Entrada ${indiceDoNeuronio + 1}';
  if (indiceDaCamada == 3) return 'Saída';
  return 'Camada $indiceDaCamada · neurônio ${indiceDoNeuronio + 1}';
}











DemonstracaoCalculada calcularDemonstracaoCompleta({
  required double primeiraEntrada,
  required double segundaEntrada,
  required double valorEsperado,
  double taxaDeAprendizado = 0.1,
}) {
  if (!primeiraEntrada.isFinite ||
      !segundaEntrada.isFinite ||
      !valorEsperado.isFinite ||
      !taxaDeAprendizado.isFinite ||
      valorEsperado < 0 ||
      taxaDeAprendizado <= 0) {
    throw ArgumentError('Entradas finitas, alvo não negativo e taxa positiva.');
  }

  List<List<List<double>>> pesosAtuais = [
    [
      [0.4, -0.2],
      [-0.3, 0.5],
      [0.2, -0.4],
    ],
    [
      [0.3, 0.2, -0.1],
      [-0.2, 0.4, 0.3],
      [0.1, -0.3, 0.2],
    ],
    [
      [0.5, 0.4, 0.2],
    ],
  ];
  List<List<double>> viesesAtuais = [
    [0.1, 0.1, 0.1],
    [0.1, 0.1, 0.05],
    [0.1],
  ];

  final List<EtapaDaDemonstracao> etapas = [];
  final List<ResumoDoCiclo> resumos = [];

  
  for (int numeroDoCiclo = 1; numeroDoCiclo <= 2; numeroDoCiclo++) {
    final List<List<double>> ativacoes = [
      [primeiraEntrada, segundaEntrada],
      [],
      [],
      [],
    ];
    final List<List<double>> somatorios = [[], [], []];
    final List<List<double>> derivadasDaRelu = [[], [], []];
    final List<List<double>> derivadasDoErroEmRelacaoAosSomatorios = [
      [],
      [],
      [],
    ];
    final List<List<List<double>>> gradientesDosPesos = [[], [], []];
    final List<List<double>> gradientesDosVieses = [[], [], []];
    final List<List<double?>> valoresVisiveis = [
      [primeiraEntrada, segundaEntrada],
      [null, null, null],
      [null, null, null],
      [null],
    ];

    
    void registrarEtapa({
      required FaseDaDemonstracao fase,
      required String titulo,
      required String descricao,
      required String formula,
      required String rotuloDoResultado,
      required String resultado,
      required List<LinhaDeCalculo> calculos,
      String observacao = '',
      int? indiceDaCamadaEmDestaque,
      int? indiceDoNeuronioEmDestaque,
      bool parametrosJaAtualizados = false,
    }) {
      etapas.add(
        EtapaDaDemonstracao(
          numeroDoCiclo: numeroDoCiclo,
          fase: fase,
          titulo: titulo,
          descricao: descricao,
          formula: formula,
          rotuloDoResultado: rotuloDoResultado,
          resultado: resultado,
          calculos: List<LinhaDeCalculo>.unmodifiable(calculos),
          observacao: observacao,
          indiceDaCamadaEmDestaque: indiceDaCamadaEmDestaque,
          indiceDoNeuronioEmDestaque: indiceDoNeuronioEmDestaque,
          valoresDosNeuronios: valoresVisiveis,
          pesos: pesosAtuais,
          vieses: viesesAtuais,
          parametrosJaAtualizados: parametrosJaAtualizados,
        ),
      );
    }

    registrarEtapa(
      fase: FaseDaDemonstracao.entradas,
      titulo: numeroDoCiclo == 1 ? 'Começamos pelas entradas' : 'Segunda ida',
      descricao: numeroDoCiclo == 1
          ? 'Regressão didática: a rede estima o consumo total em kWh a partir das horas de uso de dois aparelhos.'
          : 'A mesma amostra de consumo agora usa os pesos atualizados na primeira volta.',
      formula: '2 entradas → 3 neurônios → 3 neurônios → 1 saída',
      rotuloDoResultado: 'Consumo de referência (kWh)',
      resultado: formatarNumero(valorEsperado),
      calculos: [
        LinhaDeCalculo('x₁: horas de uso de A', formatarNumero(primeiraEntrada)),
        LinhaDeCalculo('x₂: horas de uso de B', formatarNumero(segundaEntrada)),
        LinhaDeCalculo(
          'Referência simulada: potência × tempo',
          '0,2 × (${formatarNumero(primeiraEntrada)}) + '
              '0,4 × (${formatarNumero(segundaEntrada)})'
              ' ≈ ${formatarNumero(valorEsperado)} kWh',
        ),
        LinhaDeCalculo(
          'Taxa de aprendizado',
          formatarNumero(taxaDeAprendizado),
        ),
      ],
      observacao: 'Potências fixas: A = 0,2 kW; B = 0,4 kW. '
          'A fórmula gera o alvo simulado; a previsão da rede vem de seus pesos e vieses. '
          'Os dois ciclos demonstram o ajuste para uma única amostra.',
    );

    
    
    
    
    
    for (
      int indiceDaCamada = 0;
      indiceDaCamada < pesosAtuais.length;
      indiceDaCamada++
    ) {
      for (
        int indiceDoNeuronio = 0;
        indiceDoNeuronio < pesosAtuais[indiceDaCamada].length;
        indiceDoNeuronio++
      ) {
        double somaDosProdutos = 0;
        final List<LinhaDeCalculo> calculosDoNeuronio = [];
        for (
          int indiceDaEntrada = 0;
          indiceDaEntrada <
              pesosAtuais[indiceDaCamada][indiceDoNeuronio].length;
          indiceDaEntrada++
        ) {
          final double valorDaEntrada =
              ativacoes[indiceDaCamada][indiceDaEntrada];
          final double pesoDaConexao =
              pesosAtuais[indiceDaCamada][indiceDoNeuronio][indiceDaEntrada];
          final double produtoDaConexao = valorDaEntrada * pesoDaConexao;
          somaDosProdutos = somaDosProdutos + produtoDaConexao;
          calculosDoNeuronio.add(
            LinhaDeCalculo(
              'Conexão ${indiceDaEntrada + 1}',
              '${formatarNumero(valorDaEntrada)} × (${formatarNumero(pesoDaConexao)})'
                  ' ≈ ${formatarNumero(produtoDaConexao)}',
            ),
          );
        }
        final double viesDoNeuronio =
            viesesAtuais[indiceDaCamada][indiceDoNeuronio];
        final double somatorioDoNeuronio = somaDosProdutos + viesDoNeuronio;
        double ativacaoDoNeuronio;
        double derivadaDaRelu;
        if (somatorioDoNeuronio > 0) {
          ativacaoDoNeuronio = somatorioDoNeuronio;
          derivadaDaRelu = 1;
        } else {
          ativacaoDoNeuronio = 0;
          derivadaDaRelu = 0;
        }
        if (!somatorioDoNeuronio.isFinite || !ativacaoDoNeuronio.isFinite) {
          throw StateError('Os valores excederam a precisão numérica.');
        }
        somatorios[indiceDaCamada].add(somatorioDoNeuronio);
        ativacoes[indiceDaCamada + 1].add(ativacaoDoNeuronio);
        derivadasDaRelu[indiceDaCamada].add(derivadaDaRelu);
        valoresVisiveis[indiceDaCamada + 1][indiceDoNeuronio] =
            ativacaoDoNeuronio;
        calculosDoNeuronio.add(
          LinhaDeCalculo(
            'Somatório com viés',
            '${formatarNumero(somaDosProdutos)} + (${formatarNumero(viesDoNeuronio)})'
                ' ≈ ${formatarNumero(somatorioDoNeuronio)}',
          ),
        );
        calculosDoNeuronio.add(
          LinhaDeCalculo(
            'Ativação ReLU',
            'máximo(0; ${formatarNumero(somatorioDoNeuronio)})'
                ' ≈ ${formatarNumero(ativacaoDoNeuronio)}',
          ),
        );
        registrarEtapa(
          fase: FaseDaDemonstracao.propagacaoDireta,
          titulo: nomeDoNeuronio(indiceDaCamada + 1, indiceDoNeuronio),
          descricao: 'Multiplicamos as entradas pelos pesos e somamos o viés.',
          formula: 'z = Σ(entrada × peso) + viés     a = ReLU(z)',
          rotuloDoResultado: 'Ativação',
          resultado: formatarNumero(ativacaoDoNeuronio),
          calculos: calculosDoNeuronio,
          observacao: somatorioDoNeuronio <= 0
              ? 'Somatório não positivo: a ReLU produz zero.'
              : '',
          indiceDaCamadaEmDestaque: indiceDaCamada + 1,
          indiceDoNeuronioEmDestaque: indiceDoNeuronio,
        );
      }
    }

    final double saidaDaRede = ativacoes[3][0];
    final double diferencaEntreSaidaEAlvo = saidaDaRede - valorEsperado;
    final double quadradoDaDiferenca =
        diferencaEntreSaidaEAlvo * diferencaEntreSaidaEAlvo;
    final double erroQuadratico = quadradoDaDiferenca / 2;
    if (!erroQuadratico.isFinite) {
      throw StateError('O erro excedeu a precisão numérica.');
    }

    final double constanteDaNll = matematica.log(2 * matematica.pi) / 2;
    final double nllGaussiana = erroQuadratico + constanteDaNll;
    final double logVerossimilhanca = -nllGaussiana;

    resumos.add(
      ResumoDoCiclo(
        numeroDoCiclo: numeroDoCiclo,
        saidaAntesDaAtualizacao: saidaDaRede,
        erroAntesDaAtualizacao: erroQuadratico,
      ),
    );
    registrarEtapa(
      fase: FaseDaDemonstracao.erro,
      titulo: 'Perda por máxima verossimilhança',
      descricao: 'Adotamos uma normal com média igual à previsão da rede e '
          'desvio padrão fixo de 1 kWh. Maximizar sua verossimilhança equivale '
          'a minimizar o negativo do log da densidade (NLL).',
      formula: 'Y | x ~ Normal(ŷ, 1)\n'
          'NLL = −ln p(y | x) = ½(ŷ − y)² + ½ln(2π)\n'
          'E = NLL sem a constante = ½(ŷ − y)²',
      rotuloDoResultado: 'Perda usada: NLL sem a constante',
      resultado: formatarNumero(erroQuadratico),
      calculos: [
        const LinhaDeCalculo(
          'Hipótese estatística',
          'Média μ = ŷ; σ = 1 kWh fixo. Os números de y e ŷ estão em kWh.',
        ),
        const LinhaDeCalculo(
          'Densidade normal no alvo (σ numérico = 1)',
          'p(y | x) = exp(−½(ŷ − y)²) / √(2π)',
        ),
        LinhaDeCalculo(
          'Diferença',
          '${formatarNumero(saidaDaRede)} − (${formatarNumero(valorEsperado)})'
              ' ≈ ${formatarNumero(diferencaEntreSaidaEAlvo)}',
        ),
        LinhaDeCalculo(
          'Quadrado',
          '(${formatarNumero(diferencaEntreSaidaEAlvo)})²'
              ' ≈ ${formatarNumero(quadradoDaDiferenca)}',
        ),
        LinhaDeCalculo(
          'Parte da NLL que depende da rede: E',
          '${formatarNumero(quadradoDaDiferenca)} ÷ 2'
              ' ≈ ${formatarNumero(erroQuadratico)}',
        ),
        LinhaDeCalculo(
          'Constante C, independente dos parâmetros',
          'C = ln(2π) ÷ 2 ≈ ${formatarNumero(constanteDaNll)}',
        ),
        LinhaDeCalculo(
          'Negativo do log da densidade: NLL completa',
          '${formatarNumero(erroQuadratico)} + ${formatarNumero(constanteDaNll)}'
              ' ≈ ${formatarNumero(nllGaussiana)}',
        ),
        LinhaDeCalculo(
          'Log-verossimilhança',
          'ln p(y | x) = −NLL ≈ ${formatarNumero(logVerossimilhanca)}',
        ),
        const LinhaDeCalculo(
          'Por que podemos retirar C?',
          'C é fixa: ∂C/∂peso = 0 e ∂C/∂viés = 0. '
              'Minimizar E equivale a minimizar NLL e a maximizar a verossimilhança.',
        ),
      ],
      observacao: 'A normal é uma hipótese didática para definir a perda; '
          'os dados simulados continuam sem ruído. Ela não é truncada em zero: '
          'a ReLU restringe apenas a média prevista. '
          'Dois ciclos ilustram a otimização, sem garantir que o máximo foi encontrado.',
      indiceDaCamadaEmDestaque: 3,
      indiceDoNeuronioEmDestaque: 0,
    );

    
    final double derivadaDoErroEmRelacaoASaida = diferencaEntreSaidaEAlvo;
    registrarEtapa(
      fase: FaseDaDemonstracao.retropropagacao,
      titulo: 'A derivada do erro',
      descricao: 'Começa a volta. A NLL e a perda E têm a mesma derivada, '
          'pois a constante C não depende da saída da rede.',
      formula: '∂NLL/∂saída = ∂E/∂saída + 0\n'
          '∂E/∂saída = ½ × 2 × (saída − alvo) = saída − alvo',
      rotuloDoResultado: 'Derivada em relação à saída',
      resultado: formatarNumero(derivadaDoErroEmRelacaoASaida),
      calculos: [
        LinhaDeCalculo(
          'Regra da cadeia',
          'Derivada do quadrado × derivada de (saída − alvo)',
        ),
        LinhaDeCalculo(
          'Substituição',
          '½ × 2 × (${formatarNumero(saidaDaRede)} − (${formatarNumero(valorEsperado)})) × 1'
              ' ≈ ${formatarNumero(derivadaDoErroEmRelacaoASaida)}',
        ),
      ],
      indiceDaCamadaEmDestaque: 3,
      indiceDoNeuronioEmDestaque: 0,
    );

    
    
    for (
      int indiceDaCamada = pesosAtuais.length - 1;
      indiceDaCamada >= 0;
      indiceDaCamada--
    ) {
      for (
        int indiceDoNeuronio = 0;
        indiceDoNeuronio < pesosAtuais[indiceDaCamada].length;
        indiceDoNeuronio++
      ) {
        double derivadaDoErroEmRelacaoAAtivacao = 0;
        final List<LinhaDeCalculo> calculosDaDerivada = [];
        if (indiceDaCamada == pesosAtuais.length - 1) {
          derivadaDoErroEmRelacaoAAtivacao = derivadaDoErroEmRelacaoASaida;
          calculosDaDerivada.add(
            LinhaDeCalculo(
              'Derivada recebida',
              '∂E/∂saída ≈ ${formatarNumero(derivadaDoErroEmRelacaoASaida)}',
            ),
          );
        } else {
          final int indiceDaProximaCamada = indiceDaCamada + 1;
          for (
            int indiceDoProximoNeuronio = 0;
            indiceDoProximoNeuronio < pesosAtuais[indiceDaProximaCamada].length;
            indiceDoProximoNeuronio++
          ) {
            final double derivadaDoProximoNeuronio =
                derivadasDoErroEmRelacaoAosSomatorios[indiceDaProximaCamada][indiceDoProximoNeuronio];
            final double pesoParaOProximoNeuronio =
                pesosAtuais[indiceDaProximaCamada][indiceDoProximoNeuronio][indiceDoNeuronio];
            final double contribuicaoDoProximoNeuronio =
                derivadaDoProximoNeuronio * pesoParaOProximoNeuronio;
            derivadaDoErroEmRelacaoAAtivacao =
                derivadaDoErroEmRelacaoAAtivacao +
                contribuicaoDoProximoNeuronio;
            calculosDaDerivada.add(
              LinhaDeCalculo(
                'Ramo ${indiceDoProximoNeuronio + 1}',
                '${formatarNumero(derivadaDoProximoNeuronio)}'
                    ' × (${formatarNumero(pesoParaOProximoNeuronio)})'
                    ' ≈ ${formatarNumero(contribuicaoDoProximoNeuronio)}',
              ),
            );
          }
          calculosDaDerivada.add(
            LinhaDeCalculo(
              'Soma dos ramos: ∂E/∂a',
              '≈ ${formatarNumero(derivadaDoErroEmRelacaoAAtivacao)}',
            ),
          );
        }
        final double somatorioDoNeuronio =
            somatorios[indiceDaCamada][indiceDoNeuronio];
        final double derivadaDaRelu =
            derivadasDaRelu[indiceDaCamada][indiceDoNeuronio];
        final double derivadaDoErroEmRelacaoAoSomatorio =
            derivadaDoErroEmRelacaoAAtivacao * derivadaDaRelu;
        if (!derivadaDoErroEmRelacaoAoSomatorio.isFinite) {
          throw StateError('Uma derivada excedeu a precisão numérica.');
        }
        derivadasDoErroEmRelacaoAosSomatorios[indiceDaCamada].add(
          derivadaDoErroEmRelacaoAoSomatorio,
        );
        calculosDaDerivada.add(
          LinhaDeCalculo(
            'Derivada da ReLU',
            'z ≈ ${formatarNumero(somatorioDoNeuronio)}'
                ' ${somatorioDoNeuronio > 0 ? '> 0 →' : '≤ 0 →'}'
                ' ReLU\'(z) = ${formatarNumero(derivadaDaRelu)}',
          ),
        );
        calculosDaDerivada.add(
          LinhaDeCalculo(
            'Regra da cadeia: ∂E/∂z',
            '${formatarNumero(derivadaDoErroEmRelacaoAAtivacao)}'
                ' × ${formatarNumero(derivadaDaRelu)}'
                ' ≈ ${formatarNumero(derivadaDoErroEmRelacaoAoSomatorio)}',
          ),
        );
        registrarEtapa(
          fase: FaseDaDemonstracao.retropropagacao,
          titulo:
              'Derivada · ${nomeDoNeuronio(indiceDaCamada + 1, indiceDoNeuronio)}',
          descricao:
              'O erro volta pelas conexões e atravessa a derivada da ReLU.',
          formula: indiceDaCamada == 2
              ? 'δ = ∂E/∂saída × ReLU\'(z)'
              : 'δ = Σ(δ seguinte × peso da conexão) × ReLU\'(z)',
          rotuloDoResultado: 'δ = ∂E/∂z',
          resultado: formatarNumero(derivadaDoErroEmRelacaoAoSomatorio),
          calculos: calculosDaDerivada,
          observacao: derivadaDaRelu == 0
              ? 'ReLU bloqueada: este neurônio recebe gradiente zero. Em z = 0, adotamos derivada 0.'
              : 'ReLU\'(z) = 1 para z > 0; 0 para z ≤ 0 (convenção em zero).',
          indiceDaCamadaEmDestaque: indiceDaCamada + 1,
          indiceDoNeuronioEmDestaque: indiceDoNeuronio,
        );
      }
    }

    
    
    for (
      int indiceDaCamada = 0;
      indiceDaCamada < pesosAtuais.length;
      indiceDaCamada++
    ) {
      for (
        int indiceDoNeuronio = 0;
        indiceDoNeuronio < pesosAtuais[indiceDaCamada].length;
        indiceDoNeuronio++
      ) {
        final List<double> gradientesDoNeuronio = [];
        final double derivadaDoErroEmRelacaoAoSomatorio =
            derivadasDoErroEmRelacaoAosSomatorios[indiceDaCamada][indiceDoNeuronio];
        for (
          int indiceDaEntrada = 0;
          indiceDaEntrada <
              pesosAtuais[indiceDaCamada][indiceDoNeuronio].length;
          indiceDaEntrada++
        ) {
          final double valorDaEntrada =
              ativacoes[indiceDaCamada][indiceDaEntrada];
          final double gradienteDoPeso =
              derivadaDoErroEmRelacaoAoSomatorio * valorDaEntrada;
          gradientesDoNeuronio.add(gradienteDoPeso);
        }
        gradientesDosPesos[indiceDaCamada].add(gradientesDoNeuronio);
        final double gradienteDoVies = derivadaDoErroEmRelacaoAoSomatorio * 1;
        gradientesDosVieses[indiceDaCamada].add(gradienteDoVies);
      }
    }

    
    
    final List<List<List<double>>> novosPesos = [[], [], []];
    final List<List<double>> novosVieses = [[], [], []];
    for (
      int indiceDaCamada = pesosAtuais.length - 1;
      indiceDaCamada >= 0;
      indiceDaCamada--
    ) {
      for (
        int indiceDoNeuronio = 0;
        indiceDoNeuronio < pesosAtuais[indiceDaCamada].length;
        indiceDoNeuronio++
      ) {
        final List<double> novosPesosDoNeuronio = [];
        final List<LinhaDeCalculo> calculosDaAtualizacao = [];
        final double derivadaDoErroEmRelacaoAoSomatorio =
            derivadasDoErroEmRelacaoAosSomatorios[indiceDaCamada][indiceDoNeuronio];
        for (
          int indiceDaEntrada = 0;
          indiceDaEntrada <
              pesosAtuais[indiceDaCamada][indiceDoNeuronio].length;
          indiceDaEntrada++
        ) {
          final double valorDaEntrada =
              ativacoes[indiceDaCamada][indiceDaEntrada];
          final double pesoAnterior =
              pesosAtuais[indiceDaCamada][indiceDoNeuronio][indiceDaEntrada];
          final double gradienteDoPeso =
              gradientesDosPesos[indiceDaCamada][indiceDoNeuronio][indiceDaEntrada];
          final double ajusteDoPeso = taxaDeAprendizado * gradienteDoPeso;
          final double novoPeso = pesoAnterior - ajusteDoPeso;
          if (!novoPeso.isFinite) {
            throw StateError('Um peso excedeu a precisão numérica.');
          }
          novosPesosDoNeuronio.add(novoPeso);
          calculosDaAtualizacao.add(
            LinhaDeCalculo(
              'Gradiente do peso ${indiceDaEntrada + 1}',
              'δ × entrada = ${formatarNumero(derivadaDoErroEmRelacaoAoSomatorio)}'
                  ' × (${formatarNumero(valorDaEntrada)})'
                  ' ≈ ${formatarNumero(gradienteDoPeso)}',
            ),
          );
          calculosDaAtualizacao.add(
            LinhaDeCalculo(
              'Peso ${indiceDaEntrada + 1}: anterior → novo',
              '${formatarNumero(pesoAnterior)} − ${formatarNumero(taxaDeAprendizado)}'
                  ' × (${formatarNumero(gradienteDoPeso)})'
                  ' ≈ ${formatarNumero(novoPeso)}',
            ),
          );
        }
        novosPesos[indiceDaCamada].add(novosPesosDoNeuronio);
        final double viesAnterior =
            viesesAtuais[indiceDaCamada][indiceDoNeuronio];
        final double gradienteDoVies =
            gradientesDosVieses[indiceDaCamada][indiceDoNeuronio];
        final double ajusteDoVies = taxaDeAprendizado * gradienteDoVies;
        final double novoVies = viesAnterior - ajusteDoVies;
        if (!novoVies.isFinite) {
          throw StateError('Um viés excedeu a precisão numérica.');
        }
        novosVieses[indiceDaCamada].add(novoVies);
        calculosDaAtualizacao.add(
          LinhaDeCalculo(
            'Gradiente do viés',
            'δ × 1 = ${formatarNumero(derivadaDoErroEmRelacaoAoSomatorio)}'
                ' × 1 ≈ ${formatarNumero(gradienteDoVies)}',
          ),
        );
        calculosDaAtualizacao.add(
          LinhaDeCalculo(
            'Viés: anterior → novo',
            '${formatarNumero(viesAnterior)} − ${formatarNumero(taxaDeAprendizado)}'
                ' × (${formatarNumero(gradienteDoVies)})'
                ' ≈ ${formatarNumero(novoVies)}',
          ),
        );
        registrarEtapa(
          fase: FaseDaDemonstracao.atualizacao,
          titulo:
              'Atualizar · ${nomeDoNeuronio(indiceDaCamada + 1, indiceDoNeuronio)}',
          descricao: 'Subtraímos de cada parâmetro a taxa vezes seu gradiente.',
          formula: '∂E/∂peso = δ × entrada     parâmetro novo = anterior − η × gradiente',
          rotuloDoResultado: 'Novo viés proposto',
          resultado: formatarNumero(novoVies),
          calculos: calculosDaAtualizacao,
          observacao: 'Propostas calculadas com os pesos anteriores. Todas serão aplicadas juntas no fim da volta.',
          indiceDaCamadaEmDestaque: indiceDaCamada + 1,
          indiceDoNeuronioEmDestaque: indiceDoNeuronio,
        );
      }
    }

    
    pesosAtuais = novosPesos;
    viesesAtuais = novosVieses;
    final List<LinhaDeCalculo> calculosDoResumo = [
      const LinhaDeCalculo('Atualização conjunta', '18 pesos + 7 vieses'),
      LinhaDeCalculo('Saída medida nesta ida', formatarNumero(saidaDaRede)),
      LinhaDeCalculo('Erro medido nesta ida', formatarNumero(erroQuadratico)),
    ];
    if (numeroDoCiclo == 2) {
      calculosDoResumo.add(
        LinhaDeCalculo(
          'Erro da primeira ida → segunda ida',
          '${formatarNumero(resumos[0].erroAntesDaAtualizacao)}'
              ' → ${formatarNumero(resumos[1].erroAntesDaAtualizacao)}',
        ),
      );
    }
    registrarEtapa(
      fase: FaseDaDemonstracao.conclusao,
      titulo: numeroDoCiclo == 1
          ? 'Primeira volta concluída'
          : 'Dois ciclos concluídos',
      descricao: numeroDoCiclo == 1
          ? 'Pesos e vieses atualizados. A próxima etapa inicia a segunda ida.'
          : 'A rede completou duas idas e duas voltas.',
      formula: 'Todos os gradientes primeiro → todos os parâmetros depois',
      rotuloDoResultado: 'Atualizações concluídas',
      resultado: '$numeroDoCiclo de 2',
      calculos: calculosDoResumo,
      observacao:
          'Os valores nos neurônios pertencem à última ida. '
          'O erro após esta atualização exigiria uma nova ida.',
      parametrosJaAtualizados: true,
    );
  }

  return DemonstracaoCalculada(
    etapas: List<EtapaDaDemonstracao>.unmodifiable(etapas),
    resumos: List<ResumoDoCiclo>.unmodifiable(resumos),
    primeiraEntrada: primeiraEntrada,
    segundaEntrada: segundaEntrada,
    valorEsperado: valorEsperado,
    taxaDeAprendizado: taxaDeAprendizado,
  );
}





class AplicativoDeRedeNeural extends StatelessWidget {
  const AplicativoDeRedeNeural({super.key});

  @override
  Widget build(BuildContext contexto) {
    return MaterialApp(
      title: 'Regressão de energia · passo a passo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Fonte',
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: corDeFundo,
        colorScheme: ColorScheme.fromSeed(seedColor: corDaIda),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w700,
            color: corDoTexto,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: corDoTexto,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: corDoTexto,
          ),
          bodyLarge: TextStyle(
            color: corDoTexto,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: corDoTextoSecundario,
            height: 1.5,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: corDaBorda),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
      home: const TelaDaDemonstracao(),
    );
  }
}

Color corDaFase(FaseDaDemonstracao fase) {
  if (fase == FaseDaDemonstracao.retropropagacao) return corDaVolta;
  if (fase == FaseDaDemonstracao.atualizacao ||
      fase == FaseDaDemonstracao.conclusao) {
    return corDaAtualizacao;
  }
  return corDaIda;
}

String tituloDaFase(FaseDaDemonstracao fase) {
  switch (fase) {
    case FaseDaDemonstracao.entradas:
      return 'Preparação';
    case FaseDaDemonstracao.propagacaoDireta:
      return 'Ida · forward propagation';
    case FaseDaDemonstracao.erro:
      return 'Erro';
    case FaseDaDemonstracao.retropropagacao:
      return 'Volta · backpropagation';
    case FaseDaDemonstracao.atualizacao:
      return 'Volta · atualização';
    case FaseDaDemonstracao.conclusao:
      return 'Ciclo concluído';
  }
}

class TelaDaDemonstracao extends StatefulWidget {
  const TelaDaDemonstracao({super.key});

  @override
  State<TelaDaDemonstracao> createState() => EstadoDaTelaDaDemonstracao();
}

class EstadoDaTelaDaDemonstracao extends State<TelaDaDemonstracao> {
  final GlobalKey<FormState> chaveDoFormulario = GlobalKey<FormState>();
  final TextEditingController controladorDaPrimeiraEntrada =
      TextEditingController();
  final TextEditingController controladorDaSegundaEntrada =
      TextEditingController();
  final TextEditingController controladorDoValorEsperado =
      TextEditingController();
  final ScrollController controladorDaRolagem = ScrollController();
  final FocusNode focoDaNavegacao = FocusNode();
  DemonstracaoCalculada? demonstracao;
  int indiceDaEtapaAtual = 0;
  bool mostrarCalculosEmTelaCompacta = true;

  @override
  void initState() {
    super.initState();
    controladorDaPrimeiraEntrada.addListener(atualizarConsumoDeReferencia);
    controladorDaSegundaEntrada.addListener(atualizarConsumoDeReferencia);
  }

  void atualizarConsumoDeReferencia() {
    final double? horasDeA =
        interpretarNumero(controladorDaPrimeiraEntrada.text);
    final double? horasDeB =
        interpretarNumero(controladorDaSegundaEntrada.text);
    if (horasDeA == null ||
        horasDeB == null ||
        !horasDeA.isFinite ||
        !horasDeB.isFinite ||
        horasDeA < 0 ||
        horasDeB < 0 ||
        horasDeA > 1000 ||
        horasDeB > 1000) {
      controladorDoValorEsperado.clear();
      return;
    }
    controladorDoValorEsperado.text =
        formatarNumero(calcularConsumoDeReferencia(horasDeA, horasDeB));
  }

  @override
  void dispose() {
    controladorDaPrimeiraEntrada.removeListener(atualizarConsumoDeReferencia);
    controladorDaSegundaEntrada.removeListener(atualizarConsumoDeReferencia);
    controladorDaPrimeiraEntrada.dispose();
    controladorDaSegundaEntrada.dispose();
    controladorDoValorEsperado.dispose();
    controladorDaRolagem.dispose();
    focoDaNavegacao.dispose();
    super.dispose();
  }

  double? interpretarNumero(String? texto) {
    if (texto == null) return null;
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  String? validarEntrada(String? texto) {
    final double? numero = interpretarNumero(texto);
    if (numero == null || !numero.isFinite) return 'Digite um número válido.';
    if (numero.abs() > 1000) return 'Use um valor entre −1000 e 1000.';
    return null;
  }

  String? validarAlvo(String? texto) {
    final String? erroDaEntrada = validarEntrada(texto);
    if (erroDaEntrada != null) return erroDaEntrada;
    if (interpretarNumero(texto)! < 0) return 'A saída ReLU pede um alvo ≥ 0.';
    return null;
  }

  String? validarHoras(String? texto) {
    final String? erroDaEntrada = validarEntrada(texto);
    if (erroDaEntrada != null) return erroDaEntrada;
    if (interpretarNumero(texto)! < 0) return 'As horas devem ser ≥ 0.';
    return null;
  }

  void confirmarEntradas() {
    if (!chaveDoFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    try {
      final double horasDeA =
          interpretarNumero(controladorDaPrimeiraEntrada.text)!;
      final double horasDeB =
          interpretarNumero(controladorDaSegundaEntrada.text)!;
      final DemonstracaoCalculada
      resultadoCalculado = calcularDemonstracaoCompleta(
        primeiraEntrada: horasDeA,
        segundaEntrada: horasDeB,
        valorEsperado: calcularConsumoDeReferencia(horasDeA, horasDeB),
      );
      setState(() {
        demonstracao = resultadoCalculado;
        indiceDaEtapaAtual = 0;
        mostrarCalculosEmTelaCompacta = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        focoDaNavegacao.requestFocus();
        if (controladorDaRolagem.hasClients) controladorDaRolagem.jumpTo(0);
      });
    } on StateError catch (erro) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${erro.message}')));
    }
  }

  void preencherExemplo() {
    controladorDaPrimeiraEntrada.text = '1';
    controladorDaSegundaEntrada.text = '2';
  }

  void mudarEtapa(int deslocamento) {
    final DemonstracaoCalculada? demonstracaoAtual = demonstracao;
    if (demonstracaoAtual == null) return;
    final int proximoIndice = indiceDaEtapaAtual + deslocamento;
    if (proximoIndice < 0 || proximoIndice >= demonstracaoAtual.etapas.length)
      return;
    setState(() {
      
      indiceDaEtapaAtual = proximoIndice;
    });
    if (controladorDaRolagem.hasClients) controladorDaRolagem.jumpTo(0);
  }

  void editarEntradas() {
    setState(() {
      demonstracao = null;
      indiceDaEtapaAtual = 0;
    });
  }

  @override
  Widget build(BuildContext contexto) {
    final DemonstracaoCalculada? demonstracaoAtual = demonstracao;
    return Scaffold(
      body: SafeArea(
        child: demonstracaoAtual == null
            ? construirFormulario(contexto)
            : construirDemonstracao(contexto, demonstracaoAtual),
      ),
    );
  }

  Widget construirFormulario(BuildContext contexto) {
    return LayoutBuilder(
      builder: (contexto, restricoes) {
        final double espacamento = restricoes.maxWidth < 500 ? 20 : 40;
        return SingleChildScrollView(
          padding: EdgeInsets.all(espacamento),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: chaveDoFormulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.hub_outlined, size: 36, color: corDaIda),
                    const SizedBox(height: 24),
                    Text(
                      'Regressão do consumo\nde energia.',
                      style: Theme.of(contexto).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A rede estima o consumo total (kWh) a partir das horas '
                      'de uso de dois aparelhos idealizados.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aparelho A: 0,2 kW. Aparelho B: 0,4 kW. '
                      'As potências são constantes. O alvo simulado é calculado '
                      'automaticamente: y = 0,2 × x₁ + 0,4 × x₂.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A fórmula fornece a referência; a previsão é calculada '
                      'pela rede. Dois ciclos sobre uma única amostra ilustram '
                      'o forward e o backpropagation, sem avaliar generalização.',
                    ),
                    const SizedBox(height: 20),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Etiqueta(texto: 'Regressão · dados simulados'),
                        Etiqueta(texto: '2 → 3 → 3 → 1'),
                        Etiqueta(texto: 'ReLU'),
                        Etiqueta(texto: 'Perda: NLL gaussiana sem constante'),
                        Etiqueta(texto: '2 ciclos'),
                        Etiqueta(texto: 'Taxa 0,1'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    construirCampo(
                      controladorDaPrimeiraEntrada,
                      'Uso do aparelho A (horas) · x₁',
                      'Ex.: 1',
                      validarHoras,
                    ),
                    const SizedBox(height: 16),
                    construirCampo(
                      controladorDaSegundaEntrada,
                      'Uso do aparelho B (horas) · x₂',
                      'Ex.: 2',
                      validarHoras,
                      ultimo: true,
                    ),
                    const SizedBox(height: 16),
                    construirCampo(
                      controladorDoValorEsperado,
                      'Consumo de referência (kWh) · y',
                      'Calculado a partir das horas',
                      validarAlvo,
                      somenteLeitura: true,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Alvo simulado, exibido com arredondamento. '
                      'A saída ReLU da rede também é não negativa.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: preencherExemplo,
                      icon: const Icon(Icons.science_outlined),
                      label: const Text('Usar exemplo: A = 1 h, B = 2 h'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: confirmarEntradas,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text('Iniciar demonstração'),
                        ),
                      ),
                    ),
                
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget construirCampo(
    TextEditingController controlador,
    String rotulo,
    String exemplo,
    String? Function(String?) validador, {
    bool ultimo = false,
    bool somenteLeitura = false,
  }) {
    return TextFormField(
      controller: controlador,
      validator: validador,
      readOnly: somenteLeitura,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      textInputAction: ultimo ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: ultimo ? (_) => confirmarEntradas() : null,
      decoration: InputDecoration(labelText: rotulo, hintText: exemplo),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget construirDemonstracao(
    BuildContext contexto,
    DemonstracaoCalculada dados,
  ) {
    final EtapaDaDemonstracao etapa = dados.etapas[indiceDaEtapaAtual];
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            mudarEtapa(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            mudarEtapa(1),
      },
      child: Focus(
        focusNode: focoDaNavegacao,
        autofocus: true,
        child: LayoutBuilder(
          builder: (contexto, restricoes) {
            
            final double escalaDoTexto =
                MediaQuery.textScalerOf(contexto).scale(14) / 14;
            final bool duasColunas =
                restricoes.maxWidth >= 1080 && escalaDoTexto <= 1.4;
            final double margem = restricoes.maxWidth < 600 ? 16 : 28;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(margem, 16, margem, 12),
                  child: construirCabecalho(contexto, etapa),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controladorDaRolagem,
                    padding: EdgeInsets.fromLTRB(margem, 4, margem, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1440),
                        child: duasColunas
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: PainelDaRede(
                                      etapa: etapa,
                                      aoAbrirParametros: () =>
                                          abrirParametros(etapa),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 5,
                                    child: PainelDosCalculos(etapa: etapa),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  SegmentedButton<bool>(
                                    showSelectedIcon: false,
                                    segments: const [
                                      ButtonSegment(
                                        value: true,
                                        label: Text('Cálculos'),
                                      ),
                                      ButtonSegment(
                                        value: false,
                                        label: Text('Rede'),
                                      ),
                                    ],
                                    selected: {mostrarCalculosEmTelaCompacta},
                                    onSelectionChanged: (selecao) {
                                      setState(() {
                                        mostrarCalculosEmTelaCompacta = selecao
                                            .contains(true);
                                      });
                                      if (controladorDaRolagem.hasClients) {
                                        controladorDaRolagem.jumpTo(0);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  if (mostrarCalculosEmTelaCompacta)
                                    PainelDosCalculos(etapa: etapa)
                                  else
                                    PainelDaRede(
                                      etapa: etapa,
                                      aoAbrirParametros: () =>
                                          abrirParametros(etapa),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                construirNavegacao(contexto, dados, etapa),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget construirCabecalho(BuildContext contexto, EtapaDaDemonstracao etapa) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Row(
          children: [
            const Icon(Icons.hub_outlined, color: corDaIda),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rede neural',
                style: Theme.of(contexto).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Alterar entradas',
              onPressed: editarEntradas,
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirNavegacao(
    BuildContext contexto,
    DemonstracaoCalculada dados,
    EtapaDaDemonstracao etapa,
  ) {
    final bool primeiraEtapa = indiceDaEtapaAtual == 0;
    final bool ultimaEtapa = indiceDaEtapaAtual == dados.etapas.length - 1;
    final double progresso = (indiceDaEtapaAtual + 1) / dados.etapas.length;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: corDaBorda)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progresso,
            minHeight: 3,
            color: corDaFase(etapa.fase),
            backgroundColor: corDaBorda,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Etapa anterior (←)',
                      onPressed: primeiraEtapa ? null : () => mudarEtapa(-1),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Etapa ${indiceDaEtapaAtual + 1} de ${dados.etapas.length}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: corDoTexto,
                            ),
                          ),
                          Text(
                            'Ciclo ${etapa.numeroDoCiclo} de 2',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: corDoTextoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (ultimaEtapa)
                      IconButton.filledTonal(
                        tooltip: 'Rever desde o início',
                        onPressed: () => mudarEtapa(-indiceDaEtapaAtual),
                        icon: const Icon(Icons.replay_rounded),
                      )
                    else
                      IconButton.filled(
                        tooltip: 'Próxima etapa (→)',
                        onPressed: () => mudarEtapa(1),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void abrirParametros(EtapaDaDemonstracao etapa) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (contexto) {
        return FractionallySizedBox(
          heightFactor: 0.86,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: construirListaDeParametros(contexto, etapa),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget construirListaDeParametros(
    BuildContext contexto,
    EtapaDaDemonstracao etapa,
  ) {
    final List<Widget> itens = [
      Row(
        children: [
          Expanded(
            child: Text(
              'Pesos e vieses',
              style: Theme.of(contexto).textTheme.titleLarge,
            ),
          ),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(contexto).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      Text(
        etapa.parametrosJaAtualizados
            ? 'Após a atualização conjunta do ciclo ${etapa.numeroDoCiclo}.'
            : 'Valores usados na ida do ciclo ${etapa.numeroDoCiclo}.',
      ),
      const SizedBox(height: 20),
    ];
    for (
      int indiceDaCamada = 0;
      indiceDaCamada < etapa.pesos.length;
      indiceDaCamada++
    ) {
      for (
        int indiceDoNeuronio = 0;
        indiceDoNeuronio < etapa.pesos[indiceDaCamada].length;
        indiceDoNeuronio++
      ) {
        final List<Widget> parametros = [];
        for (
          int indiceDaEntrada = 0;
          indiceDaEntrada <
              etapa.pesos[indiceDaCamada][indiceDoNeuronio].length;
          indiceDaEntrada++
        ) {
          parametros.add(
            SelectableText(
              'Peso da conexão ${indiceDaEntrada + 1}: '
              '${formatarNumero(etapa.pesos[indiceDaCamada][indiceDoNeuronio][indiceDaEntrada])}',
            ),
          );
        }
        parametros.add(
          SelectableText(
            'Viés: ${formatarNumero(etapa.vieses[indiceDaCamada][indiceDoNeuronio])}',
          ),
        );
        itens.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeDoNeuronio(indiceDaCamada + 1, indiceDoNeuronio),
                  style: Theme.of(contexto).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                ...parametros,
              ],
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: itens,
    );
  }
}

class Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;
  const Etiqueta({
    super.key,
    required this.texto,
    this.cor = corDoTextoSecundario,
  });

  @override
  Widget build(BuildContext contexto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor),
      ),
    );
  }
}

class Superficie extends StatelessWidget {
  final Widget child;
  const Superficie({super.key, required this.child});

  @override
  Widget build(BuildContext contexto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: corDaBorda),
      ),
      child: child,
    );
  }
}

class PainelDosCalculos extends StatelessWidget {
  final EtapaDaDemonstracao etapa;
  const PainelDosCalculos({super.key, required this.etapa});

  @override
  Widget build(BuildContext contexto) {
    final Color corAtual = corDaFase(etapa.fase);
    final List<Widget> linhas = [];
    for (
      int indiceDoCalculo = 0;
      indiceDoCalculo < etapa.calculos.length;
      indiceDoCalculo++
    ) {
      final LinhaDeCalculo calculo = etapa.calculos[indiceDoCalculo];
      linhas.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                calculo.rotulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: corDoTextoSecundario,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                calculo.expressao,
                style: const TextStyle(
                  fontSize: 15,
                  color: corDoTexto,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
      if (indiceDoCalculo < etapa.calculos.length - 1) {
        linhas.add(const Divider(height: 1, color: corDaBorda));
      }
    }
    return Superficie(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Etiqueta(texto: tituloDaFase(etapa.fase), cor: corAtual),
          const SizedBox(height: 18),
          Text(etapa.titulo, style: Theme.of(contexto).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(etapa.descricao),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: corDeFundo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              etapa.formula,
              style: const TextStyle(color: corDoTexto, height: 1.6),
            ),
          ),
          const SizedBox(height: 12),
          ...linhas,
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: corAtual.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etapa.rotuloDoResultado,
                  style: TextStyle(fontSize: 12, color: corAtual),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  etapa.fase == FaseDaDemonstracao.conclusao
                      ? etapa.resultado
                      : '≈ ${etapa.resultado}',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: corAtual,
                  ),
                ),
              ],
            ),
          ),
          if (etapa.observacao.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              etapa.observacao,
              style: const TextStyle(
                fontSize: 12,
                color: corDoTextoSecundario,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PainelDaRede extends StatelessWidget {
  final EtapaDaDemonstracao etapa;
  final VoidCallback aoAbrirParametros;
  const PainelDaRede({
    super.key,
    required this.etapa,
    required this.aoAbrirParametros,
  });

  @override
  Widget build(BuildContext contexto) {
    return Superficie(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Arquitetura da rede',
                style: Theme.of(contexto).textTheme.titleMedium,
              ),
              Etiqueta(
                texto: 'Ciclo ${etapa.numeroDoCiclo} / 2',
                cor: corDaFase(etapa.fase),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (contexto, restricoes) {
              final double escalaDoTexto =
                  MediaQuery.textScalerOf(contexto).scale(14) / 14;
              
              
              final double escalaGrafica = matematica.max(1.0, escalaDoTexto);
              final bool orientacaoVertical =
                  restricoes.maxWidth < 480 * escalaGrafica;
              final double larguraMinima =
                  (orientacaoVertical ? 240 : 480) * escalaGrafica;
              final double larguraDoDesenho = matematica.max(
                restricoes.maxWidth,
                larguraMinima,
              );
              final double alturaDoDesenho =
                  (orientacaoVertical ? 500 : 400) * escalaGrafica;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Semantics(
                  label:
                      'Rede com duas entradas, três neurônios na primeira camada oculta, '
                      'três na segunda e uma saída. ${etapa.titulo}.',
                  child: SizedBox(
                    width: larguraDoDesenho,
                    height: alturaDoDesenho,
                    child: CustomPaint(
                      painter: DesenhoDaRede(
                        etapa: etapa,
                        escalaDoTexto: escalaDoTexto,
                        orientacaoVertical: orientacaoVertical,
                        familiaDaFonte: Theme.of(contexto)
                            .textTheme
                            .bodyMedium
                            ?.fontFamily,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              construirLegenda('Etapa atual', corDaFase(etapa.fase)),
              construirLegenda('Ativação zero', corDoTextoSecundario),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: corDaBorda),
          TextButton.icon(
            onPressed: aoAbrirParametros,
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            label: Text(
              etapa.parametrosJaAtualizados
                  ? 'Ver parâmetros atualizados'
                  : 'Ver pesos e vieses desta ida',
            ),
          ),
          const Text(
            '≈ valores arredondados · cálculos com precisão completa',
            style: TextStyle(fontSize: 11, color: corDoTextoSecundario),
          ),
        ],
      ),
    );
  }

  Widget construirLegenda(String texto, Color cor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(fontSize: 11, color: corDoTextoSecundario),
        ),
      ],
    );
  }
}






class DesenhoDaRede extends CustomPainter {
  final EtapaDaDemonstracao etapa;
  final double escalaDoTexto;
  final bool orientacaoVertical;
  final String? familiaDaFonte;
  DesenhoDaRede({
    required this.etapa,
    required this.escalaDoTexto,
    required this.orientacaoVertical,
    required this.familiaDaFonte,
  });

  void desenharTexto(
    Canvas tela,
    String texto,
    Offset centro,
    double tamanho,
    Color cor, {
    FontWeight peso = FontWeight.w500,
    double larguraMaxima = 130,
  }) {
    final TextPainter pintorDoTexto = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          fontSize: tamanho,
          color: cor,
          fontWeight: peso,
          fontFamily: familiaDaFonte,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      textScaler: TextScaler.linear(escalaDoTexto),
    );
    pintorDoTexto.layout(maxWidth: larguraMaxima);
    
    final Rect fundoDoTexto = Rect.fromCenter(
      center: centro,
      width: pintorDoTexto.width + 4,
      height: pintorDoTexto.height + 2,
    );
    tela.drawRect(fundoDoTexto, Paint()..color = Colors.white);
    pintorDoTexto.paint(
      tela,
      Offset(
        centro.dx - pintorDoTexto.width / 2,
        centro.dy - pintorDoTexto.height / 2,
      ),
    );
  }

  @override
  void paint(Canvas tela, Size tamanho) {
    final List<int> quantidadesDeNeuronios = [2, 3, 3, 1];
    final List<List<Offset>> posicoesDasCamadas = [];
    final double escalaGrafica = matematica.max(1.0, escalaDoTexto);
    final double margemHorizontal = 40 * escalaGrafica;
    final double raioDoNeuronio = 22 * escalaGrafica;
    for (
      int indiceDaCamada = 0;
      indiceDaCamada < quantidadesDeNeuronios.length;
      indiceDaCamada++
    ) {
      final List<Offset> posicoesDosNeuronios = [];
      final double posicaoHorizontalDaCamada =
          margemHorizontal +
          (tamanho.width - margemHorizontal * 2) * indiceDaCamada / 3;
      final int quantidadeDeNeuronios = quantidadesDeNeuronios[indiceDaCamada];
      for (
        int indiceDoNeuronio = 0;
        indiceDoNeuronio < quantidadeDeNeuronios;
        indiceDoNeuronio++
      ) {
        final double posicaoVerticalNaCamada =
            62 * escalaGrafica +
            (tamanho.height - 104 * escalaGrafica) *
                (indiceDoNeuronio + 1) /
                (quantidadeDeNeuronios + 1);
        if (orientacaoVertical) {
          
          final double posicaoHorizontalDistribuida = quantidadeDeNeuronios == 1
              ? tamanho.width / 2
              : margemHorizontal +
                    (tamanho.width - margemHorizontal * 2) *
                        indiceDoNeuronio /
                        (quantidadeDeNeuronios - 1);
          final double posicaoVertical =
              58 * escalaGrafica +
              (tamanho.height - 130 * escalaGrafica) * indiceDaCamada / 3;
          posicoesDosNeuronios.add(
            Offset(posicaoHorizontalDistribuida, posicaoVertical),
          );
        } else {
          posicoesDosNeuronios.add(
            Offset(posicaoHorizontalDaCamada, posicaoVerticalNaCamada),
          );
        }
      }
      posicoesDasCamadas.add(posicoesDosNeuronios);
    }

    final Color corAtual = corDaFase(etapa.fase);
    final bool fluxoDeVolta = etapa.fase == FaseDaDemonstracao.retropropagacao;
    for (
      int indiceDaCamada = 0;
      indiceDaCamada < posicoesDasCamadas.length - 1;
      indiceDaCamada++
    ) {
      for (
        int indiceDaOrigem = 0;
        indiceDaOrigem < posicoesDasCamadas[indiceDaCamada].length;
        indiceDaOrigem++
      ) {
        for (
          int indiceDoDestino = 0;
          indiceDoDestino < posicoesDasCamadas[indiceDaCamada + 1].length;
          indiceDoDestino++
        ) {
          final bool conexaoDeEntradaAtiva =
              etapa.indiceDaCamadaEmDestaque == indiceDaCamada + 1 &&
              etapa.indiceDoNeuronioEmDestaque == indiceDoDestino;
          final bool conexaoDeSaidaAtiva =
              fluxoDeVolta &&
              etapa.indiceDaCamadaEmDestaque == indiceDaCamada &&
              etapa.indiceDoNeuronioEmDestaque == indiceDaOrigem;
          final bool emDestaque = fluxoDeVolta
              ? conexaoDeSaidaAtiva
              : conexaoDeEntradaAtiva;
          final Paint pincel = Paint()
            ..color = emDestaque ? corAtual.withValues(alpha: 0.65) : corDaBorda
            ..strokeWidth = emDestaque ? 2 : 1;
          final Offset origem =
              posicoesDasCamadas[indiceDaCamada][indiceDaOrigem];
          final Offset destino =
              posicoesDasCamadas[indiceDaCamada + 1][indiceDoDestino];
          tela.drawLine(origem, destino, pincel);
          if (emDestaque) {
            final Offset direcao = fluxoDeVolta
                ? origem - destino
                : destino - origem;
            final double angulo = matematica.atan2(direcao.dy, direcao.dx);
            final Offset ponta = fluxoDeVolta
                ? Offset.lerp(destino, origem, 0.6)!
                : Offset.lerp(origem, destino, 0.6)!;
            final double comprimentoDaSeta = 7 * escalaGrafica;
            final Path seta = Path();
            seta.moveTo(ponta.dx, ponta.dy);
            seta.lineTo(
              ponta.dx - comprimentoDaSeta * matematica.cos(angulo - 0.5),
              ponta.dy - comprimentoDaSeta * matematica.sin(angulo - 0.5),
            );
            seta.lineTo(
              ponta.dx - comprimentoDaSeta * matematica.cos(angulo + 0.5),
              ponta.dy - comprimentoDaSeta * matematica.sin(angulo + 0.5),
            );
            seta.close();
            tela.drawPath(seta, Paint()..color = corAtual);
          }
        }
      }
    }

    final List<String> titulos = ['Entradas', 'Oculta 1', 'Oculta 2', 'Saída'];
    for (
      int indiceDaCamada = 0;
      indiceDaCamada < posicoesDasCamadas.length;
      indiceDaCamada++
    ) {
      desenharTexto(
        tela,
        titulos[indiceDaCamada],
        orientacaoVertical
            ? Offset(
                tamanho.width / 2,
                posicoesDasCamadas[indiceDaCamada][0].dy - 38 * escalaGrafica,
              )
            : Offset(
                posicoesDasCamadas[indiceDaCamada][0].dx,
                16 * escalaGrafica,
              ),
        11,
        corDoTextoSecundario,
        larguraMaxima: 85 * escalaGrafica,
      );
      for (
        int indiceDoNeuronio = 0;
        indiceDoNeuronio < posicoesDasCamadas[indiceDaCamada].length;
        indiceDoNeuronio++
      ) {
        final Offset centro =
            posicoesDasCamadas[indiceDaCamada][indiceDoNeuronio];
        final bool emDestaque =
            etapa.indiceDaCamadaEmDestaque == indiceDaCamada &&
            etapa.indiceDoNeuronioEmDestaque == indiceDoNeuronio;
        final double? valor =
            etapa.valoresDosNeuronios[indiceDaCamada][indiceDoNeuronio];
        final bool ativacaoZero = indiceDaCamada > 0 && valor == 0;
        final Color corDoNeuronio = emDestaque
            ? corAtual
            : (ativacaoZero ? corDoTextoSecundario : corDaIda);
        tela.drawCircle(centro, raioDoNeuronio, Paint()..color = Colors.white);
        tela.drawCircle(
          centro,
          raioDoNeuronio,
          Paint()
            ..color = corDoNeuronio.withValues(
              alpha: emDestaque ? 0.10 : 0.035,
            ),
        );
        tela.drawCircle(
          centro,
          raioDoNeuronio,
          Paint()
            ..color = valor == null ? corDaBorda : corDoNeuronio
            ..style = PaintingStyle.stroke
            ..strokeWidth = emDestaque ? 2.5 : 1.2,
        );
        final String rotulo = indiceDaCamada == 0
            ? 'x${indiceDoNeuronio + 1}'
            : (indiceDaCamada == 3 ? 'ŷ' : '${indiceDoNeuronio + 1}');
        desenharTexto(
          tela,
          rotulo,
          centro,
          14,
          valor == null ? corDoTextoSecundario : corDoNeuronio,
          peso: FontWeight.w600,
          larguraMaxima: 40 * escalaGrafica,
        );
        desenharTexto(
          tela,
          valor == null ? '—' : formatarNumero(valor),
          Offset(centro.dx, centro.dy + raioDoNeuronio + 16 * escalaGrafica),
          10,
          corDoTexto,
          larguraMaxima: 85 * escalaGrafica,
        );
      }
    }
    final String direcaoDoFluxo = fluxoDeVolta
        ? '← gradientes'
        : (etapa.fase == FaseDaDemonstracao.atualizacao
              ? 'Atualizações propostas'
              : (etapa.parametrosJaAtualizados
                    ? 'Parâmetros atualizados'
                    : (orientacaoVertical ? 'ativações ↓' : 'ativações →')));
    desenharTexto(
      tela,
      fluxoDeVolta && orientacaoVertical ? '↑ gradientes' : direcaoDoFluxo,
      Offset(tamanho.width / 2, tamanho.height - 12 * escalaGrafica),
      11,
      corAtual,
      larguraMaxima: tamanho.width,
    );
  }

  @override
  bool shouldRepaint(covariant DesenhoDaRede desenhoAnterior) {
    return desenhoAnterior.etapa != etapa ||
        desenhoAnterior.escalaDoTexto != escalaDoTexto ||
        desenhoAnterior.orientacaoVertical != orientacaoVertical ||
        desenhoAnterior.familiaDaFonte != familiaDaFonte;
  }
}
