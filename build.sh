IMAGE="GOMAP"
if [ -f "${IMAGE}.sif" ]
then
    ${IMAGE}.sif
fi
sudo singularity build ${IMAGE}.sif singularity/Singularity.mpich-3.2.1 1>> build.out 2>>build.err

