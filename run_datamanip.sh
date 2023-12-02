#!/bin/bash
#
#PBS -N datamanip
#PBS -l select=1:ncpus=10:mem=10gb:interconnect=1g
#PBS -l walltime=3:00:00
#PBS -o datamanip_output.txt
#PBS -j oe

module load matlab/2022a
matlab -r "edited_datamanip(fin='data/repositories.csv') ; exit"
