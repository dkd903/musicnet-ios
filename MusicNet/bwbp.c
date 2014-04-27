

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "iir.h"
#include "bwbp.h"
#define n 2

void BWfilter(double f1f,double f2f,double x[],int sizeOfWindow)
{
    int i;
    double *dcof;
    double *ccofsf;
    int *ccof;
    double sf;
    /* calculate the d coefficients */
    dcof = dcof_bwbp( n, f1f, f2f );
    if( dcof == NULL )
    {
        perror( "Unable to calculate d coefficients" );
        return;
    }
    /* calculate the c coefficients */
    ccof = ccof_bwbp( n );
    ccofsf =  (double *)calloc( 2*n+1, sizeof(double) );
    if( ccof == NULL )
    {
        perror( "Unable to calculate c coefficients" );
        return;
    }
    sf = sf_bwbp( n, f1f, f2f );
    for( i = 0; i <= 2*n; ++i){
        ccofsf[i]=(double)ccof[i]*sf;
    }
    double y[sizeOfWindow];
    filter1(n, dcof, ccofsf,sizeOfWindow, x, y);
    for (i=0; i<sizeOfWindow; i++) {
        x[i]=y[i];
    }
    free(dcof);
    free(ccof);
    free(ccofsf);
}

