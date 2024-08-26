# Jenkins + Artficatory


Configure a Artifactory server in Jenkins with the ID 'artifactory'


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
