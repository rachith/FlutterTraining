import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_training/sharedPrefLogin/show_toast.dart';

class FireAuth {
  // For registering a new user
  static Future<User> registerUsingEmailPassword({
     String name,
     String email,
     String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      await user.updateProfile(displayName: name);
      await user.reload();
      user = auth.currentUser;

      await FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
            'Name': user.displayName,
            'email': user.email}).then((value) => {
              print("Data has been added")
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
       // print('The password provided is too weak.');
        ShowToast.showToast("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        //print('The account already exists for that email.');
        ShowToast.showToast("The account already exists for that email.");
      }
    } catch (e) {
      print(e);
    }

    return user;
  }

  // For signing in an user (have already registered)
  static Future<User> signInUsingEmailPassword({
     String email,
     String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
       // print('No user found for that email.');
        ShowToast.showToast("No user found for that email.");
      } else if (e.code == 'wrong-password') {
       // print('Wrong password provided.');
        ShowToast.showToast("Wrong password provided.");
      }
    }

    return user;
  }

  static Future<User> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}
