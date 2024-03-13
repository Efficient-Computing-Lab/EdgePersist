## System Architecture  
  
The proposed module employs the [Kubernetes](https://kubernetes.io/) ecosystem which is an open-source system for automating deployment, scaling, and management of containerized applications. 
  
As a storage solution, an open-source framework created by IBM is utilized, called [MinIO](https://min.io/). **MinIO** is an inherently decentralized, P2P solution which is designed to be cloud native and can run as lightweight containers managed by external orchestration services such as Kubernetes. It supports a hierarchical structure in order to form federations of clusters and it has been proven as a valid candidate for an edge data storage system. MinIO writes data and metadata together as objects, eliminating the need for a metadata database. In addition MinIO performs all functions (erasure code, bitrot check, encryption) as inline, strictly consistent operations. The result is that MinIO is exceptionally resilient. In addition, it uses object storage over block storage so it is in fact a combination of the two systems, preserving the lightweight distributed nature of block storage while providing the plethora of metadata and easy usage of the object storage. Unlike other object storage solutions that are built for archival use cases only, the MinIO platform is designed to deliver the high-performance object storage that is required by modern big data applications.  
  
## Dynamic Lifecycle Framework  
  
Hybrid edge/cloud environment is rapidly becoming the new trend for organizations seeking the perfect mix of scalability, performance and security. As a result, it is now common for an organization to rely on a mix of on-premises datacenters (private cloud), and cloud/edge solutions from different providers to store and manage their data.  
  
Nevertheless, many obstacles arise when applications have to access the data. On the one hand, developers need to know the exact location of the data and on the other hand to manage the correct credentials to access the specified data-sources holding their data. In addition, access to cloud/edge storage is often completely transparent from the cloud management standpoint and it is difficult for infrastructure administrators to monitor which containers are accessing which cloud storage solution.  
Even if containerized components and microservices are largely promoted as the appropriate solution to efficiently deploy and manage storage on top of a hybrid edge/cloud infrastructure, containerization makes it more difficult for the workloads to access the shared file systems. Currently, there are no established resource types to represent the concept of data-source on Kubernetes. As more and more applications are running on Kubernetes for batch processing, end users are burdened with configuring and optimising the data access.  
  
To tackle the aforementioned issues, **Dataset Lifecycle Framework (DLF)** is employed which is an open-source project that enables transparent and automated access for containerized applications to data-sources.  
DLF enables users to access remote data-sources via a mount-point within their containerized workloads and it is aimed to improve usability, security and performance, providing a higher level of abstraction for dynamic provisioning of storage for the users’ applications. With the integration of DLF on Kubernetes pipelines, it is able to mount object stores as PVCs and present them to pipelines as a POSIX-like file system. In addition, DLF makes use of Kubernetes access control and secret so that pipelines do not need to be run with escalated privilege or to handle secret keys, thus making the platform more secure.  
  
In more technical detail, DLF orchestrates the provisioning of PVCs required for each data-source which users can reference in their pods, allowing them to focus on the actual workload development rather than configuring/mounting/tuning the data access.  
  
DLF is designed to be cloud-agnostic and due to CSI, it is highly extensible to support various data sources. CSI is a standard for exposing arbitrary block and file storage storage systems to containerized workloads on Container Orchestration Systems (COS) like Kubernetes. With the adoption of COS, the Kubernetes volume layer becomes truly extensible. Using CSI, third-party storage providers are able to write and deploy plugins exposing new storage systems in Kubernetes without interact or change the core Kubernetes code. This provides Kubernetes users more options for storage and makes the system more secure and reliable.  
On the infrastructure side, DLF also enables cluster administrators to easily monitor, control, and audit data access.  
  
  
DLF introduces the Dataset as a Custom Resource Definition  [(CRD)](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/), which is a pointer to existing S3 or NFS data-sources. A Dataset object is a reference to a storage provided by a cloud-based storage solution, potentially populated with pre-existing data. In other words, each Dataset is a pointer to an existing remote data source and is materialized as a PVC. The Dataset is a declarative construct that abstracts access information and provides a single reference for data in Kubernetes. Users only need to include this reference in their deployments to make the data available in pods, either through the file system or through environment variables.  
  
Below is presented a Dataset named example-dataset pointing to an S3 bucket. The mandatory fields are the bucket, endpoint, accessKeyID, and secretAccessKey. The bucket entry creates a one-to-one mapping relationship between a Dataset object and a bucket in the COS. The accessKeyID and secretAccessKey fields refer to the credentials used to access the specific bucket.  
DLF is completely agnostic to where/how a specific Dataset is stored, as long as the endpoint is accessible by the nodes within the Kubernetes cluster, in which the framework is deployed.  
  
  
```yaml
cat <<EOF | kubectl apply -f -
apiVersion: com.ie.ibm.hpsys/v1alpha1
kind: Dataset
metadata:
  name: example-dataset
spec:
  local:
    type: "COS"
    accessKeyID: "{AWS_ACCESS_KEY_ID}"
    secretAccessKey: "{AWS_SECRET_ACCESS_KEY}"
    endpoint: "{S3_SERVICE_URL}"
    bucket: "{BUCKET_NAME}"
    readonly: "true" #OPTIONAL, default is false
    region: "" #OPTIONAL
EOF
```

  
  
Creating a CRD is just the first step to add custom logic in the Kubernetes cluster. The next step is to create a component that has embedded the domain-specific application logic for the CRD. Essentially, a service provider needs to develop and install a component which reacts to the various events which are part of the lifecycle of a CRD and implements the desired functionality.  
DLF utilizes the Operator-SDK, an open-source component of the [Operator Framework](https://operatorframework.io/), which provides the necessary tooling and automation in the development of these components in an effective, automated, and scalable way. Operator-SDK is utilized to create the Dataset Operator in DLF. Its main functionality is to react to the creation (or the deletion) of a new Dataset and materialize the specific object. Specifically, when a Dataset gets created, the software stack invokes the necessary Kubernetes CSI plugin and creates a PVC that provides a filesystem view of the bucket in the COS. A pod definition can refer to one or more Dataset CRDs in a declarative fashion. When the pod is initialised, the PVCs corresponding to these Datasets are directly mounted and exposed as a folders inside the pod’s constituent containers.  
  
Official Repo: [Datashim](https://github.com/datashim-io/datashim/)