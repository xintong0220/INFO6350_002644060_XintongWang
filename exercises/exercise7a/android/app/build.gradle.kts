plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") 
    id("dev.flutter.flutter-gradle-plugin") 
}

android {
    namespace = "com.example.exercise7a" 
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.example.exercise7a" 
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // 使用 debug 签名
        }
    }
}

flutter {
    source = "../.."
}
