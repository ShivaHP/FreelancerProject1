import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/collections/firebasecollections.dart';
import 'package:flutter_application_2/models/chatmodel.dart';
import 'package:flutter_application_2/models/usermodel.dart';
import 'package:flutter_application_2/screens/userdetails.dart';

class AppConversation extends StatefulWidget {
  final UserModel userDetails;
  final UserModel currentuser;

  AppConversation(this.userDetails, this.currentuser, {Key? key})
      : super(key: key);

  @override
  State<AppConversation> createState() => _AppConversationState();
}

class _AppConversationState extends State<AppConversation> {
  late TextEditingController messagecontroller;

  String chatid = "";

  List<ChatModel> chatlist = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messagecontroller = TextEditingController();
    getchatid();
  }

  @override
  void dispose() {
    super.dispose();
    messagecontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserDetails(
                            widget.userDetails, widget.currentuser)));
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: conversationcollection
                    .doc(chatid)
                    .collection("chats")
                    .orderBy("date")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return CircularProgressIndicator();
                  else if (snapshot.connectionState == ConnectionState.active) {
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.docs.isEmpty)
                      return Text("No chat found");
                    else {
                      chatlist = snapshot.data!.docs
                          .map((e) => ChatModel.fromJson(e.data() as Map))
                          .toList();
                      return ListView.separated(
                          padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10),
                          itemCount: chatlist.length,
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment: chatlist[index].senderid==widget.currentuser.useruid?MainAxisAlignment.end: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: chatlist[index].senderid==widget.currentuser.useruid?Colors.blue:Colors.grey,
                                  ),
                                  
                                    padding: const EdgeInsets.all(10),
                                    child: RichText(
                                      text: TextSpan(text: chatlist[index].message),
                                      textAlign: TextAlign.left,
                                    )),
                              ],
                            );
                          });
                    }
                  } else {
                    return Text("No chat found");
                  }
                }),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 50,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messagecontroller,
                    
                    decoration: InputDecoration(border: OutlineInputBorder(),hintText: "Enter a message"),
                  ),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 50,
                  
                  child: ElevatedButton(
                    
                      onPressed: sendmessage,
                      child: Icon(
                        Icons.send,
                      )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  getchatid() {
    int firstid = widget.currentuser.useruid.hashCode;
    int secondid = widget.userDetails.useruid.hashCode;
    print(firstid);
    print(secondid);
    if (firstid > secondid) {
      chatid = widget.currentuser.useruid + widget.userDetails.useruid;
    } else {
      chatid = widget.userDetails.useruid + widget.currentuser.useruid;
    }
  }

  sendmessage() {
    if (messagecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter a valid message")));
      return;
    }
    conversationcollection.doc(chatid).collection("chats").add({
      "message": messagecontroller.text,
      "senderid": widget.currentuser.useruid,
      "receiverid": widget.userDetails.useruid,
      "date": DateTime.now().millisecondsSinceEpoch
    });
    messagecontroller.clear();
  }
}
