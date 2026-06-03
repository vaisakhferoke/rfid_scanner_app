plugins {
    id("com.android.application")
    id("kotlin-android")
    // Resolving the Flutter plugin but deferring application
    id("dev.flutter.flutter-gradle-plugin") apply false
}

val newProps = HashMap(gradle.startParameter.projectProperties)
newProps["target-platform"] = "android-arm"
gradle.startParameter.projectProperties = newProps
project.setProperty("target-platform", "android-arm")
println("GRADLE TARGET PLATFORM: ${project.findProperty("target-platform")}")

// Apply the Flutter plugin manually after properties are overridden
apply(plugin = "dev.flutter.flutter-gradle-plugin")

val flutter = extensions.getByName("flutter") as com.flutter.gradle.FlutterExtension

android {
    namespace = "com.example.event_rfid_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.altrawaves.uhf"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.clear()
            abiFilters.add("armeabi-v7a")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        jniLibs {
            excludes.add("lib/arm64-v8a/**")
            excludes.add("lib/x86_64/**")
            excludes.add("lib/x86/**")
        }
    }
}

configure<com.flutter.gradle.FlutterExtension> {
    source = "../.."
}

dependencies {
    implementation(project(":ModuleAPI"))
}
