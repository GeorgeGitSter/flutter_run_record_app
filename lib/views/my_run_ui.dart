// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_run_record_app/models/run.dart';
import 'package:flutter_run_record_app/views/insert_run_ui.dart';
import 'package:flutter_run_record_app/views/up_del_run_ui.dart';

class MyRunUI extends StatefulWidget {
  const MyRunUI({super.key});

  @override
  State<MyRunUI> createState() => _MyRunUIState();
}

class _MyRunUIState extends State<MyRunUI> {
  // สร้างตัวแปรที่เก็บข้อมูลที่ดึงจาก Database ผ่าน API
  // myRuns เป็นตัวแปรข้อมูลประเทภ Run , List เก็บได้หลายรายการ
  late Future<List<Run>> myRuns;

  // สร้าง Method ที่ถึงข้อมูลจาก Database จาก API
  Future<List<Run>> fetchMyRuns() async {
    // คำสั่งดึงข้อมูล
    try {
      final response = await Dio().get('http://172.17.36.43:5090/api/run');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['result'] as List<dynamic>;
        return data.map((json) => Run.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load runs');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load runs: ${e.message}');
    }
  }

  // initState จะทํางานก่อนเริ่มการแสดงผล หรือ ตอนหน้าจอถูกเปิด
  @override
  void initState() {
    // ดึงข้อมูลจาก API แล้วเก็บใน myRuns
    // ทำทางขวา
    myRuns = fetchMyRuns();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'My Run Record',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset(
              'assets/images/runner.png',
              width: 200,
            ),
            SizedBox(
              height: 30,
            ),
            FutureBuilder<List<Run>>(
              future: myRuns,
              // builder จะทํางานเมื่อข้อมูลโหลดเสร็จ
              // snapshot จะเก็บข้อมูลที่โหลด หรือ sync กับ myRuns
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  //
                  List<Run> runs = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: runs.length,
                      itemBuilder: (context, index) {
                        Run run = runs[index];
                        return ListTile(
                          onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpDelRunUI(
                                runId: run.runId,
                                runLocation: run.runLocation,
                                runDistance: run.runDistance,
                                runTime: run.runTime,
                              ),
                            )
                          );
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          title: Text(
                            'สถานที่วิ่ง: ' + run.runLocation!,
                          ),
                          subtitle: Text(
                            'ระยะทางวิ่ง: ' +
                                run.runDistance!.toString() +
                                ' km',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Colors.purple),
                          tileColor:
                              index % 2 == 0 ? Colors.white : Colors.grey[200],
                        );
                      },
                    ),
                  );
                } else {
                  return const Text('No runs found.');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InsertRunUI(),
            ),
            
          ).then((Value) {
            // เมื่อกลับมาจาก InsertRunUI ให้รีเฟรชข้อมูลใหม่
            setState(() {
              myRuns = fetchMyRuns();
            });
          });
        },
        label: Text(
          'Add New Run',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
