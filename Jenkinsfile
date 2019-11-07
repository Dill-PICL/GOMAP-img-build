pipeline {
    agent { label 'ubuntu'}
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = '1.3.2'
    }
    
    stages {
        stage('Build') {
            when { changeset "singularity/*"}
            steps {
                sh '''
                    singularity --version && \
                    ls -lah && \
                    mkdir tmp && \
                    sudo singularity build --tmpdir tmp ${IMAGE}.sif singularity/Singularity.mpich-3.2.1
                '''
            }
        }
        stage('Test') {
            when { changeset "singularity/*"}
            steps {
                echo 'Testing..'
                sh '''
                    ls -lh && \
                    ./test.sh
                '''
            }
        }
    }
    post{
        success{
                echo 'Image Successfully tested'
                sh '''
                    mkdir -p /mnt/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    rsync -rluvP ${IMAGE}.sif /mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif
                '''
                echo 'Image Successfully uploaded'
            }
        }
}
