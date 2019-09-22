#export SINGULARITY_CACHEDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"
#export SINGULARITY_TMPDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"
#export SINGULARITY_LOCALCACHEDIR="/home/gokul/lab_data/dill-picl/GOMAP/GOMAP-singularity"

instance_name="GOMAP"

rm -r "$instance_name.simg"

if [ ! -d $instance_name ]
then
    time singularity -v build --tmpdir $PWD/tmp $instance_name.simg singularity/Singularity.v1.3.mpich-3.2.1 && \
    chown gokul:gokul $instance_name.simg
fi