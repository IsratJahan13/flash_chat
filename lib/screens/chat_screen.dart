
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/message_services.dart';
import '../models/message_stream.dart';


late User loggedInUser;
List<String> messageIds = [];

class ChatScreen extends StatefulWidget {

  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  final db = FirebaseFirestore.instance;

  late String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    getQuickReplies();
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



  late List<String> quickReplies = [];

  void getQuickReplies() async {

    db.collection("quick_replies").get().then(
          (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          final text = docSnapshot.get('text');
          quickReplies.add(text);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }


  void showQuickReplies (){
    List<Widget> textButtons = [];
    for(String quickReply in quickReplies){
      final textButton = TextButton(

        onPressed: (){
          sendMessage(quickReply, true, context);
        },
        child: Center(child: Text(quickReply),),
      );
      textButtons.add(textButton);
    }
    textButtons.add(IconButton(
      onPressed: (){
        showDialogForNewQuickReplies(context);
      },

      icon: Icon(Icons.add),));

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return ListView(
          children: textButtons,
        );
      },
    );
  }

  Future<void>showDialogForNewQuickReplies(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  messageText = value;
                });
              },
              controller: messageTextController,
              decoration: InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Save'),
                onPressed: () {
                  setState(() {
                    saveQuickReply(messageText);
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  child: Text('Cancel'),
                  onPressed: (){
                    setState(() {
                      Navigator.pop(context);
                    });
                  }
              )
            ],
          );
        });
  }

  void saveQuickReply(String messageText){
    FirebaseFirestore.instance.collection('quick_replies').add({
      'text': messageText,
    } as Map<String, dynamic>);

  }

    @override
    Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            TextButton(
                onPressed: (){
                  deleteMessages(messageIds);

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
                    IconButton(
                      iconSize: 25.0,
                        color: Colors.lightBlueAccent,
                        onPressed: (){
                          FocusManager.instance.primaryFocus?.unfocus();
                          showQuickReplies();
                        },
                        icon: Icon(
                          Icons.quick_contacts_mail,
                        )

                    ),
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        textCapitalization: TextCapitalization.sentences,

                        onChanged: (value) {
                          messageText = value;

                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        messageTextController.clear();
                        sendMessage(messageText, false, context);
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





