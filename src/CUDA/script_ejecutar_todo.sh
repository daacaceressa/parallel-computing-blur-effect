#!/bin/bash

kernels='3 5 7 9 11 13 15'
threads='48 96 192 384 576 768 960'
directories='720p 1080p 4K'

nvcc BlurEffect.cu -o BlurEffect `pkg-config opencv --libs`
for dir in $directories
do
	rm -f ../../logs/CUDA/$dir.txt
	touch ../../logs/CUDA/$dir.txt
	echo -e File '\t\t\t' Kernel '\t\t\t' Threads '\t\t\t' Time'('s')' >> ../../logs/CUDA/$dir.txt
	for filename in ../../images/$dir/*.jpg;
	do
		for kernel in $kernels
		do
			for thread in $threads
			do
				echo Running program with $filename, kernel size = $kernel and $thread thread'('s')'
				./BlurEffect "$filename" "$kernel" "$thread" >> ../../logs/CUDA/$dir.txt
			done
		done
	done
done

#needs numpy and matplotlib python libraries
#python GraphicsGenerator.py
