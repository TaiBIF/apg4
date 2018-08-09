#!/usr/bin/env sh
psql -A -d nvdimp -c "
SELECT 
    id,namecode,tropicos_namecode,
    family,family_zh,family_fot,
    family_fot_zh,genus,genus_zh,
    name,fullname,plant_type
FROM nomenclature.namelist
    WHERE accepted_id IS NULL order by plant_type,family,fullname;" > ../db/namelist.csv

psql -A -d nvdimp -c "SELECT 
    sn,family_apgiv,genus_apgiv,
    genus_zh,genus_accepted,genus_accepted_name 
FROM apgiv_genus order by sn" > ../db/apgiv_family_genus.csv

psql -A -d nvdimp -c "SELECT
    fid,family_subid_apgiv,family_id_lapgiii,
    order_apgiv,family,family_zh,family_zh_cn,
    in_floratw,family_id family_id_apgiv,in_paper
FROM apgiv_families order by fid" > ../db/apgiv_families.csv

psql -A -d nvdimp -c "SELECT order_id_apgiv,order_apgiv,order_zh
 FROM apgiv_orders order by order_id_apgiv
" > ../db/apgiv_orders.csv

psql -A -d nvdimp -c "SELECT
    clade_id,clade_subid,clades,
    clades_zh,order_id,\"order\",order_zh,
    in_floratw,superorder,superorder_zh,
    superorder_id,subclass,subclass_zh,
    class,class_zh,superclass,superclass_zh,
    phylum,phylum_zh,subphylum,subphylum_zh
 FROM apgiv_clades order by clade_id
" > ../db/apgiv_clades.csv

