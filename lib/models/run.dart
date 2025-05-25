//หน้าที่
// 1.เอาไว้แพ็คข้อมูล
// 2.แปลง json ไปเป็น dart
// 3.แปลง dart ไปเป็น json

class Run {
  int? runId;
  String? runLocation;
  double? runDistance;
  int? runTime;

  Run({this.runId, this.runLocation, this.runDistance, this.runTime});

  Run.fromJson(Map<String, dynamic> json) {
    runId = json['runId'];
    runLocation = json['runLocation'];
    runDistance = double.parse(json['runDistance'].toString()); //float > toString > double
    runTime = json['runTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['runId'] = this.runId;
    data['runLocation'] = this.runLocation;
    data['runDistance'] = this.runDistance;
    data['runTime'] = this.runTime;
    return data;
  }
}
