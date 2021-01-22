BLUE='\033[0;34m'
NC='\033[0m'

sudo docker pull skaskid470/madgraph

DockerName=MADGraphDocker_Gerhard
SECONDS=0

cd 
cd Documents
mkdir DockerOutput_Gerhard 
cd $_
OUTPUT=$(pwd)

echo $OUTPUT

mkdir MADGraphScripts 
cd $_

git clone https://github.com/GerhardHarmsen/MADGraph

cd MADGraph
cd Docker_Environment
tar -xzf MSSM_UFO.tgz

sudo docker run -dit --name $DockerName -v $OUTPUT/models:/var/UFO_models -v $OUTPUT/outputs:/var/MG_outputs skaskid470/madgraph bash

sudo docker cp $OUTPUT/MADGraphScripts/MADGraph/Docker_Environment/MSSM_UFO $DockerName:/home/hep/mg5amcnlo/models

cd ..
cd ..

SIGNALRUNS=5
EVENTSPERRUN=10000

NEUTRALINOMASS=(270 220 190 140 130 140 95 80 60 60 65 55 200 190 180)
SMUONMASS=(360 320 290 240 240 420 500 400 510 200 210 250 450 500 400)

len=${#SMUONMASS[@]}

for ((i=0; i<$len; i++))
do

FILE="PPtoSmuonSmuon_Smuon_Mass_${SMUONMASS[$i]}_Neatralino_${NEUTRALINOMASS[$i]}"
/bin/cat <<EOM >$FILE
####################################################################################
##### File Generates the following
##### Proton Proton to smuon pair with two jets (These smuons decay to muons) 
##### With $((SIGNALRUNS * EVENTSPERRUN)) events
##### xqcut value of 55
####################################################################################
import model MSSM_UFO/
generate p p > mur- mur+ @0
add process p p > mur- mur+ j @1
add process p p > mur- mur+ j j @2
output /Signal/Events_${FILE}
launch /Signal/Events_${FILE} -i
multi_run ${SIGNALRUNS}
1
2
4
0
decay mur- > mu- n1
decay mur+ > mu+ n1
set ebeam = 6500
set nevents = ${EVENTSPERRUN}
set ickkw = 1
set xqcut = 55
set etaj = 5
set mass 2000013 ${SMUONMASS[$i]}
set mass 1000022 ${NEUTRALINOMASS[$i]}
0
EOM


sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs

/bin/cat <<EOM>>'BashFile.sh'
/home/hep/mg5amcnlo/bin/mg5_aMC $FILE &
EOM
done

/bin/cat <<EOM>>'BashFile.sh'
wait
EOM

sudo docker cp $OUTPUT/MADGraphScripts/BashFile.sh $DockerName:/var/MG_outputs
sudo docker exec -it $DockerName bash /var/MG_outputs/BashFile.sh 

ELAPSED=" $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo -e "${BLUE}Job Completed in ${ELAPSED} ${NC}"

sudo docker kill $DockerName
sudo docker rm $DockerName
cd .. 
sudo rm -r MADGraphScripts
