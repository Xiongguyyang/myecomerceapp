import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myecomerceapp/data/auth/models/user_creation_req.dart';
import 'package:myecomerceapp/data/auth/reopositry/auth_firebase_service.dart';
import 'package:myecomerceapp/domain/auth/repository/atuh.dart';
import 'package:myecomerceapp/presentation/service_locator.dart';



class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signup(UserCreationReq user) async {
    return sl<AuthFirebaseService>().signup(user);
   }

  @override
  Future<Either> signin(String email, String password) async {
    return sl<AuthFirebaseService>().signin(email, password);
  }

  @override
  Future<Either> getUser(String id, String token) async {
    try {
      final userId = (id.isNotEmpty)
          ? id
          : FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return Left("No user logged in");
      }
      final userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .get();
      return Right(userDoc.data());
    } catch (e) {
      return Left("Please try again");
    }
  }

  @override
  Future<Either> updateUser(String id, Map<String, dynamic> data) async {
  try {
    final userId = id.isNotEmpty ? id : FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Left("No user logged in");
    
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .update(data);
    
    return Right(null);
  } catch (e) {
    return Left("Failed to update profile");
  }
}
}
