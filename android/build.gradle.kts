// Top-level build file where you can add configuration options common to all sub-projects/modules.

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Fix old plugins: inject namespace (AGP 8+ requirement) and
// force Java/Kotlin JVM target to 17 (some plugins use 8 or 11).
subprojects {
    // Skip the :app project — it's already configured in app/build.gradle.kts
    if (project.name != "app") {
        afterEvaluate {
            val androidExt = extensions.findByName("android")
            if (androidExt != null && androidExt is com.android.build.gradle.LibraryExtension) {
                // Inject namespace from AndroidManifest if missing
                if (androidExt.namespace.isNullOrEmpty()) {
                    val manifestFile = file("${projectDir}/src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val content = manifestFile.readText()
                        val packageRegex = Regex("""package="([^"]+)"""")
                        val match = packageRegex.find(content)
                        if (match != null) {
                            androidExt.namespace = match.groupValues[1]
                        }
                    }
                }

                // Force Java compatibility to 17
                androidExt.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }

            // Force Kotlin JVM target to 17
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                kotlinOptions {
                    jvmTarget = "17"
                }
            }

            // Force Java compile tasks to 17
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = "17"
                targetCompatibility = "17"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
