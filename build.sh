instance_name="GOMAP"
if [ -f "$instance_name.sif" ]
then
    rm -r "$instance_name.sif"
fi

azcopy cp https://gomap.blob.core.windows.net/gomap/gomap/GOMAP-base/1.3.1/GOMAP-base.sif > GOMAP-base.sif

if [ ! -d $instance_name ]
then
    sudo mkdir tmp
    sudo singularity build --tmpdir tmp $instance_name.sif singularity/Singularity.v1.3.1.mpich-3.2.1
fi