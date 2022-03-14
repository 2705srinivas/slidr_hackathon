import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slidr_hackathon/block_element.dart';
import 'package:slidr_hackathon/blocks_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int emptySpaceIndex = 24;
  final int rowSize = 5;
  final int columnSize = 5;
  int count = 0;
  int seconds = 0;
  Random random = Random();
  List<dynamic> randomSequence = List.filled(25, 0);
  List<dynamic> randomSequenceCopy = List.filled(25, 0);
  int indexToHighlight = -1;
  late AnimationController scaleController;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    generateRandomSequence();
    scaleController = AnimationController(
        vsync: this,
        lowerBound: 1.0,
        upperBound: 1.1,
        duration: const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     title: Text(widget.title),
      //     ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0, 1.0),
            end: Alignment(0, -1.0),
            colors: [Colors.teal, Color(0xFF80CBC4)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Count: $count",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Timer: $seconds",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.all(16)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.teal.shade600)),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MyApp()));
                      // if (seconds != 0) {
                      //   timer.cancel();
                      // }
                      // setState(() {
                      //   randomSequence = [];
                      //   randomSequenceCopy = [];
                      //   count = 0;
                      //   seconds = 0;
                      // });
                    },
                    child: const Text(
                      "Shuffle!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: IntrinsicWidth(
                            child: Row(
                              children: const [
                                Text("Puzzle",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: rowSize * 72,
                          width: rowSize * 72,
                          alignment: Alignment.center,
                          child: Stack(
                            children: randomSequence
                                .asMap()
                                .entries
                                .map((index) => AnimatedBuilder(
                                    animation: scaleController,
                                    builder: (BuildContext context, child) =>
                                        Transform.scale(
                                            origin: const Offset(180, 180),
                                            scale: index.value["index"] ==
                                                    indexToHighlight
                                                ? scaleController.value
                                                : 1,
                                            child: BlockElement(scaleController,
                                                maxRows: rowSize,
                                                maxColumns: columnSize,
                                                blockValue: index.value["name"],
                                                blockUrl: index.value["url"],
                                                initialBlockIndex: index.key,
                                                finalBlockIndex:
                                                    index.value["index"],
                                                emptyIndex: emptySpaceIndex,
                                                indexToHighlight:
                                                    indexToHighlight,
                                                updateEmptyIndex:
                                                    (int emptyIndex) {
                                              //swap empty block and current block
                                              dynamic temp = randomSequenceCopy[
                                                  emptyIndex];
                                              randomSequenceCopy[emptyIndex] =
                                                  randomSequenceCopy[
                                                      emptySpaceIndex];
                                              randomSequenceCopy[
                                                  emptySpaceIndex] = temp;
                                              if (count == 0) {
                                                timer = Timer.periodic(
                                                    const Duration(seconds: 1),
                                                    (timer) {
                                                  setState(() {
                                                    seconds++;
                                                  });
                                                });
                                              }
                                              setState(() {
                                                emptySpaceIndex = emptyIndex;
                                                count++;
                                              });
                                              if (emptyIndex == 24) {
                                                checkIfGameCompleted();
                                              }
                                            }))))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicWidth(
                            child: Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 4.0,
                                  ),
                                  child: Text("Original",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Tooltip(
                                  message:
                                      "Click on any tile here to find out where it is located on the left puzzle.",
                                  preferBelow: false,
                                  child: Icon(
                                    Icons.help_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Container(
                            height: rowSize * 72,
                            width: rowSize * 72,
                            alignment: Alignment.center,
                            child: Stack(
                              children: List.filled(25, 0)
                                  .asMap()
                                  .entries
                                  .map((index) => BlockElement(
                                        scaleController,
                                        maxRows: rowSize,
                                        maxColumns: columnSize,
                                        blockValue: fiveTileBlocks[index.key]
                                            ["name"],
                                        blockUrl: fiveTileBlocks[index.key]
                                            ["url"],
                                        initialBlockIndex: index.key,
                                        finalBlockIndex:
                                            fiveTileBlocks[index.key]["index"],
                                        emptyIndex: 24,
                                        updateEmptyIndex: (int index) {
                                          setState(() {
                                            indexToHighlight = index;
                                          });
                                          scaleController.forward().then(
                                              (value) =>
                                                  scaleController.reverse());
                                        },
                                        disableClick: true,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  generateRandomSequence() {
    List generatedSeq = List.filled(25, 0);
    for (int i = 0; i < 25; i++) {
      int randomIndex = random.nextInt(25);
      while (generatedSeq[randomIndex] != 0) {
        randomIndex = random.nextInt(25);
      }
      generatedSeq[randomIndex] = fiveTileBlocks[i];
      if (fiveTileBlocks[i]["name"] == "empty") {
        // setState(() {
        emptySpaceIndex = randomIndex;
        // });
      }
    }
    if (isSolvable(generatedSeq)) {
      setState(() {
        randomSequence = [...generatedSeq];
        randomSequenceCopy = [...generatedSeq];
      });
      return;
    } else {
      generateRandomSequence();
    }
    // return randomSequence;
  }

  bool isSolvable(List seq) {
    int inversion = checkInversion(seq);
    if (inversion.isEven) return true;
    return false;
    // int emptyIndex = seq.indexOf((element) => element["name"] == "empty");
    // final emptyIndexRow = (emptyIndex / 5).ceil();
    // if (((5 - emptyIndexRow) + 1).isOdd) {
    //   return inversion.isEven;
    // } else {
    //   return inversion.isOdd;
    // }
  }

  checkInversion(List arr) {
    int inversion = 0;
    for (int i = 0; i < arr.length - 1; i++) {
      for (int j = i + 1; j < arr.length; j++) {
        if (arr[i]["index"] > arr[j]["index"]) {
          inversion = inversion + 1;
        }
      }
    }
    return inversion;
  }

  checkIfGameCompleted() {
    bool result = true;
    for (int i = 0; i < 24; i++) {
      if (randomSequenceCopy[i]["name"] != fiveTileBlocks[i]["name"]) {
        result = false;
        break;
      }
    }
    if (result) {
      timer.cancel();
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  // color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  gradient: LinearGradient(
                    begin: Alignment(0, 1.0),
                    end: Alignment(0, -1.0),
                    colors: [
                      Color.fromRGBO(216, 150, 20, 1),
                      Color.fromRGBO(251, 200, 78, 1)
                    ],
                  ),
                ),
                child: Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: IntrinsicHeight(
                        child: Column(
                      children: [
                        Image.asset(
                          "assets/images/celebration.png",
                          width: 120,
                          height: 120,
                        ),
                        const Text(
                          "Congratulations!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700),
                        ),
                        const Text(
                          "You've completed the puzzle",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "You took $count moves to complete the puzzle in $seconds secs",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton.icon(
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(
                                  text:
                                      "https://slider-hackathon.netlify.app/#/"));
                            },
                            icon: const Icon(Icons.link),
                            label: const Text(
                              "Share the game to your friends and see how they perform!",
                              style: TextStyle(color: Colors.white),
                            ))
                      ],
                    )),
                  );
                }),
              ),
            );
          });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer.isActive && timer != null) timer.cancel();
  }
}
