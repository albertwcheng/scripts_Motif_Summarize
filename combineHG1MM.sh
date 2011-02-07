
# 1			A			Header
#2			B			Element
#3			C			p-value
#4			D			FDR
#5			E			expected rate
#6			F			expected freq
##7			G			observed rate
#8			H			observed freq
#9			I			word
#10			J			p-value
#11			K			FDR
#12			L			expected rate
#13			M			expected freq
#14			N			observed rate
#15			O			Occurences

#
#
#
#
#
TAB=`echo -e "\t"`

cd ..

for i in *.mmotif.txt; do

mmotifName=$i
hmotifName=${i/.mmotif.txt/}.hmotif.txt
jmotifName=${i/.mmotif.txt/}.jmotif.txt

joinu.py -1 ".Header,.Element,.observed freq,.word" -2 ".Header,.Element,.observed freq,.word" $hmotifName $mmotifName > t1.00
cuta.py -f1,2,9,8,7,15,6,5,3,4,13,12,10,11 t1.00 > t2.00

#Index			Excel			Field
#-----			-----			-----
#1			A			Header
#2			B			Element
#3			C			word
#4			D			observed freq
#5			E			observed rate
#6			F			Occurences
#7			G			expected freq
#8			H			expected rate
#9			I			p-value
#10			J			FDR
#11			K			expected freq
#12			L			expected rate
#13			M			p-value
#14			N			FDR


#using HG as the final FDR??, spare HG cols from being renamed
awk -v FS="\t" -v OFS="\t" '{if(FNR==1){  for(i=11;i<=14;i++){$i="1MM."$i;} } print;}' t2.00 > $jmotifName #spare for(i=7;i<=8;i++){$i="HG."$i;} for(i=7;i<=8;i++){gsub(/expected/,"background",$i);}
done

rm *.00