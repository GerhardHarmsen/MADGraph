BLUE='\033[0;34m'
NC='\033[0m'

####################################################################################
##### Pull the required Docker files#####
echo -e "${BLUE}Pulling Docker file for running python scripts${NC}"
sudo docker pull skaskid470/pythonscripts
#### Finished pulling docker files
####################################################################################

###################################################################################
###Name Docker containers
DockerNamePython=PythonDocker_Gerhard
###################################################################################
SECONDS=0

###################################################################################
########Create temporary folders to hold the necessary files
cd 
cd Documents
cd DockerOutput_Gerhard 
cd $_
OUTPUT=$(pwd)

echo $OUTPUT

mkdir MADGraphScripts 
cd $_

git clone https://github.com/GerhardHarmsen/Physics-Machine-Learning-project.git

#####Temp folders hold all necessary files
###################################################################################

###################################################################################
#### Start docker files and copy across necessary files

#### MADGraph Docker setup

echo $OUTPUT

#### Python docker setup
sudo docker run -dit --name $DockerNamePython -v $OUTPUT/outputs:/usr/src/app skaskid470/pythonscripts bash

sudo docker cp $OUTPUT/MADGraphScripts/Physics-Machine-Learning-project $DockerNamePython:/usr/src/app

###### Docker setup complete 
####################################################################################

NEUTRALINOMASS=(270 220 190 140 130 140 95 80 60 60 65 55 200 190 180 96 195 96 195)
SMUONMASS=(360 320 290 240 240 420 500 400 510 200 210 250 450 500 400 200 200 400 400)

NEUTRALINOMASS=(175 87 125 100 150 70 100 68 120 150 75 300 500 440 260)
SMUONMASS=(350 350 375 260 300 350 300 275 475 300 450 310 510 450 275)

len=${#SMUONMASS[@]}

#### Hyperparameter training

FILE="HyperparameterTrain.sh"
/bin/cat <<EOM >$FILE
cd Physics-Machine-Learning-project
python -c  "import HyperParameterTuning; HyperParameterTuning.CodeToRun(r'/usr/src/app/CSV/',r'/usr/src/app/CSV/Background',r'/usr/src/app/CSV/')"
EOM

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerNamePython:/usr/src/app

#### Run the Python scripts in the docker container
#### I have written it this way so that the sudo password is only requested twice.

FILE='RunPythonScripts'
/bin/cat <<EOM >$FILE
bash HyperparameterTrain.sh
EOM

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerNamePython:/usr/src/app

sudo docker exec -it $DockerNamePython bash /usr/src/app/$FILE

ELAPSED=" $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo -e "${BLUE}Job Completed in ${ELAPSED} ${NC}"
##########################################################################

sudo docker kill $DockerNamePython
sudo docker rm $DockerNamePython
cd .. 
sudo rm -r MADGraphScripts
