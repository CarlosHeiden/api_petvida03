plugins {
    id("com.android.application")
    id("kotlin-android")
    // O plugin do Flutter deve vir após Android e Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    // ✅ Importante: plugin do Google Services vem aqui no topo também
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.api_petvida03"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ compatível com Firebase

    defaultConfig {
        applicationId = "com.example.api_petvida03"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Habilitar suporte a Java 17 e desugaring
    compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // Usar chave debug por enquanto
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ Dependência necessária para o desugaring
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
