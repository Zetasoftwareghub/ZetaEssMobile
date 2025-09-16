import java.io.FileInputStream
//buildscript {
//    dependencies {
//        classpath("com.google.gms:google-services:4.4.1") // ✅ Add this
//    }
//    repositories {
//        google()
//        mavenCentral()
//    }
//
//}
//
//plugins {
//    id("com.android.application")
//    // START: FlutterFire Configuration
//    id("com.google.gms.google-services")
//    // END: FlutterFire Configuration
//    id("kotlin-android")
//    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
//    id("dev.flutter.flutter-gradle-plugin")
//}
//
//android {
//    namespace = "com.zeta.zeta_ess"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_11
//        targetCompatibility = JavaVersion.VERSION_11
//    }
//
//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_11.toString()
//    }
//
//    defaultConfig {
//
//        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//        applicationId = "com.zeta.zeta_ess"
//        // You can update the following values to match your application needs.
//        // For more information, see: https://flutter.dev/to/review-gradle-config.
//        minSdk = flutter.minSdkVersion
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    buildTypes {
//        release {
//            // TODO: Add your own signing config for the release build.
//            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
//}
//
//flutter {
//    source = "../.."
//}

buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
    }
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase / Google services
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.zeta.zeta_ess"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
//    ndkVersion = "26.3.11579264" // Pick the NDK version known to work


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.zeta.zeta_ess"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("upload-keystore.jks")
            storePassword = "zeta@123"
            keyAlias = "upload"
            keyPassword = "zeta@123"
        }
    }


    buildTypes {
        release {
            isMinifyEnabled = false // set true + add ProGuard rules if needed
            signingConfig = signingConfigs.getByName("release")

            // Optimize your APK / AAB
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Required for Play Store AAB
    bundle {
        storeArchive {
            enable = true
        }
    }
}

flutter {
    source = "../.."
}
