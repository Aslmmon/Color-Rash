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
import java . util . Properties


        android {


            // <--- NEW: Define Flavor Dimensions
            // This is required if you have multiple flavor dimensions.
            // For now, we'll just have one.
            flavorDimensions += "app" // Correct Kotlin DSL for adding to a collection
            // <--- NEW: Define Product Flavors
            productFlavors {
                create("dev") { // Use create("name") for named flavors
                    dimension = "app" // Correct Kotlin DSL assignment
                    resValue("string", "app_name", "(Dev)") // Correct Kotlin DSL method call
                    resValue(
                        "string",
                        "admob_app_id_value",
                        "ca-app-pub-3940256099942544~3347511713"
                    )

                }
                create("prod") { // Use create("name") for named flavors
                    dimension = "app" // Correct Kotlin DSL assignment
                    resValue("string", "app_name", "Color Rash") // Correct Kotlin DSL method call
                    resValue("string", "admob_app_id_value", "\"${System.getenv("ADMOB_APP_ID")}\"")


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
            // --- Correct Kotlin DSL for signing and build types ---
            signingConfigs {
                create("release") {
                    val keystoreProperties = Properties()
                    val keystorePropertiesFile = rootProject.file("key.properties")
                    if (keystorePropertiesFile.exists()) {
                        keystorePropertiesFile.inputStream().use {
                            keystoreProperties.load(it)
                        }
                    }
                    if (keystoreProperties.isNotEmpty()) {
                        storeFile = file(keystoreProperties["storeFile"] as String)
                        storePassword = keystoreProperties["storePassword"] as String
                        keyAlias = keystoreProperties["keyAlias"] as String
                        keyPassword = keystoreProperties["keyPassword"] as String
                    }
                }
            }

            buildTypes {
                getByName("release") {
                    // Assign the release signing config
                    //  signingConfig = signingConfigs.getByName("debug")
                    signingConfig = signingConfigs.getByName("release")
                    ndk {
                        debugSymbolLevel = "FULL" // or "SYMBOL_TABLE"
                    }
                }
            }
        }

flutter {
    source = "../.."
}
