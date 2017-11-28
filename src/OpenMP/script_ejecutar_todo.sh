#!/bin/bash

kernels='3 5 7 9 11 13 15'
threads='1 2 4 8 16'
directories='720p 1080p 4K'

g++ BlurEffect.cpp -o BlurEffect `pkg-config opencv --libs` -fopenmp
for dir in $directories
do
	rm -f ../../logs/OpenMP/$dir.txt
	touch ../../logs/OpenMP/$dir.txt
	echo -e File '\t\t\t' Kernel '\t\t\t' Threads '\t\t\t' Time'('s')' >> ../../logs/OpenMP/$dir.txt
	for filename in ../../images/$dir/*.jpg;
	do
		for kernel in $kernels
		do
			for thread in $threads
			do
				echo Running program with $filename, kernel size = $kernel and $thread thread'('s')'
				./BlurEffect "$filename" "$kernel" "$thread" >> ../../logs/OpenMP/$dir.txt
			done
		done
	done
done

#needs numpy and matplotlib python libraries
python GraphicsGenerator.py