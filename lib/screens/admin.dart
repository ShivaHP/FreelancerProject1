
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/collections/firebasecollections.dart';
import 'package:flutter_application_2/models/usermodel.dart';
import 'package:flutter_application_2/screens/chatscreen.dart';
import 'package:flutter_application_2/screens/userdetails.dart';

class AdminPanel extends StatelessWidget {
  List<UserModel> appusers=[];
   AdminPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Admin Panel"),
        
      ),
      body:StreamBuilder(
        stream: appuserscollection.snapshots(),
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
                  tileColor: appusers[index].active=="1"?Colors.green:Colors.red,
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>UserDetails(appusers[index],appusers[0],lastscreen: "admin",))),
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


