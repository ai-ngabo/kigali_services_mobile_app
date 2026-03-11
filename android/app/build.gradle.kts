plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kigali_services_mobile_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.kigali_services_mobile_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}

dependencies {
    // Force a specific Firebase BoM version to fix the StorageTask visibility issue
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    
    // Force all Kotlin dependencies to a version compatible with your compiler
    implementation(platform("org.jetbrains.kotlin:kotlin-bom:2.1.10"))
}

flutter {
    source = "../.."
}

// Point the :app build directory to {flutter_root}/build/app so that
// `flutter run` / `flutter build apk` can find the output APK.
// Without this the plugin copies to android/app/build/ but Flutter CLI looks
// in {project_root}/build/app/.
layout.buildDirectory.set(rootProject.layout.projectDirectory.dir("../build/app"))
