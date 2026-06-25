import 'package:strong/models/serie_esercizio.dart';

class EsercizioSvolto {
  final String idEsercizio;
  final List<SerieEsercizio> serie;

  EsercizioSvolto({required this.idEsercizio, required this.serie});
}

class Sessione {
  final String id;
  final String titolo; // Esempio "Allenamento Lunedì - Petto"
  final DateTime data; // Giorno e ora dell'allenamento
  final String idScheda; // Riferimento alla scheda utilizzata

  final List<EsercizioSvolto> eserciziSvolti;

  final int durataMinuti; // Durata effettiva dell'allenamento
  final String stato; // "Pianificata", "Completata", "Saltata"
  final int livelloFatica; // Livello di fatica in range 1-5
  final String note;

  Sessione({
    required this.id,
    required this.titolo,
    required this.data,
    required this.idScheda,
    required this.eserciziSvolti,
    required this.durataMinuti,
    required this.stato,
    this.livelloFatica = 0,
    this.note = "",
  });

  double get volumeTotaleSollevato {
    double totale = 0.0;
    for (var es in eserciziSvolti) {
      for (var s in es.serie) {
        if (s.completata) {
          totale += s.caricoKg * s.ripetizioni;
        }
      }
    }
    return totale;
  }
}
