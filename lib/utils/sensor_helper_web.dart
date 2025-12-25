import 'dart:js_util' as js_util;

Future<bool> requestSensorPermission() async {
  try {
    final result = await js_util.promiseToFuture(
      js_util.callMethod(js_util.globalThis, 'requestDeviceMotionPermission', [])
    );
    return result == true;
  } catch (e) {
    print('Error requesting sensor permission: $e');
    return false;
  }
}

List<double> getWebAccelerometerData() {
  try {
    final data = js_util.getProperty(js_util.globalThis, 'latestAccelerometerData');
    if (data != null) {
      final x = js_util.getProperty(data, 'x');
      final y = js_util.getProperty(data, 'y');
      final z = js_util.getProperty(data, 'z');
      return [
        (x as num).toDouble(),
        (y as num).toDouble(),
        (z as num).toDouble()
      ];
    }
  } catch (e) {
    // Ignore
  }
  return [0.0, 0.0, 0.0];
}
