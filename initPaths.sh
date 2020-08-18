#!/bin/sh

# EXECUTION :  source initPaths_Docker.sh

WORK_DIR=/home/Grammar-Tools-ASR # Or the one you picked!
KALDI_DIR=/home/kaldi # Or the one you picked!

export train_cmd="oar_queue.pl"

export PATH=$PATH:./:$KALDI_DIR/src/bin:$KALDI_DIR/src/bin:$KALDI_DIR/src/gmmbin:$KALDI_DIR/src/latbin:$KALDI_DIR/src/featbin:$KALDI_DIR/tools/openfst-1.6.1/bin:$KALDI_DIR/src/fstbin:$WORK_DIR/utils:$WORK_DIR/steps:$KALDI_DIR/src/sgmmbin/:$KALDI_DIR/src/fgmmbin:$KALDI_DIR/src/sgmm2bin:$KALDI_DIR/src/nnet-cpubin/:$KALDI_DIR/src/nnetbin/:$KALDI_DIR/src/nnet2bin:$KALDI_DIR/tools/openfst/src/bin

export LC_ALL=C

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/$KALDI_DIR/src/lib/:$KALDI_DIR/tools/openfst-1.6.7/lib

cd $WORK_DIR
