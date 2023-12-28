import 'package:bawangmerah/component/list_colours.dart';
import 'package:bawangmerah/model/waktuPenyiraman.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PageRemote extends StatefulWidget {
  const PageRemote({super.key});

  @override
  State<PageRemote> createState() => _PageRemoteState();
}

class _PageRemoteState extends State<PageRemote> {
  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  List<String> nameMenu = ['Waktu\nPenyiraman', 'Lama\nPenyiraman'];
  final TextEditingController _textController = TextEditingController();
  final CountDownController _controllerTime = CountDownController();
  int minute = 0;
  bool startimer = false;
  bool isAutoMode = true;

  int selected = 0;
  bool light = true;
  List<IconData> nameIcons = [
    Icons.alarm,
    Icons.timer_outlined,
  ];

  List<TimePenyiraman> dataPenyiraman = [];
  TimeOfDay selectedTimeStart = TimeOfDay.now();
  TimeOfDay selectedTimeEnd = TimeOfDay.now();

  Future<void> saveLamaPenyiramanToFirebase(int durationInMinutes) async {
    try {
      await FirebaseFirestore.instance
          .collection('LamaPenyiraman')
          .doc('lamapenyiraman1')
          .set({
        'menit': durationInMinutes,
      });
    } catch (e) {
      print('Error saving Lama Penyiraman data: $e');
    }
  }

