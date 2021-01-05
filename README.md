# Flutter Aqui

Progressive Web App for [Aqui](https://aqui.e-node.net)

## Installation

Flutter SDK & Dart

* Flutter  1.22.3
* Dart 2.10.3

Android SDK
* API Level 28-30

Dart is automatically installed during Flutter SDK installation

## Configuration

```bash
flutter config --android-sdk path/to/android/sdk # set path to Android SDk for Flutter
```

```bash
flutter doctor # check flutter config
```
**Expected result :**
```bash
[√] Flutter (Channel unknown, 1.22.3, on Microsoft Windows [version 10.0.18363.1256], locale fr-FR)

[√] Android toolchain - develop for Android devices (Android SDK version 30.0.3)
[!] Android Studio (version 4.1.0)
    X Flutter plugin not installed; this adds Flutter specific functionality.
    X Dart plugin not installed; this adds Dart specific functionality.
[√] Connected device (1 available)
```

## Run
Once your mobile device is connected run 
```bash
flutter run
```
```bash
Launching lib\main.dart on M2003J15SC in debug mode...
Running Gradle task 'assembleDebug'...
Running Gradle task 'assembleDebug'... Done                        20,7s
√ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...                 8,9s
```

## Build
To build your app for Android you need generated Keystore

On Mac/Linux, use the following command:
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

On Windows, use : 

```bash
keytool -genkey -v -keystore c:\Users\USER_NAME\key.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Reference the keystore from the app and configure the gradle signature
https://flutter.dev/docs/deployment/android => for more infos

Then build your app using the wished format 
```bash
flutter build apk | appbundle | bundle
```

Once the build completed, get your file in <br>
**/build/app/outputs/flutter-apk/your_file**
