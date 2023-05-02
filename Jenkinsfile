pipeline {
    agent { label 'ubuntu' }
    environment {
        CONTAINER = 'gomap'
        BASE_IMAGE = 'GOMAP-Base'
        BASE_VERSION = 'v1.1.3' 
        IMAGE = 'GOMAP'
        VERSION = 'v1.4.0'           
        BLOBSHARE_SAS = credentials('blobstorageSAS')    
        IPLANT_CREDS = credentials('iplant-credentials')
        BLOBSHARE_URL = "https://gokoolstorage.blob.core.windows.net"
    }
    stages { 
        stage('Setup Test Env') {
            when { 
                anyOf{
                    anyOf {
                        changeset 'singularity/*'
                        changeset 'Jenkinsfile'
                        changeset 'test.sh'
                        changeset 'test-mpi.sh'
                    }
                    expression {
                       currentBuild.buildCauses.toString().contains('UserIdCause')
                    }
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
                echo 'Setting up test env' 
                sh '''
                    azcopy cp "${BLOBSHARE_URL}/${CONTAINER}/${BASE_IMAGE}/${BASE_VERSION}/${BASE_IMAGE}.sif${BLOBSHARE_SAS}"   ${BASE_IMAGE}.sif
                    if [ -d "GOMAP" ]
                    then
                        rm -rf GOMAP
                    fi
                    if [ -d "tmp" ]
                    then
                        rm -rf tmp
                    fi
                    mkdir -p tmp
                    git clone --branch=master https://github.com/Dill-PICL/GOMAP.git
                ''' 
            }     
        } 
        stage('Test') {
            when {
                anyOf{
                    anyOf {
                        changeset 'singularity/*'
                        changeset 'Jenkinsfile'
                        changeset 'test.sh'
                        changeset 'test-mpi.sh'
                    }
                    expression {
                       currentBuild.buildCauses.toString().contains('UserIdCause')
                    }
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

                echo 'Waiting for Argot2 Results..'
                sh '''
                    sleep 120
                '''

                echo 'Testing aggregate..'
                sh '''
                    ./test.sh aggregate
                '''
                
                
            }
        }
        stage('Test MPI') {
            when {
                anyOf{
                    anyOf {
                        changeset 'singularity/*'
                        changeset 'Jenkinsfile'
                        changeset 'test.sh'
                        changeset 'test-mpi.sh'
                    }
                    expression {
                       currentBuild.buildCauses.toString().contains('UserIdCause')
                    }
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
                echo 'Testing MPI IPRS..'
                sh '''
                    ./test-mpi.sh domain
                '''
                
                echo 'Testing MPI Blast'
                sh '''
                    ./test-mpi.sh mixmeth-blast
                '''
            }
        }
        stage('Build') {
            when {
                anyOf{
                    anyOf {
                        changeset 'singularity/*'
                        changeset 'Jenkinsfile'
                        changeset 'test.sh'
                        changeset 'test-mpi.sh'
                    }
                    expression {
                       currentBuild.buildCauses.toString().contains('UserIdCause')
                    }
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
                    azcopy cp "${BLOBSHARE_URL}/${CONTAINER}/${BASE_IMAGE}/${BASE_VERSION}/${BASE_IMAGE}.sif${BLOBSHARE_SAS}" singularity/${BASE_IMAGE}.sif
                    if [ -d tmp2 ]
                    then
                        sudo rm -r tmp2
                    fi
                    mkdir tmp2 && \
                    sudo singularity build --tmpdir $PWD/tmp2  ${IMAGE}.sif singularity/Singularity
                    singularity run ${IMAGE}.sif -h
                '''
            }
        }
        stage('Copy Tmp Image') {
            when {
                anyOf{
                    anyOf {
                        changeset 'singularity/*'
                        changeset 'Jenkinsfile'
                        changeset 'test.sh'
                        changeset 'test-mpi.sh'
                    }
                    expression {
                       currentBuild.buildCauses.toString().contains('UserIdCause')
                    }
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
                    azcopy cp ${IMAGE}.sif "${BLOBSHARE_URL}/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif${BLOBSHARE_SAS}"
                '''
                echo 'Image Successfully uploaded'
            }
        }
        stage('Push Artifacts') {
            when {
                anyOf{
                    anyOf {
                        changeset 'singularity/*'
                        changeset 'Jenkinsfile'
                        changeset 'test.sh'
                        changeset 'test-mpi.sh'
                    }
                    expression {
                       currentBuild.buildCauses.toString().contains('UserIdCause')
                    }
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
                    azcopy cp "${BLOBSHARE_URL}/${CONTAINER}/${IMAGE}/${VERSION}/${IMAGE}.sif${BLOBSHARE_SAS}" ${IMAGE}.sif  
                '''

                echo 'Syncing to Cyverse and logging in'
                sh '''#!/bin/bash
                    rsync -r /gomap/.irods ~/
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

