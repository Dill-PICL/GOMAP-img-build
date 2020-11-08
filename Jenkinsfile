pipeline {
    agent { label 'ubuntu'}
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = '1.3.2'
        IPLANT_CREDS = credentials('iplant-credentials')
    }
    
    stages {
        stage('Build') {
            when { 
                anyOf {
                changeset "singularity/*"
                changeset "Jenkinsfile"
                }
            }
            steps {
                sh '''
                    singularity --version && \
                    ls -lah
                    if [ -d tmp ]
                    then
                        sudo rm -r tmp
                    fi
                    mkdir tmp && \
                    sudo singularity build --tmpdir $PWD/tmp  ${IMAGE}.sif singularity/Singularity.mpich-3.2.1
                    sudo rm -r tmp
                '''
            }
        }
        stage('Test') {
            when { 
                anyOf {
                changeset "singularity/*"
                changeset "Jenkinsfile"
                }
            }
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
                    export IRODS_HOST="data.cyverse.org"
                    export IRODS_PORT="1247"
                    export IRODS_USER_NAME="kokulapalan"
                    export IRODS_ZONE_NAME="iplant"
                    echo "${IPLANT_CREDS_PSW}" 
                    
                    echo "${IPLANT_CREDS_PSW}" | iinit && \
                    imkdir -p /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    icd /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    irsync -sVN1 ${IMAGE}.sif i:${IMAGE}.sif && \
                    ichmod -r read anonymous /iplant/home/shared/dillpicl/${CONTAINER}
                '''
                echo 'Image Successfully uploaded'
            }
        }
}
