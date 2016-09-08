#include "mex.h"
#include "malloc.h"
#include "math.h"
#define PI 3.1415926
#define MAX(a,b) ((a>b)?a:b)
#define ABS(x) (x>=0?x:-x)

//double maxStar(double x,double y);              //max*
//double logAPP(double y[],int u_hat[],int ui,int N,int i,double var);//logAPP
double W(double y,int x,double var)
{
	return(sqrt(1/(2*PI*var))*exp((y+1-2*x)*(y+1-2*x)/(-2*var)));
}

double maxStar(double x,double y)
{
	double z;
	z=MAX(x,y)+log(1+exp(-ABS((x-y))));
	return(z);
}

double logAPPbase(double y,int x,double var)
{
	return(log(W(y,x,var)/(W(y,0,var)+W(y,1,var))));
}

double logAPP(double y[],int u_hat[],int ui,int N,int i,double var)
{
	double M=0,M0=0,M1=0;//M is the output, M0 and M1 are middle parameters 
	int *uoe;
	int *ue;
	int ii;//
	if(N!=2)
	{
		if(i%2==1)
		{
			if(i==1)
			{
				M0=logAPP(y,u_hat,ui,N/2,i,var)+logAPP(y+N/2,u_hat,0,N/2,i,var);
				M1=logAPP(y,u_hat,ui^1,N/2,i,var)+logAPP(y+N/2,u_hat,1,N/2,i,var);
				M=maxStar(M0,M1);	
			}
			else
			
			{
				uoe=(int *)mxCalloc((i-1)/2,sizeof(int));
				ue=(int *)mxCalloc((i-1)/2,sizeof(int));
				for(ii=0;ii<=(i-1)/2-1;ii++)
				{
					uoe[ii]=u_hat[2*ii]^u_hat[2*ii+1];
					ue[ii]=u_hat[2*ii+1];
				}
				
				M0=logAPP(y,uoe,ui,N/2,(i+1)/2,var)+logAPP(y+N/2,ue,0,N/2,(i+1)/2,var);
				M1=logAPP(y,uoe,ui^1,N/2,(i+1)/2,var)+logAPP(y+N/2,ue,1,N/2,(i+1)/2,var);
				M=maxStar(M0,M1);
				mxFree(uoe);
				mxFree(ue);
			}
		}
		else
		{
			uoe=(int *)mxCalloc((i-2)/2,sizeof(int));
			ue=(int *)mxCalloc((i-2)/2,sizeof(int));
			for(ii=0;ii<=((i-2)/2-1);ii++)
			{
				uoe[ii]=u_hat[2*ii]^u_hat[2*ii+1];
				ue[ii]=u_hat[2*ii+1];
			}
			
			M=logAPP(y,uoe,u_hat[i-2]^ui,N/2,i/2,var)+logAPP(y+N/2,ue,ui,N/2,i/2,var);
			mxFree(uoe);
			mxFree(ue);
		}
		
	}
	else
	{
		if(i==1)
		{
			M0=logAPPbase(y[0],ui,var)+logAPPbase(y[1],0,var);
			M1=logAPPbase(y[0],ui^1,var)+logAPPbase(y[1],1,var);
			M=maxStar(M0,M1);
		}
		else
		{
			M=logAPPbase(y[0],u_hat[0]^ui,var)+logAPPbase(y[1],ui,var);
		}
	}
	return(M);
}



void mexFunction(int nlhs,mxArray *plhs[], int nrhs, const mxArray * prhs[])
{
    double *y;                     //received vector of the channel, pointer
	double *u_hat;                 //last (i-1) decoded bits, pointer
    int ui;                        //assumed value of i th decoded bites, value
    int N;                      //length of the code, value
    int i;                          //the number of the current bit, value
    double var;             //the variance of the gaussian noise, value
    double *M;               //the output
	int *u_hat_int;				//the interger of the u_hat, because u_hat is double
	int ii;						//u_hat transfer counter
    
    
    y=mxGetPr(prhs[0]);                 //
    u_hat=mxGetPr(prhs[1]);		//
    ui=mxGetScalar(prhs[2]);           //
    N=mxGetScalar(prhs[3]);            //  
    i=mxGetScalar(prhs[4]);             //
    var=mxGetScalar(prhs[5]);            //
    
    plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
    M=mxGetPr(plhs[0]);
	
	u_hat_int=mxCalloc(i-1,sizeof(int));
	for(ii=0;ii<=i-1;ii++)
	{
		u_hat_int[ii]=(int)u_hat[ii];
	}
    
    *M=logAPP(y,u_hat_int,ui,N,i,var);                      //
	//mxFree(u_hat_int);
}



