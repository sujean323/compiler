#include<stdio.h>

struct test{
    int a;
    float b;
    double c;
    long d;
    short e;
};
int main(){
    struct test t;
    t.a = 1;
    t.b = 0.1;
    t.c = 0.5;
    t.d = 100;
    t.e = 3;

    printf("a=%d\n", t.a);
    printf("b=%f\n", t.b);
    printf("c=%lf\n", t.c);
    printf("d=%ld\n", t.d);
    printf("e=%hd\n", t.e);

    int s=2;
    switch(s){
        case 0:
            t.c = t.a+t.b;
            break;
        case 1:
            t.c = t.a-t.b;
            break;
        default:
            break;
    }
    printf("%lf\n", t.c);

    return 0;
}
