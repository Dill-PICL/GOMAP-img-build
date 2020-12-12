#!/usr/bin/env bash

instance_name="GOMAP-base"
img_loc="$PWD/$instance_name.sif"
mkdir -p $PWD/tmp
unset SINGULARITY_TMPDIR

if [ ! -f "$img_loc" ]
then
    echo "The ${instance_name} image is missing"
	singularity pull $img_loc shub://Dill-PICL/GOMAP-base > /dev/null
fi

if [ -z $tmpdir ]
then
    tmpdir=${TMPDIR:-$PWD/tmp}
fi

export SINGULARITY_BINDPATH="$PWD:/workdir,$tmpdir:/tmpdir,$PWD/GOMAP:/opt/GOMAP"

echo "$@"

if [[ $# -eq 1 ]] 
then
	singularity run \
		-W $PWD/tmp \
		$img_loc \
		--step=$1 --config=test/config.yml
else
	singularity run -c $img_loc --step=seqsim --config=test/config.yml && \
	singularity run -c $img_loc --step=domain --config=test/config.yml && \
	singularity run -c $img_loc --step=fanngo --config=test/config.yml && \
	singularity run -c $img_loc --step=mixmeth-blast --config=test/config.yml && \
	singularity run -c $img_loc --step=mixmeth-preproc --config=test/config.yml && \
	singularity run -c $img_loc --step=mixmeth --config=test/config.yml && \
	singularity run -c $img_loc --step=aggregate --config=test/config.yml
fi
