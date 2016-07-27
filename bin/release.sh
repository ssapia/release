#!/bin/bash
# -- SSA --

##########################################

DIR="/src/release/"

PROJETOS="${DIR}/projects"

MAVEN_OPS=" --batch-mode"

##########################################


PROJETO=${2}
TMP_FILE="/tmp/release_$$.tmp"

showMsg() {
    echo -e "\033[01;31m${1}\033[0m"
}

run() {

    eval ${1}

    if [ ${?} -ne 0 ]; then

	showMsg "Ocorreu um erro!!!"

	if [ -f ${TMP_FILE} ]; then
	    cat ${TMP_FILE} && rm ${TMP_FILE}
	fi 
	exit 1
    fi 
}

releaseCmd() {
  
    projeto=$(echo ${1} | cut -d: -f1) 
    versao=$(echo ${1} | cut -d: -f2)

    if [ "${projeto}" == "${versao}" ]; then
        showMsg "Releasing.... ${projeto}"
    else 
        showMsg "Releasing.... ${projeto}-${versao}"
    fi

    if [ "$2" == "--list-only" ]; then
	return
    fi

    if [ ! -f "${PROJETOS}/${projeto}/pom.xml" ];then
	showMsg "Erro, projeto '${projeto}' não encontrado!!!"
        exit 1
    fi

    run "cd ${PROJETOS}/${projeto}"
    run "git checkout master"
    run "git pull"
    run "mvn versions:use-releases -Dmessage='update from snapshot to release' 
    	scm:checkin release:clean release:prepare release:perform ${MAVEN_OPS}"

}

release() {
  
    run "mvn dependency:list -f ${PROJETOS}/${1}/pom.xml > ${TMP_FILE}"

    SNAPSHOTS=$(grep -- '-SNAPSHOT' ${TMP_FILE} | grep compile$ | cut -d: -f2,4 | tac)
    
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

release - V0.1.0"
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


if [ -f ${TMP_FILE} ]; then
    rm ${TMP_FILE}
fi

