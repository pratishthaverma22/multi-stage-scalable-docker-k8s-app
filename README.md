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
     URL - http://localhost:80

   ![k8 1](https://github.com/user-attachments/assets/ecc9a6db-d002-436d-9bc5-d79279d0904b)


**Note:** In a typical Kubernetes setup on a cloud or a remote server, NodePort would expose the service on a port (like 30090) that can be accessed externally. However, in my local Minikube setup on my laptop, the NodePort (30090) does not work when trying to access via the Minikube IP or localhost. The primary reasons for this behavior are:

1. Minikube Network Configuration: Minikube runs in a VM or Docker container on the local machine, and NodePort is not directly accessible from outside the VM/container network in this setup. When trying to access the Minikube VM using the Minikube IP or localhost, the Kubernetes service on the NodePort is not exposed to the local system network.

2. Minikube IP vs Localhost: While the service is assigned a NodePort (like 30090), Minikube IP points to the internal network of the VM. The port 30090 is mapped inside the VM and is not automatically forwarded to the laptop’s localhost.

To overcome this, we are using Port Forwarding, which allows us to forward the service’s port directly to the local machine, making it accessible on localhost:80. This approach solves the issue of direct NodePort exposure on local setups with Minikube and ensures that we can still access the application locally in the browser.

  **Expose the Service Using ngrok**
  To expose the application externally, use ngrok:
    Install ngrok and run the following command to expose the service:
    ```bash
      ngrok http 80
    ```
    Access the application using the provided public URL. - https://5410-110-235-219-10.ngrok-free.app/

![k8 2](https://github.com/user-attachments/assets/13f620cc-d637-4d4c-b6d1-b0563ea24060)


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

**Cloud-based Load Balancing Options**
After completing the local setup with Minikube and testing the application, we can scale our deployment to a cloud environment like AWS. There are two common ways to expose our Kubernetes application in the cloud:

1. NodePort with AWS ELB
2. LoadBalancer Service with AWS ALB
   
Both approaches allow us to manage and distribute traffic to our Kubernetes application, but they differ in how they handle traffic distribution, scaling, and management.

**1. NodePort with AWS ELB**
In this setup, the Kubernetes service is exposed using a NodePort-type service. This exposes each of the Kubernetes worker nodes on a specific port like 300090, typically a high-range port, through which traffic can be routed to the pods. AWS Elastic Load Balancer (ELB) is used to distribute traffic across the worker nodes. ELB is configured to forward traffic to the NodePort on each node, ensuring that traffic reaches the application, even as the Kubernetes pods scale.

Flow:

1. The NodePort service exposes the application on a fixed port across all nodes like 30090.
2. AWS ELB listens for incoming requests and routes them to the appropriate NodePort on the Kubernetes nodes.
3. This setup requires additional configuration, including managing health checks and traffic routing for each individual node.

This approach is suitable for scenarios where we want basic load balancing and can manage our nodes manually. However, it’s less flexible and harder to scale compared to a more integrated solution like the LoadBalancer service.

**2. LoadBalancer Service with AWS ALB**
The LoadBalancer service in Kubernetes automatically provisions an AWS Application Load Balancer (ALB) to distribute traffic to the pods running in the Kubernetes cluster. The ALB listens for incoming traffic on a public IP and routes the traffic to the corresponding service in Kubernetes. Kubernetes integrates with the ALB to ensure that traffic is balanced across all available pods.

Flow:

1. The LoadBalancer service in Kubernetes automatically provisions an AWS ALB.
2. The ALB distributes traffic across multiple availability zones (AZs), ensuring high availability and fault tolerance.
3. The ALB monitors pod health and ensures that only healthy pods receive traffic.
4. This setup integrates directly with Kubernetes and automatically scales based on traffic load.

This is the preferred choice for production-grade, large-scale deployments as it provides better scalability, automated traffic distribution, SSL termination, and integrated health checks, without requiring manual management of nodes or ports.
