#!/bin/bash

DIR="/src/release/"
PROJETOS="${DIR}/projects"

PROJETO=${2}

showMsg() {
    echo -e "\033[01;31m${1}\033[0m"
}

run() {

    eval ${1}

    if [ ${?} -ne 0 ]; then
       showMsg "Ocorreu um erro!!!" && exit 1
    fi 
}

releaseCmd() {
   
    showMsg "Releasing.... $1"

    if [ "$2" == "--list-only" ]; then
	return
    fi

    if [ ! -f "${PROJETOS}/${1}/pom.xml" ];then
	showMsg "Erro, projeto '${1}' não encontrado!!!"
        exit 1
    fi

    #run "cd ${PROJETOS}/${1}"
    #run "git checkout master"
    #run "git pull"
    #run "mvn versions:use-releases -Dmessage='update from snapshot to release' 
    #	scm:checkin release:clean release:prepare release:perform"

}

release() {
  
    SNAPSHOTS=$(mvn dependency:list -f ${PROJETOS}/${1}/pom.xml | grep -- '-SNAPSHOT' | grep compile$ | cut -d: -f2 | tac)

    for SNAPSHOT in ${SNAPSHOTS}; do
	releaseCmd ${SNAPSHOT} ${2}
    done

    releaseCmd ${PROJETO} ${2} 
}

parametroInvalido() {
  echo "USO: $0 [OPCAO] [PROJETO]

Opções:
  -r, --release,  faz o release de todas as dependencias que estão como snapshot. 
  -l, --list,     exibe todas as dependencias que estão como snapshot.

release - V0.0.1"
  exit 1
}

if [ -z ${2} ]; then
    parametroInvalido
fi 

case $1 in
   -r|--release) release $2 ;;
   -l|--list) release $2 --list-only ;;
   *) parametroInvalido  ;;
esac
