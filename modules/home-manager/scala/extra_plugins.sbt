addSbtPlugin("net.vonbuchholtz" % "sbt-dependency-check"      % "5.1.0")  // dependencyCheckAggregate
addSbtPlugin("com.github.cb372" % "sbt-explicit-dependencies" % "0.3.1")  // unusedCompileDependencies
addSbtPlugin("com.timushev.sbt" % "sbt-updates"               % "0.6.3")  // dependencyUpdates
addSbtPlugin("ch.epfl.scala"    % "sbt-bloop"                 % "2.0.12") // bloopInstall
addDependencyTreePlugin //dependencyBrowseTreeHTML
// ThisBuild / libraryDependencySchemes ++= Seq("org.scala-lang.modules" %% "scala-xml" % VersionScheme.Always)
