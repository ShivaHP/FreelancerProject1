import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/collections/firebasecollections.dart';
import 'package:flutter_application_2/models/usermodel.dart';
import 'package:flutter_application_2/screens/admin.dart';
import 'package:flutter_application_2/screens/chatscreen.dart';

class FirebaseUserList extends StatelessWidget {
  List<UserModel> appusers=[];
   FirebaseUserList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text("App Users"),
        elevation: 1,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminPanel()));
          }, icon: Icon(Icons.admin_panel_settings))
        ],
        
      ),
      body:StreamBuilder(
        stream: appuserscollection.where("active",isEqualTo: "1").snapshots(),
        builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.connectionState==ConnectionState.waiting)return CircularProgressIndicator();
          else if(snapshot.connectionState==ConnectionState.active){
            if(!snapshot.hasData||snapshot.data!.docs.isEmpty)return Center(child: Text("No users found"),);
            else{
              appusers=snapshot.data!.docs.map((e)=>UserModel.fromJson(e.data()as Map)).toList();

              return ListView.separated(
                separatorBuilder: (context,index)=>SizedBox(height: 10,),
                itemCount: appusers.length,
                itemBuilder: (context,index)=>ListTile(
                  tileColor:Colors.grey.shade100,

                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AppConversation(appusers[index],appusers[0]))),
                  leading: CircleAvatar(backgroundColor: Colors.primaries[index],child: Text(appusers[index].username.substring(0,2)),),
                  title: Text(appusers[index].username,style: TextStyle(color: Colors.black),),

                )
              );

            }
          }
          else{
            return Text("No users found");
          }
        }
      ),
    );
  }
}


