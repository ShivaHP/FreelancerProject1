import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/collections/firebasecollections.dart';
import 'package:flutter_application_2/models/reviewmodel.dart';
import 'package:flutter_application_2/models/usermodel.dart';

class UserDetails extends StatefulWidget {
  final UserModel userDetails;
  final UserModel reviewerdetails;
  final String lastscreen;

  UserDetails(this.userDetails, this.reviewerdetails,{Key? key,this.lastscreen=""}) : super(key: key);

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  List<ReviewModel> userreviews = [];
  late TextEditingController reviewcontroller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reviewcontroller = TextEditingController();
  }

  @override
  void dispose() {
    reviewcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userDetails.active);
    return Scaffold(

      appBar: AppBar(
        elevation: 1,
        title: Text("UserDetails"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        children: [
          CircleAvatar(
            backgroundColor: Colors.red,
            child: Text(widget.userDetails.username.substring(0, 2),style: TextStyle(fontSize: 20,color: Colors.white),),
            radius: 60,
          ),
          Text("Add Review",style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10,),
          TextFormField(
            controller: reviewcontroller,
            decoration: InputDecoration(border: OutlineInputBorder(),hintText: "Enter your review"),
            maxLines: 5,
          ),
          const SizedBox(height: 10,),
          ElevatedButton(onPressed: submitreview, child: Text("Submit Review")),
          
          Visibility(
            visible: widget.lastscreen=="admin",
            child: IconButton(
              onPressed: () {
                changeuserstatus(widget.userDetails.active);
              },
              icon: Icon(
               Icons.power_settings_new_outlined ,
                color:
                    widget.userDetails.active == "1" ? Colors.green : Colors.red,
              ),
              iconSize: 80,
            ),
          ),
          const SizedBox(height: 10,),
          Text("User Reviews",style: TextStyle(fontWeight: FontWeight.bold),),
         
          StreamBuilder(
              stream: reviewcollectio
                  .where("userid", isEqualTo: widget.userDetails.useruid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.active) {
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.docs.isEmpty)
                    return Text("No review found");
                  else {
                    userreviews = snapshot.data!.docs
                        .map((e) => ReviewModel.fromJson(e.data() as Map))
                        .toList();
                    return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: userreviews.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(userreviews[index].review),
                            subtitle: Text("~" + userreviews[index].reviewby),
                          );
                        });
                  }
                } else {
                  return Text("No review found");
                }
              })
        ],
      ),
    );
  }

  submitreview() {
    if (reviewcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter a valid review")));
      return;
    } else {
      reviewcollectio.add({
        "review": reviewcontroller.text,
        "userid": widget.userDetails.useruid,
        "reviewby": widget.reviewerdetails.username
      });
      reviewcontroller.clear();
    }
  }

  changeuserstatus(String active) {
     print("active:$active");
    if (active == "1"){
        active = "0";
    }
    
    else {
      active = "1";
    }

      print("active:$active");
   
    appuserscollection
        .where("uid", isEqualTo: widget.userDetails.useruid)
        .get()
        .then((value) {
      if (value == null) return;
      if (value.docs != null && value.docs.isNotEmpty) {
        appuserscollection
            .doc(value.docs[0].id)
            .update({"active": active}).then((value) {
             
          if (active == "1"){
            widget.userDetails.active="1";
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("User Activated Successfully")));
          }
            
          else {
               widget.userDetails.active="0";
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("User Blocked Successfully")));
          }
       

          setState(() {});
        });
      }
    });
  }
}
