from flask import Flask, request
from docker_registry_client import DockerRegistryClient
import os, base64, kubernetes, time, random, yaml

app = Flask(__name__)

def logvalue(logstring):
    with open("/repoauths/log","a+") as logfile:
        print(logstring)
        logfile.write(str(logstring)+"\n")
        
def syncDocker(imageURL):
    srcCreds = ""
    try:
        with open('/repoauths/'+imageURL.split('/')[0].replace('.','').strip(),'r') as credFile:
            srcCreds = credFile.readline().strip()
        jobName = f"aces-syncer-{int(random.random()*10000)}"
        pod_manifest = {
            'apiVersion': 'batch/v1',
            'kind': 'Job',
            'metadata': {
                'name': jobName,
                'namespace': "aces-sync"
            },
            'spec': {
                'ttlSecondsAfterFinished': 100,
                'template' :{
                    'spec' : {
                        'hostNetwork': True,
                        'containers': [{
                            'image': 'quay.io/skopeo/stable:latest',
                            'name': 'skopeo',
                            "args": [
                                "sync",
                                "--src",
                                "docker",
                                "--dest",
                                "docker",
                                "--src-creds",
                                srcCreds,
                                "--all",
                                "--dest-tls-verify=false",
                                imageURL,
                                os.getenv('REPOURL')
                            ]
                        }],
                        'restartPolicy': 'Never'
                    }
                }
            }
        }
        kubernetes.config.load_kube_config()
        api_instance = kubernetes.client.CoreV1Api()
        batchapi_instance = kubernetes.client.BatchV1Api()
        resp = batchapi_instance.create_namespaced_job(body=pod_manifest,namespace='aces-sync')
        while True:
            try:
                resp = batchapi_instance.read_namespaced_job_status(name=jobName,namespace='aces-sync')
                if resp.status.succeeded is not None or resp.status.failed is not None:
                    break
                time.sleep(1)
            except Exception as ex: 
                logvalue(ex)
                break
        logvalue(imageURL+" copied.")
        return imageURL+" copied."
    except Exception as e: 
        logvalue(e)
        return str(e)
        
def syncVM(imageURL,dvname,namespace,storage):
    try:
        with open('/yamltemplates/datavolumetemplate.yaml') as dvtemplate:
            dv_obj = yaml.safe_load_all(dvtemplate)
        dv_obj['metadata']['name'] = dvname
        dv_obj['metadata']['namespace'] = namespace
        dv_obj['spec']['source']['http']['url'] = imageURL
        dv_obj['spec']['pvc']['resources']['requests']['storage'] = storage
        config.load_kube_config()
        k3s_client = client.ApiClient()
        res = utils.create_from_dict(k3s_client, dv_obj)
        logvalue(res)
        return res
    except Exception as ex:
        logvalue(str(ex))
        return str(ex)

@app.route("/list", methods=['GET'])
def list_repo_images():
    try:
        regClient = DockerRegistryClient(f"https://{os.getenv('REPOURL')}",verify_ssl=False)
        return str(regClient.repositories())
    except:
        return str("Cannot connect to repository.")

@app.route("/auth", methods=['GET', 'POST'])
def register_auths():
    res = ""
    if request.method == 'POST':
        content_type = request.headers.get('Content-Type')
        if content_type == "application/json":
            jsonData = request.get_json()
            try:
                os.mkdir('/repoauths')
            except Exception as e: 
                logvalue(e)
            try:
                for repoName in jsonData['auths']:
                    try:
                        with open('/repoauths/'+repoName.replace('http://','').replace('https://','').replace(':','').replace('.',''),'w+') as authFile:
                            authFile.write(str(base64.b64decode(jsonData['auths'][repoName]["auth"])).replace("b'","'")[1:-1]+'\n')
                            authFile.write(repoName)
                    except:
                        None
                res = f"Registered credentials for repos: {list(jsonData['auths'].keys())}"
            except Exception as e: 
                logvalue(e)
    else:
        files = [f for f in os.listdir('/repoauths') if os.path.isfile(os.path.join('/repoauths', f))]
        repos = []
        for file in files:
            with open(os.path.join('/repoauths', file), 'r') as authFile:
                authFile.readline()
                repos.append(authFile.readline())
        res = f"Registered repos: {repos}"
    return res
    
