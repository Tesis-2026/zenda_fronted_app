/// Maps a topic/quiz difficulty to its Spanish display label.
///
/// The real backend sends the enum form (`BEGINNER` / `INTERMEDIATE` /
/// `ADVANCED`) while demo/mock data already uses Spanish. This resolves both,
/// case-insensitively, so the Spanish-only UI never leaks the English enum.
String difficultyEs(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  switch (raw.toLowerCase()) {
    case 'beginner':
    case 'principiante':
      return 'Principiante';
    case 'intermediate':
    case 'intermedio':
      return 'Intermedio';
    case 'advanced':
    case 'avanzado':
      return 'Avanzado';
    default:
      return raw;
  }
}
