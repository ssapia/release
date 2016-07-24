#!/bin/bash

DIR="/src/release/"
JAR="${DIR}/target/release-1.0.jar"

prepare() {
    java -jar ${JAR} "${DIR}" "${1}"
}

perform() {
   echo "Building.....${1}"
   
   #cd ${DIR}/projects/${1}
   #mvn versions:use-releases -Dmessage="update from snapshot to release" scm:checkin release:clean release:prepare release:perform

}

case $1 in
   --prepare) prepare $2 ;;
   --perform) perform $2 ;;
   *) echo "Opção inválida" ;;
esac
