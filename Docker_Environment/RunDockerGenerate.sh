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
######################## Setup directories for easy saving of results ############
############## Variables for the scripts #########################################
BACKGROUNDRUNS=20
SIGNALRUNS=5
EVENTSPERRUN=10000
############## Variables for the scripts #########################################
############## Background events #################################################

FILE="PPtoTopTopBar"

/bin/cat <<EOM>$FILE
####################################################################################
#####File Generates the following
##### Proton Proton to top top-bar with two jets
##### With $((BACKGROUNDRUNS * EVENTSPERRUN)) events
##### xqcut value of 30
####################################################################################
define l+ = e+ mu+ ta+ 
define l- = e- mu- ta-
generate p p > t t~ @0
add process p p > t t~ j @1
add process p p > t t~ j j @2
output Events_${FILE}
launch Events_${FILE} -i
multi_run ${BACKGROUNDRUNS}
1
2
4
0
set ebeam = 6500
set nevents = ${EVENTSPERRUN}
set ickkw = 1
decay t > w+ b, w+ > l+ vl
decay t~ > w- b~, w- > l- vl~
set xqcut = 30
set etaj = 5
0
EOM

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs

/bin/cat <<EOM>>'BashFile.sh'
/home/hep/mg5amcnlo/bin/mg5_aMC $FILE &
EOM

#############################################################
### End of process generator  ###############################
#############################################################

FILE="PP_W_LeptonNeutrino"
/bin/cat <<EOM>$FILE
####################################################################################
##### File Generates the following
##### Proton Proton to lepton neutrino pairs with two jets (These smuons decay to muons) 
##### With $((BACKGROUNDRUNS * EVENTSPERRUN)) events
##### xqcut value of 25
####################################################################################
define l+ = e+ mu+ ta+ 
define l- = e- mu- ta-
define ll = l+ l-
define vv = vl vl~
generate p p > ll vv @0
add process p p > ll vv j @1
add process p p > ll vv j j  @2
output Events_${FILE}
launch Events_${FILE} -i
multi_run ${BACKGROUNDRUNS}
1
2
0
set ebeam = 6500
set nevents = ${EVENTSPERRUN}
set ickkw = 1
set xqcut = 25
set etaj = 5
0
EOM

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs

/bin/cat <<EOM>>'BashFile.sh'
/home/hep/mg5amcnlo/bin/mg5_aMC $FILE &
EOM

#############################################################
### End of process generator  ###############################
#############################################################

FILE="PP_WW_lvl"
/bin/cat <<EOM>$FILE
####################################################################################
##### File Generates the following
##### Proton Proton to lepton neutrino pairs with two jets (These smuons decay to muons) 
##### With $((BACKGROUNDRUNS * EVENTSPERRUN)) events
##### xqcut value of 25
####################################################################################
define l+ = e+ mu+ ta+ 
define l- = e- mu- ta-
generate  p p > w+ w-, ( w+ > l+ vl ), ( w- > l- vl~ ) @0
add process p p > w+ w- j, ( w+ > l+ vl ), ( w- > l- vl~ ) @1
add process p p > w+ w- j j, ( w+ > l+ vl ), ( w- > l- vl~ ) @2
output Events_${FILE}
launch Events_${FILE} -i
multi_run ${BACKGROUNDRUNS}
1
2
0
set ebeam = 6500
set nevents = ${EVENTSPERRUN}
set ickkw = 1
set xqcut = 25
set etaj = 5
0
EOM

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs

/bin/cat <<EOM>>'BashFile.sh'
/home/hep/mg5amcnlo/bin/mg5_aMC $FILE &
EOM

#############################################################
### End of process generator  ###############################
#############################################################	
################################## Signal Events ############
for NEUTRALINOMASS in 96 195
do
for SMUONMASS in 200 400
do

FILE="PPtoSmuonSmuon_Smuon_Mass_${SMUONMASS}_Neatralino_${NEUTRALINOMASS}"
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
output Events_${FILE}
launch Events_${FILE} -i
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
set mass 2000013 ${SMUONMASS}
set mass 1000022 ${NEUTRALINOMASS}
0
EOM


sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs

/bin/cat <<EOM>>'BashFile.sh'
/home/hep/mg5amcnlo/bin/mg5_aMC $FILE &
EOM
done
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
