#!/bin/bash -i
#
#PBS -N train_no_pca_models
#PBS -q gpu_small
#PBS -l select=1:ncpus=24:mem=46gb:interconnect=1g
#PBS -l walltime=12:00:00
#PBS -o train_no_pca_models.txt
#PBS -j oe

module load matlab/2022a
cd CPSC-8420-Machine-Learning-Project
matlab -r "train_model(model="linear", pca=0, name_data_file="data/50k_data_name.mat", descript_data_file="data/50k_data_descript.mat", other_data_file="data/50k_data_other.mat"); exit" -logfile linear_no_pca_model_train.txt
matlab -r "train_model(model="ridge", pca=0, name_data_file="data/50k_data_name.mat", descript_data_file="data/50k_data_descript.mat", other_data_file="data/50k_data_other.mat"); exit" -logfile ridge_no_pca_model_train.txt
matlab -r "train_model(model="lasso", pca=0, name_data_file="data/50k_data_name.mat", descript_data_file="data/50k_data_descript.mat", other_data_file="data/50k_data_other.mat"); exit" -logfile lasso_no_pca_model_train.txt
