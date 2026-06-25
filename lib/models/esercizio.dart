class Esercizio {
  final String id; //Id univoco per esercizio
  final String nome;
  final String descrizione; // Breve descrizione su come farlo
  final String gruppoMuscolarePrincipale;
  final String difficolta; // "principiante", "intermedio", "avanzato"
  final String
  attrezzatura; // "manubrio", "macchinario", "bilanciere", "corpo libero"
  final int ripetizioniConsigliate;
  final String note; // Note opzionali dell'utente

  Esercizio({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.gruppoMuscolarePrincipale,
    required this.difficolta,
    required this.attrezzatura,
    required this.ripetizioniConsigliate,
    this.note = "", // Note vuote di default
  });
}
