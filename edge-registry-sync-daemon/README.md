# Edge Registry Sync Daemon

## Description
Edge Registry Sync Daemon aims at syncing a number of remote repositories and the localized Edge registry hosted on a minicloud.
It is using Python v3 and Flask in order to setup a Rest API that provides multiple services that will be detailed here.

## Setup
In order to setup Edge Registry Sync Daemon its files must be downloaded from the gitlab page.
After that the file setup.sh must be executed.

## Usage
### /list
Method: GET
It returns a list of the available images in the repository.
### /auth
Method: GET
It returns a list of the available authorization credentials for remote repositories.
Method: POST
It registers a new set of authorization credentials for a remote repository. The input is expected to be a JSON object following the docker credentials schema: {"auths": {"repository URL": {"auth": "base64 encoded credentials in name:key format"}}}.
### /yaml
Method: GET
Instructions of correct usage.
Method: POST
If the images specified in the provided yaml file are not present in the Edge repository their syncing is initiated.
After the syncing is finished a modified yaml file is returned having replaced all remote repository URLs with the Edge repository URL.
If the images cannot be synced or the Edge repository is not available then the original yaml is returned.

## License
Edge Registry Sync Daemon is published under the [AGPL V3 licence](https://www.gnu.org/licenses/agpl-3.0.txt).