@app.route("/kafka", methods=['POST'])
def process_kafka():
    res = ""
    syncLogsObject = {}
    if request.method == 'POST':
        content_type = request.headers.get('Content-Type')
        if content_type == "application/json":
            try:
                jsonData = request.get_json()
                if os.path.exists('sync_logs'):
                    with open('sync_logs','r') as sync_logs_file:
                        syncLogsObject = json.load(sync_logs_file)
                if jsonData['appName'] in syncLogsObject:
                    if not syncLogsObject[jsonData['appName']]['appVersion'] == jsonData['appVersion']:
                        newer = False
                        versionOld = syncLogsObject[jsonData['appName']]['appVersion'].split('.')
                        versionNew = jsonData['appVersion'].split('.')
                        if len(versionOld) < len(versionNew):
                            for index,value in enumerate(versionOld):
                                if int(value) < int(versionNew[index]):
                                    newer = True
                                    break
                                elif int(value) > int(versionNew[index]):
                                    newer = False
                                    break
                        else:
                            for index,value in enumerate(versionNew):
                                if int(value) < int(versionOld[index]):
                                    newer = False
                                    break
                                elif int(value) > int(versionOld[index]):
                                    newer = True
                                    break
                        if newer:
                            if jsonData['appType'] == 'Docker':
                                res = syncDocker(jsonData['appURI'])
                            else:
                                res = syncVM(jsonData['appURI'],f'{jsonData["appName"]}-{jsonData["appVersion"].replace(".","-")}',jsonData["component"],jsonData.get("storage","50Gi"))
                            syncLogsObject[jsonData['appName']]['appVersion'] = jsonData['appVersion']
                else:
                    if jsonData['appType'] == 'Docker':
                        res = syncDocker(jsonData['appURI'])
                    else:
                        res = syncVM(jsonData['appURI'],f'{jsonData["appName"]}-{jsonData["appVersion"].replace(".","-")}',jsonData["component"],jsonData.get("storage","50Gi"))
                    syncLogsObject[jsonData['appName']]['appVersion'] = jsonData['appVersion']
                with open('sync_logs','w') as sync_logs_file:
                    json.dump(syncLogsObject, sync_logs_file)
            except Exception as ex:
                res = str(ex)
        else:
            res = "Only JSON allowed."
    return res
        
@app.route("/yaml", methods=['GET', 'POST'])
def process_yaml():
    res = ""
    if request.method == 'POST':
        content_type = request.headers.get('Content-Type')
        yamlLines = []
        data = str(request.get_data())
        if "\\r\\n" in data:
            yamlLines = data.split("\\r\\n")
        else:
            yamlLines = data.split("\\n")
        for line in yamlLines:
            if "image:" in line or "image :" in line:
                imageURL = line.strip().replace("image :","image:").split("image:")[-1].strip()
                try:
                    regClient = DockerRegistryClient(f"https://{os.getenv('REPOURL')}",verify_ssl=False)
                except:
                    return data
                try:
                    tags = None
                    try:
                        tags = regClient.repository(imageURL.split('/')[-1].split(':')[0]).tags()
                    except:
                        None
                    if not tags is None:
                        data = data.replace(imageURL,f"{os.getenv('REPOURL')}/"+imageURL.split('/')[-1])
                    else:
                        syncDocker(imageURL)
                        try:
                            tags = None
                            try:
                                tags = regClient.repository(imageURL.split('/')[-1].split(':')[0]).tags()
                            except:
                                None
                            if not tags is None:
                                data = data.replace(imageURL,f"{os.getenv('REPOURL')}/"+imageURL.split('/')[-1])
                            else:
                                raise Exception("Image not found.")
                        except Exception as ecs2:
                            logvalue(ecs2)
                except Exception as ecs:
                    logvalue(ecs)
        res = data
    else:
        res = "Please use POST requests including the target yaml for processing.\n"
    return res

if __name__ == '__main__':
    app.run(host="0.0.0.0",port=int(os.getenv('REPOSYNCPORT')))