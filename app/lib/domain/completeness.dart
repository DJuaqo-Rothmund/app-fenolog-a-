/// Un registro está completo cuando tiene estado fenológico y al menos una foto.
bool isObservationComplete({required bool hasStage, required int photoCount}) => hasStage && photoCount > 0;

class WeekProgress {
  const WeekProgress({required this.complete, required this.total});
  final int complete;
  final int total;

  double get fraction => total == 0 ? 0 : complete / total;
  bool get isDone => total > 0 && complete == total;
}
