#!/bin/bash

# specify data file here
datafile="../data/processed/english_corrected.txt"

# specify model path here
modelpath="best_model/"

# specify result path here
resultpath="result/"

mkdir -p $resultpath

# test
python encode_char.py $datafile $modelpath $resultpath
