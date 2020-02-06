Get raw reads accession numbers (maybe get a bad example also)
https://www.ncbi.nlm.nih.gov/sra?term=%22Mytilus%20californianus%22%5Borgn%5D&cmd=DetailsSearch

SRR9984971
SRR9984973
SRR9984974


curl -O https://sra-download.ncbi.nlm.nih.gov/traces/sra75/SRR/009750/SRR9984971; curl -O https://sra-download.ncbi.nlm.nih.gov/traces/sra19/SRR/009750/SRR9984973; curl -O https://sra-download.ncbi.nlm.nih.gov/traces/sra23/SRR/009750/SRR9984974


Download samtools and htslib somewhere
	git clone https://github.com/samtools/htslib
	git clone https://github.com/samtools/samtools
	cd samtools
	make
	

for f in *; do sam-dump --output-file $f.sam $f; done
#take the above and pipe directly to samtools to make bam
http://samtools.sourceforge.net/



FastQC
	Download
		https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
	Documentation
		https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/
	Command
		drag&drop with GUI


FASTX-Toolkit
	Download
		http://hannonlab.cshl.edu/fastx_toolkit/commandline.html
	Documentation
	Command


Trimmomatic
http://www.usadellab.org/cms/?page=trimmomatic


ALIGNMENT

Trinity

BowTie/TopHat

STAR

Oasis


QA/QC

Picard

RSeQC

Qualimap
