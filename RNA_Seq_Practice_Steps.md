# RNA Seq Data Analysis Practice

## The what and the why

The following steps outline differential gene expression (DGE) data analysis using Mytilus californianus raw read data found at [NCBI Single Read Archive (SRA)](https://www.ncbi.nlm.nih.gov/sra?term=%22Mytilus%20californianus%22%5Borgn%5D&cmd=DetailsSearch).  The entirety of this workflow will require you to use the dreaded command line!

We will be using Unix GNU for a few reasons:
 - Unix is popular in bioinformatics and data analysis so error-fixes and examples are easy to find online.
 - Unix is common. Mac style Unix is very similar to Linux styles of Unix, making them mostly cross compatible.
 - Unix is built to pass streams of data from command to command rather than saving huge temporary files on disk
 - Unix is excellent at managing files and folders on your computer. A workflow is simply file management while relaying data between programs.
 - Unix uses simple data types, mostly streams of txt, making input/output compatibility problems much less frequent
 - Unix is *powerful*, meaning short commands can do big things.

While Unix has many great advantages over other languages, most users have a love-**hate** relationship with it. First of all it is old and open, meaning it has developed layers of antiquated conventions that cant be redone, since no one *owns* Unix. The most obvious are the plethora of two letter commands that must be memorized or constantly looked up. Modern languages make use of tab completion (type half of a name and hit `TAB` to autocomplete or get suggestions) so they make use of much longer command names, making code so much more readable.  Additionally, Unix is sometimes too powerful for its own good.  Unix is setup to run commands without any fuss, this means certain bad things can happen.  Two nasty ones are silent errors and the ability to make big changes to your computer's file system without warnings (like erasing *everything* on your machine with only a five-character command `rm -r ~`). Be warned, but don't be too afraid.


We will be doing differential gene expression (DGE) because this is a fantastic way to *infer* physiological changes. DGE is best when paired with qPCR, chip-seq, physiological observation, or some other verification. In theory DGE is simple, however because of technological limitations and biological variability there are many problems that must be accounted for.
First here is the simplified theory: extract all RNA from a bunch of cells -> select only the mRNA -> read the sequences of all the mRNA -> count the number of each unique mRNA read -> calculate which mRNA read counts are more/less between different groups (groups could be control vs experiment,  or species1 vs species2 vs species3,  or time1 vs time2 vs ... time200) -> lookup the proteins that these differentially expressed mRNAs encode -> lookup the functions and families of these proteins -> infer what biological changes might occur with changing levels of these proteins
Not so bad, in theory...

Here's the rub
 - Some DNA will be extracted on accident
 - tRNA is much more prevalent than mRNA, so some of that will be sequenced on accident as well
 - Cells immediately try to break down their RNA when they are damaged, so some RNA will be naturally cut up
 - Our best technology to count genetic material can only reliably count sequences that are hundreds of bp long
    - So we have to fragment all of the mRNA into bite-sized pieces and attach unique genetic identifiers (barcodes) onto their ends to know who is who
 - Some mRNA are super long (?how long?) while some are super short (?how short?)
 - Some mRNA are expressed in high numbers (?how many?) while some are rarely expressed at all
    - Wide variability in mRNA length and quantity makes fragment counting confusing because
 - Evolution of new genes usually happens with recombination of preexisting genes, then semi-random point mutations.  So many mRNA sequences have similar or identical sections, and once fragmented for sequencing these similarities make it hard to distinguish one from the other.


## Downloading and checking data

Common Unix commands to download data are `curl` and `wget`. However there is a convenient bioinformatics package called [SRA-Toolkit](www.link.com) which is distributed by NCBI?? This package has tools to download SRA data by passing it the accession number.  We'll use `fastq-dump' because this command can also split our paired reads into individual files as it downloads them.  Meaning, we will end up with one file that is the forward read and another file that is the reverse read. Some tools later will need these separated.

Get raw reads accession numbers located at [NCBI Single Read Archive (SRA)](https://www.ncbi.nlm.nih.gov/sra?term=%22Mytilus%20californianus%22%5Borgn%5D&cmd=DetailsSearch)

The accession numbers we will be useing are: SRR9984971, SRR9984973, or SRR9984974


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
