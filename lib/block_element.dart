import 'package:flutter/material.dart';

const matrix4 = <double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

// ignore: must_be_immutable
class BlockElement extends StatefulWidget {
  final num maxRows;
  final num maxColumns;
  final String blockValue;

  BlockElement(
    this.scaleController, {
    required this.maxRows,
    required this.maxColumns,
    required this.blockValue,
    required this.blockUrl,
    required this.initialBlockIndex,
    required this.finalBlockIndex,
    required this.emptyIndex,
    required this.updateEmptyIndex,
    this.disableClick = false,
    this.indexToHighlight = -1,
    Key? key,
  }) : super(key: key);

  String blockUrl;
  int initialBlockIndex;
  int finalBlockIndex;
  int emptyIndex;
  Function updateEmptyIndex;
  bool disableClick;
  int indexToHighlight;
  AnimationController scaleController;
  @override
  _BlockElementState createState() => _BlockElementState();
}

class _BlockElementState extends State<BlockElement>
    with TickerProviderStateMixin {
  num xCoordinate = 0;
  num yCoordinate = 0;
  num finalXCordinate = 0;
  num finalYCordinate = 0;
  String blockValue = "";
  String blockUrl = "";
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    xCoordinate = widget.blockValue == 'empty'
        ? (widget.emptyIndex % widget.maxRows)
        : (widget.initialBlockIndex % widget.maxRows);
    yCoordinate = widget.blockValue == 'empty'
        ? (widget.initialBlockIndex / widget.maxColumns).floor()
        : (widget.initialBlockIndex / widget.maxColumns).floor();
    blockValue = widget.blockValue;
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));

    animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    controller.addListener(() {
      if (controller.status == AnimationStatus.completed) {
        widget.updateEmptyIndex(yCoordinate * widget.maxColumns + xCoordinate);
        setState(() {
          xCoordinate = finalXCordinate;
          yCoordinate = finalYCordinate;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, child) => Transform(
          transform: Matrix4.translationValues(
              (xCoordinate +
                      animation.value * (finalXCordinate - xCoordinate)) *
                  72,
              (yCoordinate +
                      animation.value * (finalYCordinate - yCoordinate)) *
                  72,
              12),
          child: GestureDetector(
              onTap: () {
                if (widget.disableClick) {
                  widget.updateEmptyIndex(widget.initialBlockIndex);
                  return;
                }
                num emptyXCordinate = widget.emptyIndex % widget.maxRows;
                num emptyYCordinate =
                    (widget.emptyIndex / widget.maxColumns).floor();
                if ((xCoordinate == emptyXCordinate - 1 &&
                        yCoordinate == emptyYCordinate) ||
                    (xCoordinate == emptyXCordinate + 1 &&
                        yCoordinate == emptyYCordinate) ||
                    (yCoordinate == emptyYCordinate - 1 &&
                        xCoordinate == emptyXCordinate) ||
                    (yCoordinate == emptyYCordinate + 1 &&
                        xCoordinate == emptyXCordinate)) {
                  setState(() {
                    finalXCordinate = emptyXCordinate;
                    finalYCordinate = emptyYCordinate;
                  });
                  controller.forward(from: 0);
                }
              },
              child: widget.blockValue == "empty"
                  ? Container()
                  : ColorFiltered(
                      colorFilter:
                          yCoordinate * widget.maxColumns + xCoordinate ==
                                  widget.finalBlockIndex
                              ? const ColorFilter.mode(
                                  Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.matrix(matrix4),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 2,
                                  offset: Offset(0, 0))
                            ],
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage(widget.blockUrl))),
                        height: 70,
                        width: 70,
                      ),
                    ))),
    );
  }
}
