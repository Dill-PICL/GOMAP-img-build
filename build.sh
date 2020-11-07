IMAGE="GOMAP"
if [ -f "${IMAGE}.sif" ]
then
    sudo rm ${IMAGE}.sif
fi
mkdir -p $PWD/tmp
sudo singularity build --tmpdir $PWD/tmp ${IMAGE}.sif singularity/Singularity.mpich-3.2.1 1>build.out 2>build.err

