#!/bin/sh
if [ ! -e ./dr11_promoters.gff.gz ]; then
    wget -c https://swissregulon.unibas.ch/data/dr11/dr11_promoters.gff.gz
fi
if [ ! -e ./dr11_sites.gff.gz ]; then
    wget -c https://swissregulon.unibas.ch/data/dr11/dr11_sites.gff.gz
fi
if [ ! -e ./dr11_mat_TF_associations.txt ]; then
    wget -c https://swissregulon.unibas.ch/data/dr11/dr11_mat_TF_associations.txt
fi
mkdir motifs
while read line; do
    name=`echo ${line} | sed -e 's|.*Motif=\(.*\);Sequence=.*|\1|'`
    echo ${line} | sed -e 's|.*Promoters=\(.*\);.*|\1|' | sed -e 's|,|\n|g' | sed -e 's|:.*||' \
        >> "motifs/${name}"
done < <(zcat dr11_sites.gff.gz|  tail -n +2)
rm 'motifs/##gff-version 3'
while read file; do
    sort -u "motifs/${file}" > t && mv t "motifs/${file}"
    zcat dr11_promoters.gff.gz \
        | grep -f "motifs/${file}" \
        | sed -e 's:.*Annotations="\(.*\)":\1:' \
        | cut -f 3 -d '|' \
        > t && mv t "motifs/${file}"
done < <(ls motifs)
# dr11_mat_TF_associations.txt is then edited by hand
