import numpy as np
import matplotlib.pyplot as plt

def getGraphics( filename, fileSize ):
    #mapidx = [48, 96, 192, 384, 576, 768, 960]
    mapidx = { }
    mapidx[ "48" ] = 1
    mapidx[ "96" ] = 2
    mapidx[ "192" ] = 3
    mapidx[ "384" ] = 4
    mapidx[ "576" ] = 5
    mapidx[ "768" ] = 6
    mapidx[ "960" ] = 7
    file = open( filename, "r" )
    times = np.zeros((7,8))
    speedUp = np.zeros((7,8))
    threads = [1, 48, 96, 192, 384, 576, 768, 960]
    
    if fileSize == "720p":
        times[ 0 ][ 0 ] = 0.22246923076923075
        times[ 1 ][ 0 ] = 0.51099230769230775
        times[ 2 ][ 0 ] = 0.93820000000000003
        times[ 3 ][ 0 ] = 1.5688230769230769
        times[ 4 ][ 0 ] = 2.3092923076923078
        times[ 5 ][ 0 ] = 3.1751153846153843
        times[ 6 ][ 0 ] = 4.2070769230769232
    elif fileSize == "1080p":
        times[ 0 ][ 0 ] = 0.49363333333333337
        times[ 1 ][ 0 ] = 1.1349933333333333
        times[ 2 ][ 0 ] = 2.1181733333333335
        times[ 3 ][ 0 ] = 3.5603533333333326
        times[ 4 ][ 0 ] = 5.2103866666666674
        times[ 5 ][ 0 ] = 7.1542866666666667
        times[ 6 ][ 0 ] = 9.4469400000000014
    else:
        times[ 0 ][ 0 ] = 2.334772727272727
        times[ 1 ][ 0 ] = 5.0215636363636369
        times[ 2 ][ 0 ] = 9.0411181818181827
        times[ 3 ][ 0 ] = 15.170699999999998
        times[ 4 ][ 0 ] = 22.261772727272724
        times[ 5 ][ 0 ] = 30.506090909090911
        times[ 6 ][ 0 ] = 40.447170000000007

    cnt = np.zeros((7,8))
    flag = 0
    for line in file:
        arr = line.split()
        flag += 1
        if (flag == 1):
            continue
        times[ (int(arr[1])-1)/2-1 ][ mapidx[arr[2]] ] += float(arr[ 3 ])
        cnt[ (int(arr[1])-1)/2-1 ][ mapidx[arr[2]] ] += 1
    for i in xrange(7):
        for j in xrange(1, 8):
            times[i][j] /= cnt[i][j]
            speedUp[i][j] = float(times[i][0])/float(times[i][j])

    plt.xticks( threads )
    plt.ylabel( "Time (s)" )
    plt.xlabel( "Threads" )
    plt.title( "Time of execution for images of size " + fileSize )
    for i in xrange(7):
        plt.plot( threads, times[i], label = "Kernel " + str((i+1)*2+1) )
    plt.legend()
    #plt.show()
    plt.savefig( "../../graphics/CUDA/" + fileSize + " time" )
    plt.clf()

    plt.xticks( threads )
    plt.ylabel( "Speed up" )
    plt.xlabel( "Threads" )
    plt.title( "Speed up for images of size " + fileSize )
    for i in xrange(7):
        plt.plot( threads, speedUp[i], label = "Kernel " + str((i+1)*2+1) )
    plt.legend()
    #plt.show()
    plt.savefig( "../../graphics/CUDA/" + fileSize + " speed up" )
    plt.clf()
    return

getGraphics("../../logs/CUDA/720p.txt", "720p" )
getGraphics("../../logs/CUDA/1080p.txt", "1080p" )
getGraphics("../../logs/CUDA/4K.txt", "4K" )