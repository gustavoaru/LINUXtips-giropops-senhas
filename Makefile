METRICS_SERVER_VERSION = 3.11.0
KUBE_PROMETHEUS_STACK_VERSION = 55.5.2

all: eks-create-cluster install-cluster-deps redis-deploy giropops-senhas-deploy run-load-test

help:                            ## Show help of target details
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

redis-deploy:                    ## Deploy Redis
	kubectl apply -f k8s/redis

giropops-senhas-deploy:          ## Deploy giropops-senhas
	kubectl apply -f k8s/

eks-create-cluster:              ## eksctl create cluster
	eksctl create cluster -f eks/cluster.yaml

eks-delete-cluster:              ## eksctl delete cluster
	eksctl delete cluster -f eks/cluster.yaml --disable-nodegroup-eviction

kind-create-cluster:             ## kind create cluster
	kind create cluster --config kind/cluster.yaml

metrics-server-install:          ## Install Metrics Server
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm upgrade --install metrics-server metrics-server/metrics-server --version $(METRICS_SERVER_VERSION)

kube-prometheus-stack-install:   ## Install Kube Prometheus Stack
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm install kube-prometheus prometheus-community/kube-prometheus-stack

ingress-nginx-install:           ## Install Ingress Nginx
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm upgrade --install ingress-nginx ingress-nginx \
		--repo https://kubernetes.github.io/ingress-nginx \
		--namespace ingress-nginx --create-namespace

install-cluster-deps: metrics-server-install kube-prometheus-stack-install ingress-nginx-install            ## Install Cluster Dependencies

run-load-test:                   ## Run Load Test
	k6 run load-test/giropops-senhas.js