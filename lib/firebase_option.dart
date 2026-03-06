import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import 'package:flutter/foundation.dart'

    show defaultTargetPlatform, kIsWeb, TargetPlatform;


/// Default [FirebaseOptions] for use with your Firebase apps.

///

/// Example:

/// ⁠ dart

/// import 'firebase_options.dart';

/// // ...

/// await Firebase.initializeApp(

///   options: DefaultFirebaseOptions.currentPlatform,

/// );

///  ⁠

class DefaultFirebaseOptions {

  static FirebaseOptions get currentPlatform {

    if (kIsWeb) {

      return web;

    }

    switch (defaultTargetPlatform) {

      case TargetPlatform.android:

        return android;

      case TargetPlatform.iOS:

        return ios;

      case TargetPlatform.macOS:

        return macos;

      case TargetPlatform.windows:

        return windows;

      case TargetPlatform.linux:

      default:

        throw UnsupportedError(

          'DefaultFirebaseOptions are not supported for this platform.',

        );

    }

  }


  static const FirebaseOptions web = FirebaseOptions(

    apiKey: 'dummy_api_key',

    appId: 'dummy_app_id',

    messagingSenderId: 'dummy_sender_id',

    projectId: 'dummy_project_id',

    authDomain: 'dummy_project_id.firebaseapp.com',

    storageBucket: 'dummy_project_id.appspot.com',

  );


  static const FirebaseOptions android = FirebaseOptions(

    apiKey: 'dummy_api_key',

    appId: '1:1234567890:android:dummy',

    messagingSenderId: 'dummy_sender_id',

    projectId: 'dummy_project_id',

    storageBucket: 'dummy_project_id.appspot.com',

  );


  static const FirebaseOptions ios = FirebaseOptions(

    apiKey: 'dummy_api_key',

    appId: '1:1234567890:ios:dummy',

    messagingSenderId: 'dummy_sender_id',

    projectId: 'dummy_project_id',

    storageBucket: 'dummy_project_id.appspot.com',

    iosBundleId: 'com.example.app',

  );


  static const FirebaseOptions macos = FirebaseOptions(

    apiKey: 'dummy_api_key',

    appId: '1:1234567890:ios:dummy',

    messagingSenderId: 'dummy_sender_id',

    projectId: 'dummy_project_id',

    storageBucket: 'dummy_project_id.appspot.com',

    iosBundleId: 'com.example.app',

  );


  static const FirebaseOptions windows = FirebaseOptions(

    apiKey: 'dummy_api_key',

    appId: '1:1234567890:web:dummy',

    messagingSenderId: 'dummy_sender_id',

    projectId: 'dummy_project_id',

    authDomain: 'dummy_project_id.firebaseapp.com',

    storageBucket: 'dummy_project_id.appspot.com',

  );

}