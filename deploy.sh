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
	    ln -fs "../${sf}"
	done
	cd -
    else
	ln -fs ${f} ".$(basename ${f})"
    fi
done

