// Top-level build file where you can add configuration options common to all sub-projects/modules.
import org.gradle.kotlin.dsl.closureOf
import org.gradle.api.Project
import com.android.build.gradle.BaseExtension
import com.android.build.gradle.LibraryExtension
import com.android.build.gradle.AppExtension
import org.gradle.api.file.Directory
import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}

buildscript {
    val kotlin_version: String by extra("1.9.0")

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory location
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// START: Namespace injection and Java/Kotlin compatibility enforcement
subprojects {
    afterEvaluate(closureOf<Project> {
        // Force Java 17 for Java compile tasks
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }

        // Force Java 17 for Kotlin compile tasks
        tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions.jvmTarget = "17"
        }

        // Namespace fallback (optional)
        val androidExtension = extensions.findByName("android")
        if (androidExtension != null) {
            when (androidExtension) {
                is LibraryExtension -> {
                    if (androidExtension.namespace == null) {
                        androidExtension.namespace = group.toString() ?: "com.example.android.library"
                    }
                }
                is AppExtension -> {
                    if (androidExtension.namespace == null) {
                        androidExtension.namespace = group.toString() ?: "com.example.android.app"
                    }
                }
            }
        }
    })
}
// END: Namespace injection

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
