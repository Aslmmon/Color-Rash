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

            packagingOptions { // <--- Kotlin DSL for packagingOptions
                // This ensures the build includes both 32-bit and 64-bit native libraries.
                jniLibs {
                    useLegacyPackaging = false
                }
                resources {
                    excludes += "/lib/armeabi-v7a/*" // Exclude 32-bit if not needed, but here you NEED it so it's a stylistic comment
                    excludes += "/lib/x86/*" // Exclude x86 as Flutter no longer supports it
                }
            }

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
                    ndk { // <--- Kotlin DSL for ndk block
                        abiFilters.add("armeabi-v7a") // <--- Use abiFilters.add()
                        abiFilters.add("arm64-v8a")
                        debugSymbolLevel= "FULL" // <--- Set debugSymbolLevel
                    }
                }
                getByName("debug") {
                    ndk { // <--- Kotlin DSL for ndk block
                        abiFilters.add("armeabi-v7a")
                        abiFilters.add("arm64-v8a")
                        debugSymbolLevel = "FULL" // <--- Set debugSymbolLevel
                    }
                }
            }
        }

flutter {
    source = "../.."
}
