#!/bin/bash

kernels='3 5 7 9 11 13 15'
threads='1 2 4 8 16'
directories='720p 1080p 4K'

g++ BlurEffect.cpp -o BlurEffect `pkg-config opencv --libs` -fopenmp
for dir in $directories
do
	rm -f $dir.txt
	touch $dir.txt
	echo -e File '\t\t\t' Kernel '\t\t\t' Threads '\t\t\t' Time'('s')' >> $dir.txt
	for filename in $dir/*.jpg;
	do
		for kernel in $kernels
		do
			for thread in $threads
			do
				echo Running program with $filename, kernel size = $kernel and $thread thread'('s')'
				./BlurEffect "$filename" "$kernel" "$thread" >> $dir.txt
			done
		done
	done
done

#needs numpy and matplotlib python libraries
python GraphicsGenerator.py