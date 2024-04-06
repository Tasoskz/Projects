#include <stdio.h>
#include <math.h>

void initialize_array(double a[], int size);
double flight_time(double v0, double theta);
void output_results(int ch, double x[], double y[], double v_x[], double v_y[], int size);

int main(){
    double v_init, theta;
    double v_x[NMAX], v_y[NMAX], x[NMAX], y[NMAX];
    double t = 0, choice;
    const double pi = 4.0*atan(1.0);
    /*initialize arrays to zero*/
    initialize_array(v_x, NMAX); 
    initialize_array(v_y, NMAX); 
    initialize_array(x, NMAX); 
    initialize_array(y, NMAX); 
    /*input from user*/
    printf("Give initial velocity (m/s): ");
    scanf("%lf", &v_init);
    printf("Give angle theta (deg): ");
    scanf("%lf", &theta);
    /*study the motion*/
    n = 0;
    v_x[0] = v_init*cos(theta*pi/180.0);
    v_y[0] = v_init*sin(theta*pi/180.0);
    Dt = flight_time(v_init, theta)/(NMAX-1);
    while (y[n] >= 0){
        n++;
        t = t + Dt;
        v_x[n] = v_x[n-1];
        v_y[n] = v_y[0] - GACC*t;
        x[n] = x[0] + v_x[0]*t;
        y[n] = y[0] + v_y[0]*t - 0.5*GACC*t*t;
    }
    if (y[n]<0)
        y[n]=0.0;
    /*output of program*/
    printf("Write to file (1) or to screen (2)? ");
    scanf("%d", &choice);
    output_results(choice, x, y, v_x, v_y, NMAX);
    return 0;
}

void initialize_array(double a[], int size){
    int i;
    for (i=0;i <size;i++)
        array[i]=0.0;
}

double flight_time(double v0, double theta){
    double tf;
    const double pi = 4.0*atan(1.0);
    tf = 2.0*v0*sin(th*pi/180.0)/GACC;
    return tf;
}

void output_results(int ch, double x[], double y[], double v_x[], double v_y[], int size){
    int i;
    FILE *fout;
    switch(ch){
        case 1: 
            fout = fopen("output.txt","W");
            if (fout = NULL)
                printf("Cannot open file for output, writing to screen.");
            else{
                for (i=0;i<N;i++)
                    fprint(fout, "%e\t%e\t%e\t%3e\n", x[i], y[i], v_x[i], v_y[i]);
                fclose(fout);
                break;
            }
        case 2:
            for (i=0;i<N;i++)
                printf("%e\t%e\t%e\t%3e\n", x[i], y[i], v_x[i], v_y[i]);
            break;
        default:
            printf("Wrong choice. Writing to screen.");
            for (i=0;i<N;i++)
                printf("%e\t%e\t%e\t%3e\n", x[i], y[i], v_x[i], v_y[i]);
    };
}