  Future<void> _showInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atur Durasi'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                height: 50,
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: "Masukan Durasi",
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const Text("Menit")
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  int getTime = int.parse(_textController.text);
                  minute = getTime * 60;
                  print("waktu terpilih = ${minute.toString()}");
                  startimer = true;
                  _controllerTime.restart(duration: minute);
                });

                startimer = true;
                _controllerTime.restart(duration: minute);
                await saveLamaPenyiramanToFirebase(minute);
                Navigator.of(context).pop();
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
  }

  Future<int> getCountOfDocuments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('WaktuPenyiraman').get();
    return querySnapshot.size;
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('WaktuPenyiraman').get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          dataPenyiraman = querySnapshot.docs.map((doc) {
            return TimePenyiraman(
              waktu: "${doc['selectedTimeStart'].toDate().hour}:${doc['selectedTimeStart'].toDate().minute} - ${doc['selectedTimeEnd'].toDate().hour}:${doc['selectedTimeEnd'].toDate().minute}",
              active: true,
            );
          }).toList();
        });
      } else {
        setState(() {
          dataPenyiraman = [];
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> savePenyiramanToFirebase() async {
    int documentCount = await getCountOfDocuments();

    Timestamp startTime = Timestamp.fromDate(
      DateTime(
        1970,
        1,
        1,
        selectedTimeStart.hour,
        selectedTimeStart.minute,
      ),
    );

    Timestamp endTime = Timestamp.fromDate(
      DateTime(
        2070,
        12,
        31,
        selectedTimeEnd.hour,
        selectedTimeEnd.minute,
      ),
    );

    try {
      await FirebaseFirestore.instance
          .collection('WaktuPenyiraman')
          .doc('waktupenyiraman${documentCount + 1}')
          .set({
        'selectedTimeStart': startTime,
        'selectedTimeEnd': endTime,
      });
      await fetchDataFromFirebase();
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<void> saveEditedPenyiraman(int index) async {
    Timestamp startTime = Timestamp.fromDate(
      DateTime(
        1970,
        1,
        1,
        selectedTimeStart.hour,
        selectedTimeStart.minute,
      ),
    );

    Timestamp endTime = Timestamp.fromDate(
      DateTime(
        2070,
        12,
        31,
        selectedTimeEnd.hour,
        selectedTimeEnd.minute,
      ),
    );

    try {
      await FirebaseFirestore.instance
          .collection('WaktuPenyiraman')
          .doc('waktupenyiraman$index')
          .update({
        'selectedTimeStart': startTime,
        'selectedTimeEnd': endTime,
      });
      await fetchDataFromFirebase();
    } catch (e) {
      print('Error saving edited data: $e');
    }
  }

  void editPenyiraman(int index) async {
    final TimeOfDay? timeofDayStrt = await showTimePicker(
      context: context,
      helpText: "Waktu Mulai",
      initialTime: selectedTimeStart,
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (timeofDayStrt != null) {
      setState(() {
        selectedTimeStart = timeofDayStrt;
      });
    }

    final TimeOfDay? timeofDayEnd = await showTimePicker(
      context: context,
      helpText: "Waktu Selesai",
      initialTime: selectedTimeEnd,
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (timeofDayEnd != null) {
      setState(() {
        selectedTimeEnd = timeofDayEnd;
      });
    }

    await saveEditedPenyiraman(index + 1);
  }

  Future<void> deletePenyiramanFromFirebase(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('WaktuPenyiraman').doc(documentId).delete();
      await fetchDataFromFirebase();
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  Future<void> updateConditionToFirestore(String condition) async {
    try {
      await FirebaseFirestore.instance
          .collection('LamaPenyiraman')
          .doc('lamapenyiraman2')
          .set({
        'condition': condition,
      });
    } catch (e) {
      print('Error updating condition to Firestore: $e');
    }
  }

  //------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Atur Penyiraman\nAnda!",
                    style: GoogleFonts.abel(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isAutoMode = true;
                              updateConditionToFirestore('Otomatis');
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isAutoMode
                                    ? Colors.purple
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Penyiraman Otomatis",
                                    style: GoogleFonts.abel(),
                                  ),
                                  Switch(
                                    value: isAutoMode,
                                    onChanged: (value) {
                                      setState(() {
                                        isAutoMode = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isAutoMode = false;
                              updateConditionToFirestore('Manual');
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isAutoMode
                                    ? Colors.transparent
                                    : Colors.purple,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Penyiraman Manual",
                                    style: GoogleFonts.abel(),
                                  ),
                                  Switch(
                                    value: !isAutoMode,
                                    onChanged: (value) {
                                      setState(() {
                                        isAutoMode = !value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isAutoMode)
                    Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Lama Penyiraman",
                          style: GoogleFonts.abel(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${minute / 60} Menit",
                          style: GoogleFonts.abel(fontSize: 40),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showInputDialog(context);
                                },
                                child: const Text("Atur Waktu"),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            if (minute != 0 && startimer == true)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _controllerTime.reset();
                                      minute = 0;
                                    });
                                    saveLamaPenyiramanToFirebase(0);
                                  },
                                  child: Text("Berhenti"),
                                ),
                              ),
                          ],
                        ),

                        minute != 0
                            ? Column(
                          children: [
                            CircularCountDownTimer(
                              duration: minute,
                              initialDuration: 0,
                              controller: _controllerTime,
                              width: 280,
                              height: 310,
                              ringColor: Colors.grey[300]!,
                              ringGradient: null,
                              fillColor: Colors.purpleAccent[100]!,
                              fillGradient: null,
                              backgroundColor: ColoursList.purple,
                              backgroundGradient: null,
                              strokeWidth: 5.0,
                              strokeCap: StrokeCap.butt,
                              textStyle: const TextStyle(
                                  fontSize: 33.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textFormat: CountdownTextFormat.HH_MM_SS,
                              isReverse: true,
                              isReverseAnimation: false,
                              isTimerTextShown: true,
                              autoStart: false,
                              onStart: () {
                                debugPrint('Countdown Started');
                                print(minute.toString());
                              },
                              onComplete: () {
                                debugPrint('Countdown Ended');
                                _controllerTime.reset();
                              },
                              onChange: (String timeStamp) {
                                debugPrint(
                                    'Countdown Changed $timeStamp');
                              },
                            ),
                          ],
                        )
                      : Container()
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
