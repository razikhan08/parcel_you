import 'package:firebase_database/firebase_database.dart';

class UserModel {

  String? number;
  String? id;
  String? email;
  String? name;

  UserModel({this.number, this.name, this.id, this.email});

   UserModel.fromSnapShot(DataSnapshot snap){

    email = (snap.value as dynamic)["email"];
    id = snap.key;
    name = (snap.value as dynamic)["name"];
    number = (snap.value as dynamic)["number"];



  }

}