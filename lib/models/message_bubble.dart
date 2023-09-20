
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../message_services.dart';

class MessageBubble extends StatelessWidget {

  MessageBubble({required this.messageId, required this.sender, required this.text, required this.isMe, required this.date});
  final String messageId;
  final String sender;
  final String text;
  final DateTime date;
  final bool isMe;


  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text("Are you sure you want to delete?"),
          actions: <Widget>[
            TextButton(
              child: new Text("Delete"),
              onPressed: () {

                deleteMessage(messageId);
                Navigator.pop(context);

              },
            ),
            TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {

    final DateFormat formatter = DateFormat('H:m');
    final String formatted = formatter.format(date);



    return  Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          TextButton(
            onPressed: (){
              _showDialog(context);
            },
            child: Material(
              elevation: 5.0,
              borderRadius: isMe? BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0)) : BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0)),
              color: isMe? Colors.lightBlueAccent :Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: isMe? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),

        ],
      ),
    );
  }
}