#!/bin/sh

p="$(dirname ${0})"
[ "${1}" = '-f' ] &&
    force='f'

for f in ${p}/*
do
    if [ -d ${f} ]
    then
	d=".$(basename ${f})"
	[ -d ${d} ] ||
	    mkdir ${d}
	cd ${d}
	for sf in ../${f}/*
	do
	    ln -${force}s ${sf}
	done
	cd -
    else
	ln -fs ${f} ".$(basename ${f})"
    fi
done

