#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void calc_E_field(const double position[], double t, double E_field[]);
void calc_B_field(const double position[], double t, double B_field[]);

int main(){
  double q,m,r[3],v[3],a[3],E[3],B[3],dt,t;
  int i=0,j,N;
  FILE *fout;

  fout=fopen("orbit.txt","w");
  if (fout == NULL){
    print("cannot open file for output. exiting the program.\n");
    return (-1);
  }
  /*time step for Eulerian integration*/
  dt=1e-12;
  /*mass and charge of particle*/
  m=9.10938291e-31; q=-1.60217657e-19;
  /*initial position*/
  r[0]=0; r[1]=0; r[2]=0;
  /*initial velocity*/
  v[0]=0; v[1]=1; v[2]=1;

  while (i<=N){
  fprintf(fout,"%e\t%e\t%e\n", r[0],r[1],r[2]);
  printf("%e\t%e\t%e\n",r[0],r[1],r[2]);
    t=t+dt;
    calc_E_field(r , t, E);
    calc_B_field(r , t, B);
    a[0] = q/m * ( E[0] +v[1]*B[2] - v[2]*B[1] );
    a[1] = q/m * ( E[1] +v[0]*B[2] - v[2]*B[0] );
    a[0] = q/m * ( E[2] +v[0]*B[1] - v[1]*B[0] );
    for (j=0;j<3;j++) {
      v[j]=v[j]+a[j]*dt;
      r[j]=r[j]+v[j]*dt;
    }
    i++;
  }
  fclose(fout);
  return 0;
}
void calc_E_field(const double position[], double t, double E_field[]); {
  E_field[0]=0;
  E_field[1]=0;
  E_field[2]=-1;
}
void calc_B_field(const double position[], double t, double B_field[]); {
  B_field[0]=0;
  B_field[1]=0;
  B_field[2]=0.001;  
}
  
