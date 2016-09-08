extern "C"
{
    #include <stdlib.h>
    #include <assert.h>
    #include <string.h>
}
#include <cmath>
#include <mex.h>

int compare (const void * kp, const void * vp);
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

double Phi_inv(double y, double* phi_inv_in, double *phi_inv_out,int PHI_SAMPLE_LENGTH, int PHI_SAMPLE_RANGE) 
{
    assert(y>=0);
    
	double * pItem;
	int index;
	pItem = (double*) bsearch (&y, phi_inv_in, PHI_SAMPLE_LENGTH, sizeof (double), compare);
    index = pItem-phi_inv_in;
    return  (pItem!=NULL) ? (phi_inv_out[index]): PHI_SAMPLE_RANGE;
}

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

void mexFunction(int nlhs,mxArray *plhs[], int nrhs, const mxArray * prhs[])
{
	//input parameters:function_input, phi_inv_in, phi_inv_out, sample_length, sample_range
	double input=mxGetScalar(prhs[0]);
	double *phi_inv_in=mxGetPr(prhs[1]);
	double *phi_inv_out=mxGetPr(prhs[2]);
	int PHI_SAMPLE_LENGTH = mxGetScalar(prhs[3]);
	double PHI_SAMPLE_RANGE = mxGetScalar(prhs[4]);
	plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
	double *result=mxGetPr(plhs[0]);
	
	//*result=Phi_inv(Phi(input), phi_inv_in, phi_inv_out, PHI_SAMPLE_LENGTH, PHI_SAMPLE_RANGE);
	
	*result=Phi_inv(1-pow((1-Phi(input)), 2), phi_inv_in, phi_inv_out, PHI_SAMPLE_LENGTH, PHI_SAMPLE_RANGE);
	
}