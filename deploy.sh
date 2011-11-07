#!/bin/sh

p="$(dirname ${0})"

for f in ${p}/*
do
    if [ -d ${f} ]
    then
	d=".$(basename ${f})"
	[ -d ${d} ] ||
	    mkdir ${d}
	cd ${d}
	for sf in ${f}/*
	do
	    echo ln -s "../${sf}"
	done
	cd -
    else
	echo ln -s ${f} ".$(basename ${f})"
    fi
done

