#!/bin/bash

#First argument is file, second argument is $PIPELINE

function download_files(){
 echo "Downloading $(wc -l $1 | awk '{print $1}' ) files"
 $OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'downloading'
 mkdir Downloads
 case "$2" in
    *cal1*) echo "Downloading cal1 files"; dl_cal1 $1 ;;
    *cal2*) echo "Downloading cal_solutions"; dl_cal2 $1 ;;
    *targ1*) echo "Downloading target1 SB"; dl_cal1 $1  ;;
    *targ2*) echo "Downloading targ1 solutions";dl_targ2 $1 ;;
    *) echo "Unknown Pipeline, Will try to download anyways"; dl_cal1 $1 ;;
 esac

}




function dl_targ1(){
   $OLD_PYTHON  wait_for_dl.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD}
   python ./download_srms.py $1 0 $( wc -l $1 | awk '{print $1}' ) || { echo "Download Failed!!"; exit 20; } #exit 20=> Download fails
   for i in `ls *tar`; do tar -xvf $i &&rm $i; done 
 
}

function dl_cal1(){

   if [[ ! -z $( cat $1 | grep juelich )  ]]; then 
     sed 's?srm://lofar-srm.fz-juelich.de:8443?gsiftp://lofar-gridftp.fz-juelich.de:2811?g' $1 | xargs -I{} globus-url-copy -st 30 -fast -v {} $PWD/Downloads/ || { echo 'downloading failed' ; exit 20; }
   fi

   if [[ ! -z $( cat $1 | grep sara )  ]]; then
     sed 's?srm://srm.grid.sara.nl:8443?gsiftp://gridftp.grid.sara.nl:2811?g' $1 | xargs -I{} globus-url-copy -st 30 -fast -v {} $PWD/Downloads/ || { echo 'downloading failed' ; exit 20; }
   fi

   if [[ ! -z $( cat $1 | grep psnc )  ]]; then
     sed 's?srm://lta-head.lofar.psnc.pl:8443?gsiftp://gridftp.lofar.psnc.pl:2811?g' $1 | xargs -I{} globus-url-copy -st 30 -fast -v {} $PWD/Downloads/ || { echo 'downloading failed' ; exit 20; }
   fi

   wait
   OLD_P=$PWD
   cd $PWD/Downloads

   for i in `ls *tar`; do tar -xf $i && rm -rf $i; done
   cd $OLD_P

   echo "Download Done!"
}

function dl_cal2(){
# This function is specific to the temp files created by pref_cal1 
   sed 's?srm://srm.grid.sara.nl:8443?gsiftp://gridftp.grid.sara.nl:2811?g' $1 | xargs -I{} globus-url-copy -st 30 {} $PWD/ || { echo 'downloading failed' ; exit 20; }
   for i in `ls *tar`; do tar -xf $i &&rm $i; done
   find . -name "${OBSID}*ndppp_prep_cal" -exec mv {} . \;   

}

function dl_targ2(){
   cat $1 | xargs -I{} globus-url-copy  {} $PWD/
   for i in `ls *gz`; do tar -zxf $i; done
   mv prefactor/results/L* ${RUNDIR}
}

 
