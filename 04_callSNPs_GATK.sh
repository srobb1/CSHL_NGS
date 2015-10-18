QUERY_BAM=W303.realign.bam
GENOME=genome/Saccharomyces.fa
cd data

GATK=/usr/local/GATK/GenomeAnalysisTK.jar

# run the genotyper
java -Xmx3g -jar $GATK -T UnifiedGenotyper \
    -glm SNP -I $QUERY_BAM -R $GENOME \
    -o W303.GATK_raw.vcf -nt 2

# filter the VCF
java -Xmx3g -jar $GATK \
    -T VariantFiltration -o W303.GATK_filtered.vcf \
    --variant W303.GATK_raw.vcf -R $GENOME \
    --clusterWindowSize 10  -filter "QD<8.0" -filterName QualByDepth \
    -filter "MQ<=30.0" -filterName MapQual \
    -filter "QUAL<100" -filterName QScore \
    -filter "MQ0>=10 && ((MQ0 / (1.0 * DP)) > 0.1)" -filterName MapQualRatio \
    -filter "FS>60.0" -filterName FisherStrandBias \
    -filter "HaplotypeScore > 13.0" -filterName HaplotypeScore >& output.filter.log 

java -Xmx3g -jar $GATK -T SelectVariants -R $GENOME  --variant W303.GATK_filtered.vcf \
 -o W303.GATK_selected.vcf --excludeFiltered
# stats if you have BCFTOOLS 1.1 installed

bgzip W303.GATK_raw.vcf
bgzip W303.GATK_filtered.vcf
bgzip W303.GATK_selected.vcf

tabix -p vcf W303.GATK_raw.vcf.gz
tabix -p vcf W303.GATK_filtered.vcf.gz
tabix -p vcf W303.GATK_selected.vcf.gz

BCFTOOLS=/usr/local/bcftools/bcftools
$BCFTOOLS stats -F $GENOME -s - W303.GATK_raw.vcf.gz > W303.GATK_raw.vcf.stats
$BCFTOOLS stats -F $GENOME -s - W303.GATK_filtered.vcf.gz > W303.GATK_filtered.vcf.stats
$BCFTOOLS stats -F $GENOME -s - W303.GATK_selected.vcf.gz > W303.GATK_selected.vcf.stats
