import 'package:flutter/material.dart';

class DialogBuilder {
  DialogBuilder(this.context, this.isDialogOpen);

  bool isDialogOpen;
  String progressString;
  final BuildContext context;

  Future<void> showLoadingIndicator(String text, String msg) async {
    LoadingIndicator loadingIndicator = LoadingIndicator(text);
    String title = 'Loading';
    if (msg != 'Loading...') {
      loadingIndicator.text = '0';
      title = 'Downloading';
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: loadingIndicator,
            );
          },
        );
      },
    );
  }

  void hideOpenDialog() {
    if (isDialogOpen == true) {
      Navigator.of(context).pop();
    }
  }
}

class LoadingIndicator extends StatefulWidget {
  String text;

  LoadingIndicator(this.text);

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  var displayedText;

  @override
  Widget build(BuildContext context) {
    displayedText = widget.text;

    return Container(
        padding: EdgeInsets.all(05),
        //color: Colors.blueGrey[50],
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getLoadingIndicator(),
              SizedBox(height: 10.0),
              Text(
                widget.text,
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              )
            ]));
  }

  Padding _getLoadingIndicator() {
    return Padding(
        child: Container(
            child: CircularProgressIndicator(
              strokeWidth: 05,
            ),
            width: 35,
            height: 35),
        padding: EdgeInsets.only(bottom: 16));
  }
}
