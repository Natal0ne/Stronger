class Obiettivo {
  final String id;
  final String titolo;
  final String categoria;

  final double valoreTarget;
  final double valoreAttuale;

  final DateTime dataInizio;
  final String stato;

  Obiettivo({
    required this.id,
    required this.titolo,
    required this.categoria,
    required this.valoreTarget,
    required this.valoreAttuale,
    required this.dataInizio,
    required this.stato,
  });

  double get percentualeAvanzamento {
    if (valoreTarget == 0) return 0.0;
    double percentuale = (valoreAttuale / valoreTarget) * 100;
    return percentuale > 100 ? 100.0 : percentuale;
  }
}
