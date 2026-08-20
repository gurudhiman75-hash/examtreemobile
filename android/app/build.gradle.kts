import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.isFile) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

val releaseStoreFilePath = keystoreProperties.getProperty("storeFile")?.trim()
val releaseStorePassword = keystoreProperties.getProperty("storePassword")?.trim()
val releaseKeyAlias = keystoreProperties.getProperty("keyAlias")?.trim()
val releaseKeyPassword = keystoreProperties.getProperty("keyPassword")?.trim()
val releaseSigningReady = listOf(
    releaseStoreFilePath,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }

android {
    namespace = "com.examtree.examtree"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.examtree.examtree"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val stableDebugKeystore = file("${System.getProperty("user.home")}/.android/debug.keystore")
    signingConfigs {
        getByName("debug") {
            if (stableDebugKeystore.isFile) {
                storeFile = stableDebugKeystore
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }

        if (releaseSigningReady) {
            create("release") {
                storeFile = file(releaseStoreFilePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // Never fall back to the debug certificate for a production build.
            // verifyReleaseSigning below makes release tasks fail before packaging
            // when the private upload-key configuration is unavailable.
            if (releaseSigningReady) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

val verifyReleaseSigning by tasks.registering {
    group = "verification"
    description = "Fails release builds unless the production upload key is configured."

    doLast {
        if (!releaseSigningReady) {
            throw GradleException(
                "Android release signing is not configured. Provide android/key.properties " +
                    "with storeFile, storePassword, keyAlias and keyPassword."
            )
        }

        val storeFile = file(releaseStoreFilePath!!)
        if (!storeFile.isFile) {
            throw GradleException(
                "Android release keystore does not exist at ${storeFile.absolutePath}."
            )
        }
    }
}

tasks.configureEach {
    if (name == "preReleaseBuild") {
        dependsOn(verifyReleaseSigning)
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
