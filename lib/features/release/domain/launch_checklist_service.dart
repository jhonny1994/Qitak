import 'package:qitak_app/features/release/domain/launch_operations_models.dart';

class LaunchChecklistService {
  LaunchDecision evaluate(List<ChecklistPrerequisite> prerequisites) {
    if (prerequisites.isEmpty) return LaunchDecision.hold;
    for (final prerequisite in prerequisites) {
      if (prerequisite.status != SignalStatus.pass) return LaunchDecision.hold;
    }
    return LaunchDecision.go;
  }
}
