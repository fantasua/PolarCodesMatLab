extern "C"
{
    #include <stdlib.h>
    #include <assert.h>
    #include <string.h>
}
#include <iostream>
#include <fstream>
#include <cmath>
#include <mex.h>


static const double ALFA=-0.4527;
static const double BETA= 0.0218;
static const double GAMA= 0.86;
static const double PI= 3.1415926535897932384626433832795;



double Phi(double x) 
{
	//assert x>0
	assert(x>=0);

    if(x<=10) {
		return exp(ALFA*pow(x,GAMA)+BETA);
	}
	else if(x>10) {
		return sqrt(PI/x)*exp(-x/4)*(1+1/(14*x)-3/(2*x));
	}
}
/*
double Phi_inv(double y, double phi_inv_in) 
{
    assert(y>=0);
    
	double * pItem;
	int index;
	pItem = (double*) bsearch (&y, phi_inv_in, PHI_SAMPLE_LENGTH, sizeof (double), compare);
    index = pItem-phi_inv_in;
    return  (pItem!=NULL) ? (phi_inv_out[index]): PHI_SAMPLE_RANGE;
}
*/
/*
int compare (const void * kp, const void * vp)
{
    //key is the item I want to search
    double key = *(const double*)kp;
    const double *vec = (const double*)vp;
    
	//////////////////////////////////////////////////
	//	vec[-1]            vec[0]               vec[1] 
	//     |                |                       |
	//              |                     |
	//  (vec[-1]+vec[0])/2.0        (vec[0]+vec[1])/2.0
	//////////////////////////////////////////////////
	if (key > (vec[0]+vec[1])/2.0)
		return 1;
	else if (key < (vec[-1]+vec[0])/2.0)
		return -1;
	else
		return 0;
}
*/
void mexFunction(int nlhs,mxArray *plhs[], int nrhs, const mxArray * prhs[])
{
	//parameters are PHI_SAMPLE_LENGTH, PHI_SAMPLE_RANGE
	int PHI_SAMPLE_LENGTH = mxGetScalar(prhs[0]);
	double PHI_SAMPLE_RANGE = mxGetScalar(prhs[1]);
	double PHI_SAMPLE_STEP = PHI_SAMPLE_RANGE/PHI_SAMPLE_LENGTH;
	plhs[0]=mxCreateDoubleMatrix(1,PHI_SAMPLE_LENGTH,mxREAL);
	plhs[1]=mxCreateDoubleMatrix(1,PHI_SAMPLE_LENGTH,mxREAL);
	double *phi_inv_in=mxGetPr(plhs[0]);
	double *phi_inv_out=mxGetPr(plhs[1]);
	
	for (int i=0;(PHI_SAMPLE_RANGE-i*PHI_SAMPLE_STEP)>0;i++) 
	{ 
		phi_inv_out[i]=PHI_SAMPLE_RANGE-i*PHI_SAMPLE_STEP;
		phi_inv_in[i]=Phi(phi_inv_out[i]);
	}
	
}