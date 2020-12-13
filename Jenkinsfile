pipeline {
    agent { label 'ubuntu' }
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = 'v1.3.4'
        IPLANT_CREDS = credentials('iplant-credentials')
    }
    stages {
        stage('Setup Test Env') {
            when {
                anyOf {
                    changeset 'singularity/*'
                    changeset 'Jenkinsfile'
                }
                anyOf {
                    branch 'dev'     
                }
                anyOf {
                     expression { 
                         sh(returnStdout: true, script: '[ -f "/mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'false' 
                    }
                }
            }
            steps {
                echo 'Setting up test env' 
                sh '''
                    echo $FILEPATH
                    git lfs pull
                    singularity pull GOMAP-base.sif shub://Dill-PICL/GOMAP-base > /dev/null
                '''

                sh '''
                    du -chs *
                    git clone --branch=dev https://github.com/Dill-PICL/GOMAP.git
                    mkdir -p GOMAP/data/data/ && 
                    azcopy sync https://gomap.blob.core.windows.net/gomap/GOMAP-1.3/pipelineData/data/ GOMAP/data/data/  --recursive=true
                    mkdir -p GOMAP/data/software/ &&
                    azcopy sync https://gomap.blob.core.windows.net/gomap/GOMAP-1.3/pipelineData/software/ GOMAP/data/software/ --recursive=true &&
                    chmod -R a+rwx GOMAP/data/software/  
                ''' 
            }
        }
        stage('Test') {
            when {
                anyOf {
                    changeset 'singularity/*'
                    changeset 'Jenkinsfile'  
                }
                anyOf {
                    branch 'dev'
                }
                anyOf {
                     expression { 
                        sh(returnStdout: true, script: '[ -f "/mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'false' 
                    }
                }
            }
            steps {
                echo 'Testing seqsim..'
                sh '''
                    ./test.sh seqsim
                '''

                echo 'Testing domain..'
                sh '''
                    ./test.sh domain
                '''

                echo 'Testing fanngo..'
                sh '''
                    ./test.sh fanngo
                '''

                echo 'Testing mixmeth-blast..'
                sh '''
                    ./test.sh mixmeth-blast
                '''

                echo 'Testing mixmeth-preproc..'
                sh '''
                    ./test.sh mixmeth-preproc
                '''

                echo 'Testing mixmeth..'
                sh '''
                    ./test.sh mixmeth
                '''

                echo 'Testing aggregate..'
                sh '''
                    ./test.sh aggregate
                '''
            }
        }
        stage('Build') {
            when {
                anyOf {
                    changeset 'singularity/*'
                    changeset 'Jenkinsfile'
                }
                anyOf {
                    branch 'dev'
                }
                anyOf {
                     expression { 
                        sh(returnStdout: true, script: '[ -f "/mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'false' 
                    }
                }
            }
            steps {
                sh '''
                    if [ -d tmp ]
                    then
                        sudo rm -r tmp
                    fi
                    mkdir tmp && \
                    sudo singularity build --tmpdir $PWD/tmp  ${IMAGE}.sif singularity/Singularity.mpich-3.2.1
                    sudo rm -r $PWD/tmp
                    singularity run ${IMAGE}.sif -h
                '''
            }
        }
        stage('Copy Tmp Image') {
            when {
                anyOf {
                    changeset 'singularity/*'
                    changeset 'Jenkinsfile'  
                }
                anyOf {
                    branch 'dev'
                }
                anyOf {
                     expression { 
                        sh(returnStdout: true, script: '[ -f "/mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'false' 
                    }
                }
            }
            steps {
                echo 'Image Successfully tested'
                sh '''
                    mkdir -p /mnt/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    rsync -uP ${IMAGE}.sif /mnt/${CONTAINER}/${IMAGE}/${VERSION}/
                '''
                echo 'Image Successfully uploaded'
            }
        }
        stage('Push Artifacts') {
            when {
                anyOf {
                    changeset 'singularity/*'
                    changeset 'Jenkinsfile'
                }
                anyOf {
                    branch 'master'
                }
                anyOf {
                     expression { 
                        sh(returnStdout: true, script: '[ -f "/mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'true' 
                    }
                }
            }
            steps {
                echo 'Image Successfully tested'
                sh '''#!/bin/bash
                    export IRODS_HOST="data.cyverse.org"
                    export IRODS_PORT="1247"
                    export IRODS_USER_NAME="kokulapalan"
                    export IRODS_ZONE_NAME="iplant"

                    set +x
                    echo ${IPLANT_CREDS_PSW} | iinit
                    set -x
                    imkdir -p /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    icd /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    irsync -V -N 32 /mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif  i:${IMAGE}.sif &&  \
                    ichmod -r read anonymous /iplant/home/shared/dillpicl/${CONTAINER} && \
                    ichmod -r read public /iplant/home/shared/dillpicl/${CONTAINER}
                    #iput -vTkP -X restart.file --retries 3 -N 16 /mnt/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif  ${IMAGE}.sif || echo "Container already exisits" &&  \
                '''  
                echo 'Image Successfully uploaded  '
            }   
        }
    }
}


 





 




