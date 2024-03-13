# Edge Storage Component  
  
This is the Edge Storage component. It aims to provide storage capabilities, utilizing the edge resources and optimizing the data transfer, caching and storage.  

More info for the System Architecture is provided in `SystemArchitect.md` file.

# Installation  
  
## Single node cluster  
  
The file `singleClusterInstallScript.sh` is a self-contained installation script for a single node cluster deployment.  

Make the installation script executable:

```sh
sudo chmod +x ./singleClusterInstallScript.sh
```
Execute the installation script:

    sh singleClusterInstallScript.sh
  
## Multi-node cluster  
  
For multinode clusters the `edgeServerDeploy.sh` should be used.   

In order for it to be used a manual configuration need to be carried out before it's execution.  

The configuration includes:  
* Defining the data path for data storage in the storage workers, which includes creating the necessary folders and setting the access rights in a way that Kubernetes is able to read and write into this path.  
     - Example: Create a folder `/data/test` and give access permissions with `sudo chmod 775 /data/test`    
* Set the data path in the edge storage config file `edgeConfig.conf` (`"data-path"` field)
* Add the label `edge-storage-worker=true` to all storage worker nodes.  
* Add the label `edge-storage-master=true` to the storage master node.  
    - How to label nodes? 
        - `kubectl get nodes` returns the nodes of the cluster   
        - `kubectl label node [name of the node]` `ches-worker=true` or `ches-master=true`

Make the installation script executable:

```sh
sudo chmod +x ./edgeServerDeploy.sh
```
Execute the installation script:

    sh edgeServerDeploy.sh

 
```mermaid
flowchart LR
 id1(edgeServerDeploy.sh) --apply--> id3(edgeServerDeployment.yaml)
```

Please make sure that everything is up and running. To ensure execute:

     kubectl get pods -A

In case that the STATUS is *ContainerCreating* and/or *PodInitializing* please wait until everything is up and running. Check periodically with the command mentioned above.

## Test the installation

Get datasets

     kubectl get datasets -A


> expected output:

    NAMESPACE   NAME            AGE
    default     edge-data    23m


Get pvc(s) in ches namespace

     kubectl get pvc -n ches

> expected output:

    NAME          STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    data-edgestorage-0   Bound     pvc-269dc91f-57dc-4d5a-9532-c15dcebc4885   1Gi        RWO            local-path     27m

Get the Dataset CRD

     kubectl get pvc

> expected output:

    NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    edge-data    Bound    pvc-af0b3841-97ea-4384-9548-8f79bdb61a20   9314Gi     RWX            csi-s3         2m42s


*If this command does not result the expected output something might gone wrong. Undeploy the cluster by running `sh edgeServerUndeploy.sh` and do the installation process again*

Connect to the MinIO console with the following credentials:

-   Username: chesAccesskeyMinio
-   Password: chesSecretkey

## Create Root User and Password (optional)

In `edgeConfig.conf`, there are already stored the access credentials for MinIO.
The username and password of the root user need to be created as secrets and
provided as environment variables. These need to be in base64 format in order to be created as secrets in Kubernetes.

In order to create new credentials (optional, better use the defaults that already exist):
```sh
$ echo -n 'my-access-key' | base64
bXktYWNjZXNzLWtleQ==
$ echo -n 'my-secret key' | base64
bXlYWFh4eHgvc2VjcmV0WFhYWHh4eC9rZXlYWHh4eA==
```

## File Sharing and Live Syncing

## Create a Pod and connect it to the Dataset CRD

Make the client deployment script executable:

 ```sudo chmod +x ./edgeClientDeploy.sh```
 
#### Client Installation Procedure

```mermaid
flowchart LR
 id1(edgeClientDeploy.sh) --triggers--> id2(edgeClientDeployment.yaml)
```
Make sure that

```yaml
persistentVolumeClaim:
 claimName: [your-dataset]
```

in edgeClientDeployment.yaml file  has the correct value returned from`kubectl get pvc` command.

Execute the client installation script and wait until pod is up and running:

     sh chesClientDeploy.sh

Connect to client pod:

     kubectl exec --stdin --tty [name_of_pod] -- /bin/bash

The `[name_of_pod]` corresponds to the

```yaml
metadata:
 name: [name_of_pod]
```

in edgeClientDeployment.yaml file.


See the contents of folder:

     ls -la /data/test/

Create a file inside the folder:

     echo "This is a file for testing" > /data/test/my_test_file.txt

 
Then connect to the MinIO Console with the credentials mentioned above in order to see the newly created file.



## Python Client API

The MinIO Python Client API provides high level APIs to access MinIO Object Storage.

#### Example - Bucket(s) listing and file uploader

The example below does the following:

-   Connects to the MinIO server using the provided credentials (an API is exposed)
-   List information of all accessible buckets
-   Uploads a file to a bucket

Full documentation can be found here:  [Python Client API Reference](https://min.io/docs/minio/linux/developers/python/API.html)

```python
import logging
from minio import Minio
from minio.error import S3Error
from multiprocessing import Process

minio = Minio(
    '[add the IP of the MiniO API]',
    access_key='chesAccesskeyMinio',
    secret_key='chesSecretkey',
    secure=False,
)

def list_all_buckets():
    #files_num = 0
    bucket_list = minio.list_buckets()
    for bucket in bucket_list:
        objects = minio.list_objects(bucket.name, recursive=True)
        print ("bucket name:", bucket.name)
        # for obj in objects:
        #     files_num += 1

def put_object_in_bucket():
    # Specify the bucket name and local file path
    bucket_name = "charitybucket"
    local_file_path = "test.txt"

    # Specify the object name (optional, default to the local file name)
    object_name = "remote-example.txt"

    # Upload the local file to the MinIO bucket
    minio.fput_object(
        bucket_name,
        object_name,
        local_file_path
    )
    print(f"Local file {local_file_path} uploaded to {bucket_name}/{object_name} successfully.")

if __name__ == '__main__':
    try:
        list_all_buckets()
        put_object_in_bucket()
    except S3Error as exc:
        print("error occurred.", exc)
        logging.critical("Object storage not reachable")
```

## License  
Edge Storage is published under the [AGPL V3 licence](https://www.gnu.org/licenses/agpl-3.0.txt).