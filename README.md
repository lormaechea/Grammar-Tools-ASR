<h1 align="center">
    Grammar Tools ASR &middot; Regulus Lite to FST
</h1>



Grammar-Tools-ASR is a minimal tool that helps transforming [Regulus Lite](https://arxiv.org/abs/1510.01942) regular grammars into compiled Finite State Transducers (FSTs). This thus makes them readable as language models in Kaldi as a part of a Automatic Speech Recognition (ASR) system.  

The tool that we present is built from a collection of programs written in Bash, Perl and Python using standard libraries and the C++ OpenFST library. 

<p align="center">
    <a href="https://github.com/lormaechea/Grammar-Tools-ASR/archive/master.zip">
        <img src="https://img.shields.io/badge/Grammar--Tools--ASR%201.0-DOWNLOAD-brightgreen?style=for-the-badge&logo=appveyor">
    </a>
</p>


## Requirements

In order to properly run Grammar-Tools-ASR, it is necessary to previously install the latest version of [Kaldi](https://github.com/kaldi-asr/kaldi).

## Usage

Once you have installed Kaldi, you can load its path by using the `source`  command and editing (if necessary) the `initPaths.sh` script made available in the main directory. 

    $ source initPaths

As for the grammar generation, it results from the consecutive execution of **2 scripts**, whose functioning is detailed below. 

### 1. Data preparation and normalization − `prepareGrammar.pl`

In order to prepare our data, we will use the Perl `prepareGrammar.pl` script, which will:

- First take as input a source grammar written in the Regulus Lite formalism and split the **main grammar** (containing a set of phrases which represent some specific discourse) from the **sub-grammars** (corresponding to word classes represented by non-terminal symbols). 
- And then normalize the data so that it can be properly converted into FSTs in the next phase. 

The execution of the program is done in the following way:

    $ perl prepareGrammar.pl <INPUT_FILE>

From which we will get the subsequent files as output (let's assume that `demo.txt`is the `<INPUT_FILE>`):

- `demo_main.txt` &rarr; Main grammar.

- `demo_sub.txt` &rarr;Sub-grammars.

- `demo_main_norm.txt` &rarr;Normalized main grammar.

- `demo_sub_norm.txt `&rarr; Normalized sub-grammars.

- `newWords.txt` &rarr; This is a file that will add to a pre-existing lexicon the absent non-terminal symbols and the Out-Of-Vocabulary (OOV) forms found in the grammar given in input. It will assign an identifier to each unit. 

  


### 2. Grammar compilation with OpenFST − `genGrammar.sh`

Once the normalized files have been produced, we can move on to the compilation stage. For this purpose, we will use the Bash script `genGrammar.sh`. In order to launch it, the following command needs to be used:

    $ bash genGrammar.sh <MAIN_NORM_FILE> <SUB_NORM_FILE> (<ROOT_ID)?

Where:

- `<MAIN_NORM_FILE>` corresponds to the main normalized grammar.

- `<SUB_MAIN_FILE>` stands for the normalized sub-grammars.

- `(<ROOT_ID>)?` works as an optional argument. It represents the root id (#0). If not specified, the program will default to the one available in the `newWords.txt` file.

  

The **`genGrammar.sh`** script which will take care of the grammar generation in 3 sub-steps :

1. First it will compile the main grammar.

   - **Functions involved**: `process_G_FST | compile_G_FST | unify_G_FST`
   - **Exit folder** : `./demoFST/mainFST/*`

2. It will subsequently compile every sub-grammar word class. 

   - **Functions involved**: `process_subG_FST | compile_subG_FST | rename_subG_FST | unify_subG_FST`
   - **Exit folder** : `./demoFST/subFST/*`

3. Finally it will replace the non terminal symbols found in the main grammar by its corresponding terminals (found on the sub-grammars).

   - **Functions involved**: `replace_FST`
   - **Exit folder** : `./demoFST/replaceFST/*` &rarr;**(Note: the resulting grammar will be found on this folder by the name of `G.fst`).**

###    Once the `G.fst`file is generated, it can be used as a language model in your Kaldi ASR experiments!

