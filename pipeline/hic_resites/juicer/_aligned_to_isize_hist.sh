bed=aligned/merged_nodups.bed
len=/data/projects/phillippy/projects/hummingbird/juicer_hic/pacbio_falcon_pa_pilon_ponly.fasta.len.bed

<<'END'

echo "=== Convert Juicer output to distance bed file ==="
head -n 100000000 aligned/merged_nodups.txt | awk '{if ($2 == $6 && $1 ==0 && $5 == 0) { \
	if ($3 < $7) {print $2"\t"$3"\t"$7} \
	else {print $2"\t"$7"\t"$3}}}'  > $bed.subsample20x
echo ""
#END

bed=$bed.subsample20x

echo "=== Sort bed file along position ==="
java -jar -Xmx4g /home/rhiea/codes/bedSort.jar $bed $bed.sort
echo ""
END

#cov_hist="cov_hist_20x_subsampling"
cov_hist="cov_hist_effective_2M"
mkdir -p $cov_hist
#END

bed=aligned/effective_interactions.20M.bed

echo "=== Get coverage by insert size ==="
for isize in 500 1000 5000 10000 50000 100000 500000 1000000 5000000 10000000 20000000 
do
	echo "  ... $isize"
	#awk -v isize=$isize '($3-$2) >= isize' $bed.sort | bedtools coverage -hist -a - -b $len > $cov_hist/$isize.bed
	awk -v isize=$isize '($3-$2) >= isize' $bed | bedtools coverage -hist -a - -b $len > $cov_hist/$isize.bed
	awk -v isize=$isize '$1=="all" && $2>=10 {sum += $NF} END {print isize"\t"sum}' $cov_hist/$isize.bed >> cov_over_10.20x.bed
done
