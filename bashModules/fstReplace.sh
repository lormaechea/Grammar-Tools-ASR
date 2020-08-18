#!/usr/bash

GREEN=$'\e[1;32m';
BLUE=$'\e[1;36m';
NC=$'\e[0m';

replace_FST() {
    echo -e "\n\t________________________________________________________";
    echo -e "${GREEN}\n\n\t\t\t*****************************";
    echo -e "${GREEN}\t\t\t****** REPLACING STAGE ******";
    echo -e "${GREEN}\t\t\t*****************************\n${NC}";

    # We create a specific folder for the fstreplace commands:
    goodRep="replaceFST";
    mkdir -p "$goodRep";

    # We select the variable ids:
    stringDollars=$(cat newWords.txt | egrep '\$' | tr -d '\$' | tr '\n' ',');

    # And save them into a list:
    IFS=',' read -a listDollars <<< "$stringDollars";

    # We create a list for the directories:
    declare -a folders
    iFold=1
    for folder in */*/; 
        do
            folders[iFold++]="${folder%/}"; 
        done

    #------------------------------------------------------

    # We specify the naming form:
    tmpCounter1=1;
    tmpCounter2=2;
    prefix="tmp_";
    extension=".fst";

    tmpFile1=${prefix}${tmpCounter1}${extension};
    tmpFile2=${prefix}${tmpCounter2}${extension};

    #------------------------------------------------------

    # Backup copy (to initialize):
    cp ./mainFST/G_det.fst ./${goodRep}/finalG_det.fst;
    echo -e "--> INITIALIZING... cp ./mainFST/G_det.fst ./${goodRep}/finalG_det.fst";

    #------------------------------------------------------

    while fstprint ./${goodRep}/finalG_det.fst | egrep '\$' > /dev/null;
        do
            for folder in "${folders[@]}"
                do
                    folderName=$(echo $folder | cut -f2 -d'/');
                    # echo "$folderName";

                    for dollar in "${listDollars[@]}"
                        do
                            cle=$(echo $dollar | cut -f1 -d' ');
                            val=$(echo $dollar | cut -f2 -d' ');

                            if [[ "${cle}" = "${folderName}" ]]; then

                                tmpFile1=${prefix}${tmpCounter1}${extension};
                                tmpFile2=${prefix}${tmpCounter2}${extension};

                                if [ $tmpCounter1 -eq 1 ]; then
                                    echo -e "--> REPLACING... fstreplace --epsilon_on_replace ./mainFST/G_det.fst $rootID ./subFST/${cle}/${cle}_minenc.fst $val ./$goodRep/$tmpFile2";
                                    fstreplace --epsilon_on_replace ./mainFST/G_det.fst $rootID ./subFST/${cle}/${cle}_minenc.fst $val ./$goodRep/$tmpFile2;
                                else
                                    #echo "KEY ---> $cle | VALUE ---> $val";
                                    echo -e "--> REPLACING... fstreplace --epsilon_on_replace ./$goodRep/$tmpFile1 $rootID ./subFST/${cle}/${cle}_minenc.fst $val ./$goodRep/$tmpFile2";
                                    fstreplace --epsilon_on_replace ./$goodRep/$tmpFile1 $rootID ./subFST/${cle}/${cle}_minenc.fst $val ./$goodRep/$tmpFile2;

                                    # We remove the now unnecessary tmp files:
                                    rm ./${goodRep}/${tmpFile1};
                                fi

                            # Counter incrementation:
                            tmpCounter1=$((tmpCounter1+1));
                            tmpCounter2=$((tmpCounter2+1));

                            fi
                        done
                    done
                    
                    echo -e "\n---------------------------------------------------\n";
                    echo -e "--> ENDING LOOP... cp ./$goodRep/$tmpFile2 ./$goodRep/finalG.fst";
                    cp ./$goodRep/$tmpFile2 ./$goodRep/finalG.fst;

                    # We later proceed to the following steps of epsilon removal:
                    echo -e "--> EPSILON REMOVAL... fstrmepsilon ./$goodRep/finalG.fst ./$goodRep/finalG_eps.fst";
                    fstrmepsilon ./$goodRep/finalG.fst ./$goodRep/finalG_eps.fst;
                    # fstdraw --portrait=true --isymbols=newWords.txt --osymbols=newWords.txt ./$goodRep/finalG_eps.fst | dot -Tpng -Gsize=60,60  > ./$goodRep/finalG_eps.png;

                    # To the determinization:
                    echo -e "--> DETERMINIZATION... fstdeterminize ./$goodRep/finalG_eps.fst ./$goodRep/finalG_det.fst";
                    fstdeterminize ./$goodRep/finalG_eps.fst ./$goodRep/finalG_det.fst;
                    # fstdraw --portrait=true --isymbols=newWords.txt --osymbols=newWords.txt ./$goodRep/finalG_det.fst | dot -Tpng -Gsize=60,60  > ./$goodRep/finalG_det.png;
                done

    # We remove the now unnecessary tmp files:
    rm -r ./${goodRep}/tmp_*;

    # And the final minimization:
    echo -e "\n\n----------------------------------------------------"
    echo -e "\nFINAL STAGE...";
    echo -e "--> MINIMIZATION... fstminimizeencoded ./$goodRep/finalG_det.fst ./$goodRep/finalG_minenc.fst";
    fstminimizeencoded ./$goodRep/finalG_det.fst ./$goodRep/finalG_minenc.fst;
    # fstdraw --portrait=true --isymbols=newWords.txt --osymbols=newWords.txt ./$goodRep/finalG_minenc.fst | dot -Tpng -Gsize=60,60  > ./$goodRep/finalG_minenc.png;

    echo -e "--> SORTING... fstarcsort ./$goodRep/finalG_det.fst ./$goodRep/finalG_minenc.fst";
    fstarcsort ./$goodRep/finalG_minenc.fst ./$goodRep/G.fst;
    fstdraw --portrait=true --isymbols=newWords.txt --osymbols=newWords.txt ./$goodRep/G.fst | dot -Tpng -Gsize=60,60  > ./$goodRep/G.png;

    echo -e "${GREEN}\n\n\t\t******************************************************";
    echo -e "\t\t*** NOW THE FINAL GRAMMAR 'G.fst' IS READY TO USE! ***";
    echo -e "\t\t******************************************************\n\n${NC}";
}
