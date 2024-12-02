# Multi-Stage Scalable Docker Kubernetes App

## Task

The objective of the task is as under:

- Create a **multi-stage Docker build** on any of the following services: Node.js, Go, or Python.
- Push the Docker image to a **public Docker repository**.
- Create deployment configuration files that satisfy the following requirements:
  - Deploy the Docker image on **Kubernetes**.
  - Ensure the application is accessible on **port 80** from the browser. You can test this locally.
  - Maintain a minimum of **3 pods** of this application running at all times.
  - Create a **scaling policy** for the deployment:
    - **Scaling should be based on CPU utilization.**
    - Target CPU utilization is **60%**.
- Use Minikube or other K8s tools to run Kubernetes applications locally.
- Ensure **all configurations are written in YAML files**.
- Be prepared to explain the task and your setup.

---

## Prerequisites

1. **Minikube installed and running** with Docker as the driver.
2. A **Python application Docker image** pushed to a public Docker repository.
3. **Kubernetes CLI (kubectl)** installed.
4. **Metrics Server** installed and configured on Minikube.

---

## Project Setup

1. **Start Docker.**
2. **Start Minikube**:
   ```bash
   minikube start --driver=docker
   ```
3. **Create a Dockerfile, build the image, and push it to Docker Hub:**
  ```bash
  docker build -t pratishtha22/python-app:latest .
  docker push pratishtha22/python-app:latest
  ```
4. **Create deployment and service manifest files:**
  ```bash
  kubectl apply -f deployment.yaml
  kubectl apply -f service.yaml
  ```
5. **Set up Horizontal Pod Autoscaler (HPA):**
  ```bash
  kubectl apply -f hpa.yaml
  ```
6. **Load Testing**
To simulate load and verify HPA functionality, use stress or apache-bench to generate CPU load:
  ```bash
  ab -n 10000 -c 50 http://localhost:80/
  kubectl get hpa python-app-hpa
  ```
7. **Testing Port Forwarding and ngrok**

   **Port Forwarding**
     Forward the application port to your local machine.
     ```bash
      kubectl port-forward svc/python-app-svc 80:80
     ```

**Note:** In a typical Kubernetes setup on a cloud or a remote server, NodePort would expose the service on a port (like 30090) that can be accessed externally. However, in my local Minikube setup on my laptop, the NodePort (30090) does not work when trying to access via the Minikube IP or localhost. The primary reasons for this behavior are:

1. Minikube Network Configuration: Minikube runs in a VM or Docker container on the local machine, and NodePort is not directly accessible from outside the VM/container network in this setup. When trying to access the Minikube VM using the Minikube IP or localhost, the Kubernetes service on the NodePort is not exposed to the local system network.

2. Minikube IP vs Localhost: While the service is assigned a NodePort (like 30090), Minikube IP points to the internal network of the VM. The port 30090 is mapped inside the VM and is not automatically forwarded to the laptop’s localhost.

To overcome this, we are using Port Forwarding, which allows us to forward the service’s port directly to the local machine, making it accessible on localhost:80. This approach solves the issue of direct NodePort exposure on local setups with Minikube and ensures that we can still access the application locally in the browser.

  **Expose the Service Using ngrok**
     To expose the application externally, use ngrok:
      Install ngrok.
      Run the following command to expose the service:
      ```bash
      ngrok http 80
      ```
      Access the application using the provided public URL.

8. **Enable Metrics Server for HPA**
Install Metrics Server on Minikube
Check if the Metrics Server is running:
```bash
kubectl get deployment metrics-server -n kube-system
```
If the output shows no resources, you'll need to install the Metrics Server:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
Edit the Metrics Server Deployment
Update the deployment configuration to allow the Metrics Server to ignore certificate validation and use internal IP addresses:
```bash
kubectl edit deployment metrics-server -n kube-system
```
Add the following arguments under the args section of the metrics-server container:

```bash
yaml
Copy code
spec:
  containers:
  - name: metrics-server
    args:
    - --kubelet-insecure-tls
    - --kubelet-preferred-address-types=InternalIP
```
