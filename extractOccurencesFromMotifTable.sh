#!/bin/sh
#extractOccurencesFromMotifTable.sh

if [ $# -lt 3 ]; then
	echo $0 filename startRow outfile
	exit
fi

filename=$1
startRow=$2
outfile=$3

ocCol=`colSelect.py $filename .Occurences`
headerCol=`colSelect.py $filename .Header`
elementCol=`colSelect.py $filename .Element`
pvalueCol=`colSelect.py $filename .p^mvalue`
FDRCol=`colSelect.py $filename .FDR`
wordCol=`colSelect.py $filename .word`

awk -v FS="\t" -v OFS="\t" -v ocCol=$ocCol -v headerCol=$headerCol -v elementCol=$elementCol -v pvalueCol=$pvalueCol -v FDRCol=$FDRCol -v wordCol=$wordCol -v startRow=$startRow 'BEGIN{printf("GeneName\tEventType\tEventID\tHeader\tElement\tPos\tWord\tpvalue\tFDR\n");}(FNR>=startRow){ocString=$ocCol; split(ocString,ocStringA,"|"); for(i=1;i<=length(ocStringA);i++){singOcur=ocStringA[i]; split(singOcur,singOcurInfo,":"); pos=singOcurInfo[2]; split(singOcurInfo[1],singOcurInfoA,"#"); eventType=singOcurInfoA[1]; geneName=singOcurInfoA[2]; eventID=singOcurInfoA[3]; printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",geneName,eventType,eventID,$headerCol,$elementCol,pos,$wordCol,$pvalueCol,$FDRCol); } }' $filename > $outfile

