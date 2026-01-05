plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.solvelens"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID for SolveLens
        applicationId = "com.example.solvelens"
        
        // Google Play Store Requirements
        minSdk = 21  // Android 5.0 (Lollipop)
        targetSdk = 34  // Android 14
        
        versionCode = 1
        versionName = "1.0.0"
        
        // Enable multidex support
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Optimizations for release build
            minifyEnabled = true
            shrinkResources = true
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
        
        debug {
            minifyEnabled = false
            debuggable = true
        }
    }
    
    // Optimize build performance
    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}