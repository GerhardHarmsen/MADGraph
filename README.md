# MADGraph
Set of files for installing MADGraph and running simulations
## Overview
This repository contains files for both an installation on a clean Linux system and a docker container. It would be best to use the bare-metal install on your own computer and to use the Docker files on the cluster that you wish to use. \
The generate files can be used as examples and show the exact commands used to generate the results we are interested in using. 
## MADGraph installation on a bare-metal machine

It is recommended that you have the most up to date version of Linux to ensure everything is running correctly.
Once the system is up to date you can run the **MADGraphInstall.sh** file. 
**Note: The script executes correctly and installs necessary packages as of 29/07/2020 later version of MADGraph and ROOT may require other libraries.**
The file installs the following:
- Python2 for Linux (This is required to ensure that MADGraph opens correctly as some legacy code exists)
- git and bzr (So that the files can be downloaded from the repositories) 
- cmake (Needed to install ROOT)
- gcc (Needed for ROOT)
- gfortran (Need for ROOT)
- Various third-party libraries used by ROOT (See ROOT installation page to see an exact list)
- Texlive and Texmaker (Required to output graphs produced by MADAnalysis)
- ROOT 
- MADGraph5, and the following packages:
  - Delphes
  - pythia8
  - lhapdf6
  - MADAnalysis5
  - RootExAnalysis
  - MADAnalysis 5

The bash file will also edit the **.bshsrc** file to include the path of the ROOT installation. **Note that this is necessary to ensure that MADGraph can use ROOT.**

There are two prompts, in the beginning, asking for the number of the cores to use and to select the correct python version to use. Once these prompts have been dealt with the process should complete automatically over a couple of hours depending on the number of CPU cores chosen. 

To manually install individual packages look at the following sections. 
### ROOT
Install **all** dependencies using the commands given at *https://root.cern/install/dependencies/*. Then follow the instruction given at *http://tylern4.github.io/InstallRoot/*. Note that to ensure that ROOT works on all terminals and can be accessed by MADGraph you need to edit the **.bashrc** file which affects the terminal environment.
### MADGraph
Best way to get the latest stable version of MADGraph is to type the command \
`<bzr branch lp:mg5amcnl>`\
Alternatively, go to the MADGraph web page for more details.
### MADAnalysis
This can be installed in MADGraph, or separately by typing \
`<bzr branch lp:madanalysis5>`\
For more information go to the MADAnalysis web page.

## DockerFile
Install the docker container with the command \
`<docker pull skaskid470/madgraph>`\
\
MADGraph is installed in the following folder in the container:\
*/home/hep/mg5amcnlo/*

There are two ways to run MADGraph in the container.
### Option 1
`<docker run -t -i -v $HOME/models:/var/UFO_models -v $HOME/outputs:/var/MG_outputs skaskid470/madgraph>`\
\
Where $HOME is the absolute path to where you want the output and model folders to be.  This will open up MADGraph in the container, and allow you to generate processes. These processes will be saved in the output folder on the local machine. 
#### Run as current user
By default, the madgraph run as root. If you want to run it as the current user, add --user=$(id -u):$(id -g) like this:\
`<docker run -t -i --user=$(id -u):$(id -g) -v $HOME/models:/var/UFO_models -v $HOME/outputs:/var/MG_outputs skaskid470/madgraph>`\
Note that $HOME/outputs must exist beforehand. Otherwise MADGraph doesn't work well due to the permission problem.

### Option 2
To pass scripts to the container use the following set of commands. First we need to start up the Docker container in a bash mode,\
`< docker run -dit -v $HOME/models:/var/UFO_models -v $HOME/outputs:/var/MG_outputs skaskid470/madgraph bash >`

$HOME must be the absolute path to the output and model folders on the local machine. Then you will need to copy the script to the container using the following code\
`< docker cp $OUTPUT/MADGraphScripts/$FILE $DockerName:/var/MG_outputs >`
Where $DockerName is the name of the docker container, use \
`<docker ps -a >`\
to find out the name of the Docker container. Alternatively use \
`< docker run -dit --name $DockerName -v $HOME/models:/var/UFO_models -v $HOME/outputs:/var/MG_outputs skaskid470/madgraph bash >`	\
and to give the Docker container a specific name.\
`<docker exec -it $DockerName /home/hep/mg5amcnlo/bin/mg5_aMC $FILE >`\
This will execute the script named $FILE and open it in MADGraph and will begin executing. \
\
For an example of how this method can be used see the file named **RunDockerGenerate.sh**.
