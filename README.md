# antonioazambuja/LINUXtips-giropops-senhas

This project was created on the PICK [LinuxTips](https://www.linuxtips.io) and have objective allow practice my abilities in Security Practices, Resource Efficient, Monitoring and Automation.

## Project tasks

### TODO
- [ ] Lint Kube and YAML;
- [ ] README.md:
  - [ ] How to fix spike request on application;

### WIP

### DONE

- [x] Project Fork;
- [x] Repository Organization;
- [x] Docker image:
  - [x] Otimization with multi-stage builds and Chainguard images;
  - [x] Security scan;
- [x] K8s Configuration:
  - [x] YAML manifests;
  - [x] Best Practices;
  - [x] YAML Linting;
- [x] Prometheus Monitoring:
  - [x] Install Prometheus on K8s;
  - [x] Instrument Prometheus on project using ServiceMonitor CRD;
- [x] Chainguard Cosign - Signing Docker images;
- [x] CI with Github Actions;
- [x] Load Test with K6 (min TP: 1000 rpm without any errors):
  - [x] K8s resource analysis after Load Test;
- [x] README.md:
  - [x] What's your decisions and process used in this project;

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

## Load Test

I used K6 to run load test on application. Using K6 my objective was ensure application receive 1000 rpm 