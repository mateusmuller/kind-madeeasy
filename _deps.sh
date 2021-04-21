function _install_kind () {

    local kind_version=${$1:-'v0.10.0'}

    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${kind_version}/kind-linux-amd64" && \
    chmod +x ./kind && \
    sudo mv ./kind /usr/local/bin/kind

}

function _install_kubectl () {

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    kubectl version --client

}

function _install_helm () {

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh
    
}