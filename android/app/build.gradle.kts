plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {


    // <--- NEW: Define Flavor Dimensions
    // This is required if you have multiple flavor dimensions.
    // For now, we'll just have one.
    flavorDimensions "app"
    // <--- NEW: Define Product Flavors
    productFlavors {
        dev {
            dimension "app"
            // Application ID for development builds. Good for distinguishing on device.
            applicationIdSuffix ".dev"
            // App name visible on device for development build
            resValue "string", "app_name", "Color Rash (Dev)"


            // Firebase config file for this flavor (e.g., google-services.json)
            // You would place your dev google-services.json in:
            // android/app/src/dev/google-services.json
        }
        prod {
            dimension "app"
            // No applicationIdSuffix for production (it will be your default applicationId from defaultConfig)
            // App name for production
            resValue "string", "app_name", "Color Rash"


            // Firebase config file for this flavor (e.g., google-services.json)
            // You would place your prod google-services.json in:
            // android/app/src/prod/google-services.json
        }
    }
    namespace = "com.colorrash.color_rash"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.colorrash.color_rash"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
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

flutter {
    source = "../.."
}
