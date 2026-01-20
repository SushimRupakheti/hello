

//PROVIDER
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


//shared prefs provider
final sharedPreferencesProvider = Provider<SharedPreferences> ((ref){
  throw UnimplementedError("shared prefs lai hamle main.dart ma initialize garinxa,so tmi dhukka basa sir dinu hunxa hai");
});

final userSessionServiceProvider =Provider <UserSessionServices>((ref) {
  return UserSessionServices(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionServices{
  final SharedPreferences _prefs;

  UserSessionServices({required SharedPreferences prefs}) : _prefs = prefs;

  //keys for stroing data
  static const String _keysIsLoggedIn='is_logged_in';
  static const String _keyUserId='user_id';
  static const String _keyUserEmail='user_email';
  static const String _keyUserUsername='user_username';
  static const String _keyUserFullName='user_full_name';
  static const String _keyUserPhoneNumber='user_phone_number';
  static const String _keyUserBatchId='user_batch_id';
  static const String _keyUserProfileImage='user_profile_image';
// Store user session data

Future<void> saveUserSession({
required String userId,
required String email,
required String username,
required String fullName,
String? phoneNumber,
String? batchId,
String? profilePicture,
}) async {
await _prefs.setBool(_keysIsLoggedIn, true);
await _prefs.setString(_keyUserId, userId);
await _prefs.setString(_keyUserEmail, email);
await _prefs.setString(_keyUserUsername, username);
await _prefs.setString(_keyUserFullName, fullName);



if(phoneNumber!= null){
  await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
}
if(batchId!=null){
  await _prefs.setString(_keyUserBatchId,batchId);
}
if(profilePicture!=null){
  await _prefs.setString(_keyUserProfileImage,profilePicture);
}
}

  Future<void> clearUserSession() async{
    await _prefs.remove(_keysIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserUsername);
    await _prefs.remove(_keyUserBatchId);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyUserProfileImage);
    await _prefs.remove(_keyUserFullName);


  }

 bool isLoggedIn() {
    return _prefs.getBool(_keysIsLoggedIn) ?? false;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Get current user full name
  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  // Get current user username
  String? getCurrentUserUsername() {
    return _prefs.getString(_keyUserUsername);
  }

  // Get current user phone number
  String? getCurrentUserPhoneNumber() {
    return _prefs.getString(_keyUserPhoneNumber);
  }

  // Get current user batch ID
  String? getCurrentUserBatchId() {
    return _prefs.getString(_keyUserBatchId);
  }

  // Get current user profile picture
  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyUserProfileImage);
  }


  

}