Heroku buildpack: Java
=========================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for Maven-based Java apps.
It uses Maven 3.0.3 to build your application runs the app with the latest major version of OpenJDK 6 or 7.
If no version is specified, it defaults to OpenJDK 7.

Usage
-----

Example usage:

    $ ls
    Procfile  pom.xml  src

    $ heroku create --stack cedar --buildpack http://github.com/naamannewbold/heroku-buildpack-java-jdk7.git

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Fetching custom buildpack... done
    -----> Java app detected
    -----> Installing Java 1.7 done
    -----> Installing Maven 3.0.3..... done
    -----> executing mvn -B -Duser.home="/tmp/build_20jjpjlaxpjd" -Dmaven.repo.local="/app/tmp/repo.git/.cache/.m2/repository" -s "/app/tmp/repo.git/.cache"/.m2/settings.xml -DskipTests=true clean install
       [INFO] Scanning for projects...
       [INFO]                                                                         
       [INFO] ------------------------------------------------------------------------
       [INFO] Building java-app 1.0
       [INFO] ------------------------------------------------------------------------
    ...

By default, the app will use Java 7. However, the primary version of java can be specified with the 
maven-compiler-plugin. To specify Java 6, add the following to your `pom.xml`

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>2.4</version>
    <configuration>
        <source>1.6</source>
        <target>1.6</target>
    </configuration>
</plugin>
```

The buildpack will detect your app as Java if it has the file `pom.xml` in the root.  It will use Maven 
to execute the build defined by your pom.xml and download your dependencies. The .m2 folder (local maven 
repository) will be cached between builds for faster dependency resolution. However neither the mvn 
executable or the .m2 folder will be available in your slug at runtime.

Building Locally
----------------

This buildpack can be used to build locally on *nix systems.

> Note: This has only been tested with Ubuntu 10.04 x86_64, Ubuntu 12.04 x86_64, and Mac 10.7.4 x86_64. This has not been tested with 32-bit systems.

To use locally, clone the repo:

`git clone git://github.com/naamannewbold/heroku-buildpack-java-jdk7.git jdk7buildpack`

From your project directory, create a cache dir and compile:

`mkdir -p /tmp/jdk7buildpackcache`

`/path/to/jdk7buildpack . /tmp/jdk7buildpackcache`

Hacking
-------

To use this buildpack, fork it on Github.  Push up changes to your fork, then create a test app with `--buildpack <your-github-url>` and push to it.

For example if you want to have maven available to use at runtime in your application you simply have to copy it from the cache directory to the build directory by adding the following lines to the compile script:

    for DIR in ".m2" ".maven" ; do
      cp -r $CACHE_DIR/$DIR $BUILD_DIR/$DIR
    done

Now that you have changes, make sure to test them using the [testrunner buildpack](https://github.com/ryanbrainard/heroku-buildpack-testrunner). 
Tests are located in the `test` directory and use the naming convention `xxxxx_test.sh`. Any function beginning with `test_` will
be evaluated by the test runner. To run tests:

    `/path/to/heroku-buildpack-testrunner/bin/run .`

When all tests are passing, commit and push the changes to your buildpack to your Github fork, then push a sample app to Heroku to test. Once the push succeeds you should be able to run:

    $ heroku run bash

and then:

    $ ls -al

and you'll see the .m2 and .maven directories are now present in your slug.
