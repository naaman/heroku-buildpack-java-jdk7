#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/common

test_invalidGetPomFileParameters() {
  capture _get_pom_file
  assertCapturedError
  assertCapturedEquals "Invalid directory specified for pom file."
}

test_noPomFile() {
  capture _get_pom_file "${BUILD_DIR}"
  assertCapturedError
  assertCapturedEquals "No pom file specified for maven project."
}

test_missingPomFile() {
  touch ${BUILD_DIR}/pom.xml.xml
  capture _get_pom_file "${BUILD_DIR}"
  assertCapturedError
  assertCapturedEquals "No pom file specified for maven project."
}

test_existingPomFile() {
  touch ${BUILD_DIR}/pom.xml
  capture _get_pom_file "${BUILD_DIR}"
  assertCapturedSuccess
  assertCapturedEquals "${BUILD_DIR}/pom.xml"
}

test_existingUppercasePomFile() {
  touch ${BUILD_DIR}/POM.XML
  capture _get_pom_file "${BUILD_DIR}"
  assertCapturedSuccess
  assertCapturedEquals "${BUILD_DIR}/pom.xml"
}

test_defaultJdkUrl() {
  capture _get_jdk_download_url 
  assertCapturedSuccess
  assertCapturedEquals "${JDK_URL_1_7}"
}

test_nonDefaultJdkUrl() {
  capture _get_jdk_download_url "1.6"
  assertCapturedSuccess
  assertCapturedEquals "${JDK_URL_1_6}"
}

test_javaVersionInPom() {
  cat > ${BUILD_DIR}/pom.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.heroku.buildpack</groupId>
  <artifactId>buildpack-jvm-utils-test</artifactId>
  <version>0.1</version>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>2.4</version>
        <configuration>
          <source>1.6</source>
          <target>1.6</target>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
EOF
  capture get_java_version ${BUILD_DIR}
  assertCapturedSuccess
  assertCapturedEquals "1.6"
}

test_unsupportedJavaVersionInPom() {
  cat > ${BUILD_DIR}/pom.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.heroku.buildpack</groupId>
  <artifactId>buildpack-jvm-utils-test</artifactId>
  <version>0.1</version>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>2.4</version>
        <configuration>
          <source>1.5</source>
          <target>1.5</target>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
EOF
  capture get_java_version ${BUILD_DIR}
  assertCapturedSuccess
  assertCapturedEquals "${LATEST_JDK_VERSION}"
}

test_unspecifiedJavaVersionInPom() {
  cat > ${BUILD_DIR}/pom.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.heroku.buildpack</groupId>
  <artifactId>buildpack-jvm-utils-test</artifactId>
  <version>0.1</version>

</project>
EOF
  capture get_java_version ${BUILD_DIR}
  assertCapturedSuccess
  assertCapturedEquals "${LATEST_JDK_VERSION}"
}

test_installJavaWithoutDirectoryFails() {
  capture install_java
  assertCapturedError
  assertCapturedEquals "Invalid directory to install java."
}

test_installDefaultJava() {
  capture install_java ${BUILD_DIR}
  assertCapturedSuccess
  assertTrue "A .jdk directory should be created when installing java." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "The java runtime should be present." "[ -f ${BUILD_DIR}/.jdk/bin/java ]"
  assertEquals "${BUILD_DIR}/.jdk" "${JAVA_HOME}"
  assertContains "${BUILD_DIR}/.jdk/bin" "${PATH}"
}
