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
                    imkdir -p /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    ichmod -r read anonymous /iplant/home/shared/dillpicl/${CONTAINER} && \
                    icd /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    irsync -sVN1 ${IMAGE}.sif i:${IMAGE}.sif && \
                    ichmod read anonymous ${IMAGE}.sif
                '''
                echo 'Image Successfully uploaded'
            }
        }
}
