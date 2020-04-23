#!/usr/bin/bash
################################################################
# ScriptName: runGuppy.sh                                      #
# Descriptint: Do basecalling and barcoding on Nanopore data   #
# Version: 0.1                                                 #
# Provider: Chiachun Chiu <nostalgie.chiu@genebook.com.tw>     #
################################################################

## Setting
guppybasecaller=$(command -v guppy_basecaller)
configureFile="dna_r9.4.1_450bps_hac.cfg"
inputFast5Dir="fast5"
basecalledFastqDir="fastq"
barcodedFastqDir="barcoded"
barcodeKit="EXP-NBD114"
gpuRunners=4
chunkSize=500
chunksPerRunner=600
cpuCallers=4
cpuThreadsPerCaller=2
workerThreads=6
barcodingThreads=4
dualBarcode=false
barcodingConfigureFile="configuration.cfg"

if ( $dualBarcode ); then 
	barcodingConfigureFile="configuration_dual.cfg"
	barcodeKit="EXP-DUAL00"
fi

if [[ $? -ne 0 ]]; then
	echo -e "\033[1;31m[Error] Cannot find guppy_basecaller! Please check the installation path of guppy_basecaller!\033[0m"
fi

## Do Basecalling
$guppybasecaller -c $configureFile \
	   -r -i $inputFast5Dir \
	   -s $basecalledFastqDir \
	   -x "cuda:all" \
	   --gpu_runners_per_device $gpuRunners \
	   --chunk_size $chunkSize \
	   --chunks_per_runner $chunksPerRunner \
	   --num_callers $cpuCallers \
	   --cpu_threads_per_caller $cpuThreadsPerCaller


## Do Demultiplexing
guppybarcoder=$(command -v guppy_barcoder)

if [[ $? -ne 0 ]]; then
	echo -e "\033[1;31m[Error] Cannot find guppy_barcoder! Please check the installation path of guppy_barcoder!\033[0m"
fi


$guppybarcoder -r -i $basecalledFastqDir \
	           -s $barcodedFastqDir \
			   --worker_threads $workerThreads \
			   --config $barcodingConfigureFile \
			   --num_barcode_threads $barcodingThreads \
			   --barcode_kits $barcodeKit \
			   --trim_barcodes
