import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_run_record_app/models/run.dart';


class UpDelRunUI extends StatefulWidget {
  /// ตัวแปรรับข้อมูลมาแสดงผลจากอีกหน้าจอหนึ่ง
  int? runId;
  String? runLocation;
  double? runDistance;
  int? runTime;

  // เอาตัวแปรมารับข้อมูล
  UpDelRunUI(
      {super.key,
      this.runId,
      this.runLocation,
      this.runDistance,
      this.runTime});

  @override
  State<UpDelRunUI> createState() => _UpDelRunUIState();
}

class _UpDelRunUIState extends State<UpDelRunUI> {
  // สร้างตัวควบคุม TextField
  TextEditingController runLocationCtrl = TextEditingController();
  TextEditingController runDistanceCtrl = TextEditingController();
  TextEditingController runTimeCtrl = TextEditingController();

  // Dialog คำเตือนเมื่อกรอกข้อมูลไม่ครบถ้วน
  Future<void> _showWarningDialog(String msg) async {
    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('คำเตือน'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog สำหรับแสดงผลการบันทึกข้อมูล
  Future<void> _showResultDialog(String msg) async {
    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ผลการทำงาน'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // เอาค่าที่ส่งมาไปกำหนดให้ Ctrl ตอนหน้าจอถูกเปิด
  @override
  void initState() {
    runLocationCtrl.text = widget.runLocation!;
    runDistanceCtrl.text = widget.runDistance.toString();
    runTimeCtrl.text = widget.runTime.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'แก้ไข/ลบการวิ่งของฉัน',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // ปิดคีย์บอร์ดเมื่อแตะที่พื้นที่ว่าง
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 60.0),
                  Image.asset(
                    'assets/images/runner.png',
                    width: 200.0,
                  ),
                  const SizedBox(height: 20.0),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'สถานที่วิ่ง',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: runLocationCtrl,
                    decoration: const InputDecoration(
                      hintText: 'กรุณากรอกสถานที่วิ่ง',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ระยะทางที่วิ่ง (กิโลเมตร)',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: runDistanceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'กรุณากรอกระยะทางที่วิ่ง',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'เวลาที่ใช้ในการวิ่ง (นาที)',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: runTimeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'กรุณากรอกเวลาที่ใช้ในการวิ่ง',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (runLocationCtrl.text.isEmpty) {
                        await _showWarningDialog('กรุณากรอกข้อมูลสถานที่วิ่ง');
                      } else if (runDistanceCtrl.text.isEmpty) {
                        await _showWarningDialog('กรุณากรอกระยะทางที่วิ่ง');
                      } else if (runTimeCtrl.text.isEmpty) {
                        await _showWarningDialog('กรุณากรอกเวลาในการวิ่ง');
                      } else {
                        // ถ้ากรอกข้อมูลครบถ้วนแล้ว ทำการบันทึกข้อมูล
                        // แพ็กข้อมูล
                        Run run = Run(
                          runLocation: runLocationCtrl.text,
                          runDistance: double.parse(runDistanceCtrl.text),
                          runTime: int.parse(runTimeCtrl.text),
                        );
          
                        // ส่งเป็น JSON
                        final result = await Dio().put(
                          'http://172.17.36.43:5090/api/run/${widget.runId}',
                          data: run.toJson(),
                        );
          
                        // ตรวจสอบผลลัพธ์
                        if(result.statusCode == 200) {
                          await _showResultDialog('บันทึกแก้ไขการวิ่งสำเร็จ').then((value){
                            Navigator.pop(context); // กลับไปหน้าจอวิ่ง
                          });
                        } else {
                          await _showWarningDialog('บันทึกแก้ไขการวิ่งไม่สําเร็จ');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      fixedSize: Size(MediaQuery.of(context).size.width, 60.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'บันทึกแก้ไขการวิ่ง',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () async {
                     final result = await Dio().delete(
                          'http://172.17.36.43:5090/api/run/${widget.runId}',
                        );
          
                        // ตรวจสอบผลลัพธ์
                        if(result.statusCode == 200) {
                          await _showResultDialog('บันทึกแก้ไขการวิ่งสำเร็จ').then((value){
                            Navigator.pop(context); // กลับไปหน้าจอวิ่ง
                          });
                        } else {
                          await _showWarningDialog('บันทึกแก้ไขการวิ่งไม่สําเร็จ');
                        }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      fixedSize: Size(MediaQuery.of(context).size.width, 60.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'ลบการวิ่ง',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
