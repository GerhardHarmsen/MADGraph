sudo docker pull skaskid470/madgraph

DockerName=MADGraphDocker

cd 
cd Documents
mkdir DockerOutput 
cd $_
OUTPUT=$(pwd)

echo $OUTPUT

mkdir MADGraphScripts 
cd $_

sudo docker run -dit --rm --name $DockerName -v $OUTPUT/models:/var/UFO_models -v $OUTPUT/outputs:/var/MG_outputs skaskid470/madgraph

######################## Setup directories for easy saving of results ############
############## Variables for the scripts #########################################
BACKGROUNDRUNS=2
SIGNALRUNS=2
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
output ${FILE}
launch ${FILE} -i
multi_run ${BACKGROUNDRUNS}
1
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

sudo docker exec -it $DockerName /home/hep/MG5_aMC_v2_6_3_2/bin/mg5_aMC  $FILE
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
output ${FILE}
launch ${FILE} -i
multi_run ${BACKGROUNDRUNS}
1
0
set ebeam = 6500
set nevents = ${EVENTSPERRUN}
set ickkw = 1
set xqcut = 25
set etaj = 5
0
EOM

cd $WORKINGPATH

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs

sudo docker exec -it $DockerName /home/hep/MG5_aMC_v2_6_3_2/bin/mg5_aMC  $FILE
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
generate  p p > w+ w- @0
add process p p > w+ w- j @1
add process p p > w+ w- j j @2
output ${FILE}
launch ${FILE} -i
multi_run ${BACKGROUNDRUNS}
1
4
0
set ebeam = 6500
set nevents = ${EVENTSPERRUN}
set ickkw = 1
set xqcut = 25
set etaj = 5
decay w+ > l+ vl
decay w- > l- vl~
0
EOM

cd $WORKINGPATH

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs

sudo docker exec -it $DockerName /home/hep/MG5_aMC_v2_6_3_2/bin/mg5_aMC  $FILE

#############################################################
### End of process generator  ###############################
#############################################################	

################################## Signal Events ############

for SMUONMASS in 200 400
do	
FILE="PPtoSmuonSmuon_Smuon_Mass_${SMUONMASS}"

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
output ${FILE}
launch ${FILE} -i
multi_run ${SIGNALRUNS}
1
4
0
decay mur- > mu- n1
decay mur+ > mu+ n1
set ebeam = 6500
set nevents = ${EVENTSPERRUN}
set ickkw = 1
set xqcut = 55
set etaj = 5
0
EOM

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs

sudo docker exec -it $DockerName /home/hep/mg5amcnlo/bin/mg5_aMC  $FILE

#############################################################
### End of process generator  ###############################
#############################################################
done

sudo docker kill $DockerName

cd .. 
sudo rm -r MADGraphScripts
