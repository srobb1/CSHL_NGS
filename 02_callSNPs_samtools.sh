cd data

QUERY_BAM=W303.sorted.bam
# HERE WE ARE USING SAMTOOLS 1.2
SAMTOOLS=/usr/local/samtools-1.2/samtools
BCFTOOLS=/usr/local/bcftools/bcftools

# IF YOU RUN THE REALIGNER (step 03) change this to the following
# QUERY_BAM=W303.realign.bam

GENOME=genome/Saccharomyces.fa
# also make index from samtools
$SAMTOOLS faidx $GENOME

#BEGIN SAMTOOLS 1.1
$SAMTOOLS mpileup -ugf $GENOME $QUERY_BAM | $BCFTOOLS call -vmO z -o W303.samtools_raw.vcf.gz

tabix -p vcf W303.samtools_raw.vcf.gz

$BCFTOOLS stats -F $GENOME -s - W303.samtools_raw.vcf.gz > W303.samtools_raw.vcf.stats

$BCFTOOLS filter -O z -o W303.samtools_filtered.vcf.gz -s LOWQUAL -i'%QUAL>10' W303.samtools_raw.vcf.gz

tabix -p vcf W303.samtools_filtered.vcf.gz

$BCFTOOLS stats -F $GENOME -s - W303.samtools_filtered.vcf.gz > W303.samtools_filtered.vcf.stats

#END SAMTOOLS 1.1

#IF YOU ARE USING SAMTOOLS 0.1.19
#BEGIN SAMTOOLS 0.1.19
#ACC=W303
#$SAMTOOLS mpileup -D -S -gu -f $GENOME $QUERY_BAM | $BCFTOOLS view -bvcg - > $ACC.samtools_raw.vcf
#$BCFTOOLS view $ACC.samtools_raw.vcf | vcfutils.pl varFilter -D100 > $ACC.samtools_filter.vcf
#END SAMTOOLS 0.1.19
