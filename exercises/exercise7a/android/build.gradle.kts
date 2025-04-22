buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }

    repositories {
        google()
        mavenCentral()
    }
}

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

subprojects {
    project.plugins.whenPluginAdded {
        if (this.javaClass.name.contains("com.android.build.gradle")) {
            project.extensions.findByName("android")?.let { ext ->
                @Suppress("UNCHECKED_CAST")
                val android = ext as com.android.build.gradle.BaseExtension
                android.buildFeatures.apply {
                    buildConfig = true
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
