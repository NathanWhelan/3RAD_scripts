#!/bin/bash 

mkdir remFolder
mv *.rem.* remFolder

mkdir cloneFiltered
for FILE in *.1.fq.gz
do
NAME2=`echo $FILE |sed 's/\.1\./\.2\./'`
echo $NAME2
/usr/local/genome/stacks2.53/bin/clone_filter -1 $FILE -2 $NAME2 -i gzfastq -o cloneFiltered/ --null_index --oligo-len-2 8
done;
