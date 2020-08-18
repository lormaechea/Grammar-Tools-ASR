#!/usr/bash

###########################################################################################
# DESCRIPTION :    A Bash script that creates an FST grammar.
# EXECUTION   :    bash genGrammar.sh <MAIN_G_NORM_FILE> <SUB_G_NORM_FILE> (<ROOT_ID>)?
###########################################################################################

RED=$'\e[1;31m';
NC=$'\e[0m';
YELLOW=$'\e[1;33m';

# We export $ROOTVAR:
source ./wordsGenerator/addOOV.sh ./wordsGenerator/totalGram.txt;

# Module import:
. bashModules/fstGProcessing.sh --source-only 
. bashModules/fstSubGProcessing.sh --source-only 

# Kaldi initialization:
source ./initPaths.sh;

# We establish the argument line:
mainGFile=$1; # Main grammar.
subGFile=$2; # Sub grammars.
rootID=$3; # Root identifier.

# Filename, no extension:
filename=$(echo "$mainGFile" | cut -f1 -d'_');

# Log location on server:
logLocation=./logs;
exec > >(tee -i ${logLocation}/${filename}File.log);
exec 2>&1;

# Usage verification:
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo -e "${RED}\n\t*** WRONG USAGE: bash $0 $@";
    echo -e "\t--> PLEASE TYPE: bash $0 <MAIN_G_NORM_FILE> <SUB_G_NORM_FILE> (<ROOT_ID>)?";
    echo -e "\t\t\t ( <ROOT_ID> == <#0_ID> )\n${NC}";
    exit 1; # We stop the program execution.
fi

# If rootID is undefined, we take the global $ROOTVAR:
if [ "$rootID" == "" ]; then
    rootID=$ROOTVAR;
fi

echo -e "${YELLOW}\n\tINPUT FILES WILL BE THE FOLLOWING:";
echo -e "\t\t--> MAIN-G : $mainGFile";
echo -e "\t\t--> SUB-G : $subGFile";
echo -e "\t\t--> WE WILL TAKE '$rootID' AS <ROOT_ID>";
echo -e "\t\t*** LOG FILE : ${filename}File.log\n${NC}";

#------------------------------------------

# First stage --> FST main grammar generation:
process_G_FST;

# Second stage --> We proceed to its compilation:
compile_G_FST;

# Final stage --> We unify the total series of FST into a single G.fst file:
unify_G_FST;

#------------------------------------------

# First stage --> FST subgrammars generation:
process_subG_FST;

# Second stage --> We proceed to its compilation:
compile_subG_FST;

# Third stage --> We rename the resulting files:
rename_subG_FST;

# Final stage --> We unify every subgrammar into a single FST file:
unify_subG_FST;

#------------------------------------------

# Importing fstreplace source script:
. bashModules/fstReplace.sh --source-only 

# We end up replacing the non terminals symbols (found in the main grammar) 
# for their corresponding terminals (in subgrammars):
replace_FST;

#------------------------------------------

# Arranging files:
mkdir -p "${filename}FST";
mv mainFST/ subFST/ replaceFST/ "${filename}FST";
