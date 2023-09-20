import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'screens/chat_screen.dart';


void sendMessage(String messageText, bool needPopNavigator, BuildContext context){

  FirebaseFirestore.instance.collection('messages').add({
    'text': messageText,
    'sender': loggedInUser.email,
    'date' : FieldValue.serverTimestamp(),
  } as Map<String, dynamic>);
  Vibration.vibrate(duration: 1000);

  //         FlutterRingtonePlayer.play( fromAsset: "sounds/fire-04-loop.wav",);

  FlutterRingtonePlayer.playNotification();

  if(needPopNavigator == true){
    Navigator.pop(context);
  }


}


Future deleteMessages(List<String> messageIds) async{
  for(String messageId in messageIds){
    deleteMessage(messageId);
  }
}


Future deleteMessage(String messageId) async {
  try {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(messageId)
        .delete();
  } catch (e) {
    return false;
  }
}
