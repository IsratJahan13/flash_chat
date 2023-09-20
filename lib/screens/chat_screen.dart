import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';


final _fireStore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {

  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();

  late String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    }
    catch (e) {
      print(e);
    }
  }




 /* Future deleteAllData() async {
    try {
      await .resetMyHistory();
    } catch (e) {
      // Handle error.
    }
  }
*/

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            TextButton(
                onPressed: (){
            //      deleteAllData();

                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
            ),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _auth.signOut();
                  Navigator.pop(context);
                }),
          ],
          title: Text('⚡️Chat'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        messageTextController.clear();
                        _fireStore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'date' : FieldValue.serverTimestamp(),
                        } as Map<String, dynamic>);
                        Vibration.vibrate(duration: 1000);
                        FlutterRingtonePlayer.playNotification();
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }




class MessagesStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').orderBy('date').snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent,),
          );
        }
        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for(var message in messages){
          final messageId = message.id;
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final messageDate = message.get('date') as Timestamp;
          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            messageId : messageId,
              sender: messageSender,
              text: messageText,
              date: messageDate.toDate(),

              isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}




class MessageBubble extends StatelessWidget {

  MessageBubble({required this.messageId, required this.sender, required this.text, required this.isMe, required this.date});
  final String messageId;
  final String sender;
  final String text;
  final DateTime date;
  final bool isMe;


  Future deleteData(String messageId) async {
    try {
      await _fireStore
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      return false;
    }
  }

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

                deleteData(messageId);
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
