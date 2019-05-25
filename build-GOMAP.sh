#export SINGULARITY_CACHEDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"
export SINGULARITY_TMPDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"
#export SINGULARITY_LOCALCACHEDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"

instance_name="GOMAP"
if [ -f "$instance_name.simg" ]
then
    rm -rf "$instance_name"
    rm -r "$instance_name.simg"
fi

if [ ! -d $instance_name ]
then
    time singularity -v build -s $instance_name singularity/Singularity.v1.2.mpich-3.2.1 && \
    time singularity -v build $instance_name.simg $instance_name && \
    chown gokul:gokul $instance_name.simg
fi