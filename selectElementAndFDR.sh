#!/bin/sh
#selectElementAndFDR

if [ $# -lt 7 ]; then
	echo $0 filename startRow headerSelector[.=noselect] elementSelect[.=noselect] FDRCutOff[3=nobound] wordSelector[.=no] outfile
	exit
fi

filename=$1
startRow=$2
headerSelector=$3
elementSelector=$4
FDRCutOff=$5
wordSelector=$6
outfile=$7

headerCol=`colSelect.py $filename .Header`
elementCol=`colSelect.py $filename .Element`
#if [ $boundSelector == "." ]; then
#	boundCol="."
#else
#	boundCol=`colSelect.py -o, $filename "$boundSelector"`
#fi

FDRCol=`colSelect.py $filename .FDR`
wordCol=`colSelect.py $filename .word`

#awk -v FS="\t" -v OFS="\t" -v headerCol=$headerCol -v elementCol=$elementCol -v boundCol="$boundCol" -v FDRCol=$FDRCol -v wordCol=$wordCol -v headerSelector=$headerSelector -v elementSelector=$elementSelector -v FDRCutOff=$FDRCutOff -v startRow=$startRow 'BEGIN{split(boundCol,boundCols,",");}{if(FNR<startRow){print;}else{  if(headerSelector=="." || $headerCol~headerSelector ){  if(elementSelector=="." || $elementCol~elementSelector ){ if($FDRCol<FDRCutOff) {  if(boundCol=="."){print;}else{PRINTIT=1;for(i=1;i<=length(boundCols);i++){if($i!=1){PRINTIT=0;break;} if(PRINTIT){print;}}} }}  }}}' $filename > $outfile

awk -v FS="\t" -v OFS="\t" -v headerCol=$headerCol -v elementCol=$elementCol -v wordSelector="$wordSelector" -v FDRCol=$FDRCol -v wordCol=$wordCol -v headerSelector=$headerSelector -v elementSelector=$elementSelector -v FDRCutOff=$FDRCutOff -v startRow=$startRow 'BEGIN{split(wordSelector,wordSelectors,",");}{if(FNR<startRow){print;}else{  if(headerSelector=="." || $headerCol~headerSelector ){  if(elementSelector=="." || $elementCol~elementSelector ){ if($FDRCol<FDRCutOff) {  if(wordSelector=="."){print;}else{PRINTIT=0;for(i=1;i<=length(wordSelectors);i++){if($wordCol~wordSelectors[i]){PRINTIT=1;break;}} if(PRINTIT){print;}} }}  }}}' $filename > $outfile