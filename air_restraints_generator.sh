#!/bin/sh 
####################################################
# VMD Haddock AIR Restraints Generator 2 Proteins
# Script adapted from CGI scripts within 
# the Haddock distribution
# Sven Klumpe, July 2018
####################################################

#usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }



AIR_ACTIVE_1=$1
AIR_ACTIVE_2=$2
AIR_PASSIVE_1=$3
AIR_PASSIVE_2=$4
PROT_SEGID_1=$5
PROT_SEGID_2=$6
AIR_DIST=$7

#while getopts ":active1:active2:passive1:passive2:segid1:segid2:airdist:" option;
#do 
#case ${option} in
#active1 ) echo "BLABLABLA";;
#active2 ) AIR_ACTIVE_2=${OPTARG};;
#passive1 ) AIR_PASSIVE_1=${OPTARG};;
#passive2 ) AIR_PASSIVE_2=${OPTARG};;
#segid1 ) PROT_SEGID_1=${OPTARG};;
#segid2 ) PROT_SEGID_2=${OPTARG};;
#airdist ) AIR_DIST=${OPTARG};;
#esac
#done

echo '! HADDOCK AIR restraints for 1st partner'

for i in $AIR_ACTIVE_1
do
  echo '!' 
  echo 'assign ( resid '$i ' and segid '$PROT_SEGID_1')'
  echo '       ('
  inum=0
  itot=`echo $AIR_ACTIVE_2 $AIR_PASSIVE_2 | wc | awk '{print $2}'`
  for j in $AIR_ACTIVE_2 $AIR_PASSIVE_2 
  do
    inum=`expr $inum + 1`
    echo '        ( resid '$j ' and segid '$PROT_SEGID_2')' 
    if [ $inum != $itot ]
      then
        echo '     or' 
    fi
    if [ $inum = $itot ]
      then
        echo '       ) ' $AIR_DIST $AIR_DIST '0.0'
    fi
  done
    
done
#
# Now the same for the 2nd partner
#
echo '!' 
echo '! HADDOCK AIR restraints for 2nd partner'

for i in $AIR_ACTIVE_2
do
  echo '!'
  echo 'assign ( resid '$i ' and segid '$PROT_SEGID_2')'
  echo '       ('
  inum=0
  itot=`echo $AIR_ACTIVE_1 $AIR_PASSIVE_1 | wc | awk '{print $2}'`
  for j in $AIR_ACTIVE_1 $AIR_PASSIVE_1 
  do
    inum=`expr $inum + 1`
    echo '        ( resid '$j ' and segid '$PROT_SEGID_1')' 
    if [ $inum != $itot ]
      then
	echo '     or' 
    fi
    if [ $inum = $itot ]
      then
	echo '       ) ' $AIR_DIST $AIR_DIST '0.0'
    fi
  done
    
done
