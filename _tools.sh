function _build_kind_cluster () {

    kind create cluster --config config/config.yaml --name "${1}"

}

function _pre_deploy_monitoring_stack () {

    local cluster_name="${1}"

    docker exec -it "${cluster_name}"-control-plane \
        sed 's/--bind-address.*/--bind-address=0\.0\.0\.0/' \
        -i /etc/kubernetes/manifests/kube-controller-manager.yaml

    docker exec -it "${cluster_name}"-control-plane \
        sed 's/--bind-address.*/--bind-address=0\.0\.0\.0/' \
        -i /etc/kubernetes/manifests/kube-scheduler.yaml

    kubectl get cm -n kube-system kube-proxy -oyaml | sed 's/metricsBindAddress.*/metricsBindAddress: "0.0.0.0:10249"/' | kubectl apply -f -

    kubectl get pods -n kube-system \
        -l k8s-app=kube-proxy \
        -o=jsonpath='{.items[*].metadata.name}' | xargs kubectl delete po -n kube-system

    docker cp "${cluster_name}"-control-plane:/etc/kubernetes/pki/etcd/ca.crt .
    docker cp "${cluster_name}"-control-plane:/etc/kubernetes/pki/etcd/peer.crt .
    docker cp "${cluster_name}"-control-plane:/etc/kubernetes/pki/etcd/peer.key .

    kubectl create ns monitoring || sleep 1
    kubectl create secret generic -n monitoring \
                                  --from-file=etcd-ca=ca.crt \
                                  --from-file=etcd-client=peer.crt \
                                  --from-file=etcd-client-key=peer.key \
                                  etcd-client-cert

}

function _deploy_monitoring () {

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
    helm repo update && \
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
                --namespace monitoring \
                --create-namespace \
                --values config/prometheusValues.yaml

}

function _deploy_ingress () {

    kubectl apply -f config/ingress.yml

}

function _build_cluster () {

    local enable_monitoring="${1}"
    local enable_ingress="${2}"
    local cluster_name="${3}"

    kind get clusters | grep "${cluster_name}" || _build_kind_cluster "${cluster_name}"

    kubectl config use-context "${cluster_name}-kind" 
    
    [ "${enable_ingress}" == "1" ]    && _deploy_ingress
    [ "${enable_monitoring}" == "1" ] && \
        _pre_deploy_monitoring_stack "${cluster_name}" && \
        _deploy_monitoring

}