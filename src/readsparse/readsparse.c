/*=================================================================
 * readsparse.c
 * This code reads the sparse input files into the sparse matrix format
 * Input:
 * [number_of_points] [p1.idx] [p1.val] [p2.idx] [p2.val]...[pn.idx] [pn.val]
 * Maximum readable matrix : 1.2Mx80K entries
 * This is a MEX-file for MATLAB based on the examples provided at MATLAB website.
 *
 * Use with:
 * ~/matlabtools/../.matlab/R2011b/mexopts.sh
 * to compile: mex readsparse.c -largeArrayDims
 *=================================================================*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "mex.h"
#include "math.h"
/* If you are using a compiler that equates NaN to be zero, you must
 * compile this example using the flag  -DNAN_EQUALS_ZERO. For example:
 *
 *     mex -DNAN_EQUALS_ZERO fulltosparse.c
 *
 * This will correctly define the IsNonZero macro for your C compiler.
 */

#if defined(NAN_EQUALS_ZERO)
#define IsNonZero(d) ((d)!=0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d)!=0.0)
#endif

#define _myopen(f) ((*(f)==0)?stdin:(*(f)=='<')?popen((f)+1,"r"):fopen((f),"r"))
#define _myclose(f,fp) ((*(f)==0)?0:(*(f)=='<')?pclose(fp):fclose(fp))
#define PSEUDOZERO 10e-8;
typedef struct Instance{
     int idx;
     double val;
} Ins;

typedef struct _Row{
     int nnz;
     Ins * neigs;
} * Row;

int nrow = 1200000 ,initnnz = 13000, ncol = 0,allnnz = 0, maxnnz = 0;
Row * data = NULL;
int comp(const void * a, const void * b){
     Ins *A = (Ins*) a;
     Ins *B = (Ins*) b;
     if(A->idx > B->idx) return 1;
     else if(A->idx < B->idx) return -1;
     return 0;
}

void sparse_data_to_array(char * fname){ 
     FILE *_fp;
     int i,ri = 0;
     char *_ptr, *tok;     
     data  = (Row*) mxMalloc(nrow * sizeof(Row));
     /* for(i = 0 ; i < nrow; i++){  */
     /*      data[i] = (Row) mxMalloc(sizeof(struct _Row));  */
     /*      data[i]->neigs = (Ins*) mxMalloc(initnnz * sizeof(Ins));     */
     /* }  */
     errno = 0;
     for (_fp = _myopen(fname);                                         \
          (_fp != NULL) || (errno && (perror(fname), exit(errno), 0));  \
          _fp = (_myclose(fname, _fp), NULL)){
          char str[3000000];
          for (;                                          \
               ((str[3000000 - 1] = -1) &&                              \
                    fgets(str, 3000000, _fp) &&                            \
                    ((str[3000000 - 1] != 0) ||                            \
                         (perror("Line too long"), exit(-1), 0))); ){
               data[ri] = (Row) mxMalloc(sizeof(struct _Row)); 
               data[ri]->neigs = (Ins*) mxMalloc(initnnz * sizeof(Ins));    
               int ti = 0, rowid = 0, nnz = 0, nn;
               if(ri % 100 == 0)
                    mexPrintf(".");
               for (_ptr = NULL, tok = strtok_r(str, " \t\n\r\f\v", &_ptr); \
                    tok != NULL; tok = strtok_r(NULL," \t\n\r\f\v", &_ptr)){
                    double dd;
                    if(ti == 0) rowid = atoi(tok);
                    else if(ti % 2 == 1) nn = atoi(tok);
                    else if(ti % 2 == 0){
                         if(maxnnz != 0 && nnz >= maxnnz)
                              break;
                         dd = atof(tok);
                         (data[ri]->neigs[nnz]).idx = nn;
                         if (dd == 0) dd = PSEUDOZERO;
                         (data[ri]->neigs[nnz]).val = dd;
                         if(nn > ncol) ncol = nn;               
                         nnz++;
                         allnnz++;
                    }
                    ti++;
               }
               data[ri]->nnz = nnz;
               /*Matlab expects sorted non-zero indexes*/
               qsort(data[ri]->neigs, data[ri]->nnz, sizeof(Ins), comp);
               ri++;
          }
     }
     /* for(i = ri; i < nrow ; i++){ */
     /*      if(data[i]->neigs != NULL) */
     /*           free(data[i]->neigs); */
     /* } */
     nrow = ri;     
     ncol = ncol + 1;     
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
     mwSize m,n, nzmax;
     mwIndex *irs,*jcs,i,j,k;
     double *sr, percent_sparse;
     char *buf;
     int buflen;
     ncol = 0,allnnz = 0;
     /* Check for proper number of input and output arguments */    
     if (nrhs < 1) {
          mexErrMsgTxt("One input argument required.");
     }
     else if(nrhs == 1){
          maxnnz = 0; /*Default value no limit*/
     }
     else if(nrhs == 2){
          maxnnz = mxGetScalar(prhs[1]);
     }
     if(nlhs > 1){
          mexErrMsgTxt("Too many output arguments.");
     }     
     buflen = mxGetN(prhs[0])*sizeof(mxChar)+10;
     buf = mxMalloc(buflen);
     mxGetString(prhs[0],buf,buflen);
     mexPrintf("fname:%s\n",buf);
     sparse_data_to_array(buf);
     percent_sparse = (double)allnnz/nrow;
     mexPrintf("row:%d col:%d nnz:%d(%g)\n",nrow,ncol,allnnz, percent_sparse);
     nzmax=(mwSize)allnnz+1;
     m = (mwSize)nrow;
     n = (mwSize)ncol;
     plhs[0] = mxCreateSparse(n,m,nzmax,0);
     sr  = mxGetPr(plhs[0]); 
     irs = mxGetIr(plhs[0]); 
     jcs = mxGetJc(plhs[0]); 
     /* Copy nonzeros */
     k = 0; 
     for (j=0; j<m; j++) {
          jcs[j] = k; 
          if (k>=nzmax){
               mexPrintf("More elements than memory:max:%d k:%d\n",(int)nzmax,(int)k);
          }
          for (i=0; (i< data[j]->nnz); i++) {
               sr[k] = (data[j]->neigs[i]).val; 
               irs[k] = (data[j]->neigs[i]).idx; 
               k++;                
          }
          mxFree(data[j]->neigs);
          mxFree(data[j]);
     }
     mxFree(data);
     mxFree(buf);
     jcs[m] = k;
     mexPrintf("allnnz:%d\n",(int)k);
     return;
}
 
