DockerName=MADGraphDocker

cd 
cd Documents
mkdir DockerOutput 
cd $_
OUTPUT=$(pwd)

echo $OUTPUT

mkdir MADGraphScripts 
cd $_

/bin/cat <<EOM > ProtonProtonToTopTopBar

import model sm/
define l+ = e+ mu+ ta+
define l- = e- mu- ta-
generate p p > t t~
add process p p > t t~ j
add process p p > t t~ j j
output pp_ttbar_ll_13TeV_xqcut_45
launch pp_ttbar_ll_13TeV_xqcut_45 -i
multi_run 2
1
4
0
decay t > w+ b , w+ > l+ vl
decay t~ > w- b~ , w- > l- vl~
set ebeam = 6500
set nevents = 10000
set ickkw = 1
set xqcut = 30
set etaj = 5
0
EOM

sudo docker run -dit --rm --name $DockerName -v $OUTPUT/models:/var/UFO_models -v $OUTPUT/outputs:/var/MG_outputs hfukuda/madgraph

sudo docker cp $OUTPUT/MADGraphScripts/ProtonProtonToTopTopBar MADGraphDocker:/var/MG_outputs


sudo docker exec -it MADGraphDocker /home/hep/MG5_aMC_v2_6_3_2/bin/mg5_aMC  ProtonProtonToTopTopBar

sudo docker kill MADGraphDocker

cd .. 
sudo rm -r MADGraphScripts
