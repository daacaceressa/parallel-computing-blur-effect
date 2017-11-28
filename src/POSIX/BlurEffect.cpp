#include <stdio.h>
#include <sstream>
#include <iomanip>
#include <time.h>
#include <pthread.h>
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

int kernelSize, numberOfThreads;
Mat image, newImage;

Vec3b getNewPixel( int row, int col, Mat &image ){
    //Calculate the value of the pixel [row][col]
    int newColor[3]; newColor[0] = newColor[1] = newColor[2] = 0;
    Vec3b currentColor;
    for( int i = row - kernelSize/2; i <= row + kernelSize/2; ++i ){
        for( int j = col - kernelSize/2; j <= col + kernelSize/2; ++j ){
            currentColor = image.at<Vec3b>(Point( (i+image.cols)%image.cols , (j+image.rows)%image.rows ));
            for( int k = 0; k < 3; ++k ) {
                newColor[k] +=  (int)currentColor[k];
            }
        }
    }

    //Store it as the variable of a pixel
    Vec3b newPixel;
    for( int k = 0; k < 3; ++k ) {
        newPixel[k] = newColor[k] / (kernelSize*kernelSize);
    }
    return newPixel;
}

//Apply blur effect in the rows assigned to threadId
void * blurRows( void * threadId ){
    long id = (intptr_t) threadId;
    int rowsPerThread = image.rows / numberOfThreads;
    int fr = id * rowsPerThread, to;
    if( id == numberOfThreads-1 ) to = image.rows;
    else to = (id+1) * rowsPerThread;
    //Go through every pixel and calculate the new one
    for( int i = 0; i < image.cols; ++i ){
        for( int j = fr; j < to; ++j ){
            newImage.at<Vec3b>(Point(i,j)) = getNewPixel( i, j, image );
        }
    }
}

void blur(){
    newImage = Mat(image.rows, image.cols, CV_8UC3);
    //Create the threads
    pthread_t threads[ numberOfThreads ];
    for( int i = 0; i < numberOfThreads; ++i ){
        int flag = pthread_create( &threads[i], NULL, blurRows, (void *)(intptr_t) i );
        if( flag ){
            printf( "Error: unable to create threads\n" );
            exit(-1);
        }
    }
    for( int i = 0; i < numberOfThreads; ++i )
        pthread_join( threads[ i ], NULL );
}

void displayImage( Mat &image ){
    namedWindow("Display Image", WINDOW_AUTOSIZE );
    imshow("Display Image", image);
    waitKey(0);
}

int main(int argc, char** argv )
{
    //start time
    struct timespec start, finish;
    double elapsed;
    clock_gettime(CLOCK_MONOTONIC, &start);

    if ( argc != 4 )
    {
        printf("usage: ./script.sh <Image_Path> <Kernel_Size> <Number_Threads>\n");
        return -1;
    }

    //Read original image using path
    image = imread( argv[1], 1 );
    if ( !image.data )
    {
        printf("No image data \n");
        return -1;
    }

    //Read kernel size
    stringstream ss1( argv[ 2 ] );
    ss1 >> kernelSize;
    if( !(kernelSize&1) || kernelSize < 1 ){
        printf( "Kernel size must be an odd positive integer.\n" );
        return -1;
    }

    //Read number of threads
    stringstream ss2( argv[ 3 ] );
    ss2 >> numberOfThreads;
    if( (numberOfThreads < 1) || (numberOfThreads > 16) || (numberOfThreads&(numberOfThreads-1)) ){
        printf( "Number of threads must be a power of two in the range [1-16].\n" );
        return -1;
    }

    //cout << "File\t\tKernel\t\tThreads\t\tTime(s)\n";
    printf( "%s\t\t", argv[ 1 ] );
    printf( "%d\t\t\t\t", kernelSize );
    printf( "%d\t\t\t\t", numberOfThreads );

    //Create new image applying blur effect
    blur();

    //calculate and print elapsed time
    clock_gettime(CLOCK_MONOTONIC, &finish);
    elapsed = (finish.tv_sec - start.tv_sec);
    elapsed += (finish.tv_nsec - start.tv_nsec) / 1000000000.0;
    printf( "%.4f\n", elapsed );

    //Display blurred image
    //displayImage( newImage );

    return 0;
}