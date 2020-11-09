pipeline {
    agent { label 'ubuntu'}
    environment {
        CONTAINER = 'gomap'
        IMAGE = 'GOMAP'
        VERSION = 'v1.3.3'
        IPLANT_CREDS = credentials('iplant-credentials')
    }
    
    stages {
        stage('Build') {
            when { 
                anyOf {
                    changeset "singularity/*"
                    changeset "Jenkinsfile"
                }
                anyOf {
                    branch 'master'
                    branch 'dev'
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

                    azcopy cp https://gomap.blob.core.windows.net/gomap/GOMAP-1.3/pipelineData/data/ .  --recursive=true
                    azcopy cp https://gomap.blob.core.windows.net/gomap/GOMAP-1.3/pipelineData/software/ .  --recursive=true
                    mkdir tmp && \
                    git clone --branch="${VERSION}-dev https://github.com/Dill-PICL/GOMAP.git GOMAP
                    sudo singularity build --tmpdir $PWD/tmp  ${IMAGE}.sif singularity/Singularity.mpich-3.2.1
                    sudo rm -r $PWD/tmp
                '''
            }
        }
        stage('Test') {
            when { 
                anyOf {
                    changeset "singularity/*"
                    changeset "Jenkinsfile"
                }
                anyOf {
                    branch 'master'
                    branch 'dev'
                }
            }
            steps {
                echo 'Testing seqsim..'
                sh '''
                    ls -lh && \
                    ./test.sh seqsim
                '''
            
                echo 'Testing domain..'
                sh '''
                    ls -lh && \
                    ./test.sh domain
                '''
            
                echo 'Testing fanngo..'
                sh '''
                    ls -lh && \
                    ./test.sh fanngo
                '''
            
                echo 'Testing mixmeth-blast..'
                sh '''
                    ls -lh && \
                    ./test.sh mixmeth-blast
                '''
            
                echo 'Testing mixmeth-preproc..'
                sh '''
                    ls -lh && \
                    ./test.sh mixmeth-preproc
                '''
            
                echo 'Testing mixmeth..'
                sh '''
                    ls -lh && \
                    ./test.sh mixmeth
                '''
            
                echo 'Testing aggregate..'
                sh '''
                    ls -lh && \
                    ./test.sh aggregate
                '''
            }
        }
        stage('Push Artifacts') {
           when { 
                anyOf {
                    changeset "singularity/*"
                    changeset "Jenkinsfile"
                }
                anyOf {
                    branch 'master'
                    branch 'dev'
                }
            }
            steps{
                echo 'Image Successfully tested'
                sh '''
                    export IRODS_HOST="data.cyverse.org"
                    export IRODS_PORT="1247"
                    export IRODS_USER_NAME="kokulapalan"
                    export IRODS_ZONE_NAME="iplant"
                    
                    echo "${IPLANT_CREDS_PSW}" | iinit && \
                    imkdir -p /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    icd /iplant/home/shared/dillpicl/${CONTAINER}/${IMAGE}/${VERSION}/ && \
                    irsync -sVN1 ${IMAGE}.sif i:${IMAGE}.sif && \
                    ichmod -r read anonymous /iplant/home/shared/dillpicl/${CONTAINER}
                '''
                echo 'Image Successfully uploaded  '
            }
        }
    }
}
