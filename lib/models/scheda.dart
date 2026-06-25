class Scheda {
  final String id;
  final String nome; // Esempio "Scheda Petto"
  final String descrizione;
  final String obiettivo; // Esempio "Ipertrofia" o "Forza"
  final String durataPrevistaMinuti; // Esempio "60"

  final List<String> idEserciziInclusi; // Lista di esercizi della scheda

  Scheda({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.obiettivo,
    required this.durataPrevistaMinuti,
    required this.idEserciziInclusi,
  });
}
