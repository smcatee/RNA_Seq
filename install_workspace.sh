#!/bin/bash


# After updating and downloading git
sudo apt-get -y install ssh make gcc zlib1g-dev libncurses5-dev libncursesw5-dev cmake build-essential unzip python-dev python-numpy python3-dev python3-pip gfortran libreadline-dev default-jdk libx11-dev libxt-dev xorg-dev libxml2-dev libcurl4-openssl-dev apache2 python-pip csh ruby-full gnuplot cpanminus r-base libssl-dev gcc-4.8 g++-4.8

sudo timedatectl set-timezone America/Los_Angeles

# Reboot here ??

## Download Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
# set PATH
echo ' '  >> /home/ubuntu/.profile
echo '# set PATH so it includes Homebrew if it exists' >> /home/ubuntu/.profile
echo 'if [ -d "/home/linuxbrew/.linuxbrew/bin" ] ; then' >> /home/ubuntu/.profile
echo '        PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> /home/ubuntu/.profile
echo 'fi' >> /home/ubuntu/.profile

sudo apt-get install build-essential
sudo apt install linuxbrew-wrapper


## APPLICATION DOWNLOADS
sudo -s
cd /opt
# SRA Toolkit
wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.10.4/sratoolkit.2.10.4-ubuntu64.tar.gz
# FastQC
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip
# SolexaQA
wget https://sourceforge.net/projects/solexaqa/files/src/SolexaQA%2B%2B_v3.1.7.1.zip
# Trinity
apt-get install gmap bowtie2 emacs25 # Dependencies
wget https://github.com/trinityrnaseq/trinityrnaseq/releases/download/v2.10.0/trinityrnaseq-v2.10.0.FULL.tar.gz
# Oasis (requires Velvet)
wget https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz
wget https://www.ebi.ac.uk/~zerbino/oases/oases_0.2.08.tgz
# SOAPdenovo-Trans
git https://github.com/aquaskyline/SOAPdenovo-Trans.git

# TransABySS (requires boost, openmpi, sparsehash, python igraph, BLAT)
brew install boost open-mpi google-sparsehash
sudo apt-get install abyss
brew install igraph
pip -v install python-igraph==0.7.1.post6
apt-get install mysql-server
apt-get install libmysqlclient-dev

wget http://downloads.sourceforge.net/project/libpng/libpng16/older-releases/1.6.2/libpng-1.6.2.tar.gz?r=http%3A%2F%2Fwww.libpng.org%2Fpub%2Fpng%2Flibpng.html&ts=1374540894&use_mirror=hivelocity
tar -xvf libpng-1.6.2.tar.gz
cd libpng-1.6.2
./configure --prefix=`pwd`
make
make install
LIBPNGDIR=`pwd`
cd ..
wget https://genome-test.gi.ucsc.edu/~kent/src/blatSrc.zip
unzip blatSrc.zip
cd blatSrc/
cp ${LIBPNGDIR}/png.h lib/
cp ${LIBPNGDIR}/pngconf.h lib/
cp cp ${LIBPNGDIR}/pnglibconf.h lib/
MACHTYPE=x86_64
export MACHTYPE
mkdir -p /bin/$MACHTYPE
make





## Decompression
tar -zxvf ./*.tar.gz
unzip ./*.zip



## Make
cd trinityrnaseq*/
make
cd ../velvet*/
make
make doc
cd ../oasis*/
make
cd ../SOAPdenovo-Trans/
bash make.sh
bash clean.sh

cd ..



## Assigning PATH

