BLUE='\033[0;34m'
NC='\033[0m'

sudo docker pull skaskid470/pythonscripts

DockerNamePython=PythonDocker_Gerhard
SECONDS=0

cd 
cd Documents
mkdir DockerOutput_Gerhard 
cd $_
OUTPUT=$(pwd)

echo $OUTPUT

mkdir MADGraphScripts 
cd $_

git clone https://github.com/GerhardHarmsen/Physics-Machine-Learning-project.git

cd Physics-Machine-Learning-project

sudo docker run -dit --name $DockerNamePython -v $OUTPUT/outputs:/usr/src/app skaskid470/pythonscripts bash

sudo docker cp $(pwd)/DelphesToCSV.py $DockerNamePython:/usr/src/app

cd ..

NEUTRALINOMASS=(270 220 190 140 130 140 95 80 60 60 65 55 200 190 180)
SMUONMASS=(360 320 290 240 240 420 500 400 510 200 210 250 450 500 400)

len=${#SMUONMASS[@]}
FILE="ConvertScripts.sh"
/bin/cat <<EOM >$FILE
####################################################################################
##### File will convert the DElphes files to CSV files
####################################################################################
mkdir CSV
cd CSV
EOM

for ((i=0; i<$len; i++))
do

/bin/cat <<EOM >>$FILE
mkdir Events_PPtoSmuonSmuon_Smuon_Mass_${SMUONMASS[$i]}_Neatralino_${NEUTRALINOMASS[$i]}
cd ..
python -c "import DelphesToCSV; DelphesToCSV.DELPHESTOCSV2(r'/usr/src/app/Signal/Events_PPtoSmuonSmuon_Smuon_Mass_${SMUONMASS[$i]}_Neatralino_${NEUTRALINOMASS[$i]}',r'/usr/src/app/CSV/Events_PPtoSmuonSmuon_Smuon_Mass_${SMUONMASS[$i]}_Neatralino_${NEUTRALINOMASS[$i]}')" &
cd CSV
EOM
done

/bin/cat <<EOM >>$FILE
wait
EOM

sudo docker cp $OUTPUT/MADGraphScripts/$FILE $DockerNamePython:/usr/src/app

echo Copied python scripts

sudo docker exec -it $DockerNamePython bash /usr/src/app/ConvertScripts.sh 
ELAPSED=" $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo -e "${BLUE}Job Completed in ${ELAPSED} ${NC}"
sudo docker kill $DockerNamePython
sudo docker rm $DockerNamePython
cd .. 
sudo rm -r MADGraphScripts
