Blur effect in parallel computing
===================
This project is created for the course Parallel Computing and Distributed systems at Universidad Nacional de Colombia and is intended to show how easy and powerful parallel computing can be by letting the user select a group of images of different resolutions (720p, 1080p, 4K) and blur them by just running one command.

----------

Requisites
-------------
For proper compilation this project needs the `OpenCV` library. For the POSIX part it needs the `lpthread` library; for OpenMP it needs the `omp` library and for CUDA it needs the `nvcc` compiler set at PATH.
If you also want to generate the corresponding graphics, then `Python 2.7` or higher must be installed along with matplotlib and numpy libraries.


Usage
-------------
Set your terminal to the directory that you want to run (POSIX, CUDA, OpenMP) inside the folder `src`, once inside you should give execution permits to the file `script_ejecutar_todo.sh` and run it.

The script will detect all files with extension `.jpg`  inside the directories 720p, 1080p, 4K inside the folder `images` and will apply the blur effect over them.

Time logs will be in the files `720p.txt`, `1080p.txt` and `4K.txt` inside the folder `logs`.
Graphics generated with the file `GraphicsGenerator.py` will be stored at the folder `graphics` and will have as name the resolution it belongs to and if it is of time or of speed up.
