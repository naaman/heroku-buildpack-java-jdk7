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
  assertCapturedEquals "1.7"
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
  assertCapturedEquals "1.7"
}

