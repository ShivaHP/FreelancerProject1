class UserModel{
  final String username;
  final String useruid;
   String active;
  UserModel(this.username,this.useruid,this.active);

  factory UserModel.fromJson(Map data){
    return UserModel(data["user_name"]??"", data["uid"]??"",data["active"]??"0");
  }
}