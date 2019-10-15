pipeline {
    agent { label 'ubuntu'}
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = '1.3.1'
        ZENODO_KEY = credentials('zenodo')
    }
    
    stages {
        stage('Build') {
            when { changeset "singularity/*"}
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
            when { changeset "singularity/*"}
            steps {
                echo 'Testing..'
                sh '''
                    singularity exec ${IMAGE}.sif ls
                '''
            }
        }
        stage('Post') {
            when { changeset "singularity/*"}
            steps {
                echo 'Image Successfully Built'
                azureUpload (storageCredentialId:'gomap', filesPath:"${IMAGE}.sif",allowAnonymousAccess:true, virtualPath:"${IMAGE}/${VERSION}/", storageType:"blob",containerName:'gomap')
                sh '''
                    python3 zenodo_upload.py ${ZENODO_KEY}
                '''
            }
        }
    }
}