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

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return ListView(
          children: textButtons,
        );
      },
    );
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





