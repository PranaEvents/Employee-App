class ScannedCountData {
  final int totalScannedCount;
  final int totalEmployees;

  ScannedCountData({required this.totalScannedCount, required this.totalEmployees});

  factory ScannedCountData.fromJson(Map<String, dynamic> json) {
    return ScannedCountData(
      totalScannedCount: json['totalScanedCount'],
      totalEmployees: json['totalEmployees'],
    );
  }

  get totalItems => null;
}
