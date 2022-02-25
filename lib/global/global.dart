

import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcel_you/models/model_user.dart';

final FirebaseAuth fbAuth = FirebaseAuth.instance;
User? currentFirebaseUser;

UserModel? userModelCurrentInfo;
