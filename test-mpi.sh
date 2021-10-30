#!/usr/bin/env bash

instance_name="GOMAP-Base"
img_loc="$PWD/$instance_name.sif"
mkdir -p $PWD/tmp
unset SINGULARITY_TMPDIR

if [ ! -f "$img_loc" ]
then
    echo "The GOMAP image is missing" > /dev/stderr
    echo "Please run the setup.sh before running the test" > /dev/stderr
    exit 1
fi

if [ -z $tmpdir ]
then
    tmpdir=${TMPDIR:-$PWD/tmp}
fi

export SINGULARITY_BINDPATH="$PWD:/workdir,$PWD/tmp:/tmpdir,GOMAP:/opt/GOMAP"

echo "$@"

nodes=2 
   
if [[ $# -eq 1 ]] 
then
	mpiexec -np $nodes singularity run -W $PWD/tmp $img_loc --step=$1 --config=test-mpi/config.yml
else
	mpiexec -np $nodes singularity run -W $PWD/tmp $img_loc --step=domain --config=test-mpi/config.yml \
	mpiexec -np $nodes singularity run -W $PWD/tmp $img_loc --step=mixmeth-blast --config=test-mpi/config.yml
fi
