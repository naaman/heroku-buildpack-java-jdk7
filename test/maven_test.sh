#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/java
. ${BUILDPACK_HOME}/bin/maven
. ${BUILDPACK_HOME}/test/testlib

test_installMaven() {
  install_java ${BUILD_DIR}
  capture install_maven ${CACHE_DIR}
  assertCapturedSuccess
  assertTrue "Maven should be installed." "[ -f ${CACHE_DIR}/.maven/bin/mvn ]"
  assertTrue "Maven should be executable." "[ -x ${CACHE_DIR}/.maven/bin/mvn ]" 
  assertEquals "${CACHE_DIR}/.maven" "${M2_HOME}"
  assertContains "${CACHE_DIR}/.maven/bin" "${PATH}"
  assertEquals "${CACHE_DIR}/.maven/bin/mvn" "$(which mvn)"
  assertEquals "$(find ${BUILD_DIR} -name maven.tar.gz | wc -l | sed 's/ //g')" "0"
  assertContains "Maven 3.0.3" "$(mvn --version)"
  assertTrue "Settings should be installed." "[ -f ${CACHE_DIR}/.m2/settings.xml ]"
}

test_installMavenWithInvalidBuildDir() {
  install_java ${BUILD_DIR}
  capture install_maven
  assertCapturedError
  assertCapturedEquals "Invalid directory to install maven in."
}

test_build() {
  install_java ${BUILD_DIR}
  _writePomFile
  install_maven ${CACHE_DIR}
  capture build ${BUILD_DIR} ${CACHE_DIR}
  assertCapturedSuccess
  assertTrue "A JAR file should have been created from the build." "[ -f ${BUILD_DIR}/target/${TEST_ARTIFACT_FILE} ]"
  assertTrue "The jar plugin should be present in the .m2/repository." "[ -d ${CACHE_DIR}/.m2/repository/org/apache/maven/plugins/maven-compiler-plugin ]"
}

test_getBuildCommandWithInvalidHomeDirectory() {
  assertTrue "not implemented" "[ 1 = 0 ]"
}

test_getBuildCommandWithNoHomeDirectorySpecifiedButValidMavenBaseDirectory() {
  assertTrue "not implemented" "[ 1 = 0 ]"

}

test_getBuildCommandWithInvalidMavenBaseDirectory() {
  assertTrue "not implemented" "[ 1 = 0 ]"

}

test_getBuildCommandWithNoSettingsXml() {
  assertTrue "not implemented" "[ 1 = 0 ]"

}
