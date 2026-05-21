plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

val androidKeystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
val androidKeyAlias = System.getenv("ANDROID_KEY_ALIAS")
val androidKeyPassword = System.getenv("ANDROID_KEY_PASSWORD")
val androidStorePassword = System.getenv("ANDROID_STORE_PASSWORD")
val hasReleaseSigningCredentials =
    !androidKeystorePath.isNullOrBlank() &&
    !androidKeyAlias.isNullOrBlank() &&
    !androidKeyPassword.isNullOrBlank() &&
    !androidStorePassword.isNullOrBlank()

val generatedPluginRegistrant = file(
    "src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java",
)

fun sanitizeGeneratedPluginRegistrant() {
    if (!generatedPluginRegistrant.exists()) {
        return
    }

    val integrationTestBlock = Regex(
        """
        \s*try \{
        \s*flutterEngine\.getPlugins\(\)\.add\(new dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin\(\)\);
        \s*\} catch \(Exception e\) \{
        \s*Log\.e\(TAG, "Error registering plugin integration_test, dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin", e\);
        \s*\}
        
        """.trimIndent(),
        setOf(RegexOption.MULTILINE),
    )

    val current = generatedPluginRegistrant.readText()
    val sanitized = current.replace(integrationTestBlock, "")
    if (sanitized != current) {
        generatedPluginRegistrant.writeText(sanitized)
    }
}

android {
    namespace = "com.carbodex.qitak"
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
        applicationId = "com.carbodex.qitak"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = 100
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigningCredentials) {
                keyAlias = androidKeyAlias
                keyPassword = androidKeyPassword
                storeFile = file(androidKeystorePath!!)
                storePassword = androidStorePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigningCredentials) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

tasks.withType<JavaCompile>().configureEach {
    doFirst {
        sanitizeGeneratedPluginRegistrant()
    }
}

tasks.withType<KotlinCompile>().configureEach {
    doFirst {
        sanitizeGeneratedPluginRegistrant()
    }
}
