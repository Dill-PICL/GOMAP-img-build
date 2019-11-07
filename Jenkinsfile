pipeline {
    agent none
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = '1.3.2'
    }
    
    stages {
        stage('Build') {
            agent { label 'ubuntu'}
            when { changeset "singularity/*"}
            steps {
                sh '''
                    sudo chown gokool:gokool /mnt
                    echo "$AZCOPY_JOB_PLAN_LOCATION"
                    echo "$AZCOPY_BUFFER_GB"
                    singularity --version && \
                    ls -lah && \
                    mkdir tmp && \
                    sudo singularity build --tmpdir tmp ${IMAGE}.sif singularity/Singularity.mpich-3.2.1
                '''
            }
            post{
                success{
                    echo 'Image Successfully Built'
                }
            }
        }
        stage('Test') {
            agent { label 'ubuntu'}
            when { changeset "singularity/*"}
            steps {
                echo 'Testing..'
                sh '''
                    singularity exec ${IMAGE}.sif ls /opt/
                '''
            }
            post{
                success{
                    echo 'Image Successfully tested'
                    azureUpload (storageCredentialId:'gomap', filesPath:"${IMAGE}.sif",allowAnonymousAccess:true, virtualPath:"${IMAGE}/${VERSION}/", storageType:"file",containerName:'gomap')
                    echo 'Image Successfully uploaded'
                }
            }
        }
    }
}
