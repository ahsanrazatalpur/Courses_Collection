import org.gradle.api.tasks.Delete
import org.gradle.api.Project
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/**
 * Move build directory outside android/
 * (Flutter recommended structure)
 */
val rootBuildDir = rootProject.layout.buildDirectory.dir("../../build")

rootProject.layout.buildDirectory.set(rootBuildDir)

subprojects {
    layout.buildDirectory.set(rootBuildDir.map { it.dir(project.name) })
}

subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
