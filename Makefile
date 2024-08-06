METRICS_SERVER_VERSION = 3.11.0
KUBE_PROMETHEUS_STACK_VERSION = 56.1.0
K6_OPERATOR_VERSION = 3.3.0
INGRESS_NGINX_VERSION = 4.11.1

help:                            ## Show help of target details
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

wait-deploy:                     ## Wait ready Redis and giropops-senhas
	kubectl wait --for=condition=ready pod -l app=redis --timeout 5m
	kubectl wait --for=condition=ready pod -l app=giropops-senhas --timeout 5m

eks-create-cluster:              ## eksctl create cluster
	eksctl create cluster -f eks/cluster.yaml
	$(MAKE) install-cluster-deps
	kustomize build manifests/overlays/eks | kubectl apply -f -
	$(MAKE) wait-deploy

eks-delete-cluster:              ## eksctl delete cluster
	eksctl delete cluster -f eks/cluster.yaml --disable-nodegroup-eviction

kind-create-cluster:             ## kind create cluster
	kind create cluster --config kind/cluster.yaml
	$(MAKE) install-cluster-deps
	kustomize build manifests/overlays/local | kubectl apply -f -
	$(MAKE) wait-deploy

metrics-server-install:          ## Install Metrics Server
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	helm repo update
	helm upgrade --install metrics-server metrics-server/metrics-server \
		--namespace monitoring --create-namespace \
		-f manifests/metrics-server-values.yaml \
		--version $(METRICS_SERVER_VERSION) --wait

k6-operator-install:             ## Install Metrics Server
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm install k6-operator grafana/k6-operator --version $(K6_OPERATOR_VERSION) --wait

kube-prometheus-stack-install:   ## Install Kube Prometheus Stack
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install kube-prometheus prometheus-community/kube-prometheus-stack \
		--namespace monitoring --create-namespace \
		-f manifests/kube-prometheus-stack-values.yaml \
		--version $(KUBE_PROMETHEUS_STACK_VERSION) --wait

ingress-nginx-install:           ## Install Ingress Nginx
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
		--values https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/hack/manifest-templates/provider/kind/values.yaml \
		--namespace ingress-nginx --create-namespace \
		--version $(INGRESS_NGINX_VERSION) --wait

install-cluster-deps:            ## Install Cluster Dependencies
	$(MAKE) metrics-server-install
	$(MAKE) kube-prometheus-stack-install
	$(MAKE) ingress-nginx-install
	$(MAKE) k6-operator-install

run-load-test-k6-operator:       ## Run Load Test in the K6 Operator
	kubectl apply -f load-test/
	sleep 10
	kubectl wait --for=condition=complete job -l k6_cr=giropops-senhas-load-test-k6 --timeout 10m
	kubectl delete -f load-test/