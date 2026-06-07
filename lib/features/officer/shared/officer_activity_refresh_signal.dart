import 'package:flutter/foundation.dart';

final ValueNotifier<int> officerActivityRefreshSignal = ValueNotifier<int>(0);

void notifyOfficerActivityChanged() {
  officerActivityRefreshSignal.value++;
}
