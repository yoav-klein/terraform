# Jenkins + Artficatory
---

First, run terraform apply.

## Artifactory

SSH to the Artifactory machine and run the `./run.sh` script

Log to Artifactory GUI `http://<artifactory-machine-domain>:8081`

Default credentials: `admin:password`


## Jenkins

Log in to Jenkins: `http://<jenkins-machine-domain>:8080`


Run this to get the initial passsord:
```
ssh -i private.key ubuntu@$(terraform output -raw jenkins_public_domain) 'docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'
```

Configure a Artifactory server in Jenkins with the ID 'artifactory' using the `artifactory_private_domain` output


Start with a simple Pipeline:

```

node() {
    sh script: 'echo "Hello" > file'
    sh script: 'ls'
    

    rtUpload (
        serverId: 'artifactory',
        spec: '''{
              "files": [
                {
                  "pattern": "file",
                  "target": "example-repo-local/froggy-files/"
                }
             ]
        }''',
    
        buildName: 'holyFrog',
        buildNumber: '42',
        project: 'my-project-key'
    )
}
```
