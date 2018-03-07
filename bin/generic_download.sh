#!/bin/bash

#First argument is file, second argument is $PIPELINE

function dl_generic(){
    echo "Initiating generic download"
  if [[ ! -z $( cat $1 | grep juelich )  ]]; then 
     sed 's?srm://lofar-srm.fz-juelich.de:8443?gsiftp://lofar-gridftp.fz-juelich.de:2811?g' $1 | xargs -I{} globus-url-copy -st 30 -fast -v {} $PWD/Input/ || { echo 'downloading failed' ; exit 21; }
   fi

   if [[ ! -z $( cat $1 | grep sara )  ]]; then
     sed 's?srm://srm.grid.sara.nl:8443?gsiftp://gridftp.grid.sara.nl:2811?g' $1 | xargs -I{} globus-url-copy -st 30 -fast -v {} $PWD/Input/ || { echo 'downloading failed' ; exit 21; }
   fi
   
   if [[ ! -z $( cat $1 | grep psnc )  ]]; then
     sed 's?srm://lta-head.lofar.psnc.pl:8443?gsiftp://gridftp.lofar.psnc.pl:2811?g' $1 | xargs -I{} globus-url-copy -st 30 -fast -v {} $PWD/Input/ || { echo 'downloading failed' ; exit 21; }
   fi
   
   wait
   OLD_P=$PWD 
   cd ${RUNDIR}/Input

   for i in `ls *tar`; do tar -xvf $i && rm -rf $i; done
   for i in `ls *gz`; do tar -zxvf $i && rm -rf $i; done
   cd ${RUNDIR}

   echo "Download Done!"

}
