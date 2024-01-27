METRICS_SERVER_VERSION = 3.11.0
KUBE_PROMETHEUS_STACK_VERSION = 56.1.0
K6_OPERATOR_VERSION = 3.3.0
INGRESS_NGINX_VERSION = 4.9.0

all: eks-create-cluster install-cluster-deps redis-deploy giropops-senhas-deploy run-load-test

help:                            ## Show help of target details
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

redis-deploy:                    ## Deploy Redis
	kubectl apply -f manifests/redis.yaml

giropops-senhas-deploy:          ## Deploy giropops-senhas
	kubectl apply -f manifests/deploy.yaml

giropops-senhas-deploy-without-ingress:          ## Deploy giropops-senhas without ingress
	kubectl apply -f manifests/deploy-without-ingress.yaml

eks-create-cluster:              ## eksctl create cluster
	eksctl create cluster -f eks/cluster.yaml
	kustomize build manifests/overlays/eks | kubectl apply -f -

eks-delete-cluster:              ## eksctl delete cluster
	eksctl delete cluster -f eks/cluster.yaml --disable-nodegroup-eviction

kind-create-cluster:             ## kind create cluster
	kind create cluster --config kind/cluster.yaml
	kustomize build manifests/overlays/local | kubectl apply -f -

metrics-server-install:          ## Install Metrics Server
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm upgrade --install metrics-server metrics-server/metrics-server \
		--version $(METRICS_SERVER_VERSION) --wait

k6-operator-install:          ## Install Metrics Server
	helm repo add grafana https://grafana.github.io/helm-charts
	helm install k6-operator grafana/k6-operator --version $(K6_OPERATOR_VERSION) --wait

kube-prometheus-stack-install:   ## Install Kube Prometheus Stack
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm install kube-prometheus prometheus-community/kube-prometheus-stack \
		-f manifests/kube-prometheus-stack-values.yaml \
		--version $(KUBE_PROMETHEUS_STACK_VERSION) --wait

ingress-nginx-install:           ## Install Ingress Nginx
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm upgrade --install ingress-nginx ingress-nginx \
		--repo https://kubernetes.github.io/ingress-nginx \
		--namespace ingress-nginx --create-namespace \
		--version $(INGRESS_NGINX_VERSION) --wait

install-cluster-deps: metrics-server-install kube-prometheus-stack-install ingress-nginx-install k6-operator-install           ## Install Cluster Dependencies

run-load-test:                   ## Run Load Test
	k6 run load-test/giropops-senhas.js

run-load-test-k6-operator:       ## Run Load Test in the K6 Operator
	kubectl apply -f load-test/
	sleep 10
	kubectl wait --for=condition=complete job -l k6_cr=giropops-senhas-load-test-k6 --timeout 10m
	kubectl delete -f load-test/