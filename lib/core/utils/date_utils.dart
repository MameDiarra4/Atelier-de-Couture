String formatDateHeure(DateTime d) {
  final jours = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final jour = jours[d.weekday];
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return "$jour ${d.day}/${d.month} à $h:$m";
}
