#!/bin/bash
# usage: run1.sh NAME "Var1=val1 Var2=val2"  -- edits only set lines of Solar_Cell_FIXED.in
name=$1; top=$PWD; d=$top/runs/$name; rm -rf $d; mkdir -p $d
cp AM15G_ATLAS_POWER.spec AM15G.dat $d/; cp ${DECK:-Solar_Cell_FIXED.in} $d/deck.in
for kv in $2; do k=${kv%%=*}; v=${kv#*=}; sed -i -E "s|^set[[:space:]]+$k[[:space:]]*=.*|set $k = $v|I" $d/deck.in; done
cd $d && deckbuild -run deck.in -outfile out.txt > /dev/null 2>&1
r=$(for q in Jsc_mA_cm2 Voc_V FF_percent Efficiency_percent; do grep -oh "$q=[-0-9.e+]*" results.final out.txt 2>/dev/null | tail -1; done | tr '\n' ' ')
echo "$name $r" >> $top/summary.txt
