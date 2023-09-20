import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/chat_screen.dart';
import 'message_bubble.dart';

class MessagesStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').orderBy('date').snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent,),
          );
        }
        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        messageIds.clear();
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
          messageIds.add(messageId);
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