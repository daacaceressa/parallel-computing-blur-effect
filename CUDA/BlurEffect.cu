#include <stdio.h>
#include <sstream>
#include <iomanip>
#include <time.h>
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

const int MAX_ROW = 2200, MAX_COL = 4100;
const int NUMBER_OF_BLOCKS = 4;
int kernelSize, numberOfThreads;
Mat image, newImage;
int h_in[ 3 * MAX_ROW * MAX_COL ];
int h_out[ 3 * MAX_ROW * MAX_COL ];
int size;

/*void getNewPixel( int row, int col, int totalRow, int totalCol ){
    //Calculate the value of the pixel [row][col]
    int newColor[3]; newColor[0] = newColor[1] = newColor[2] = 0;
    for( int i = row - kernelSize/2; i <= row + kernelSize/2; ++i ){
        for( int j = col - kernelSize/2; j <= col + kernelSize/2; ++j ){
            for( int k = 0; k < 3; ++k ) {
                newColor[k] +=  h_in[ k ][ (i+totalRow)%totalRow ][ (j+totalCol)%totalCol ];
            }
        }
    }

    //Store it as the variable of a pixel
    for( int k = 0; k < 3; ++k ) {
        h_out[k][row][col] = newColor[k] / (kernelSize*kernelSize);
    }
}*/

/*void blur(){
    newImage = Mat(image.rows, image.cols, CV_8UC3);
    int j;
    omp_set_num_threads( numberOfThreads );
    #pragma omp parallel for
        for( j = 0; j < image.rows; ++j ){
            for( int i = 0; i < image.cols; ++i ){
                getNewPixel( j, i, image.rows, image.cols );
            }
        }
    
}*/

__global__ void blur( int * d_in, int * d_out, int rowsPerThread, int totalRow, int totalCol, int kernelSize ){
    int fr = rowsPerThread * (blockDim.x * blockIdx.x + threadIdx.x);
    int to = fr + rowsPerThread;
    int newColor[3];
    for( int row = fr; row < to && row < totalRow; ++row ){
        for( int col = 0; col < totalCol; ++col ){
            //Calculate the value of the pixel [row][col]
            newColor[0] = newColor[1] = newColor[2] = 0;
            for( int i = row - kernelSize/2; i <= row + kernelSize/2; ++i ){
                for( int j = col - kernelSize/2; j <= col + kernelSize/2; ++j ){
                    for( int k = 0; k < 3; ++k ) {
                        newColor[k] += d_in[ (totalCol*((i+totalRow)%totalRow) + ((j+totalCol)%totalCol))*3+k ];
					
                    }
                }
            }
            //Store it as the variable of a pixel
            for( int k = 0; k < 3; ++k ) {
                d_out[ (totalCol*row + col)*3+k ] = newColor[k] / (kernelSize*kernelSize);
            }
        }
    }
}

void storeImageData(){
    Vec3b currentColor;
    for( int j = 0; j < image.rows; ++j ){
        for( int i = 0; i < image.cols; ++i ){
            currentColor = image.at<Vec3b>(Point( i, j ));
            for( int k = 0; k < 3; ++k ){
                h_in[ (image.cols*j + i)*3+k ] = currentColor[ k ];
            }
        }
    }
}

void saveNewImageData(){
    newImage = Mat(image.rows, image.cols, CV_8UC3);
    for( int j = 0; j < image.rows; ++j ){
        for( int i = 0; i < image.cols; ++i ){
            Vec3b currentPixel;
            for( int k = 0; k < 3; ++k ){
                currentPixel[ k ] = h_out[ (image.cols*j + i)*3+k ];
            }
            newImage.at<Vec3b>(Point( i, j )) = currentPixel;
        }
    }
}

void displayImage( Mat &image ){
    namedWindow("Display Image", WINDOW_AUTOSIZE );
    imshow("Display Image", image);
    waitKey(0);
}

int main(int argc, char** argv )
{
	cudaSetDevice(0);
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
    if( (numberOfThreads < 1) || (numberOfThreads&1) ){
        printf( "Number of threads must be an even positive integer.\n" );
        return -1;
    }

    //cout << "File\t\tKernel\t\tThreads\t\tTime(s)\n";
    printf( "%s\t\t", argv[ 1 ] );
    printf( "%d\t\t\t\t", kernelSize );
    printf( "%d\t\t\t\t", numberOfThreads );


    size = sizeof( int ) * 3 * MAX_COL * MAX_ROW;

    //Declaring pointers
    int * d_in, * d_out;

    //Alloc memory
    cudaMalloc( (void **) &d_in, size );
    cudaMalloc( (void **) &d_out, size );

    //Initialize variables
    storeImageData();

    //Copy host to device
    cudaMemcpy( d_in, &h_in, size, cudaMemcpyHostToDevice );

    //Launch kernel
    //blur();
    blur<<< NUMBER_OF_BLOCKS, numberOfThreads/NUMBER_OF_BLOCKS >>>( d_in, d_out, (image.rows + numberOfThreads - 1)/numberOfThreads, image.rows, image.cols, kernelSize );
    
    //Copy device to host
    cudaMemcpy( &h_out, d_out, size, cudaMemcpyDeviceToHost );

    //Free memory
    cudaFree( d_in );
    cudaFree( d_out );

    //Create newImage with the matrix out
    saveNewImageData();



    //calculate and print elapsed time
    clock_gettime(CLOCK_MONOTONIC, &finish);
    elapsed = (finish.tv_sec - start.tv_sec);
    elapsed += (finish.tv_nsec - start.tv_nsec) / 1000000000.0;
    printf( "%.4f\n", elapsed );

    //Display blurred image
    //displayImage( newImage );

    return 0;
}
