instance_name="GOMAP"
azcopy cp https://gomap.blob.core.windows.net/gomap/gomap/GOMAP-base/1.3.1/GOMAP-base.sif > GOMAP-base.sif
ls -lh
sudo mkdir tmp
sudo singularity build --tmpdir tmp $instance_name.sif singularity/Singularity.v1.3.1.mpich-3.2.1
