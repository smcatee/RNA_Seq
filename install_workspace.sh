#!/bin/bash


# After updating and downloading git
sudo apt-get -y install make gcc zlib1g-dev libncurses5-dev libncursesw5-dev cmake build-essential unzip python-dev python-numpy python3-dev python3-pip gfortran libreadline-dev default-jdk libx11-dev libxt-dev xorg-dev libxml2-dev libcurl4-openssl-dev apache2 python-pip csh ruby-full gnuplot cpanminus r-base libssl-dev gcc-4.8 g++-4.8 libtbb-dev

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

sudo apt install linuxbrew-wrapper
brew install gcc
brew install boost


## APPLICATION DOWNLOADS
sudo -s
cd /opt

# SRA Toolkit
wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.10.4/sratoolkit.2.10.4-ubuntu64.tar.gz
tar -zxvf sratoolkit*.tar.gz
# set PATH
echo ' '  >> /home/ubuntu/.profile
echo '# set PATH for SRAtoolkit' >> /home/ubuntu/.profile
echo 'export PATH="${PATH}:/opt/sratoolkit.2.10.4-ubuntu64/bin"' >> /home/ubuntu/.profile
source ~/.profile
source ~/.bashrc
vdb-config --restore-defaults

# Samtools
wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
tar -xvjf samtools*.tar.bz2
./samtools-1.10/configure --prefix=/opt/samtools*/
cd samtools*/
make
make install
# set PATH
echo ' '  >> /home/ubuntu/.profile
echo '# set PATH for Samtools' >> /home/ubuntu/.profile
echo 'export PATH="${PATH}:/opt/samtools-1.10/bin"' >> /home/ubuntu/.profile
source ~/.profile
source ~/.bashrc


# FastQC
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip
unzip fastqc*.zip
chmod 755 ./FastQC/fastqc

# Trimmomatic
wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip
unzip Trimmomatic*.zip
touch ./Trimmomatic-0.39/adapters/all_adapters.fa
chmod a+w ./Trimmomatic-0.39/adapters/all_adapters.fa
cat ./trimmomatic-0.39/adapters/* | sed 's/>/\n>/g' > ./trimmomatic-0.39/adapters/all_adapters.fa


# SolexaQA (requires boost)
wget https://sourceforge.net/projects/solexaqa/files/src/SolexaQA%2B%2B_v3.1.7.1.zip
unzip SolexaQA*.zip
rm -r Mac*/ Windows*/
cd source/
make
cd ..

# Trinity
add-apt-repository ppa:kelleyk/emacs
add-apt-repository ppa:jonathonf/gcc-7.1  #maybe not necessary
apt update
apt-get -y install gmap bowtie2 emacs25 gcc-7 g++-7 # Dependencies
wget https://github.com/gmarcais/Jellyfish/releases/download/v2.2.10/jellyfish-2.2.10.tar.gz
tar -zxvf jellyfish*.gz
cd jellyfish*/
./configure
make
make install
sudo ldconfig
cd ..
# set PATH
echo ' '  >> /home/ubuntu/.profile
echo '# set PATH for Jellyfish' >> /home/ubuntu/.profile
echo 'export PATH="${PATH}:/opt/jellyfish-2.2.10/bin"' >> /home/ubuntu/.profile
source ~/.profile
source ~/.bashrc
wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.1/bowtie2-2.4.1-source.zip
unzip bowtie2-2.4.1-source.zip
cd bowtie2*/
make
cd ..

wget https://github.com/COMBINE-lab/salmon/releases/download/v1.1.0/salmon-1.1.0_linux_x86_64.tar.gz
tar -zxvf salmon*.tar.gz
# set PATH
echo ' '  >> /home/ubuntu/.profile
echo '# set PATH for Salmon' >> /home/ubuntu/.profile
echo 'export PATH="${PATH}:/opt/salmon-latest_linux_x86_64/bin"' >> /home/ubuntu/.profile
source ~/.profile
source ~/.bashrc

wget https://github.com/trinityrnaseq/trinityrnaseq/releases/download/v2.10.0/trinityrnaseq-v2.10.0.FULL.tar.gz
tar -zxvf ./trinity*.tar.gz
cd trinityrnaseq*/
chmod a+w ./trinity-plugins/bamsifter/Makefile
sed -i 's/g++/g++ -std=c++11/' ./trinity-plugins/bamsifter/Makefile
make
cd ..


# Oasis (requires Velvet, TexLive)
apt-get -y install texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra
wget https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz
tar -zxvf velvet_1.2.10.tgz
cd velvet*/
make
cd ..
mv velvet*/ velvet/
wget https://www.ebi.ac.uk/~zerbino/oases/oases_0.2.08.tgz
tar -zxvf oases_0.2.08.tgz
cd oases*/
make

# SOAPdenovo-Trans
wget https://github.com/aquaskyline/SOAPdenovo-Trans.git
cd ../SOAPdenovo-Trans/
bash make.sh
bash clean.sh

# # TransABySS (requires boost, openmpi, sparsehash, python igraph, BLAT)
# brew install boost open-mpi google-sparsehash
# sudo apt-get install abyss
# brew install igraph
# pip -v install python-igraph==0.7.1.post6
# apt-get install mysql-server
# apt-get install libmysqlclient-dev

# wget http://downloads.sourceforge.net/project/libpng/libpng16/older-releases/1.6.2/libpng-1.6.2.tar.gz?r=http%3A%2F%2Fwww.libpng.org%2Fpub%2Fpng%2Flibpng.html&ts=1374540894&use_mirror=hivelocity
# tar -xvf libpng-1.6.2.tar.gz
# cd libpng-1.6.2
# ./configure --prefix=`pwd`
# make
# make install
# LIBPNGDIR=`pwd`
# cd ..
# wget https://genome-test.gi.ucsc.edu/~kent/src/blatSrc.zip
# unzip blatSrc.zip
# cd blatSrc/
# cp ${LIBPNGDIR}/png.h lib/
# cp ${LIBPNGDIR}/pngconf.h lib/
# cp cp ${LIBPNGDIR}/pnglibconf.h lib/
# MACHTYPE=x86_64
# export MACHTYPE
# mkdir -p /bin/$MACHTYPE
# make


rm *.tgz *.zip *.tar.gz 

exit