pipeline {
    agent any
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = '1.3.1'
    }
    stages {
        stage('Build') {
            steps {
                sh '''
                    singularity --version && \
                    ls -lah && \
                    azcopy cp https://gomap.blob.core.windows.net/gomap/GOMAP-base/1.3.1/GOMAP-base.sif > GOMAP-base.sif && \
                    mkdir tmp && \
                    sudo singularity build --tmpdir tmp ${IMAGE}.sif singularity/Singularity.v1.3.1.mpich-3.2.1
                '''
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                sh '''
                    singularity exec ${IMAGE}.sif ls
                '''
            }
        }
        stage('Post') {
            steps {
                echo 'Image Successfully Built'
                azureUpload (storageCredentialId:'gomap', filesPath:"${IMAGE}.sif",allowAnonymousAccess:true, virtualPath:"${IMAGE}/${VERSION}/", storageType:"blob",containerName:'gomap')
            }
        }
    }
}