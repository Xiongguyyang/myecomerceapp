import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myecomerceapp/data/auth/models/user_creation_req.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AuthFirebaseService {
  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(String email, String password);
}
//jkjjjj
class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either> signup(UserCreationReq user) async {
    try {
      var returnDAta = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: user.Email!,
            password: user.Password!,
          );

      FirebaseFirestore.instance
          .collection("Users")
          .doc(returnDAta.user!.uid)
          .set({
            "FirstName": user.FirstName,
            "LastName": user.LastName,
            "Email": user.Email,
          });
      return Right("Sign up successfully");
    } on FirebaseAuthException {
      return Left("Sign up failed");
    }
  }

  @override
  Future<Either> signin(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right("Sign in successful");
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? "Sign in failed");
    }
  }
}
