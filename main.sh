#!/usr/bin/env bash

source _deps.sh
source _tools.sh

# -------------------------------TESTS----------------------------------------- #
[ ! -x "$(which curl)" ] && {
    echo "curl is not installed, please install it."
    exit 1
}

[ ! -x "$(which docker)" ] && {
    echo "docker is not installed, please install it."
    exit 1
}

docker ps &> /dev/null || {
    echo "It seems you don't have permissions to use docker. Fix it."
    exit 1
}

[ ! -x "$(which kind)" ]    && _install_kind
[ ! -x "$(which kubectl)" ] && _install_kubectl
[ ! -x "$(which helm)" ]    && _install_helm
# ------------------------------------------------------------------------ #

# -------------------------------VARIABLES----------------------------------------- #
ENABLE_MONITORING="1"
ENABLE_INGRESS="1"
ENABLE_KONG="0"
ENABLE_METALLB="1"
CLUSTER_NAME="kind"

OPTIONS="
    AVAILABLE OPTIONS:

    --no-monitoring - Do not install Prometheus Operator
    --no-nginx - Do not install NGINX ingress
    --enable-kong - Enable kong as the Ingress controller
    --no-metallb - Do not install metallb
"
# ------------------------------------------------------------------------ #

# -------------------------------FUNCTIONS----------------------------------------- #
function _throw_error_message () {
    echo "Option ${1} does not exist."
    echo "${OPTIONS}"
    exit 1
}

function _show_help () {
    echo "${OPTIONS}"
    exit 0
}
# ------------------------------------------------------------------------ #
if [ -n "$1" ]; then
    while [ -n "$1" ]; do
        case $1 in
            --no-monitoring) ENABLE_MONITORING="0"        ;;
            --no-nginx)      ENABLE_INGRESS="0"           ;;
            --cluster-name)  shift && CLUSTER_NAME="${1}" ;;
            -h|--help)       _show_help                   ;;
            --enable-kong)   ENABLE_KONG="1"              ;;
            --no-metallb)    ENABLE_METALLB="0"           ;;
            *)               _throw_error_message "${1}"  ;;
        esac
        shift
    done
fi

_build_cluster "${ENABLE_MONITORING}" "${ENABLE_INGRESS}" "${CLUSTER_NAME}" "${ENABLE_KONG}" "${ENABLE_METALLB}"