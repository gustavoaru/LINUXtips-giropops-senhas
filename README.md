# antonioazambuja/LINUXtips-giropops-senhas

This project was created on the PICK [LinuxTips](https://www.linuxtips.io) and have objective allow practice my abilities in Security Practices, Resource Efficient, Monitoring and Automation.

## Project tasks

### BACKLOG

- [ ] [k8sgpt](https://github.com/k8sgpt-ai/k8sgpt);
- [ ] Kyverno;
- [ ] [kube-bench](https://github.com/aquasecurity/kube-bench);
- [ ] Github Actions:
  - [ ] Use [GitHub's OIDC provider](https://github.com/aws-actions/configure-aws-credentials#OIDC) instead AWS IAM secrets;
    - [ ] https://medium.com/@extio/kubernetes-authentication-with-oidc-simplifying-identity-management-c56ede8f2dec
- [ ] Github Actions:
  - [ ] CD:
    - [ ] Infrastructure:
      - [ ] eksctl with YAML;
      - [ ] Metrics Server;
      - [ ] kube-prometheus;
      - [ ] Ingress Nginx;
    - [ ] Application:
      - [ ] Deploy;
      - [ ] Install Kind on Github Action to test giropops-senhas;

### TODO
- [ ] Prometheus Monitoring:
  - [ ] AlertManager Alarms to giropops-senhas and Redis;
  - [ ] Add more metrics to giropops-senhas;
- [ ] cert-manager;
- [ ] Kustomize;
- [ ] EKS:
  - [ ] aws-efs-csi-driver addon: https://hervekhg.medium.com/stop-using-ebs-as-persistant-volume-for-eks-pod-use-efs-instead-fev-2023-d9ee4a9b9eeb;
- [ ] Remove `exclude` Kube-linter config;
- [ ] Github Actions:
  - [ ] Use container Chainguard image on Github Actions;
  - [ ] Add CRDs support on kube-linter;
- [ ] Infrastructure:
  - [ ] Fix vulnerabilities founds in each Chart using [Chainguard Images](https://images.chainguard.dev/);
- [ ] Application:
  - [ ] CI:
    - [ ] Migrate Public Docker Hub Repository to Private Docker Hub Registry or AWS ECR;
- [ ] README.md:
  - [ ] Add README how to install dependencies to use Makefile;
  - [ ] How to fix spike request on application?;

### WIP


### DONE

- [x] Project Fork;
- [x] Remove spec.replicas Deployment when exist HPA;
- [x] Repository Organization;
- [x] Docker image:
  - [x] Otimization with multi-stage builds and Chainguard images;
  - [x] Security scan;
- [x] K8s Configuration:
  - [x] YAML manifests;
  - [x] Best Practices;
  - [x] YAML Linting;
- [x] Github Actions:
  - [x] Sign with Cosign;
  - [x] Lint Kube and YAML;
- [x] Redis:
  - [x] User nonRoot with StatefulSet using Chainguard image;
  - [x] Create K8s headless service;
  - [x] Add support to PV and Statefulset on AWS EKS;
- [x] Infrastructure:
  - [x] K6 Operator Install;
- [x] Prometheus Monitoring:
  - [x] Install Prometheus on K8s;
  - [x] Instrument Prometheus on project using ServiceMonitor CRD;
  - [x] Add more metrics to Redis;
- [x] Chainguard Cosign - Signing Docker images;
- [x] Load Test with K6 (min TP: 1000 rpm without any errors):
  - [x] K8s resource analysis after Load Test;
  - [x] Using K6 Operator to run load test inside K8s cluster using K8s service endpoint;
  - [x] Using K6 local with ingress of giropops-senhas;
- [x] README.md:
  - [x] What's your decisions and process used in this project;
  - [x] How to verify signed container images using cosign?

Below have some descriptions and decisions about tools used in this project:

## Fork

This project is a fork of [badtuxx/giropops-senhas](https://github.com/badtuxx/giropops-senhas). I'm participating in the LinuxTips PICK and we task as a students was developing full project using more latest tools knowledged in the course and based in this fork repository application **Giropops Senhas**.

## Developing Docker image

I used Python [Chainguard](https://www.chainguard.dev/) image with free account available. This image base is Distroless, then my objective was built this project free vulnerabilities and with base image more lower size possible with objective increase pull on my K8s cluster.

### Optimizing

I used Chainguard Distroless base image and multistage build on Python environment. More details about: [Dockerfile](Dockerfile).

### Trivy - Security Scan


I used [Trivy](https://trivy.dev/) to security scan in base image developed. Below you can view latest scan performed in the image.

**Performed in: November 26th, 2024.**

```
✗ trivy image giropops-senhas:0.1
2023-11-26T21:29:04.967-0300	INFO	Need to update DB
2023-11-26T21:29:04.967-0300	INFO	DB Repository: ghcr.io/aquasecurity/trivy-db
2023-11-26T21:29:04.967-0300	INFO	Downloading DB...
40.99 MiB / 40.99 MiB [-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------] 100.00% 16.06 MiB p/s 2.8s
2023-11-26T21:29:08.969-0300	INFO	Vulnerability scanning is enabled
2023-11-26T21:29:08.969-0300	INFO	Secret scanning is enabled
2023-11-26T21:29:08.969-0300	INFO	If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2023-11-26T21:29:08.969-0300	INFO	Please see also https://aquasecurity.github.io/trivy/v0.47/docs/scanner/secret/#recommendation for faster secret detection
2023-11-26T21:29:17.509-0300	INFO	Detected OS: wolfi
2023-11-26T21:29:17.509-0300	INFO	Detecting Wolfi vulnerabilities...
2023-11-26T21:29:17.510-0300	INFO	Number of language-specific files: 1
2023-11-26T21:29:17.510-0300	INFO	Detecting python-pkg vulnerabilities...

giropops-senhas:0.1 (wolfi 20230201)

Total: 0 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0)
```

## Running

For running this project look steps above:

- Choose how to run your cluster. I'm running on Kind cluster locally:
```
kind create cluster --config kind/cluster.yaml
```
- Install kube-prometheus to instrument your application on Prometheus with ServiceMonitor CRD. More details about installation method in the Github repository: https://github.com/prometheus-operator/kube-prometheus.
- 
```
git clone 
```

## CI

I used Github Actions to create CI on this project. When new push is performed in the branches `main` and `develop` these steps are executed:
- Docker Hub login;
- Docker build;
- Run Trivy scan to search any vulnerabilities;
- Build and push to Docker Hub;
- Sign the container image with Cosign;

### How to verify the container image

You can do that by using the cosign verify command against the published container image:

```sh
cosign verify ablackout3/giropops-senhas:latest \
  --certificate-identity https://github.com/antonioazambuja/LINUXtips-giropops-senhas/.github/workflows/ci.yaml@refs/heads/develop \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com | jq

```

PS.: Because we are doing a public repository, this will automatically be pushed to the public instance of the Rekor transparency log. More details about Rekor you can see [here](https://edu.chainguard.dev/open-source/sigstore/rekor/).

## Load Test

Objective: I used K6 to run load test on application. Using K6 my objective was ensure application receive 1000 rpm.

Reality: K6 load test on application with 4000 rpm in each endpoint `GET /`, `GET /api/senhas` and, `POST /api/gerar-senha` using 2 value on K6 parallelism parameter with up up 8000 rpm withot any error.