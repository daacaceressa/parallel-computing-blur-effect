import numpy as np
import matplotlib.pyplot as plt

def getGraphics( filename, fileSize ):
    file = open( filename, "r" )
    times = np.zeros((7,5))
    speedUp = np.zeros((7,5))
    threads = []
    for i in xrange(5):
        threads.append(2**i)
    cnt = np.zeros((7,5))
    flag = 0
    for line in file:
        arr = line.split()
        flag += 1
        if (flag == 1):
            continue
        times[ (int(arr[1])-1)/2-1 ][ int(np.log2(int(arr[2]))) ] += float(arr[ 3 ])
        cnt[ (int(arr[1])-1)/2-1 ][ int(np.log2(int(arr[2]))) ] += 1
    for i in xrange(7):
        for j in xrange(5):
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
    plt.savefig( "../../graphics/POSIX/" + fileSize + " time" )
    plt.clf()

    plt.xticks( threads )
    plt.ylabel( "Speed up" )
    plt.xlabel( "Threads" )
    plt.title( "Speed up for images of size " + fileSize )
    for i in xrange(7):
        plt.plot( threads, speedUp[i], label = "Kernel " + str((i+1)*2+1) )
    plt.legend()
    #plt.show()
    plt.savefig( "../../graphics/POSIX/" + fileSize + " speed up" )
    plt.clf()
    return

getGraphics("../../logs/POSIX/720p.txt", "720p" )
getGraphics("../../logs/POSIX/1080p.txt", "1080p" )
getGraphics("../../logs/POSIX/4K.txt", "4K" )

