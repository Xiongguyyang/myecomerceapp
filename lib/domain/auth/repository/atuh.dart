import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/data/auth/models/user_creation_req.dart';

abstract class AuthRepository {
  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(String email, String password);
  Future<Either> getUser(String email, String password);
  Future<Either> updateUser(String id, Map<String, dynamic> data);

}
