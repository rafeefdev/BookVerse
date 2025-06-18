plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Definisikan fungsi untuk membaca versi dari Flutter
fun flutterVersionCode(): String {
    val flutterVersionCode = project.findProperty("flutter.versionCode")
    return flutterVersionCode?.toString() ?: "1"
}

fun flutterVersionName(): String {
    val flutterVersionName = project.findProperty("flutter.versionName")
    return flutterVersionName?.toString() ?: "1.0.0"
}

android {
    namespace = "com.bookverse.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.bookverse.app"
        ndkVersion = "27.0.12077973"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode().toInt()
        versionName = flutterVersionName()
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ...
    implementation("com.google.android.material:material:1.14.0-alpha01")
    // ...
}

flutter {
    source = "../.."
}