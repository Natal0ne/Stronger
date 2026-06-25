class SerieEsercizio {
  final int numeroSerie; // Es "1", "2", "3", "4"
  final int ripetizioni;
  final double caricoKg;
  final bool completata;

  SerieEsercizio({
    required this.numeroSerie,
    required this.ripetizioni,
    required this.caricoKg,
    this.completata = false,
  });
}
