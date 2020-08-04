INSTALLPATH='Documents/MADGraphLocation'
BLUE='\033[0;34m'
NC='\033[0m'

sudo apt-get update

NCORES=$(nproc)

echo -e "${BLUE}Total available cores: ${NCORES} ${NC}"
read -p "Would you like to use all the cores to install the programs?(y/n)" -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    TEMP=${NCORES}
    while [ $TEMP == $NCORES ]
    do
    echo "Select the number of core you would like to use."
    read INPUT
    if (( $INPUT > $NCORES ));
    then
    	echo " Number of cores selected exceeds number of actual cores. Please selected a value lower than ${NCORES}."
    else 
        NCORES=$INPUT
    fi
    done
fi

echo "${BLUE} ${NCORES} cores selected for installation. ${NC}"


sudo apt install python2
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 2
sudo update-alternatives --list python
echo
echo -e "${BLUE} Press 1 to select python2 as the primary python environment. This ensures MADGraph5 will start up and install the nessecary packages.${NC}"
echo 
sudo update-alternatives --config python
python -V

sudo apt-get install git dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev libxft-dev libxext-dev bzr gnuplot
sudo apt-get install gfortran libssl-dev libpcre3-dev xlibmesa-glu-dev libglew1.5-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev libgsl0-dev 

sudo apt-get install texlive-full
sudo apt-get install texmaker

echo
echo -e "${BLUE}Installing ROOT. Time for a coffee, this will take a few hours to complete.${NC}" 
echo

cd ~
mkdir $INSTALLPATH
cd $INSTALLPATH
sudo git clone https://github.com/root-mirror/root.git
mkdir ROOT
cd ROOT
cmake ../root
cmake --build . -- -j$NCORES
cd ~ 
cd $INSTALLPATH
source ./ROOT/bin/thisroot.sh

cd
cd $INSTALLPATH/ROOT
ROOTLOCATION=$(pwd)
/bin/cat <<EOM >>~/.bashrc


###############################################
###Location of the ROOT files##################
###############################################
export ROOTSYS=$ROOTLOCATION
export PATH=\$ROOTSYS/bin:$PATH
export LD_LIBRARY_PATH=\$ROOTSYS/lib:\$PYTHONDIR/lib:\$LD_LIBRARY_PATH
export PYTHONPATH=\$ROOTSYS/lib:\$PYTHONPATH
EOM

source ~/.bashrc


cd 
cd $INSTALLPATH

echo
echo -e "${BLUE}Installing MADGraph5 and the packages Delphes|pythia8|lhapdf6|MADAnalysis5|RootExAnalysis.${NC}"
echo

bzr branch lp:mg5amcnlo

FILE="InstalledMADPackages.sh"

/bin/cat <<EOM >$FILE
install Delphes
install pythia8
install lhapdf6
install MadAnalysis5
install ExRootAnalysis
quit
EOM

cd ~
cd $INSTALLPATH
./mg5amcnlo/bin/mg5_aMC ./InstalledMADPackages.sh

cd ~ 
cd $INSTALLPATH
bzr branch lp:madanalysis5

cd ~
cd $INSTALLPATH
echo -e "${BLUE}Cleaning up.${NC}"
sudo rm -r root
rm InstalledMADPackages.sh

echo
echo -e "${BLUE}Installation complete. MADGraph, MADAnalysis and ROOT have been installed to the machine. 
MADGraph has had Delphes|pythia8|lhapdf6|MADAnalysis5|RootExAnalysis installed.
MADAnalysis is installed in MADGraph. 
MADAnalysis is also installed seperately from MADGraph if post processing is to be done outside of MADGraph. To remove the seperate version of MADAnalysis simply delete the folder. ${NC}"
echo
