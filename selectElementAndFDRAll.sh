#!/bin/sh
#selectElementAndFDRAll

scriptDir=`pwd`

FDR[0]=3
FDR[1]=0.25
FDR[2]=0.20
FDR[3]=0.15
FDR[4]=0.10
FDR[5]=0.05
FDR[6]=0.01
FDR[7]=0.005
FDR[8]=0.0005


InputFile[0]=up.5.hmotif.txt ## up.5.mmotif.txt
InputFile[1]=down.5.hmotif.txt ## down.5.mmotif.txt
HEADER[0]=inUFSeq
#HEADER[1]=exUFSeq
HEADER[1]=inMFSeq
HEADER[2]=exMFSeq
HEADER[3]=inDFSeq
#HEADER[5]=exDFSeq
ELEMENT[0]=I5
ELEMENT[1]=I3
BINDINGNUC[0]="GGG"
BINDINGNAME[0]="HNRNPFH"
BINDINGNUC[1]="GCAUG,UGCAU"
BINDINGNAME[1]="FOX"
BINDINGNUC[2]="UUUU"
BINDINGNAME[2]="TIA1R"
#BINDINGNUC[3]="CUG"
BINDINGNUC[3]="CGCC,CGCU,UGCC,UGCU"
BINDINGNAME[3]="MBNL"
BINDINGNUC[4]="CUCUC,UCUCU"
BINDINGNAME[4]="PTB"
BINDINGNUC[5]="GUGUG,UGUGU"
BINDINGNAME[5]="CELF"
BINDINGNUC[6]="ACACA,CACAC"
BINDINGNAME[6]="HRPL"
BINDINGNUC[7]="UGGUG,GGUGG,GUGGU"
BINDINGNAME[7]="ESRP"
numBinder=${#BINDINGNUC[@]}
initialElementSelector="I"
initialHeaderSelector="in"

cd ..

rm eventcount.log
rm empty_event.log

for inputfile in ${InputFile[@]}; do
	echo "processing $inputfile"
	inputsuffix=${inputfile/.txt/}
	if [ -e $inputsuffix ]; then
		rm -R $inputsuffix
	fi
	mkdir $inputsuffix
	for fdr in ${FDR[@]}; do
		echo processing FDR=$fdr	
		bash $scriptDir/selectElementAndFDR.sh $inputfile 2 $initialHeaderSelector $initialElementSelector $fdr . $inputsuffix/${inputsuffix}_FDR${fdr}.txt
		
		fileToCount=$inputsuffix/${inputsuffix}_FDR${fdr}.txt
		numRow=`wc -l "$fileToCount" | awk '{printf("%s\n", $1);}'`
		#echo $numRow
		if [ $numRow -lt 2 ]; then
			echo "$fileToCount" is empty >> empty_event.log
			rm $fileToCount
		else
			numRow=`expr $numRow - 1`
			echo $numRow ${fileToCount/.txt/}_NOHEADER >> eventcount.log
		fi
		
		#continue
		
		echo $inputsuffix/
		mkdir $inputsuffix/FDR$fdr;
		
		for((i=0;i<numBinder;i++)); do
				bindingnuc=${BINDINGNUC[$i]}
				bindingname=${BINDINGNAME[$i]}
				bash $scriptDir/selectElementAndFDR.sh $inputfile 2 . . $fdr $bindingnuc $inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${bindingname}.txt
				#bash $scriptDir/extractOccurencesFromMotifTable.sh $inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${bindingname}.txt 2 $inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${bindingname}.occ.txls
		done;
		
		for header in ${HEADER[@]}; do
			for element in ${ELEMENT[@]}; do
				echo processing header_element $header $element
				
				#echo "
				#echo "_a $header $element" >> eventcount.log
				
				bash $scriptDir/selectElementAndFDR.sh $inputfile 2 $header $element $fdr . $inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${header}_${element}.txt
				
				fileToCount=$inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${header}_${element}.txt
				numRow=`wc -l "$fileToCount" | awk '{printf("%s\n", $1);}'`
				#echo $numRow
				if [ $numRow -lt 2 ]; then
					echo "$fileToCount" is empty >> empty_event.log
					rm $fileToCount
					continue;
				else
					numRow=`expr $numRow - 1`
					echo $numRow ${fileToCount/.txt/}_NOHEADER >> eventcount.log
					
					cuta.py -f".expected freq,.observed freq" $fileToCount | awk -v FS="\t" -v OFS="\t" 'BEGIN{totalObs=0.0;totalExp=0.0;nUniq=0;}(FNR>1){totalExp+=$1;totalObs+=$2;nUniq++;}END{printf("uniqSeq=%d\ntotalObs=%d\ntotalExp=%f\nfold=%.4f\n",nUniq,totalObs,totalExp,totalObs/totalExp);}' > tmp.sh
					source tmp.sh
					BigTotalUniq=$uniqSeq
					BigTotalObs=$totalObs
					BigTotalExp=$totalExp

				fi
				
				#echo "a" >> eventcount.log
				BoundTotalUniq=0
				BoundTotalObs=0
				BoundTotalExp=0
				
				#echo "b" >> eventcount.log

				for((i=0;i<numBinder;i++)); do
					bindingnuc=${BINDINGNUC[$i]}
					bindingname=${BINDINGNAME[$i]}
					
					
					
					bash $scriptDir/selectElementAndFDR.sh $inputfile 2 $header $element $fdr $bindingnuc $inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${header}_${element}_${bindingname}.txt
					#bash $scriptDir/extractOccurencesFromMotifTable.sh $inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${header}_${element}_${bindingname}.txt 2 $inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${header}_${element}_${bindingname}.occ.txls
					
					fileToCount=$inputsuffix/FDR$fdr/${inputsuffix}_FDR${fdr}_${header}_${element}_${bindingname}.txt
					numRow=`wc -l "$fileToCount" | awk '{printf("%s\n", $1);}'`
					#echo $numRow
					if [ $numRow -lt 2 ]; then
						echo "$fileToCount" is empty >> empty_event.log
						rm $fileToCount
					else
						#numRow=`expr $numRow - 1`
						#echo $numRow ${fileToCount/.txt/}_NOHEADER >> eventcount.log
						echo "========" $bindingname "========" >> eventcount.log
						cuta.py -f".word" $fileToCount | awk -v suf="${inputsuffix}:${header}:${element},${bindingname},FDR<${fdr}" '{if(FNR>1){printf("%s   %s\n",$0,suf);}}' >> eventcount.log
						cuta.py -f".expected freq,.observed freq" $fileToCount | awk -v FS="\t" -v OFS="\t" 'BEGIN{totalObs=0.0;totalExp=0.0;nUniq=0;}(FNR>1){totalExp+=$1;totalObs+=$2;nUniq++;}END{printf("uniqSeq=%d\ntotalObs=%d\ntotalExp=%f\nfold=%.4f\n",nUniq,totalObs,totalExp,totalObs/totalExp);}' > tmp.sh
						source tmp.sh
						echo "${inputsuffix}:${header}:${element},${bindingname},FDR<${fdr},uniqSeq=$uniqSeq,totalObs=$totalObs,totalExp=$totalExp,fold=$fold" >> eventcount.log
						BoundTotalUniq=`echo "print $BoundTotalUniq+$uniqSeq" | python -`
						BoundTotalObs=`echo "print $BoundTotalObs+$totalObs" | python -`
						BoundTotalExp=`echo "print $BoundTotalExp+$totalExp" | python -`
						
					fi					
					
					
					
				done
				#echo "c" >> eventcount.log

				#after all bound
				OtherTotalUniq=`echo "print $BigTotalUniq-$BoundTotalUniq" | python -`
				OtherTotalObs=`echo "print $BigTotalObs-$BoundTotalObs" | python -`
				OtherTotalExp=`echo "print $BigTotalExp-$BoundTotalExp" | python -`
				
				#echo "a"
				otherfold=`echo -e "try:\n\tprint float($OtherTotalObs)/$OtherTotalExp\nexcept ZeroDivisionError:\n\tprint 'N/A'" | python -`
				#echo "b"
				totalfold=`echo -e "try:\n\tprint float($BigTotalObs)/$BigTotalExp\nexcept ZeroDivisionError:\n\tprint 'N/A'" | python -`
				#echo "c"
				#echo "d" >> eventcount.log

				
				echo "TOTAL: uniqSeq=$BigTotalUniq,totalObs=$BigTotalObs,totalExp=$BigTotalExp,fold=$totalfold" >> eventcount.log
				echo "OTHER: uniqSeq=$OtherTotalUniq,totalObs=$OtherTotalObs,totalExp=$OtherTotalExp,fold=$otherfold" >> eventcount.log
				echo "***************************************" >> eventcount.log
				#echo "e" >> eventcount.log

				
			done
		done
	done
	
	
	
done
		
