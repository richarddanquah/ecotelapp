import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSharedPref {
  final String _userFullName = "fullName";
  final String _userName = "userName";
  final String _userEmail = "userEmail";
  final String _userId = "userId";
  final String _userPhone = "userPhoneNumber";
  final String _userPhoto = "userPhoto";
  final String _userCompanyBranch = "userCompanyBranch";
  final String _userToken = "userToken";
  final String _userGender = "userGender";
  final String _userComment = "userComment";
  final String _userAuth = "userAuth";
  final String _userDate = "userDate";

  Future<bool> setUserAuth(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userAuth, value);
  }

  Future<String> getUserAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userAuth) ?? 'false';
  }

  Future<bool> setUserDate(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userDate, value);
  }

  Future<String> getUserDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDate) ?? '';
  }

  //fullName
  Future<bool> setUserFullName(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userFullName, value);
  }

  Future<String> getUserFullName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userFullName) ?? 'N/A';
  }

  //username
  Future<bool> setUserName(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userName, value);
  }

  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName) ?? 'N/A';
  }

  //userEmail
  Future<bool> setUserEmail(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userEmail, value);
  }

  Future<String> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName) ?? 'N/A';
  }

  // userId
  Future<bool> setUserId(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userId, value);
  }

  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userId) ?? 'N/A';
  }

  //userPhone
  Future<bool> setUserPhone(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userPhone, value);
  }

  Future<String> getUserPhone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhone) ?? 'N/A';
  }

  //userPhoto
  Future<bool> setUserPhoto(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userPhoto, value);
  }

  Future<String> getUserPhoto() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoto) ?? '';
  }

  //userCompanyBranch

  Future<bool> setUserCompanyBranch(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userCompanyBranch, value);
  }

  Future<String> getUserCompanyBranch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userCompanyBranch) ?? 'N/A';
  }

  //userToken
  Future<bool> setUserToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userToken, value);
  }

  Future<String> getUserToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userToken) ?? 'N/A';
  }

  //userGender
  Future<bool> setUserGender(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userGender, value);
  }

  Future<String> getUserGender() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userGender) ?? 'N/A';
  }
  //userComment

  Future<bool> setUserComment(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userComment, value);
  }

  Future<String> getUserComment() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userComment) ?? '';
  }

  Future<void> removeSavedDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
