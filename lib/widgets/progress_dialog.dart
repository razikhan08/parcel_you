import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {

  String? message;
  ProgressDialog({this.message});


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),

        child:Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget> [
              SizedBox(width: 6),
              const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),

              SizedBox(width: 26),

              Text(message!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
