#export SINGULARITY_CACHEDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"
export SINGULARITY_TMPDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"
#export SINGULARITY_LOCALCACHEDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"

instance_name="GOMAP"
if [ -f "$instance_name.simg" ]
then
    sudo rm -r "$instance_name.simg"
fi

sudo singularity -v build --tmpdir $SINGULARITY_TMPDIR $instance_name.simg singularity/Singularity.v1.2

#time sudo singularity -v build $instance_name.simg $instance_name-dir.simg && \
#sudo chown gokul:gokul $instance_name.simg