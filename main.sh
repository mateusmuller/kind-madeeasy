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

[ ! -x "$(which kind)" ]    && _install_kind
[ ! -x "$(which kubectl)" ] && _install_kubectl
[ ! -x "$(which helm)" ]    && _install_helm
# ------------------------------------------------------------------------ #

# -------------------------------VARIABLES----------------------------------------- #
ENABLE_MONITORING="1"
ENABLE_INGRESS="1"
CLUSTER_NAME="kind"

OPTIONS="
    AVAILABLE OPTIONS:

    --no-monitoring - Do not install Prometheus Operator
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
}
# ------------------------------------------------------------------------ #
if [ -n "$1" ]; then
    while [ -n "$1" ]; do
        case $1 in
            --no-monitoring) ENABLE_MONITORING="0"          ;;
            --no-ingress)    ENABLE_INGRESS="0"             ;;
            --cluster-name)  shift && CLUSTER_NAME="${1}" ;;
            -h|--help)       _show_help                   ;;
            *)               _throw_error_message "${1}"  ;;
        esac
        shift
    done
fi