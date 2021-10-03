pipeline {
    agent { label 'ubuntu' }
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = 'v1.3.7'   
        IPLANT_CREDS = credentials('iplant-credentials')
        FILESHARE_SAS = credentials('fileshareSAS') 
        BLOBSHARE_SAS = credentials('blobstorageSAS') 
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
                    # singularity pull GOMAP-base.sif shub://Dill-PICL/GOMAP-base > /dev/null
                    #azcopy cp "https://gomap.file.core.windows.net/gomap/GOMAP/base/GOMAP-base.sif${FILESHARE_SAS}" GOMAP-base.sif
                    rsync -P /gomap/GOMAP-base_latest.sif GOMAP-base.sif
                '''

                sh '''
                    du -chs *
                    git clone --branch=dev https://github.com/Dill-PICL/GOMAP.git
                    mkdir -p GOMAP/data/data/ && 
                    #rsync -ruP /gomap/GOMAP-1.3/pipelineData/data/ GOMAP/data/data/ && 
                    azcopy sync https://gokoolstorage.blob.core.windows.net/gomap/GOMAP-1.3/pipelineData/data/ GOMAP/data/data/  --recursive=true && 
                    mkdir -p GOMAP/data/software/ && 
                    azcopy sync https://gokoolstorage.blob.core.windows.net/gomap/GOMAP-1.3/pipelineData/software/ GOMAP/data/software/ --recursive=true &&
                    #rsync -ruP /gomap/GOMAP-1.3/pipelineData/software/ GOMAP/data/software/ && 
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
                        sh(returnStdout: true, script: '[ -f "/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'false' 
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
                        sh(returnStdout: true, script: '[ -f "/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'false' 
                    }
                }
            }
            steps {
                sh '''
                    rsync -P /gomap/GOMAP-base_latest.sif GOMAP-base.sif 
                    rsync -P /gomap/GOMAP-base_latest.sif singularity/GOMAP-base.sif 
                    #azcopy cp "https://gomap.file.core.windows.net/gomap/GOMAP/base/GOMAP-base.sif${FILESHARE_SAS}" GOMAP-base.sif
                    #azcopy cp "https://gomap.file.core.windows.net/gomap/GOMAP/base/GOMAP-base.sif${FILESHARE_SAS}" singularity/GOMAP-base.sif
                    if [ -d tmp ]
                    then
                        sudo rm -r tmp
                    fi
                    mkdir tmp && \
                    sudo singularity build --tmpdir $PWD/tmp  ${IMAGE}.sif singularity/Singularity
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
                        sh(returnStdout: true, script: '[ -f "/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'false' 
                    }
                }
            }
            steps {
                echo 'Image Successfully tested'
                sh '''
                    mkdir /${CONTAINER}/${IMAGE}/${VERSION}/
                    rsync -v ${IMAGE}.sif /${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif 
                    #azcopy cp ${IMAGE}.sif "https://gomap.file.core.windows.net/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif${FILESHARE_SAS}"
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
                        sh(returnStdout: true, script: '[ -f "/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif" ] && echo "true" || echo "false"').trim()  == 'true' 
                    }
                }
            }
            steps {
                echo 'Image Successfully tested'
                echo 'Copying from File Share to local Disk'
                
                sh '''
                    rsync ${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif ${IMAGE}.sif 
                    #azcopy cp "https://gomap.file.core.windows.net/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif${FILESHARE_SAS}" ${IMAGE}.sif
                '''
                

                echo 'Syncing to Cyverse'
                sh '''#!/bin/bash
                    set +x
                    echo ${IPLANT_CREDS_PSW} | iinit
                    set -x
                    imkdir -p /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    icd /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    irsync -sV -N 32 ${IMAGE}.sif  i:${IMAGE}.sif &&  \
                    ichmod -r read anonymous /iplant/home/shared/dillpicl/${CONTAINER} && \
                    ichmod -r read public /iplant/home/shared/dillpicl/${CONTAINER}
                '''  
                echo 'Image Successfully uploaded'
            }
        }
    }
}